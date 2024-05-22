extends Control

@export_multiline var raw_screenplay_content: String = "INT. HOUSE - DAY"
# debug var
@export var debug_spacer_colors: bool = false
@export var SP_ACTION_WIDTH: int = 61
@export var SP_DIALOGUE_WIDTH: int = 36
@export var SP_FONT_SIZE: int = 20
@export var font_ratio: float = 0.725

@onready var SP_CHARACTER_SPACING: float = SP_FONT_SIZE * font_ratio * 10
@onready var SP_PARENTHETICAL_SPACING: float = SP_FONT_SIZE * font_ratio * 5
@onready var page_panel: Panel = %ScreenplayPagePanel
@onready var page_container: Node = %ScreenplayPageContentVBox

const uuid_util = preload ("res://addons/uuid/uuid.gd")

var shotline_2D_scene := preload ("res://Components/ShotLine2D.tscn")

var current_page_number: int = 0
var shotlines_for_pages: Dictionary = {}

signal created_new_shotline(shotline_struct: Shotline)
signal shotline_clicked
signal last_hovered_line_idx(last_ine_idx: int)

# TODO
# - This logic needs to be abstracted into another file;
# - This needs another piece to break up an FNLineGD array into
# Pages, which are arrays with a maximum size and also
# special logic to ensure CHARACTER headings are not orphaned
# at the bottom of a page

## - DRAWING LOGIC - need to get the following:
## 1. mouse click down - which row of the page does the mouse click into?
## 2. mouse click up - which row of the page does the mouse release its click?
## using those two data points, we can create a ShotLine which concretely correlates
## to a start and end position on a page, then draw it accordingly

## EMPHASIS is not handled here -- asterisks need to be removed from the fountain screenplay.

# Called when the node enters the scene tree for the first time.

func _ready() -> void:
	page_panel.shotline_clicked.connect(_on_shotline_clicked)

func replace_current_page(page_content: PageContent, new_page_number: int=0) -> void:
	for child in page_container.get_children():
		page_container.remove_child(child)
	for shotline: Node in page_panel.get_children():
		if shotline is ShotLine2D:
			page_panel.remove_child(shotline)
			shotline.queue_free()
			#print("lmao", shotline)
	populate_container_with_page_and_shotlines(page_content, new_page_number)

func populate_container_with_page_and_shotlines(cur_page_content: PageContent, page_number: int=0) -> void:
	current_page_number = page_number
	var line_counter: int = 0
	for fnline: FNLineGD in cur_page_content.lines:

		var screenplay_line: Label = construct_screenplay_line(fnline, line_counter)
		page_container.add_child(screenplay_line)

		# adds a toggleable highlight to text lines
		var line_bg := ColorRect.new()
		screenplay_line.add_child(line_bg)
		line_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
		line_bg.color = Color(1, .8, 1, 0.125)
		line_bg.set_size(line_bg.get_parent_area_size())
		line_bg.set_size(Vector2(500, line_bg.get_rect().size.y))
		line_bg.set_position(screenplay_line.position)

		screenplay_line.z_index = 0
		line_bg.z_index = 1
		line_bg.visible = false
		line_counter += 1
	
	if shotlines_for_pages.has(current_page_number):
		await get_tree().process_frame
		#await get_tree().process_frame
		var cur_page_shotlines: Array = shotlines_for_pages[current_page_number]
		print("funny shotline constructiond")
		
		for sl: Shotline in cur_page_shotlines:
			print("Adding this shotline: ", sl)
			page_panel.add_child(construct_shotline(sl))

# TODO: these two funcs are confusingly named and structured;
# constructing the shotline should constitute putting the metadata into a Shotline struct
# adding the shotline to the page should create the Line2D
# Also, the Line2D
func add_new_shotline_to_page(start_idx: int, end_idx: int, last_mouse_pos: Vector2) -> void:
	if not shotlines_for_pages.has(current_page_number):
		var empty_shotlines_dict: Array = []
		shotlines_for_pages[current_page_number] = empty_shotlines_dict
	var cur_shotlines: Array = shotlines_for_pages[current_page_number]
	var cur_shotline: Shotline = Shotline.new()
	var new_shotline_id: String = uuid_util.v4()
	cur_shotline.shotline_uuid = new_shotline_id
	cur_shotline.start_index = start_idx
	cur_shotline.end_index = end_idx
	cur_shotline.x_position = last_mouse_pos.x
	cur_shotlines.append(cur_shotline)
	await get_tree().process_frame
	page_panel.add_child(construct_shotline(cur_shotline))
	created_new_shotline.emit(cur_shotline)

func construct_shotline(shotline: Shotline) -> ShotLine2D:
	var start_idx: int = shotline.start_index
	var end_idx: int = shotline.end_index
	var last_mouse_pos: float = shotline.x_position

	var real_start: int
	var real_end: int
	# This bit ensures that lines are always oriented to start at the top and end at the bottom
	if start_idx > end_idx:
		real_start = end_idx
		real_end = start_idx
	else:
		real_start = start_idx
		real_end = end_idx
	var screenplay_lines: Array = page_container.get_children()
	var screenplay_line_start: Label
	var screenplay_line_end: Label

	for spl: Label in screenplay_lines:
		if spl is Label:
			if spl.line_index == real_start:
				screenplay_line_start = spl
				print("start line: ", spl.fnline.fn_type, " | ", spl.text, )
			if spl.line_index == real_end:
				screenplay_line_end = spl

	var screenplay_line_vertical_size: float = screenplay_line_start.get_rect().size.y

	# TODO: I don't know why the shotlines' vertical position is off by like 3 lines,
	# But it is and so, it needs the following offsets. Must investigate further.
	# However, I do like the effect of having there being 0.5x line height of
	# overhang for the start and end;
	var start_pos: Vector2 = Vector2(
		last_mouse_pos,
		screenplay_line_start.global_position.y - 4.5 * screenplay_line_vertical_size
		)
	var end_pos: Vector2 = Vector2(
		last_mouse_pos,
		screenplay_line_end.global_position.y - 3.5 * screenplay_line_vertical_size
		)

	print("Current shotline positions: ", start_pos.y, ", ", end_pos.y)

	var new_line2D: Line2D = shotline_2D_scene.instantiate()
	new_line2D.shotline_struct_reference = shotline
	new_line2D.width = 6.0
	new_line2D.default_color = Color.SEA_GREEN
	new_line2D.begin_cap_mode = Line2D.LINE_CAP_ROUND
	new_line2D.end_cap_mode = Line2D.LINE_CAP_ROUND
	new_line2D.set_points([start_pos, end_pos])

	shotline.shotline_node = new_line2D

	return new_line2D

