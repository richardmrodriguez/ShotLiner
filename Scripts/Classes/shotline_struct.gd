class_name Shotline

var shotline_2D_scene := preload ("res://Components/ShotLine2D.tscn")

var visual_line: Line2D
var start_page_index: int
var end_page_index: int
var start_uuid: String
var end_uuid: String
var x_position: float

var unfilmed_sections: Array[PagelineSection]

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

func starts_on_earlier_page(page_idx: int) -> bool:
	if start_page_index < page_idx:
		return true
	return false

func ends_on_later_page(page_idx: int) -> bool:
	if end_page_index > page_idx:
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

func update_page_line_indices_with_points(
	pages: Array[PageContent],
	cur_page_idx: int,
	page_container_children: Array[Node],
	last_node_global_pos: Vector2) -> void:
	
	# if this is the middle of a multipage shotline, don't do anything to update the vertical 
	# position ;
	# Might change this behavior in the future
	if is_multiline():
		if starts_on_earlier_page(cur_page_idx)&&ends_on_later_page(cur_page_idx):
			return
	
	var cur_pageline_labels: Array[Node] = page_container_children
	var y_movement_delta: float = shotline_node.global_position.y - last_node_global_pos.y
	
	var begin_point: Vector2 = shotline_node.points[0] + shotline_node.position
	var end_point: Vector2 = shotline_node.points[1] + shotline_node.position

	var line_label_height: float
	var screenplay_line_offset: int

	var line_label_height_set: bool = false
	var new_start_point_set: bool = false
	var new_end_point_set: bool = false

	var old_start_line_idx: int
	var old_end_line_idx: int

	print("Points of this particular shotline: ", begin_point, " | ", end_point)
	print("Node position of this Shotline: ", shotline_node.global_position)

	# grab the first PageLineLabel and set the screenplay_line_offset to
	# the Label's height
	for cur_screenplay_line: Node in cur_pageline_labels:
		if not cur_screenplay_line is PageLineLabel:
			continue
		if not line_label_height_set:
			line_label_height = cur_screenplay_line.size.y
			screenplay_line_offset = int(y_movement_delta / line_label_height)
			if screenplay_line_offset == 0:
				return
			line_label_height_set = true
			break
	
	var start_page_lines: Array[FNLineGD] = pages[start_page_index].lines
	for fnline: FNLineGD in start_page_lines:
		if fnline.uuid == start_uuid:
			old_start_line_idx = start_page_lines.find(fnline)
			print("old_start: ", old_start_line_idx)

	var end_page_lines: Array[FNLineGD] = pages[end_page_index].lines
	for fnline: FNLineGD in end_page_lines:
		if fnline.uuid == end_uuid:
			old_end_line_idx = start_page_lines.find(fnline)
			print("old_end: ", old_end_line_idx)

	var new_start_line_idx: int = old_start_line_idx + screenplay_line_offset
	var new_end_line_idx: int = old_end_line_idx + screenplay_line_offset

	# figure out if the offsets point to a valid screenplay line in this array
	var start_idx_page: PageContent = pages[start_page_index]
	var end_idx_page: PageContent = pages[end_page_index]

	print("Start / end line  indices", new_start_line_idx, " | ", new_end_line_idx)

	if (new_start_line_idx >= 0)&&(new_start_line_idx < (start_idx_page.lines.size() - 1)):
		new_start_point_set = true

	if (new_end_line_idx >= 0)&&(new_end_line_idx < (end_idx_page.lines.size() - 1)):
		new_end_point_set = true

	if new_start_point_set&&new_end_point_set:
		start_uuid = start_idx_page.lines[new_start_line_idx].uuid
		end_uuid = end_idx_page.lines[new_end_line_idx].uuid
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

