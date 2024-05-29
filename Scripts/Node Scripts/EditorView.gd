extends Control

@onready var toolbar: Node = %ToolBar
@onready var screenplay_page: Node = %ScreenplayPage
@onready var inspector_panel: Node = %InspectorPanel
@onready var page_panel: Node = screenplay_page.page_panel
@onready var page_container: Node = screenplay_page.page_container

const FIELD_CATEGORY = TextInputField.FIELD_CATEGORY
const uuid_util = preload ("res://addons/uuid/uuid.gd")

enum TOOL {
	MOVE,
	SELECT,
	DRAW,
	DRAW_SQUIGGLE,
	ERASE,
}

var shotline_2D_scene := preload ("res://Components/ShotLine2D.tscn") # TODO: Move the shotline creating logic and shotlines Dictionary to here instead of screenplay_page.gd

# ------ STATES ------
var is_drawing: bool = false
var is_erasing: bool = false
var cur_tool: TOOL = TOOL.MOVE

var last_mouse_hover_position: Vector2
var cur_mouse_global_position_delta: Vector2
var last_shotline_node_global_pos: Vector2
var last_mouse_click_above_top_margin: bool = false
var last_mouse_click_below_bottom_margin: bool = false
var last_mouse_click_past_right_margin: bool = false
var last_mouse_click_past_left_margin: bool = false
var last_hovered_line_uuid: String = ""
var last_clicked_line_uuid: String = ""

var cur_selected_shotline: Shotline
var last_hovered_shotline_node: ShotLine2D
var is_dragging_shotline: bool = false

var cur_page_idx: int = 0
var pages: Array[PageContent]
var all_shotlines: Array = []

signal created_new_shotline(shotline_struct: Shotline)
signal tool_changed

# --------------- READY ------------------------------

func _init() -> void:
	pass

func _ready() -> void:
	DisplayServer.window_set_min_size(Vector2(920, 920))
	var screenplay_file_content := load_screenplay("Screenplay Files/VCR2L-2024-05-08.fountain")
	var fnlines: Array[FNLineGD] = screenplay_page.get_parsed_lines(screenplay_file_content)
	pages = split_fnline_array_into_page_groups(fnlines)

	screenplay_page.populate_container_with_page_lines(pages[cur_page_idx])

	# -------------connecting signals-----------
	screenplay_page.page_lines_populated.connect(_on_page_lines_populated)
	screenplay_page.gui_input.connect(_on_screenplay_page_gui_input)
	created_new_shotline.connect(_on_new_shotline_added)
	inspector_panel.field_text_changed.connect(_on_inspector_panel_field_text_changed)
	page_container.screenplay_line_hovered_over.connect(_on_screenplay_line_hovered)
	page_panel.shotline_clicked.connect(_on_shotline_clicked)
	page_panel.shotline_released.connect(_on_shotline_released)
	page_panel.shotline_hovered_over.connect(_on_shotline_hovered_over)
	page_panel.shotline_mouse_drag.connect(_on_shotline_mouse_drag)
	tool_changed.connect(_on_tool_changed)

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
		var cur_page := cur_pages[- 1]
		if cur_page is PageContent:
			ln.uuid = uuid_util.v4()
			cur_page.lines.append(ln)

	return cur_pages

func load_screenplay(filename: String) -> String:
	var file := FileAccess.open(filename, FileAccess.READ)
	var content := file.get_as_text()
	return content

func set_current_tool(tool: TOOL) -> void:
	cur_tool = tool

# -------------------- SHOTLINE LOGIC -----------------------------------

# TODO: these two funcs are confusingly named and structured;
# constructing the shotline should constitute putting the metadata into a Shotline struct
# adding the shotline to the page should create the Line2D
# Also, the Line2D
func create_and_add_shotline_node_to_page(shotline: Shotline) -> void:
	var empty_shotline_node: ShotLine2D = shotline_2D_scene.instantiate()
	var shotline_node: ShotLine2D = Shotline.construct_shotline_node(
		shotline,
		pages,
		cur_page_idx,
		page_container,
		empty_shotline_node
		)
	screenplay_page.page_panel.add_child(shotline_node)
	created_new_shotline.emit(shotline)

