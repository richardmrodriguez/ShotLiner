extends VBoxContainer

class_name ShotLine2DContainer

@onready var shot_number_label: Label = $ShotNumber
@onready var screenplay_page_panel: Panel = get_parent()
@onready var begin_cap_grab_region: ColorRect = %BeginCapGrabRegion
@onready var end_cap_grab_region: ColorRect = %EndCapGrabRegion
@onready var segments_container: VBoxContainer = %SegmentsContainer

@export var color_rect_width: float = 12
@export var click_width: float = 12
@export var hover_line_width: float = 10
@export var line_width: float = 4
@export var cap_grab_region_height: float = 6
@export var cap_grab_region_vertical_position_offset: float = 6

var line_is_hovered_over: bool = false
var last_hovered_segment: ShotLineSegment2D

var shotline_segment_scene: PackedScene = preload ("res://Components/ShotlineSegment2D.tscn")
var unfilmed_sections: Array = []
var shotline_length: int
var cur_pageline_label_height: float

var shotline_struct_reference: Shotline
var cap_line_width_offset: float = 8

var begin_cap_open: bool = false
var end_cap_open: bool = false

var true_start_pos: Vector2 = Vector2(0, 0)
var true_end_pos: Vector2 = Vector2(0, 0)

signal mouse_clicked_on_shotline(shotline2D: ShotLine2DContainer, button_index: int)
signal mouse_released_on_shotline(shotline2D: ShotLine2DContainer, button_index: int)

func _init() -> void:
	visible = false

func _ready() -> void:
	if visible == false:
		visible = true
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
	mouse_clicked_on_shotline.connect(EventStateManager._on_shotline_clicked)
	mouse_released_on_shotline.connect(EventStateManager._on_shotline_released)

func is_hovered_over() -> bool:
	for segment: Node in segments_container.get_children():
		if not segment is ShotLineSegment2D:
			continue
		if segment.is_hovered_over:
			return true
	return false

# ---------------- CONSTRUCT NODE ------------------------

func construct_shotline_node(shotline: Shotline) -> void:
	
	shotline_struct_reference = shotline

	var pages: Array[PageContent] = ScreenplayDocument.pages
	var current_page_index: int = EventStateManager.cur_page_idx
	var last_mouse_x_pos: float = shotline_struct_reference.x_position

	var cur_start_uuid: String = shotline_struct_reference.start_uuid
	var cur_end_uuid: String = shotline_struct_reference.end_uuid

	var cur_start_page_line_indices: Vector2i = ScreenplayDocument.get_fnline_index_from_uuid(cur_start_uuid)
	var cur_end_page_line_indices: Vector2i = ScreenplayDocument.get_fnline_index_from_uuid(cur_end_uuid)

	var shotline_start_page_idx: int = cur_start_page_line_indices.x
	var shotline_end_page_idx: int = cur_end_page_line_indices.x

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

	var debug_fnline_str: String = ScreenplayDocument.get_fnline_from_uuid(cur_end_uuid).string.substr(0, 10)
	print("end_fnline_uuid: ", cur_end_uuid, " | ", debug_fnline_str)
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
			print("local_end_label: ", local_end_label, " | ", local_end_label.fnline.string.substr(0, 10))
			
	elif starts_on_earlier_page and ends_on_later_page:
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
		local_start_label.global_position.y - (shot_number_label.size.y + 8)
		)
	var end_pos: Vector2 = Vector2(
		last_mouse_x_pos,
		(local_end_label.global_position.y + local_end_label.size.y) - (shot_number_label.size.y + 8)
		)

	var shotline_points: Array[Vector2] = [] # empty array to be filled by the following section

	# Get the start and end positions of each unfilmed (squiggle) section

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

	update_line_color(ShotLinerColors.line_color)

	cur_pageline_label_height = screenplay_line_vertical_size
	global_position = start_pos

	populate_shotline_with_segments(shotline_length, cur_pageline_label_height)

func align_shot_number_label() -> void:
	var x: float = true_start_pos.x
	var y: float = true_start_pos.y
	shot_number_label.position = Vector2(
		x - (0.5 * shot_number_label.size.x),
		y - (shot_number_label.size.y + 16)
		)

