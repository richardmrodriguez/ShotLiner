extends VBoxContainer

class_name ShotLine2DContainer

@onready var shot_number_label: Label = $ShotNumber
@onready var screenplay_page_panel: Panel = get_parent()
#@onready var line_body_grab_region: ColorRect = $ColorRect
@onready var begin_cap_grab_region: ColorRect = %BeginCapGrabRegion
@onready var end_cap_grab_region: ColorRect = %EndCapGrabRegion
@onready var segments_container: VBoxContainer = %SegmentsContainer
@export var color_rect_width: float = 12
@export var click_width: float = 12
@export var hover_line_width: float = 10
@export var line_width: float = 4
@export var cap_grab_region_height: float = 6
@export var cap_grab_region_vertical_position_offset: float = 6

var shotline_segment_scene: PackedScene = preload ("res://Components/ShotlineSegment2D.tscn")
var unfilmed_sections: Array = []
var shotline_length: int
var cur_pageline_label_height: float

var shotline_struct_reference: Shotline
var is_hovered_over: bool = false
var cap_line_width_offset: float = 8

var begin_cap_open: bool = false
var end_cap_open: bool = false

var true_start_pos: Vector2 = Vector2(0, 0)
var true_end_pos: Vector2 = Vector2(0, 0)

signal mouse_clicked_on_shotline(shotline2D: ShotLine2DContainer, button_index: int)
signal mouse_released_on_shotline(shotline2D: ShotLine2DContainer, button_index: int)
signal mouse_drag_on_shotline(shotline_node: ShotLine2DContainer)

func _init() -> void:
	visible = false

func _ready() -> void:
	if visible == false:
		visible = true
	#await get_tree().process_frame
	#line_body_grab_region.mouse_filter = Control.MOUSE_FILTER_PASS
	#print( %BeginCapGrabRegion)
	#print(end_cap_grab_region)

	begin_cap_grab_region.mouse_filter = Control.MOUSE_FILTER_PASS
	end_cap_grab_region.mouse_filter = Control.MOUSE_FILTER_PASS

	if begin_cap_open:
		begin_cap_grab_region.toggle_open_endcap(true)
		pass
	if end_cap_open:
		end_cap_grab_region.toggle_open_endcap(true)
		pass

	await get_tree().process_frame
	
	align_grab_regions()
	align_shot_number_label()
	update_shot_number_label()

	var line_color: Color = Color.hex(0x2aa198)
	update_line_color(line_color)
	update_line_width(line_width)
	
	for ln in begin_cap_grab_region.get_children():
		ln.default_color = ShotLinerColors.line_color
	for ln in end_cap_grab_region.get_children():
		ln.default_color = ShotLinerColors.line_color

	#end_cap_mode = Line2D.LINE_CAP_BOX
	#begin_cap_mode = Line2D.LINE_CAP_BOX
	#line_body_grab_region.color = Color.TRANSPARENT
	begin_cap_grab_region.color = Color.TRANSPARENT
	end_cap_grab_region.color = Color.TRANSPARENT
	#line_body_grab_region.gui_input.connect(_on_line_body_gui_input)
	mouse_clicked_on_shotline.connect(screenplay_page_panel._on_shotline_clicked)
	mouse_released_on_shotline.connect(screenplay_page_panel._on_shotline_released)
	mouse_drag_on_shotline.connect(screenplay_page_panel._on_shotline_dragged)

# ---------------- CONSTRUCT NODE ------------------------

