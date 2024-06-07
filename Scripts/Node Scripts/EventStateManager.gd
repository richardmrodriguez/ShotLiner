extends Node

const FIELD_CATEGORY = TextInputField.FIELD_CATEGORY
const uuid_util = preload ("res://addons/uuid/uuid.gd")

var line_hover_width: float

enum TOOL {
	MOVE,
	SELECT,
	DRAW,
	DRAW_SQUIGGLE,
	ERASE,
}
# ------ NODES -------
@onready var page_node: ScreenplayPage
@onready var inpsector_panel_node: InspectorPanel
@onready var toolbar_node: ToolBar
@onready var editor_view: Node

# ------ STATES ------
var is_drawing: bool = false
var is_erasing: bool = false
var cur_tool: TOOL = TOOL.DRAW

var last_mouse_hover_position: Vector2
var last_shotline_node_global_pos: Vector2
var last_mouse_click_above_top_margin: bool = false
var last_mouse_click_below_bottom_margin: bool = false
var last_mouse_click_past_right_margin: bool = false
var last_mouse_click_past_left_margin: bool = false
var last_hovered_line_uuid: String = ""
var last_clicked_line_uuid: String = ""
var last_hovered_shotline_node: ShotLine2DContainer
var last_valid_shotline_position: Vector2

var cur_mouse_global_position_delta: Vector2
var cur_selected_shotline: Shotline

var is_dragging_shotline: bool = false

# ------ PAGE STATUS ------

var cur_page_idx: int = 0

# ------ READY ------

func _ready() -> void:
	pass

# ----- UITIL FUNCS ------

func get_page_idx_of_fnline_from_uuid(uuid: String) -> int:
	for page: PageContent in ScreenplayDocument.pages:
		for line: FNLineGD in page.lines:
			if line.uuid == uuid:
				return ScreenplayDocument.pages.find(page)

	return - 1

# -------------------- SHOTLINE LOGIC -----------------------------------

# TODO: these two funcs are confusingly named and structured;
# constructing the shotline should constitute putting the metadata into a Shotline struct
# adding the shotline to the page should create the Line2D
# Also, the Line2D
func create_and_add_shotline_node_to_page(shotline: Shotline) -> void:
	
	var create_shotline_command: CreateShotLineCommand = CreateShotLineCommand.new([shotline])
	CommandHistory.add_command(create_shotline_command)
	cur_selected_shotline = shotline

func create_new_shotline_obj(start_uuid: String, end_uuid: String, last_mouse_pos: Vector2) -> Shotline:

	var new_shotline: Shotline = Shotline.new()

	var start_line_page_idx: int = get_page_idx_of_fnline_from_uuid(start_uuid)
	var end_line_page_idx: int = get_page_idx_of_fnline_from_uuid(end_uuid)

	assert(start_line_page_idx != - 1, "Start line page index for shotline does not exist.")
	assert(end_line_page_idx != - 1, "End line page index for shotline does not exist.")

	new_shotline.shotline_uuid = uuid_util.v4()
	
	if start_line_page_idx < end_line_page_idx:
		new_shotline.start_page_index = start_line_page_idx
		new_shotline.end_page_index = end_line_page_idx
		new_shotline.start_uuid = start_uuid
		new_shotline.end_uuid = end_uuid
	else:
		new_shotline.start_page_index = end_line_page_idx
		new_shotline.end_page_index = start_line_page_idx
		new_shotline.start_uuid = end_uuid
		new_shotline.end_uuid = start_uuid

	new_shotline.x_position = last_mouse_pos.x
	print("Start and end page indices: ", new_shotline.start_page_index, " | ", new_shotline.end_page_index)
	return new_shotline

func set_current_tool(tool: TOOL) -> void:
	EventStateManager.cur_tool = tool

#
#
# -------------------- SIGNAL HANDLING -----------------------------
#
#

func _on_tool_changed() -> void:
	pass