func construct_screenplay_line(fnline: FNLineGD, idx: int) -> Label:

	var screenplay_line := Label.new()
	screenplay_line.set_script(preload ("res://Scripts/Node Scripts/LabelWithVars.gd"))
	screenplay_line.fnline = fnline
	screenplay_line.line_index = idx
	screenplay_line.autowrap_mode = TextServer.AUTOWRAP_OFF
	screenplay_line.add_theme_font_size_override("font_size", SP_FONT_SIZE)

	match fnline.fn_type:
		"Heading":
			screenplay_line.add_theme_font_override("font",
				load("res://Fonts/Courier Prime Bold.ttf"))
			screenplay_line.text = fnline.string
			#print("Heading: ", fnline.string)
		"Character":
			screenplay_line.text = " ".repeat(20) + fnline.string
		"Parenthetical":
			screenplay_line.text = " ".repeat(15) + fnline.string
		"TransitionLine":
			
			screenplay_line.text = " ".repeat(50) + fnline.string
		_:
			if fnline.fn_type.begins_with("Dialog"):
				screenplay_line.text = " ".repeat(10) + fnline.string
			else:
				screenplay_line.text = fnline.string
	
	return screenplay_line

# -------- FOUNTAIN / STRING MANIPULATION --------

func split_string_by_newline(string: String) -> PackedStringArray:
	var split := string.split("\n", true, ) as PackedStringArray
	return split

func get_parsed_lines(screenplay_as_str: String) -> Array:
	var pre_paginated_string := pre_paginate_lines_from_raw_string(screenplay_as_str)
	var parsed_lines := FountainParser.get_parsed_lines_from_raw_string(pre_paginated_string)

	var fnline_arr := construct_fnline_arr(parsed_lines)

	for ln: FNLineGD in fnline_arr:
		if ln.is_type_forced == "true":
			ln.string = ln.string.erase(0)

	return fnline_arr

func pre_paginate_lines_from_raw_string(screenplay_str: String) -> String:
	var preparsed_lines := FountainParser.get_parsed_lines_from_raw_string(screenplay_str)
	var pre_fnline_arr: Array[FNLineGD] = construct_fnline_arr(preparsed_lines)
	var paginated_lines: Array[String] = get_paginated_lines_from_fnline_arr(pre_fnline_arr)
	var paginated_multiline_str: String = ""
	for pgln: String in paginated_lines:
		paginated_multiline_str += pgln + "\n"
	return paginated_multiline_str

func construct_fnline_arr(lines_dict: Dictionary) -> Array[FNLineGD]:
	var linekeys := lines_dict.keys()
	var fnline_arr: Array[FNLineGD] = []
	linekeys.sort()
	for key: int in linekeys:

		var fnline_struct := FNLineGD.new()
		fnline_struct.pos = key
		fnline_struct.string = lines_dict[key][0]
		fnline_struct.fn_type = lines_dict[key][1]
		fnline_struct.is_type_forced = lines_dict[key][2]
		fnline_arr.append(fnline_struct)
	return fnline_arr

func get_paginated_lines_from_fnline_arr(fnline_arr: Array) -> Array[String]:
	var new_arr: Array[String] = []
	var forced_type_offset: int = 0

	for ln: FNLineGD in fnline_arr:
		if ln.is_type_forced == "true":
			forced_type_offset = 1
		else:
			forced_type_offset = 0
		var s := ln.string
		var sub_arr := []
		if not ln.fn_type.begins_with("Dialog"):
			sub_arr = recursive_line_splitter(s, SP_ACTION_WIDTH + forced_type_offset)
		else:
			sub_arr = recursive_line_splitter(s, SP_DIALOGUE_WIDTH + forced_type_offset)
		for sub_s: String in sub_arr:
			new_arr.append(sub_s)
	return new_arr

func recursive_line_splitter(line: String, max_length: int) -> Array:
	var final_arr: Array = []
	if line.length() <= max_length:
			final_arr.append(line)
	else:
		var words := line.split(" ")
		var cur_substring := ""
		var next_substring := ""
		var cur_line_full: bool = false
		for word: String in words:
			if word.length() + cur_substring.length() <= max_length and not cur_line_full:
					cur_substring += word + " "
			else:
				cur_line_full = true
				next_substring += word + " "

		final_arr.append(cur_substring)
		var new_arr := recursive_line_splitter(next_substring, max_length)
		for nl: String in new_arr:
			final_arr.append(nl)
		 
	return final_arr

func _on_screenplay_page_content_v_box_screenplay_line_hovered_over(last_line_idx: int) -> void:
	last_hovered_line_idx.emit(last_line_idx)

func _on_shotline_clicked(shotline_node: ShotLine2D, button_index: int) -> void:
	shotline_clicked.emit(shotline_node, button_index)
