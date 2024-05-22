extends Control

@onready var toolbar: Node = %ToolBar
@onready var screenplay_page: Node = %ScreenplayPage
@onready var inspector_panel: Node = %InspectorPanel

const FIELD_CATEGORY = TextInputField.FIELD_CATEGORY

# ------ STATES ------
var is_drawing: bool = false
var is_erasing: bool = false
var last_mouse_hover_position: Vector2
var last_hovered_line_idx: int = 0
var last_clicked_line_idx: int = 0

var cur_selected_shotline: Shotline
var last_selected_shotline: Shotline

var cur_page_index: int = 0
var pages: Array[PageContent]

func _ready() -> void:
	inspector_panel.field_text_changed.connect(_on_inspector_panel_field_text_changed)
	var screenplay_file_content := load_screenplay("Screenplay Files/VCR2L-2024-05-08.fountain")
	var fnlines: Array[FNLineGD] = screenplay_page.get_parsed_lines(screenplay_file_content)
	pages = split_fnline_array_into_page_groups(fnlines)
	screenplay_page.populate_container_with_page_and_shotlines(pages[cur_page_index])
	screenplay_page.created_new_shotline.connect(_on_new_shotline_added)
	screenplay_page.shotline_clicked.connect(_on_shotline_clicked)

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

# -------------------- CHILD INPUT HANDLING -----------------------------

func _on_tool_bar_toolbar_button_pressed(toolbar_button: int) -> void:
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
					screenplay_page.add_new_shotline_to_page(last_clicked_line_idx, last_hovered_line_idx, event.global_position)
					print("Clicked and hovered: ", last_clicked_line_idx, ",   ", last_hovered_line_idx)
		if event.button_index == 2:
			pass

func _on_screenplay_page_last_hovered_line_idx(last_line: int) -> void:
	last_hovered_line_idx = last_line

func _on_new_shotline_added(shotline_struct: Shotline) -> void:
	inspector_panel.scene_num.focus_on_field()
	inspector_panel.populate_fields_from_shotline(shotline_struct)
	cur_selected_shotline = shotline_struct

func _on_inspector_panel_field_text_changed(new_text: String, field_category: TextInputField.FIELD_CATEGORY) -> void:

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
			var current_shotlines: Array = screenplay_page.shotlines_for_pages[cur_page_index]
			var cur_shotline_uuid: String = shotline_node.shotline_struct_reference.shotline_uuid
			for sl: Node in current_shotlines:
				if not sl is Shotline:
					continue
				if sl.shotline_uuid == cur_shotline_uuid:
					cur_selected_shotline = sl
					break
			inspector_panel.populate_fields_from_shotline(cur_selected_shotline)