func _on_tool_bar_toolbar_button_pressed(toolbar_button: int) -> void:
	await get_tree().process_frame
	var pages: Array[PageContent] = ScreenplayDocument.pages
	match toolbar_button:
		toolbar_node.TOOLBAR_BUTTON.NEXT_PAGE:
			var next_page_idx: int = cur_page_idx + 1
			var page_nav_command: PageNavigateCommand = PageNavigateCommand.new(
				[next_page_idx,
				cur_page_idx
				])
			CommandHistory.add_command(page_nav_command)

		toolbar_node.TOOLBAR_BUTTON.PREV_PAGE:
			var prev_page_idx: int = cur_page_idx - 1
			var page_nav_command: PageNavigateCommand = PageNavigateCommand.new(
				[prev_page_idx,
				cur_page_idx
				])
			CommandHistory.add_command(page_nav_command)

		# TOOL SELECTION
		toolbar_node.TOOLBAR_BUTTON.SELECT:
			cur_tool = TOOL.SELECT
		toolbar_node.TOOLBAR_BUTTON.MOVE:
			cur_tool = TOOL.MOVE
		toolbar_node.TOOLBAR_BUTTON.DRAW:
			cur_tool = TOOL.DRAW
		toolbar_node.TOOLBAR_BUTTON.DRAW_SQUIGGLE:
			cur_tool = TOOL.DRAW_SQUIGGLE
		toolbar_node.TOOLBAR_BUTTON.ERASE:
			cur_tool = TOOL.ERASE

func _on_screenplay_page_gui_input(event: InputEvent) -> void:
	
	if event is InputEventMouseButton:
		var cur_global_pos: Vector2 = event.global_position
		last_mouse_click_below_bottom_margin = (
			page_node.bottom_page_margin.global_position.y
			< cur_global_pos.y
			)
		last_mouse_click_above_top_margin = (
			page_node.top_page_margin.global_position.y +
			page_node.top_page_margin.size.y
			> cur_global_pos.y
			)
		last_mouse_click_past_left_margin = (
				page_node.left_page_margin.global_position.x +
				page_node.left_page_margin.size.x
				> cur_global_pos.x
			)
		last_mouse_click_past_right_margin = (
			page_node.right_page_margin.global_position.x
			< cur_global_pos.x
			)
		
		if event.button_index == MOUSE_BUTTON_LEFT:
			_handle_left_click(event)
	if event is InputEventMouseMotion:
		var pageline_labels: Array[Node] = page_node.page_container.get_children()
		var cur_global_mouse_pos: Vector2 = editor_view.get_global_mouse_position()

		# highlight a pageline if the mouse is hovering over it
		for pageline in pageline_labels:
			if pageline is PageLineLabel:
				if pageline.get_global_rect().has_point(event.global_position):
					for subchild in pageline.get_children():
						subchild.visible = true
					var cur_child_uuid: String = pageline.fnline.uuid
					if EventStateManager.last_hovered_line_uuid != cur_child_uuid:
						EventStateManager.last_hovered_line_uuid = cur_child_uuid
						#screenplay_line_hovered_over.emit(cur_child_uuid)
						#print(screenplay_line.get_index(), "   ", screenplay_line.fnline.fn_type)
				else:
					for subchild in pageline.get_children():
						pageline.get_child(0).visible = false
		#Highlight the margins if mouse is over a margin rect
		if page_node.top_page_margin.get_global_rect().has_point(cur_global_mouse_pos):
			page_node.top_page_margin.color = Color.RED
		else:
			page_node.top_page_margin.color = Color.TRANSPARENT
		
		# Handle dragging shotlines
		match cur_tool:
			TOOL.MOVE:
				if is_dragging_shotline:

					var new_x_pos: float = (
						cur_mouse_global_position_delta.x
						+ editor_view.get_global_mouse_position().x
					)
					cur_selected_shotline.shotline_node.global_position = Vector2(
						new_x_pos,
						last_shotline_node_global_pos.y
					)

func _handle_left_click(event: InputEvent) -> void:
	var pages: Array[PageContent] = ScreenplayDocument.pages
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
							var new_shotline: Shotline = create_new_shotline_obj(last_clicked_line_uuid, last_hovered_line_uuid, event.position)
							create_and_add_shotline_node_to_page(new_shotline)
					
						elif last_mouse_click_above_top_margin:
							# click released past top or bottom margin
							# give the add_new_shotline the last line of prev page or first line of next page

							var start_uuid: String
							if cur_page_idx - 1 >= 0:
								start_uuid = pages[cur_page_idx - 1].lines[- 1].uuid
							else:
								start_uuid = pages[cur_page_idx].lines[0].uuid
							var new_shotline: Shotline = create_new_shotline_obj(start_uuid, last_hovered_line_uuid, event.position)
							create_and_add_shotline_node_to_page(new_shotline)
						elif last_mouse_click_below_bottom_margin:
							var end_uuid: String
							if cur_page_idx + 1 <= pages.size() + 1:
								end_uuid = pages[cur_page_idx + 1].lines[+ 1].uuid
							else:
								end_uuid = pages[cur_page_idx].lines[- 1].uuid
							var new_shotline: Shotline = create_new_shotline_obj(last_clicked_line_uuid, end_uuid, event.position)
							create_and_add_shotline_node_to_page(new_shotline)

							#print("Clicked and hovered: ", last_clicked_line_idx, ",   ", last_hovered_line_idx)