func align_grab_regions() -> void:
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

# TODO: Break this process into two parts: the segments_filmed dictionary population, and the Shotline2D segments population
# Basically, we don't reconstruct the existing shotline segments which have
func populate_shotline_with_segments(
	#unfilmed_pagelines: Array,
	total_shotline_length: int,
	line_label_height: float) -> void:

	if not segments_container:
		for child: Node in get_children():
			if child is VBoxContainer:
				segments_container = child

	for segment: Node in segments_container.get_children():
		segments_container.remove_child(segment)
		segment.queue_free()
	
	var section_indices: Array = range(total_shotline_length)
	# TODO: Fix the order of the god damn start and end indices when CREATING the shotline in the first place...
	var fnline_start_idx: Vector2i = ScreenplayDocument.get_fnline_index_from_uuid(shotline_struct_reference.start_uuid)
	var fnline_end_idx: Vector2i = ScreenplayDocument.get_fnline_index_from_uuid(shotline_struct_reference.end_uuid)

	var real_fnline_start_idx: Vector2i
	var real_fnline_end_idx: Vector2i
	if fnline_start_idx.x > fnline_end_idx.x:
		real_fnline_end_idx = fnline_start_idx
		real_fnline_start_idx = fnline_end_idx
	elif fnline_start_idx.x == fnline_end_idx.x:
		if fnline_start_idx.y > fnline_end_idx.y:
			real_fnline_end_idx = fnline_start_idx
			real_fnline_start_idx = fnline_end_idx
	else:
		real_fnline_end_idx = fnline_end_idx
		real_fnline_start_idx = fnline_start_idx

	print("Shotline start and end indicices: ", real_fnline_start_idx, " | ", real_fnline_end_idx)

	var fnline_uuids: Array[String] = []

	for page: PageContent in ScreenplayDocument.pages:
		for line: FNLineGD in page.lines:
			var cur_fnline_index: Vector2i = ScreenplayDocument.get_fnline_index_from_uuid(line.uuid)
			if cur_fnline_index.x == real_fnline_start_idx.x:
				if cur_fnline_index.y < real_fnline_start_idx.y:

					continue
			elif cur_fnline_index.x == real_fnline_end_idx.x:
				if cur_fnline_index.y > real_fnline_end_idx.y:
					break
			elif cur_fnline_index.x > real_fnline_end_idx.x:
				break
			fnline_uuids.append(line.uuid)

	for idx: int in section_indices:
		var new_segment: ShotLineSegment2D = shotline_segment_scene.instantiate()
		var cur_uuid_for_segment: String = fnline_uuids[idx]
		segments_container.add_child(new_segment)
		var shotline_start_index: Vector2i = ScreenplayDocument.get_fnline_index_from_uuid(
			shotline_struct_reference.start_uuid
		)
		#print("idx before: ", idx)
		#print("shotline_start_index.y: ", shotline_start_index.y)
		new_segment.pageline_uuid = fnline_uuids[idx]
		# TODO: This doesn't quite reconstruct an existing set of filmed or unfilmed segments
		
		if cur_uuid_for_segment in shotline_struct_reference.segments_filmed_or_unfilmed.keys():
			if shotline_struct_reference.segments_filmed_or_unfilmed[cur_uuid_for_segment] == false:
				new_segment.set_straight_or_jagged(false)
		else:
			new_segment.set_straight_or_jagged(true)
		
		#shotline_struct_reference.segments_filmed_or_unfilmed[new_segment.pageline_uuid] = new_segment.is_straight
		
		new_segment.set_segment_height(line_label_height)
		# if this index is also in the unfilmed indices, add a squiggle segment to the segment container
		# else, add a straight segment to the segment container
		# also the section indices needs to be offset, to start at the Shotline's actual starting index ?	
	
	#print(shotline_struct_reference.segments_filmed_or_unfilmed)

# ----------------- UPDATE NODE ---------------------
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
	if is_hovered_over():
		update_line_width(hover_line_width)
	else:
		update_line_width(line_width)

