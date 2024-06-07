extends Control

class_name ScreenplayPage

@export_multiline var raw_screenplay_content: String = "INT. HOUSE - DAY"
@export var SP_ACTION_WIDTH: int = 61
@export var SP_DIALOGUE_WIDTH: int = 36
@export var SP_FONT_SIZE: int = 20
@export var font_ratio: float = 0.725

@onready var SP_CHARACTER_SPACING: float = SP_FONT_SIZE * font_ratio * 10
@onready var SP_PARENTHETICAL_SPACING: float = SP_FONT_SIZE * font_ratio * 5
@onready var page_panel: Panel = %ScreenplayPagePanel
@onready var page_container: Node = %ScreenplayPageContentVBox
@onready var left_page_margin: Node = %LeftPageMarginRegion
@onready var right_page_margin: Node = %RightPageMarginRegion
@onready var bottom_page_margin: Node = %BottomPageMarginRegion
@onready var top_page_margin: Node = %TopPageMarginRegion
@onready var background_color_rect: ColorRect = %PageBackground

const uuid_util = preload ("res://addons/uuid/uuid.gd")
const page_margin_region: PackedScene = preload ("res://Components/PageMarginRegion.tscn")

var current_page_number: int = 0
var shotlines_for_pages: Dictionary = {}

signal created_new_shotline(shotline_struct: Shotline)
signal shotline_clicked
signal page_lines_populated

# TODO
# - Fountain Parsing logic should be in a different file, probably an autoload

## EMPHASIS is not handled here -- asterisks need to be removed from the fountain screenplay.

# Called when the node enters the scene tree for the first time.

func _ready() -> void:
	EventStateManager.page_node = self
	left_page_margin.color = Color.TRANSPARENT
	right_page_margin.color = Color.TRANSPARENT
	top_page_margin.color = Color.TRANSPARENT
	bottom_page_margin.color = Color.TRANSPARENT
	
func replace_current_page(page_content: PageContent, new_page_number: int=0) -> void:
	for child in page_container.get_children():
		page_container.remove_child(child)
	for shotline_container: Node in page_panel.get_children():
		if shotline_container is ShotLine2DContainer:
			page_panel.remove_child(shotline_container)
			shotline_container.queue_free()
	await get_tree().process_frame
	populate_container_with_page_lines(page_content, new_page_number)
	populate_page_panel_with_shotlines_for_page()

func populate_container_with_page_lines(cur_page_content: PageContent, page_number: int=0) -> void:
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

	page_lines_populated.emit()

func populate_page_panel_with_shotlines_for_page() -> void:
	await get_tree().process_frame
	var cur_page_idx: int = EventStateManager.cur_page_idx
	var shotlines_in_page: Array[Shotline] = []

	for sl: Shotline in ScreenplayDocument.shotlines:
		if (
			sl.start_page_index == cur_page_idx # starts on this page
			or sl.end_page_index == cur_page_idx # ends on this page
			) or (
				sl.start_page_index < cur_page_idx
				and sl.end_page_index > cur_page_idx # Starts before this page and ends after this page
			):
				if sl.end_page_index < cur_page_idx:
					break
				shotlines_in_page.append(sl)

	for sl: Shotline in shotlines_in_page:
		var create_shotline_command: CreateShotLineCommand = CreateShotLineCommand.new([sl])
		create_shotline_command.execute()

func construct_screenplay_line(fnline: FNLineGD, idx: int) -> Label:

	var screenplay_line := Label.new()
	screenplay_line.set_script(preload ("res://Scripts/Node Scripts/LabelWithVars.gd"))
	screenplay_line.fnline = fnline
	screenplay_line.line_index = idx
	screenplay_line.autowrap_mode = TextServer.AUTOWRAP_OFF
	screenplay_line.add_theme_font_size_override("font_size", SP_FONT_SIZE)
	screenplay_line.add_theme_color_override("font_color", ShotLinerColors.text_color)

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

func set_color_of_all_page_margins(color: Color=Color.TRANSPARENT) -> void:
	left_page_margin.color = color
	right_page_margin.color = color
	bottom_page_margin.color = color
	top_page_margin.color = color

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