func add_new_shotline_to_shotlines_array(start_uuid: String, end_uuid: String, last_mouse_pos: Vector2) -> void:

	var cur_shotline: Shotline = Shotline.new()
	var new_shotline_id: String = uuid_util.v4()

	var start_line_page_idx: int = get_page_idx_of_fnline_from_uuid(start_uuid)
	var end_line_page_idx: int = get_page_idx_of_fnline_from_uuid(end_uuid)

	assert(start_line_page_idx != - 1, "Start line page index for shotline does not exist.")
	assert(end_line_page_idx != - 1, "End line page index for shotline does not exist.")

	cur_shotline.shotline_uuid = new_shotline_id
	
	if start_line_page_idx < end_line_page_idx:
		cur_shotline.start_page_index = start_line_page_idx
		cur_shotline.end_page_index = end_line_page_idx
		cur_shotline.start_uuid = start_uuid
		cur_shotline.end_uuid = end_uuid
	else:
		cur_shotline.start_page_index = end_line_page_idx
		cur_shotline.end_page_index = start_line_page_idx
		cur_shotline.start_uuid = end_uuid
		cur_shotline.end_uuid = start_uuid

	cur_shotline.x_position = last_mouse_pos.x
	print("Start and end page indices: ", cur_shotline.start_page_index, " | ", cur_shotline.end_page_index)
	all_shotlines.append(cur_shotline)

func get_page_idx_of_fnline_from_uuid(uuid: String) -> int:
	for page: PageContent in pages:
		for line: FNLineGD in page.lines:
			if line.uuid == uuid:
				return pages.find(page)
	return - 1

func populate_page_panel_with_shotlines_for_page() -> void:
	await get_tree().process_frame
	for sl: Shotline in all_shotlines:
		if sl.start_page_index == cur_page_idx or sl.end_page_index == cur_page_idx:
			var new_shotline_node: ShotLine2D = Shotline.construct_shotline_node(
				sl,
				pages,
				cur_page_idx,
				page_container,
				shotline_2D_scene.instantiate()
			)
			screenplay_page.page_panel.add_child(new_shotline_node)
#
#
# -------------------- SIGNAL HANDLING -----------------------------
#
#

func _on_tool_changed() -> void:
	pass

func _on_tool_bar_toolbar_button_pressed(toolbar_button: int) -> void:
	await get_tree().process_frame
	match toolbar_button:
		toolbar.TOOLBAR_BUTTON.NEXT_PAGE:
			if cur_page_idx + 2 <= pages.size():
				cur_page_idx += 1
				print(pages.size())
				screenplay_page.replace_current_page(pages[cur_page_idx], cur_page_idx)

		toolbar.TOOLBAR_BUTTON.PREV_PAGE:
			if cur_page_idx - 1 >= 0:
				cur_page_idx -= 1
				screenplay_page.replace_current_page(pages[cur_page_idx], cur_page_idx)

		# TOOL SELECTION
		toolbar.TOOLBAR_BUTTON.SELECT:
			cur_tool = TOOL.SELECT
		toolbar.TOOLBAR_BUTTON.MOVE:
			cur_tool = TOOL.MOVE
		toolbar.TOOLBAR_BUTTON.DRAW:
			cur_tool = TOOL.DRAW
		toolbar.TOOLBAR_BUTTON.DRAW_SQUIGGLE:
			cur_tool = TOOL.DRAW_SQUIGGLE
		toolbar.TOOLBAR_BUTTON.ERASE:
			cur_tool = TOOL.ERASE

func _on_screenplay_page_gui_input(event: InputEvent) -> void:

	if event is InputEventMouseButton:
		var cur_global_pos: Vector2 = event.global_position
		last_mouse_click_below_bottom_margin = (
			screenplay_page.bottom_page_margin.global_position.y
			< cur_global_pos.y
			)
		last_mouse_click_above_top_margin = (
			screenplay_page.top_page_margin.global_position.y +
			screenplay_page.top_page_margin.size.y
			> cur_global_pos.y
			)
		last_mouse_click_past_left_margin = (
				screenplay_page.left_page_margin.global_position.x +
				screenplay_page.left_page_margin.size.x
				> cur_global_pos.x
			)
		last_mouse_click_past_right_margin = (
			screenplay_page.right_page_margin.global_position.x
			< cur_global_pos.x
			)
		
		if event.button_index == MOUSE_BUTTON_LEFT:
			_handle_left_click(event)

