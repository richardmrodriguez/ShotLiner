extends Node

class_name Shotline

var shotline_2D_scene := preload ("res://Components/ShotLine2D.tscn")

var visual_line: Line2D
var start_page_index: int
var end_page_index: int
var start_uuid: String
var end_uuid: String
var x_position: float

var unfilmed_sections: Array[Dictionary] # sections[index]["section_start"] = 14

var shotline_node: ShotLine2D
var shotline_uuid: String

# User - Facing Metadata
var scene_number: String
var shot_number: String
var shot_type: String
var shot_subtype: String
var setup_number: String
var group: String
var tags: String

var tags_as_arr: Array[String]

func print_self() -> void:
	pretty_print_properties(
		[scene_number,
		shot_number,
		shot_type,
		shot_subtype,
		setup_number,
		group,
		tags])
func pretty_print_properties(props: Array) -> void:
	for prop: Variant in props:
		print("- ", prop)

# TODO: This method is inaccurate, because it calculates the closetst Label
# of each point separately. This leads to the Shotline becoming unintentionally
# expanded or shrunk due to rounding. 
# Instead:
# 1. First calculate the screenplay line index length (the span of the Shotline in terms of 
# number of fnline elements in order)
# 2. only calculate the Label nearest to one line
# 3. From that singular nearest Label as reference, then find the Label exactly the
# index span away
# i.e. if the line starts at line index 5, and is 5lines long, it begins with
# a span from 5 to 10. If the lines is then moved to start at line index 10,
# The new span will be from 10 to 15, exactly.
# Alternately, you could grab the Label height of one of the Screenplay lines,
# and use that with the mouse's position.y delta over time to determine
# how many "Label heights" the current ShotLine has moved.

func update_page_line_indices_with_points(cur_page_screenplay_lines: Array, last_node_global_pos: Vector2) -> void:
	#await get_tree().process_frame
	
	var y_movement_delta: float = shotline_node.global_position.y - last_node_global_pos.y
	var line_label_height: float
	var line_label_height_set: bool = false
	var screenplay_line_offset: int

	var new_start_point_set: bool = false
	var new_end_point_set: bool = false

	var begin_point: Vector2 = shotline_node.points[0] + shotline_node.position
	var end_point: Vector2 = shotline_node.points[1] + shotline_node.position

	var old_start_uuid: String = start_uuid
	var old_end_uuid: String = end_uuid

	print("Points of this particular shotline: ", begin_point, " | ", end_point)
	print("Node position of this Shotline: ", shotline_node.global_position)
	
	var assigned_both_uuids: bool = false

	var assigned_start_uuid: bool = false
	var assigned_end_uuid: bool = false

	var old_start_label_idx: int
	var old_end_label_idx: int

	for cur_screenplay_line: Node in cur_page_screenplay_lines:
		if not cur_screenplay_line is ScreenplayLineLabel:
			continue
		if not line_label_height_set:
			line_label_height = cur_screenplay_line.size.y
			screenplay_line_offset = int(y_movement_delta / line_label_height)
			#break
		if cur_screenplay_line.fnline.uuid == start_uuid:
			old_start_label_idx = cur_screenplay_line.get_index()
		if cur_screenplay_line.fnline.uuid == end_uuid:
			old_end_label_idx = cur_screenplay_line.get_index()
	
	if screenplay_line_offset == 0:
		return

	var new_start_label_idx: int = old_start_label_idx + screenplay_line_offset
	var new_end_label_idx: int = old_end_label_idx + screenplay_line_offset

	# figure out if the offsets point to a valid screenplay line in this array
	if (1 <= new_start_label_idx)&&(new_start_label_idx < (cur_page_screenplay_lines.size() - 1)):
		new_start_point_set = true

	if (1 <= new_end_label_idx)&&(new_end_label_idx < (cur_page_screenplay_lines.size() - 1)):
		new_end_point_set = true

	if new_start_point_set&&new_end_point_set:
		start_uuid = cur_page_screenplay_lines[new_start_label_idx].fnline.uuid
		end_uuid = cur_page_screenplay_lines[new_end_label_idx].fnline.uuid
	elif new_end_point_set:
		# too high up;, move down
		# but what about multipage shotlines AAAUUUGGHHHHH
		pass
	elif new_start_point_set:
		pass
		#too low: move up
	else:
		#you fucked up bro lmao
		pass

static func construct_shotline_node(
	shotline: Shotline,
	cur_screenplay_page_lines: Array,
	empty_shotline_2D: ShotLine2D
	) -> ShotLine2D:
	var cur_start_uuid: String = shotline.start_uuid
	var cur_end_uuid: String = shotline.end_uuid
	var last_mouse_pos: float = shotline.x_position

	var screenplay_line_start: Label
	var screenplay_line_end: Label

	var start_idx: int
	var end_idx: int
	for spl: Node in cur_screenplay_page_lines:
		if spl is Label:
			#print(spl.fnline.uuid)
			if spl.fnline.uuid == cur_start_uuid:
				screenplay_line_start = spl
				start_idx = spl.get_index()
				#print("start line: ", spl.fnline.fn_type, " | ", spl.text, )
			if spl.fnline.uuid == cur_end_uuid:
				screenplay_line_end = spl
				end_idx = spl.get_index()
	
	var real_end: Label
	var real_start: Label
	if start_idx > end_idx:
		real_start = screenplay_line_end
		real_end = screenplay_line_start
	else:
		real_end = screenplay_line_end
		real_start = screenplay_line_start

	var screenplay_line_vertical_size: float = screenplay_line_start.get_rect().size.y

	# TODO: I don't know why the shotlines' vertical position is off by like 3 lines,
	# But it is and so, it needs the following offsets. Must investigate further.
	# However, I do like the effect of having there being 0.5x line height of
	# overhang for the start and end;
	var start_pos: Vector2 = Vector2(
		last_mouse_pos,
		real_start.global_position.y - 4.5 * screenplay_line_vertical_size
		)
	var end_pos: Vector2 = Vector2(
		last_mouse_pos,
		real_end.global_position.y - 3.5 * screenplay_line_vertical_size
		)

	#print("Current shotline positions: ", start_pos.y, ", ", end_pos.y)

	var new_line2D: ShotLine2D = empty_shotline_2D
	new_line2D.shotline_struct_reference = shotline
	new_line2D.set_points([start_pos, end_pos])
	new_line2D.true_start_pos = start_pos
	new_line2D.true_end_pos = end_pos

	shotline.shotline_node = new_line2D

	return new_line2D