func _on_new_shotline_added(shotline_struct: Shotline) -> void:
	inpsector_panel_node.scene_num.line_edit.grab_focus()
	inpsector_panel_node.populate_fields_from_shotline(shotline_struct)
	cur_selected_shotline = shotline_struct

func _on_inspector_panel_field_text_changed(new_text: String, field_category: TextInputField.FIELD_CATEGORY) -> void:
	if (not cur_selected_shotline) or ScreenplayDocument.shotlines == []:
		return
	await get_tree().process_frame
	match field_category:
		FIELD_CATEGORY.SCENE_NUM:
			cur_selected_shotline.scene_number = new_text
		FIELD_CATEGORY.SHOT_NUM:
			cur_selected_shotline.shot_number = new_text
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
	cur_selected_shotline.shotline_node.update_shot_number_label()

func _on_shotline_clicked(shotline_node: ShotLine2DContainer, button_index: int) -> void:
	match cur_tool:
		TOOL.MOVE:
			match button_index:
				1:
					inpsector_panel_node.populate_fields_from_shotline(shotline_node.shotline_struct_reference)
					cur_selected_shotline = shotline_node.shotline_struct_reference
					is_dragging_shotline = true
					cur_mouse_global_position_delta = shotline_node.global_position - editor_view.get_global_mouse_position()
					last_shotline_node_global_pos = shotline_node.global_position
					print(is_dragging_shotline)

# TODO: have a func which calls all the on_something_released whenever the mouse leaves the Screenplay Page area

func _on_shotline_released(shotline_node: ShotLine2DContainer, button_index: int) -> void:
	print("shotline released!!!")
	match cur_tool:
		TOOL.MOVE:
			if button_index != 1:
				return
			if shotline_node.shotline_struct_reference == cur_selected_shotline:
				if is_dragging_shotline:
					
					is_dragging_shotline = false
					
					# If the mouse has dragged the shotline past the left or right margins,
					# Put the shotline back where it came from
					if (
						(page_node.left_page_margin.global_position.x
						+ page_node.left_page_margin.size.x)
						> editor_view.get_global_mouse_position().x
						or
						(page_node.right_page_margin.global_position.x)
						< editor_view.get_global_mouse_position().x
						):
						shotline_node.global_position = last_shotline_node_global_pos
						return
					var move_shotline_cmd := MoveShotLineCommand.new(
						[
							cur_selected_shotline,
							editor_view.get_global_mouse_position().x + cur_mouse_global_position_delta.x
						]
					)
					print(CommandHistory.add_command(move_shotline_cmd))
					#cur_selected_shotline.x_position = editor_view.get_global_mouse_position().x
					
					#var page_container_children := page_node.page_container.get_children()
					#cur_selected_shotline.update_page_line_indices_with_points(
					#	page_container_children,
					#	last_shotline_node_global_pos
					#	)
					#print(is_dragging_shotline)
					
		TOOL.ERASE:
			if button_index != 1:
				return
			if shotline_node == last_hovered_shotline_node:
				print("Erasing...?")
				if last_hovered_shotline_node.is_hovered_over:
					# TODO: Erasing isnt working because the shotlines arent working again lmao
					var erase_command: EraseShotLineCommand = EraseShotLineCommand.new(
						[
							shotline_node.shotline_struct_reference,
							page_node.page_panel
						]
					)
					CommandHistory.add_command(erase_command)

					#ScreenplayDocument.shotlines.erase(shotline_node.shotline_struct_reference)
					#shotline_node.queue_free()

func _on_shotline_hovered_over(shotline_container: ShotLine2DContainer) -> void:
	#print("Shotline Hovered changed: ", shotline_node, shotline_node.is_hovered_over)
	last_hovered_shotline_node = shotline_container

func _on_shotline_mouse_drag(shotline_node: ShotLine2DContainer) -> void:
	print("among us TWO")
	if is_dragging_shotline:
			print(cur_selected_shotline.shotline_node.global_position)
			var new_x_pos: float = (
				cur_mouse_global_position_delta.x + editor_view.get_global_mouse_position().x
			)
			cur_selected_shotline.shotline_node.global_position = Vector2(new_x_pos, cur_selected_shotline.shotline_node.global_position.y)

func _on_page_lines_populated() -> void:
	pass
	#page_node.populate_page_panel_with_shotlines_for_page()