# TODO: If a shotline is resized such that it no longer starts or ends on the current page,
# It fails to construct. So we should do one of the following:
	# - Delete the SLContainer (and account for this in the ResizeShotlineCommand's undo function)
	# - 

func update_length_from_endcap_drag(
	is_endcap_begincap: bool,
	y_movement_delta: float
	) -> void:

	var pages: Array[PageContent] = ScreenplayDocument.pages
	var cur_page_idx: int = EventStateManager.cur_page_idx
	
	# if this is the middle of a multipage shotline, don't do anything to update the vertical 
	# position ;
	# Might change this behavior in the future
	if shotline_struct_reference.is_multipage():
		if (
			shotline_struct_reference.starts_on_earlier_page(cur_page_idx)
			&&shotline_struct_reference.ends_on_later_page(cur_page_idx)):
			return
	
	var cur_pageline_labels: Array[Node] = EventStateManager.page_node.page_container.get_children()

	#var y_movement_delta: float = EventStateManager.last_mouse_drag_delta.y

	var line_label_height: float
	var screenplay_line_offset: int

	var line_label_height_set: bool = false
	var new_start_point_set: bool = false
	var new_end_point_set: bool = false

	var old_start_fnline_uuid: String
	var old_end_fnline_uuid: String

	var old_start_2D_index: Vector2i
	var old_end_2D_index: Vector2i

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
	
	var start_page_lines: Array[FNLineGD] = pages[shotline_struct_reference.start_page_index].lines
	for fnline: FNLineGD in start_page_lines:
		if fnline.uuid == shotline_struct_reference.start_uuid:
			old_start_2D_index = Vector2i(
				shotline_struct_reference.start_page_index,
				start_page_lines.find(fnline))
			old_start_fnline_uuid = fnline.uuid

	var end_page_lines: Array[FNLineGD] = pages[shotline_struct_reference.end_page_index].lines
	for fnline: FNLineGD in end_page_lines:
		if fnline.uuid == shotline_struct_reference.end_uuid:
			old_end_2D_index = Vector2i(
				shotline_struct_reference.end_page_index,
				end_page_lines.find(fnline))
			old_end_fnline_uuid = fnline.uuid

	var new_start_2D_index: Vector2i = old_start_2D_index
	new_start_2D_index.y += screenplay_line_offset

	var new_end_2D_index: Vector2 = old_end_2D_index
	new_end_2D_index.y += screenplay_line_offset

	# This code assumes only EITHER  the start or end endcap is being dragged
	# Therefore, only change either the start or end index, not both

	var new_start_later: bool = shotline_struct_reference.starts_on_later_page(cur_page_idx)
	var new_start_earlier: bool = shotline_struct_reference.starts_on_earlier_page(cur_page_idx)
	var new_end_later: bool = shotline_struct_reference.ends_on_later_page(cur_page_idx)
	var new_end_earlier: bool = shotline_struct_reference.ends_on_earlier_page(cur_page_idx)

	if is_endcap_begincap:
		# figure out if the offsets point to a valid screenplay line in this page
			# If yes, then update the start or end uuid with that exact place
			# If no, then update the start or end uuid to:
				# the last line of the previous page or first line of the next page
		
		# NOTE: The following three vars and for loop is necessary because
			# I appear to have encountered a bug where the following line doesn't resolve properly:
			# if range(end_page_lines.size()).has(new_end_2D_index.y)
			# I don't knwo why, but trying that one liner just doesn;t work
			# the range seems to work when giving it explicit numbers, i.e. if range(10).has(5) == true
			# And if I PRINT THE VALUES of the variables, it should work:
			# print(new_end_2D_index.y) == 6 eg.
			# print(range(end_page_lines.size())) == [0, 1, 2, 3, 4, 5, 6, etc...]
			#so... I have no god damn idea why that might be failing.
			# I have got to figure out if / how to replicate it 
			# I should redownload this project and try it on a different operating system (windows, mac)
			# I should also try just a new blank project but using arbitrary variables
			# I also wonder if my gdscript warning settings being "stricter" are causing an issue
	
		var line_in_page: bool = false
		
		var start_page_line_size: int = start_page_lines.size()
		var start_page_range: Array = range(start_page_line_size)

		for n: int in start_page_range:
			if n == new_start_2D_index.y:
				line_in_page = true
				break
		
		if line_in_page:
			shotline_struct_reference.start_uuid = start_page_lines[new_start_2D_index.y].uuid
		else:
			if new_start_2D_index.y < 0:
				new_start_earlier = true
				if shotline_struct_reference.start_page_index - 1 < 0:
					shotline_struct_reference.start_uuid = (
					pages[shotline_struct_reference.start_page_index - 1].lines.back().uuid
					)
					shotline_struct_reference.start_page_index -= 1
				else:
					shotline_struct_reference.start_uuid = pages.front().lines.front().uuid
					shotline_struct_reference.start_page_index = 0
					if EventStateManager.cur_page_idx == 0:
						new_start_earlier = false
			else:
				new_start_later = true
				print("Begin cap after page")
				if shotline_struct_reference.start_page_index + 1 < pages.size():
					shotline_struct_reference.start_uuid = (
					pages[shotline_struct_reference.start_page_index + 1].lines.front().uuid
					)
					shotline_struct_reference.start_page_index += 1
				else:
					shotline_struct_reference.start_uuid = pages.back().lines.back().uuid
					shotline_struct_reference.start_page_index = pages.size() - 1
					if EventStateManager.cur_page_idx == pages.size() - 1:
						new_start_later = false

	elif not is_endcap_begincap:
		
		var line_in_page: bool = false

		var end_page_lines_size: int = end_page_lines.size()
		var end_page_line_range: Array = range(end_page_lines_size)
		
		for n: int in end_page_line_range:
			if n == new_end_2D_index.y:
				line_in_page = true
	
		if line_in_page:
			shotline_struct_reference.end_uuid = end_page_lines[new_end_2D_index.y].uuid
		else:
			if new_end_2D_index.y < 0:
				new_end_earlier = true
				if shotline_struct_reference.end_page_index - 1 >= 0:
					shotline_struct_reference.end_uuid = (
					pages[shotline_struct_reference.end_page_index - 1].lines.back().uuid
					)
					shotline_struct_reference.end_page_index -= 1
				else:
					shotline_struct_reference.end_uuid = pages.front().lines.front().uuid
					shotline_struct_reference.end_page_index = 0
					if EventStateManager.cur_page_idx == 0:
						new_end_earlier = false
			else:
				new_end_later = true
				if shotline_struct_reference.end_page_index + 1 < pages.size():
					shotline_struct_reference.end_uuid = (
					pages[shotline_struct_reference.end_page_index + 1].lines.front().uuid
					)
					shotline_struct_reference.end_page_index += 1
					print_debug(shotline_struct_reference.end_page_index)
				else:
					shotline_struct_reference.end_uuid = pages.back().lines.back().uuid
					shotline_struct_reference.end_page_index = pages.size() - 1
					if EventStateManager.cur_page_idx == pages.size() - 1:
						new_end_later = false
	
	# If the new shotline positions don't include this page, just delete this shotline node
	print(new_start_earlier, new_start_later, new_end_earlier, new_end_later)
	if (new_start_earlier and new_end_earlier) or (new_start_later and new_end_later):
			print_debug("Shotline not on page, removing....")
			queue_free()
			return
	# If the new shotline positions do include somewhere on this page, then reconstruct
	construct_shotline_node(shotline_struct_reference)

# ------------- SIGNAL CALLBACKS ----------------------

# -------------LOCAL INPUT ------------------

func _input(event: InputEvent) -> void:

	if event is InputEventMouseMotion:
		if is_hovered_over():
			if not line_is_hovered_over:
				line_is_hovered_over = true
		else:
			if line_is_hovered_over:
				line_is_hovered_over = false

	if event is InputEventMouseButton:
		if is_hovered_over():
			if event.button_index == MOUSE_BUTTON_LEFT:
				if event.pressed:
					mouse_clicked_on_shotline.emit(self, event.button_index)
				else:
					mouse_released_on_shotline.emit(self, event.button_index)