func construct_shotline_node(shotline: Shotline) -> void:
	
	shotline_struct_reference = shotline

	var pages: Array[PageContent] = ScreenplayDocument.pages
	var current_page_index: int = EventStateManager.cur_page_idx

	var cur_start_uuid: String = shotline_struct_reference.start_uuid
	var cur_end_uuid: String = shotline_struct_reference.end_uuid

	var cur_start_page_line_indices: Vector2i
	var cur_end_page_line_indices: Vector2i
	
	for page: PageContent in pages:
		for line: FNLineGD in page.lines:
			if line.uuid == cur_start_uuid:
				cur_start_page_line_indices = Vector2i(pages.find(page), page.lines.find(line))
			elif line.uuid == cur_end_uuid:
				cur_end_page_line_indices = Vector2i(pages.find(page), page.lines.find(line))

	var shotline_start_page_idx: int = shotline_struct_reference.start_page_index
	var shotline_end_page_idx: int = shotline_struct_reference.end_page_index

	var last_mouse_x_pos: float = shotline_struct_reference.x_position

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
	for pageline: Node in EventStateManager.page_node.page_container.get_children():
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
	var screenplay_line_vertical_size: float = cur_pagelines[0].size.y

	# TODO: I don't know why the shotlines' vertical position is off by like 3 lines,
	# But it is and so, it needs the following offsets. Must investigate further.
	# However, I do like the effect of having there being 0.5x line height of
	# overhang for the start and end;
	var start_pos: Vector2 = Vector2(
		last_mouse_x_pos,
		local_start_label.global_position.y - .65 * shot_number_label.size.y
		)
	var end_pos: Vector2 = Vector2(
		last_mouse_x_pos,
		(local_end_label.global_position.y + local_end_label.size.y) - .65 * shot_number_label.size.y
		)

	var shotline_points: Array[Vector2] = [] # empty array to be filled by the following section

	# Get the start and end positions of each unfilmed (squiggle) section
	var unfilmed_sections_in_page: Array[PagelineSection] = []

	# TODO: too much copy-pasting here, extract the inner for loops into a single func 
	for section: PagelineSection in unfilmed_sections:
		print("looking for sections")

		var start_idx: Vector2i = shotline.get_fnline_index_from_uuid(section.start_index_uuid)
		var end_idx: Vector2i = shotline.get_fnline_index_from_uuid(section.end_index_uuid)
		
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
					section._end_position = label.global_position # + Vector2(0, screenplay_line_vertical_size)
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
					new_final_section._end_position = label.global_position # + Vector2(0, screenplay_line_vertical_size)
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

	for section: PagelineSection in unfilmed_sections_in_page:
		section.start_index = ScreenplayDocument.get_index_from_uuid(section.start_index_uuid)
		section.end_index = ScreenplayDocument.get_index_from_uuid(section.end_index_uuid)

	if starts_on_earlier_page:
		print("Shotline starts earlier")
		begin_cap_open = true
		begin_cap_grab_region.toggle_open_endcap(begin_cap_open)
	if ends_on_later_page:
		print("Shotline ends later")
		end_cap_open = true
		end_cap_grab_region.toggle_open_endcap(end_cap_open)

	true_start_pos = start_pos
	true_end_pos = end_pos
	#print("pageline end and start: ", local_end_label, " | ", local_start_label)
	shotline_length = absi(local_end_label.get_index() - local_start_label.get_index()) + 1

	#actually make the shotline length appropriate
	#1 . change the Line2D length of the segment
	#2. append

	update_line_color(ShotLinerColors.line_color)
	unfilmed_sections = unfilmed_sections_in_page
	cur_pageline_label_height = screenplay_line_vertical_size
	global_position = start_pos
	populate_shotline_with_segments(unfilmed_sections, shotline_length, cur_pageline_label_height)

func align_shot_number_label() -> void:
	#await get_tree().process_frame
	var x: float = true_start_pos.x
	var y: float = true_start_pos.y
	shot_number_label.position = Vector2(
		x - (0.5 * shot_number_label.get_rect().size.x),
		y - (shot_number_label.get_rect().size.y + 16)
		)

func align_grab_regions() -> void:
	#await get_tree().process_frame
	var line_length: float = true_end_pos.y - true_start_pos.y

	#line_body_grab_region.position = Vector2(
	#	true_start_pos.x - (0.5 * color_rect_width),
	#	true_start_pos.y
	#	)
	#line_body_grab_region.size = Vector2(
	#	color_rect_width,
	#	line_length
	#	)

	begin_cap_grab_region.position = Vector2(
		true_start_pos.x - (0.5 * color_rect_width),
		true_start_pos.y - (begin_cap_grab_region.size.y + cap_grab_region_vertical_position_offset)
		)
	begin_cap_grab_region.size = Vector2(
		color_rect_width,
		cap_grab_region_height
		)

	end_cap_grab_region.position = Vector2(
		true_start_pos.x - (0.5 * color_rect_width),
		true_end_pos.y - (begin_cap_grab_region.size.y - 0 * cap_grab_region_vertical_position_offset)
		)
	end_cap_grab_region.size = Vector2(
		color_rect_width,
		cap_grab_region_height
		)

func populate_shotline_with_segments(
	unfilmed_sections_in_page: Array[PagelineSection],
	total_shotline_length: int,
	line_label_height: float) -> void:

	if not segments_container:
		for child: Node in get_children():
			if child is VBoxContainer:
				segments_container = child
	
	var section_indices: Array = range(total_shotline_length)

	var unfilmed_indices: Array = []
	print("length: ", total_shotline_length)
	for section: PagelineSection in unfilmed_sections_in_page:
		for num: int in range(section.start_index.y, section.end_index.y + 1):
			unfilmed_indices.append(num)
	
	if section_indices == [0] or section_indices == []:
		print("Instantiating segment...")
		var new_segment: ShotLineSegment2D = shotline_segment_scene.instantiate()
		segments_container.add_child(new_segment)
		new_segment.set_segment_height(line_label_height)
		print("Instantiated segment.")
		return

	for idx: int in section_indices:
		var new_segment: ShotLineSegment2D = shotline_segment_scene.instantiate()
		segments_container.add_child(new_segment)
		
		if idx in unfilmed_sections_in_page:
			new_segment.set_straight_or_jagged(false)
		else:
			new_segment.set_straight_or_jagged(true)
		new_segment.set_segment_height(line_label_height)
		# if this index is also in the unfilmed indices, add a squiggle segment to the segment container
		# else, add a straight segment to the segment container
		# also the section indices needs to be offset, to start at the Shotline's actual starting index ?		