func _handle_left_click(event: InputEvent) -> void:
	if event.is_pressed():
		match cur_tool:
			TOOL.DRAW:
				if not last_mouse_click_past_left_margin or last_mouse_click_past_right_margin:
					#print("imma clicking")
					if not is_drawing:
						is_drawing = true
						last_mouse_hover_position = event.position
						last_clicked_line_uuid = last_hovered_line_uuid
						#print("last hovered line: ", last_hovered_line_uuid)
						#print(event.position)
	if event.is_released():
		match cur_tool:
			TOOL.DRAW:
				if is_drawing:
					is_drawing = false
					if not (
						last_mouse_click_past_left_margin or
						last_mouse_click_past_right_margin):
						if not (last_mouse_click_below_bottom_margin or last_mouse_click_above_top_margin):
							add_new_shotline_to_shotlines_array(last_clicked_line_uuid, last_hovered_line_uuid, event.position)
							create_and_add_shotline_node_to_page(all_shotlines[ - 1])
					
						elif last_mouse_click_above_top_margin:
							# click released past top or bottom margin
							# give the add_new_shotline the last line of prev page or first line of next page

							var start_uuid: String
							if cur_page_idx - 1 >= 0:
								start_uuid = pages[cur_page_idx - 1].lines[- 1].uuid
							else:
								start_uuid = pages[cur_page_idx].lines[0].uuid
							add_new_shotline_to_shotlines_array(start_uuid, last_hovered_line_uuid, event.position)
							create_and_add_shotline_node_to_page(all_shotlines[ - 1])
						elif last_mouse_click_below_bottom_margin:
							print("it's here lmao gotem")
							var end_uuid: String
							if cur_page_idx + 1 <= pages.size() + 1:
								end_uuid = pages[cur_page_idx + 1].lines[+ 1].uuid
							else:
								end_uuid = pages[cur_page_idx].lines[- 1].uuid
							add_new_shotline_to_shotlines_array(last_clicked_line_uuid, end_uuid, event.position)
							create_and_add_shotline_node_to_page(all_shotlines[ - 1])

							#print("Clicked and hovered: ", last_clicked_line_idx, ",   ", last_hovered_line_idx)

func _on_screenplay_line_hovered(screenplay_line_uuid: String) -> void:
	last_hovered_line_uuid = screenplay_line_uuid

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
	match cur_tool:
		TOOL.MOVE:
			match button_index:
				1:
					inspector_panel.populate_fields_from_shotline(shotline_node.shotline_struct_reference)
					cur_selected_shotline = shotline_node.shotline_struct_reference
					is_dragging_shotline = true
					cur_mouse_global_position_delta = shotline_node.global_position - get_global_mouse_position()
					last_shotline_node_global_pos = shotline_node.global_position
					print(is_dragging_shotline)

func _on_shotline_released(shotline_node: ShotLine2D, button_index: int) -> void:
	match cur_tool:
		TOOL.MOVE:
			if button_index != 1:
				return
			if shotline_node.shotline_struct_reference == cur_selected_shotline:
				if is_dragging_shotline:
					
					is_dragging_shotline = false
					cur_selected_shotline.x_position = get_global_mouse_position().x
					await get_tree().process_frame
					var page_container_children := page_container.get_children()
					#await get_tree().process_frame
					cur_selected_shotline.update_page_line_indices_with_points(
						page_container_children,
						last_shotline_node_global_pos
						)
					print(is_dragging_shotline)
					
		TOOL.ERASE:
			if button_index != 1:
				return
			if shotline_node == last_hovered_shotline_node:
				if last_hovered_shotline_node.is_hovered_over:
					all_shotlines.erase(shotline_node.shotline_struct_reference)
					shotline_node.queue_free()

func _on_shotline_hovered_over(shotline_node: ShotLine2D) -> void:
	#print("Shotline Hovered changed: ", shotline_node, shotline_node.is_hovered_over)
	last_hovered_shotline_node = shotline_node

func _on_shotline_mouse_drag(shotline_node: ShotLine2D) -> void:
	#print("among us TWO")
	if is_dragging_shotline:
			print(cur_selected_shotline.shotline_node.global_position)
			cur_selected_shotline.shotline_node.global_position = (
				cur_mouse_global_position_delta + get_global_mouse_position()
			)

func _on_page_lines_populated() -> void:
	await get_tree().process_frame
	populate_page_panel_with_shotlines_for_page()
