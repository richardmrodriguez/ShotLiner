extends Control

@onready var toolbar: Node = %ToolBar
@onready var screenplay_page: Node = %ScreenplayPage
@onready var inspector_panel: Node = %InspectorPanel
@onready var page_panel: Node = screenplay_page.page_panel

const FIELD_CATEGORY = TextInputField.FIELD_CATEGORY
const uuid_util = preload ("res://addons/uuid/uuid.gd")

var shotline_2D_scene := preload ("res://Components/ShotLine2D.tscn") # TODO: Move the shotline creating logic and shotlines Dictionary to here instead of screenplay_page.gd

# ------ STATES ------
var is_drawing: bool = false
var is_erasing: bool = false
var last_mouse_hover_position: Vector2
var cur_mouse_global_position_delta: Vector2
var last_hovered_line_idx: int = 0
var last_clicked_line_idx: int = 0

var cur_selected_shotline: Shotline
var last_hovered_shotline_node: ShotLine2D
var is_dragging_shotline: bool = false

var cur_page_index: int = 0
var pages: Array[PageContent]
var all_shotlines: Array = []

signal created_new_shotline(shotline_struct: Shotline)

# --------------- READY ------------------------------

func _ready() -> void:
	inspector_panel.field_text_changed.connect(_on_inspector_panel_field_text_changed)
	var screenplay_file_content := load_screenplay("Screenplay Files/VCR2L-2024-05-08.fountain")
	var fnlines: Array[FNLineGD] = screenplay_page.get_parsed_lines(screenplay_file_content)
	pages = split_fnline_array_into_page_groups(fnlines)

	created_new_shotline.connect(_on_new_shotline_added)
	screenplay_page.populate_container_with_page_lines(pages[cur_page_index])
	#screenplay_page.created_new_shotline.connect(_on_new_shotline_added)
	screenplay_page.page_lines_populated.connect(_on_page_lines_populated)

	page_panel.shotline_clicked.connect(_on_shotline_clicked)
	page_panel.shotline_released.connect(_on_shotline_released)
	page_panel.shotline_hovered_over.connect(_on_shotline_hovered_over)
	page_panel.shotline_mouse_drag.connect(_on_shotline_mouse_drag)

# This merely splits an array of FNLineGDs into smaller arrays. 
# It then returns an array of those page arrays. This does not construct a ScreenplayPage object.
func split_fnline_array_into_page_groups(fnlines: Array) -> Array[PageContent]:
	var page_counter := 0
	var cur_pages: Array[PageContent] = []
	cur_pages.append(PageContent.new())

	for ln: FNLineGD in fnlines:
		if ln.string.begins_with("=="):
			page_counter += 1
			continue

		if (cur_pages.size() < page_counter + 1):
			cur_pages.append(PageContent.new())
			print("uh oh stinky", cur_pages.size())
		
		if ln.fn_type.begins_with("Title") or ln.fn_type.begins_with("Sec"):
			continue
		if cur_pages[- 1] is PageContent:
			cur_pages[- 1].lines.append(ln)

	return cur_pages

func load_screenplay(filename: String) -> String:
	var file := FileAccess.open(filename, FileAccess.READ)
	var content := file.get_as_text()
	return content

# -------------------- SHOTLINE LOGIC -----------------------------------

# TODO: these two funcs are confusingly named and structured;
# constructing the shotline should constitute putting the metadata into a Shotline struct
# adding the shotline to the page should create the Line2D
# Also, the Line2D
func add_shotline_node_to_page(shotline: Shotline) -> void:
	var current_lines: Array = screenplay_page.page_container.get_children()
	var empty_shotline_node: ShotLine2D = shotline_2D_scene.instantiate()
	var shotline_node: ShotLine2D = Shotline.construct_shotline_node(shotline, current_lines, empty_shotline_node)
	screenplay_page.page_panel.add_child(shotline_node)
	created_new_shotline.emit(shotline)

func add_new_shotline_to_shotlines_array(start_idx: int, end_idx: int, last_mouse_pos: Vector2) -> void:

	var cur_shotline: Shotline = Shotline.new()
	var new_shotline_id: String = uuid_util.v4()

	cur_shotline.shotline_uuid = new_shotline_id
	cur_shotline.start_page_index = cur_page_index
	cur_shotline.end_page_index = cur_page_index
	cur_shotline.start_index = start_idx
	cur_shotline.end_index = end_idx
	cur_shotline.x_position = last_mouse_pos.x
	all_shotlines.append(cur_shotline)

func populate_page_panel_with_shotlines_for_page() -> void:
	await get_tree().process_frame
	for sl: Shotline in all_shotlines:
		if sl.start_page_index == cur_page_index or sl.end_page_index == cur_page_index:
			var cur_lines: Array = screenplay_page.page_container.get_children()
			var new_shotline_node: ShotLine2D = Shotline.construct_shotline_node(
				sl,
				cur_lines,
				shotline_2D_scene.instantiate()
			)
			screenplay_page.page_panel.add_child(new_shotline_node)
