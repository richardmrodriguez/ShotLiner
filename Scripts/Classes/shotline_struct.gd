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

func is_multiline() -> bool:
	if start_page_index != end_page_index:
		return true
	return false

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
		if not cur_screenplay_line is PageLineLabel:
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
		# TODO: Actually handle moving the shotline above or below the top or bottom margins

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
	pages: Array[PageContent],
	current_page_index: int,
	page_container: Node,
	empty_shotline_2D: ShotLine2D
	) -> ShotLine2D:

	var cur_start_uuid: String = shotline.start_uuid
	var cur_end_uuid: String = shotline.end_uuid

	var cur_start_page_line_indices: Vector2i
	var cur_end_page_line_indices: Vector2i
	
	for page: PageContent in pages:
		for line: FNLineGD in page.lines:
			if line.uuid == cur_start_uuid:
				cur_start_page_line_indices = Vector2i(pages.find(page), page.lines.find(line))
			elif line.uuid == cur_end_uuid:
				cur_end_page_line_indices = Vector2i(pages.find(page), page.lines.find(line))

	var shotline_start_page_idx: int = shotline.start_page_index
	var shotline_end_page_idx: int = shotline.end_page_index

	var last_mouse_pos: float = shotline.x_position

	var starts_on_earlier_page: bool = false
	var ends_on_later_page: bool = false

	var pageline_start: Label
	var pageline_end: Label

	var pageline_real_start_idx: int
	var pageline_real_end_idx: int

	if shotline_start_page_idx < current_page_index:
		starts_on_earlier_page = true
	if shotline_end_page_idx > current_page_index:
		ends_on_later_page = true
	
	var cur_pagelines: Array[PageLineLabel] = []
	for pageline: Node in page_container.get_children():
		if not pageline is PageLineLabel:
			continue
		cur_pagelines.append(pageline)

	var local_end_label: PageLineLabel
	var local_start_label: PageLineLabel

	if not (starts_on_earlier_page or ends_on_later_page):
		for pageline: PageLineLabel in cur_pagelines:
			if pageline.fnline.uuid == cur_start_uuid:
				
				pageline_start = pageline
				pageline_real_start_idx = pageline.get_index()
				#print("start line: ", spl.fnline.fn_type, " | ", spl.text, )
			if pageline.fnline.uuid == cur_end_uuid:
				pageline_end = pageline
				pageline_real_end_idx = pageline.get_index()
		print("Normal shotline")
		if pageline_real_start_idx > pageline_real_end_idx:
			local_start_label = pageline_end
			local_end_label = pageline_start
		else:
			local_end_label = pageline_end
			local_start_label = pageline_start
	elif starts_on_earlier_page&&ends_on_later_page:
		print("Start earlier and ends later")
		local_start_label = cur_pagelines[0]
		local_end_label = cur_pagelines[- 1]
	elif starts_on_earlier_page:
		print("Starts on previous page")
		local_start_label = cur_pagelines[0]
		for pageline: PageLineLabel in cur_pagelines:
			if cur_start_page_line_indices.x < cur_end_page_line_indices.x:
				if pageline.fnline.uuid == cur_end_uuid:
					local_end_label = pageline
			else:
				if pageline.fnline.uuid == cur_start_uuid:
					local_end_label = pageline
				
	elif ends_on_later_page:
		print("Ends on later page")
		local_end_label = cur_pagelines[- 1]
		for pageline: PageLineLabel in cur_pagelines:
			if cur_start_page_line_indices.x < cur_end_page_line_indices.x:
				if pageline.fnline.uuid == cur_start_uuid:
					local_start_label = pageline
			else:
				if pageline.fnline.uuid == cur_end_uuid:
					local_start_label = pageline

	# ------------ SET POINTS AND POSITION FOR SHOTLINE NODE -------------------
	var screenplay_line_vertical_size: float = cur_pagelines[0].get_rect().size.y

	# TODO: I don't know why the shotlines' vertical position is off by like 3 lines,
	# But it is and so, it needs the following offsets. Must investigate further.
	# However, I do like the effect of having there being 0.5x line height of
	# overhang for the start and end;
	var start_pos: Vector2 = Vector2(
		last_mouse_pos,
		local_start_label.global_position.y - 4.5 * screenplay_line_vertical_size
		)
	var end_pos: Vector2 = Vector2(
		last_mouse_pos,
		local_end_label.global_position.y - 3.5 * screenplay_line_vertical_size
		)

	#print("Current shotline positions: ", start_pos.y, ", ", end_pos.y)

	var new_line2D: ShotLine2D = empty_shotline_2D
	new_line2D.default_color = ShotLinerColors.line_color
	new_line2D.shotline_struct_reference = shotline
	new_line2D.set_points([start_pos, end_pos])

	if starts_on_earlier_page:
		print("Shotline starts earlier")
		new_line2D.begin_cap_open = true
	if ends_on_later_page:
		print("Shotline ends later")
		new_line2D.end_cap_open = true

	new_line2D.true_start_pos = start_pos
	new_line2D.true_end_pos = end_pos

	shotline.shotline_node = new_line2D

	return new_line2D