# ---------------- STATIC FUNC - CONSTRUCT NODE ------------------------

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

	var shotline_points: Array[Vector2] = [] # empty array to be filled by the following section

	# Get the start and end positions of each unfilmed (squiggle) section, use those positions to construct a points array which includes jagged squiggles for unfilmed sections
	var unfilmed_sections_in_page: Array[PagelineSection] = []

	# TODO: too much copy-pasting here, extract the inner for loops into a single func 
	for section: PagelineSection in shotline.unfilmed_sections:
		print("looking for sections")

		var start_idx: Vector2i = shotline.get_fnline_index_from_uuid(section.start_index_uuid, pages)
		var end_idx: Vector2i = shotline.get_fnline_index_from_uuid(section.end_index_uuid, pages)
		
		# The entirety of the unfilmed section is not even on this page, skip it
		if end_idx.x < current_page_index or start_idx.x > current_page_index:
			continue

		# The entire unfilmed section is on this page, handle it
		if start_idx.x == current_page_index&&end_idx.x == current_page_index:
			# this section is entirely on this page, add the positions to the section struct, then add it to the array
			for label: PageLineLabel in cur_pagelines:
				if label.fnline.uuid == section.start_index_uuid:
					section._start_position = label.global_position
				elif label.fnline.uuid == section.end_index_uuid:
					section._end_position = label.global_position + Vector2(0, screenplay_line_vertical_size)
			unfilmed_sections_in_page.append(section)
		
		# only the start of this section is on this page
		elif start_idx.x == current_page_index:
			# we can simply conclude the rest of the line is a squiggle, so
			# make a new PagelineSection which ends at the line's end, add it to the array, then break
			var new_final_section: PagelineSection = PagelineSection.new()
			new_final_section.start_index_uuid = section.start_index_uuid
			new_final_section.end_index_uuid = local_end_label.fnline.uuid
			for label: PageLineLabel in cur_pagelines:
				if label.fnline.uuid == section.start_index_uuid:
					new_final_section._start_position = label.global_position
				elif label.fnline.uuid == section.end_index_uuid:
					new_final_section._end_position = label.global_position + Vector2(0, screenplay_line_vertical_size)
			unfilmed_sections_in_page.append(new_final_section)
			break
		
		# only the end of this section is on this page
		elif end_idx.x == current_page_index:
			# make the entire first part of the line a squiggle up to this point, then continue
			var new_start_section: PagelineSection = PagelineSection.new()
			new_start_section.start_index_uuid = local_start_label.fnline.uuid
			new_start_section.end_index_uuid = section.end_index_uuid

			for label: PageLineLabel in cur_pagelines:
				if label.fnline.uuid == section.start_index_uuid:
					new_start_section._start_position = label.global_position
				elif label.fnline.uuid == section.end_index_uuid:
					new_start_section._end_position = label.global_position + label.get_global_rect().size

			unfilmed_sections_in_page.clear()
			unfilmed_sections_in_page.append(new_start_section)

	shotline_points = shotline.create_points_with_squiggles_from_sections(
		start_pos, end_pos,
		unfilmed_sections_in_page,
		screenplay_line_vertical_size
		)

	var new_line2D: ShotLine2D = empty_shotline_2D
	new_line2D.default_color = ShotLinerColors.line_color
	new_line2D.shotline_struct_reference = shotline
	new_line2D.set_points(shotline_points)

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

func create_points_with_squiggles_from_sections(
	line_start: Vector2,
	line_end: Vector2,
	squiggle_sections: Array[PagelineSection],
	pageline_label_height: float=12.0) -> Array[Vector2]:

	var fraction_denominator: float = 2.0
	var squiggle_x_offset: float = pageline_label_height / fraction_denominator
	var squiggle_y_offset: float = pageline_label_height / fraction_denominator

	var new_array: Array[Vector2] = []
	
	# construct the squiggly sections, then return the array with those sections
	if squiggle_sections != []:
		
		new_array.append(line_start)
		
		for section: PagelineSection in squiggle_sections:
			new_array.append(section.start_position)

			var x_center: float = section.start_position.x
			var y_pos: float = section.start_position.y + squiggle_y_offset
			var x_offset_positive: bool = false
			var cur_x_offset: float = squiggle_x_offset

			while y_pos < section.end_position.y:
				if x_offset_positive:
					cur_x_offset = squiggle_x_offset
				else:
					cur_x_offset = -squiggle_x_offset
				new_array.append(Vector2(x_center + cur_x_offset, y_pos))

				x_offset_positive = !x_offset_positive
				y_pos += squiggle_y_offset
			
			if not section.end_position in new_array:
				new_array.append(section.end_position)
		
		if not line_end in new_array:
			new_array.append(line_end)
		
		return new_array
	
	# if no squiggle sections, just return the line start and end
	return [line_start, line_end]

func get_fnline_index_from_uuid(uuid: String, pages: Array[PageContent]) -> Vector2i:
	for page: PageContent in pages:
		for line: FNLineGD in page.lines:
			if line.uuid == uuid:
				return Vector2i(pages.find(page), page.lines.find(line))
	return Vector2i()