func update_line_width(width: float) -> void:
	for node: Node in get_children():
		if node is ShotLineSegment2D:
			node.line.width = width

func update_line_color(color: Color) -> void:
	for node: Node in get_children():
		if node is ShotLineSegment2D:
			node.line.color = color

func update_shot_number_label() -> void:
	if shotline_struct_reference.scene_number == null:
		print("funny null shot numbers")
		return
	var shotnumber_string: String = str(shotline_struct_reference.scene_number) + "." + str(shotline_struct_reference.shot_number) + "\n" + str(shotline_struct_reference.shot_type)
	shot_number_label.text = shotnumber_string

func resize_line_width_on_hover() -> void:
	if is_hovered_over:
		update_line_width(hover_line_width)
	else:
		update_line_width(line_width)

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

func update_page_line_indices_with_points(
	page_container_children: Array[Node],
	last_node_global_pos: Vector2) -> void:
	var pages: Array[PageContent] = ScreenplayDocument.pages
	var cur_page_idx: int = EventStateManager.cur_page_idx
	
	# if this is the middle of a multipage shotline, don't do anything to update the vertical 
	# position ;
	# Might change this behavior in the future
	if shotline_struct_reference.is_multiline():
		if (
			shotline_struct_reference.starts_on_earlier_page(cur_page_idx)
			&&shotline_struct_reference.ends_on_later_page(cur_page_idx)):
			return
	
	var cur_pageline_labels: Array[Node] = page_container_children
	var y_movement_delta: float = global_position.y - last_node_global_pos.y
	
	#var begin_point: Vector2 = shotline_node.points[0] + shotline_node.position
	#var end_point: Vector2 = shotline_node.points[1] + shotline_node.position

	var line_label_height: float
	var screenplay_line_offset: int

	var line_label_height_set: bool = false
	var new_start_point_set: bool = false
	var new_end_point_set: bool = false

	#var old_start_line_idx: int
	#var old_end_line_idx: int

	#print("Points of this particular shotline: ", begin_point, " | ", end_point)
	#print("Node position of this Shotline: ", shotline_node.global_position)

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
	
	#var start_page_lines: Array[FNLineGD] = pages[start_page_index].lines
	#for fnline: FNLineGD in start_page_lines:
		#if fnline.uuid == start_uuid:
			#old_start_line_idx = start_page_lines.find(fnline)
			#print("old_start: ", old_start_line_idx)

	#var end_page_lines: Array[FNLineGD] = pages[end_page_index].lines
	#for fnline: FNLineGD in end_page_lines:
	#	if fnline.uuid == end_uuid:
	#		old_end_line_idx = start_page_lines.find(fnline)
	#		print("old_end: ", old_end_line_idx)

	#var new_start_line_idx: int = old_start_line_idx + screenplay_line_offset
	#var new_end_line_idx: int = old_end_line_idx + screenplay_line_offset

	# figure out if the offsets point to a valid screenplay line in this array
	#var start_idx_page: PageContent = pages[start_page_index]
	#var end_idx_page: PageContent = pages[end_page_index]

	#print("Start / end line  indices", new_start_line_idx, " | ", new_end_line_idx)

	#if (new_start_line_idx >= 0)&&(new_start_line_idx < (start_idx_page.lines.size() - 1)):
		new_start_point_set = true

	#if (new_end_line_idx >= 0)&&(new_end_line_idx < (end_idx_page.lines.size() - 1)):
		new_end_point_set = true

	#if new_start_point_set&&new_end_point_set:
		#start_uuid = start_idx_page.lines[new_start_line_idx].uuid
		#end_uuid = end_idx_page.lines[new_end_line_idx].uuid
	#elif new_end_point_set:
		# TODO: Actually handle moving the shotline above or below the top or bottom margins

		# too high up;, move down
		# but what about multipage shotlines AAAUUUGGHHHHH
		pass
	#elif new_start_point_set:
		pass
		#too low: move up
	#else:
		#you fucked up bro lmao
		pass

# -------------LOCAL INPUT ------------------

func _on_line_body_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			update_line_width(click_width)
			mouse_clicked_on_shotline.emit(self, event.button_index)
		else:
			mouse_released_on_shotline.emit(self, event.button_index)
			resize_line_width_on_hover()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_drag_on_shotline.emit(self)