#
#
# -------------------- CHILD INPUT HANDLING -----------------------------
#
#

func _on_tool_bar_toolbar_button_pressed(toolbar_button: int) -> void:
	await get_tree().process_frame
	match toolbar_button:
		toolbar.TOOLBAR_BUTTON.NEXT_PAGE:
			if cur_page_index + 2 <= pages.size():
				cur_page_index += 1
				print(pages.size())
				screenplay_page.replace_current_page(pages[cur_page_index], cur_page_index)

		toolbar.TOOLBAR_BUTTON.PREV_PAGE:
			if cur_page_index - 1 >= 0:
				cur_page_index -= 1
				screenplay_page.replace_current_page(pages[cur_page_index], cur_page_index)

func _on_screenplay_page_gui_input(event: InputEvent) -> void:
	
	if event is InputEventMouseButton:
		if event.button_index == 1:
			if event.is_pressed():
				if not is_drawing:
					is_drawing = true
					last_mouse_hover_position = event.position
					last_clicked_line_idx = last_hovered_line_idx
					print(event.position)
			if event.is_released():
				if is_drawing:
					is_drawing = false
					add_new_shotline_to_shotlines_array(last_clicked_line_idx, last_hovered_line_idx, event.global_position)
					add_shotline_node_to_page(all_shotlines[ - 1])

					#print("Clicked and hovered: ", last_clicked_line_idx, ",   ", last_hovered_line_idx)
		if event.button_index == 2:
			pass

func _on_screenplay_page_last_hovered_line_idx(last_line: int) -> void:
	last_hovered_line_idx = last_line

func _on_new_shotline_added(shotline_struct: Shotline) -> void:
	inspector_panel.scene_num.line_edit.grab_focus()
	inspector_panel.populate_fields_from_shotline(shotline_struct)
	cur_selected_shotline = shotline_struct

func _on_inspector_panel_field_text_changed(new_text: String, field_category: TextInputField.FIELD_CATEGORY) -> void:
	if cur_selected_shotline == null or all_shotlines == []:
		return
	await get_tree().process_frame
	match field_category:
		FIELD_CATEGORY.SCENE_NUM:
			cur_selected_shotline.scene_number = new_text
			cur_selected_shotline.shotline_node.update_shot_number_label()
		FIELD_CATEGORY.SHOT_NUM:
			cur_selected_shotline.shot_number = new_text
			cur_selected_shotline.shotline_node.update_shot_number_label()
		FIELD_CATEGORY.SHOT_TYPE:
			cur_selected_shotline.shot_type = new_text
		FIELD_CATEGORY.SHOT_SUBTYPE:
			cur_selected_shotline.shot_subtype = new_text
		FIELD_CATEGORY.SETUP_NUM:
			cur_selected_shotline.setup_number = new_text
		FIELD_CATEGORY.GROUP:
			cur_selected_shotline.group = new_text
		FIELD_CATEGORY.TAGS:
			cur_selected_shotline.tags = new_text

func _on_shotline_clicked(shotline_node: ShotLine2D, button_index: int) -> void:
	match button_index:
		1:
			inspector_panel.populate_fields_from_shotline(shotline_node.shotline_struct_reference)
			cur_selected_shotline = shotline_node.shotline_struct_reference
			is_dragging_shotline = true
			cur_mouse_global_position_delta = shotline_node.global_position - get_global_mouse_position()
			print(is_dragging_shotline)
		2:
			pass

func _on_shotline_released(shotline_node: ShotLine2D, button_index: int) -> void:

	match button_index:
		1:
			if shotline_node.shotline_struct_reference == cur_selected_shotline:
				if is_dragging_shotline:
					is_dragging_shotline = false
		2:
			if shotline_node == last_hovered_shotline_node:
				if last_hovered_shotline_node.is_hovered_over:
					all_shotlines.erase(shotline_node.shotline_struct_reference)
					shotline_node.queue_free()
	print(is_dragging_shotline)

func _on_shotline_hovered_over(shotline_node: ShotLine2D) -> void:
	#print("Shotline Hovered changed: ", shotline_node, shotline_node.is_hovered_over)
	last_hovered_shotline_node = shotline_node

func _on_shotline_mouse_drag(shotline_node: ShotLine2D) -> void:
	print("among us TWO")
	if is_dragging_shotline:
			print(cur_selected_shotline.shotline_node.global_position)
			cur_selected_shotline.shotline_node.global_position = (
				cur_mouse_global_position_delta + get_global_mouse_position()
			)

func _on_page_lines_populated() -> void:
	await get_tree().process_frame
	populate_page_panel_with_shotlines_for_page()

func get_shotline_node_from_shotline_uuid(shotline_uuid: String) -> ShotLine2D:
	for sl: Node in all_shotlines:
		if not sl is Shotline:
			continue
		if sl.shotline_uuid == shotline_uuid:
			return sl
	
	return null
