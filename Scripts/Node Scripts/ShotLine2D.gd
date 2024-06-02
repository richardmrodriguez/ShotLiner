extends VBoxContainer

class_name ShotLine2D

@onready var shot_number_label: Label = $ShotNumber
@onready var screenplay_page_panel: Panel = get_parent()
#@onready var line_body_grab_region: ColorRect = $ColorRect
@onready var begin_cap_grab_region: ColorRect = %BeginCapGrabRegion
@onready var end_cap_grab_region: ColorRect = %EndCapGrabRegion
@onready var segments_container: VBoxContainer = %SegmentsContainer
@onready var shotline_segment_scene: PackedScene = preload ("res://Components/ShotlineSegment2D.tscn")

@export var color_rect_width: float = 12
@export var click_width: float = 12
@export var hover_line_width: float = 10
@export var line_width: float = 4
@export var cap_grab_region_height: float = 6
@export var cap_grab_region_vertical_position_offset: float = 6

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

signal mouse_clicked_on_shotline(shotline2D: ShotLine2D, button_index: int)
signal mouse_released_on_shotline(shotline2D: ShotLine2D, button_index: int)
signal mouse_drag_on_shotline(shotline_node: ShotLine2D)

func _init() -> void:
	visible = false

func _ready() -> void:
	#line_body_grab_region.mouse_filter = Control.MOUSE_FILTER_PASS
	begin_cap_grab_region.mouse_filter = Control.MOUSE_FILTER_PASS
	end_cap_grab_region.mouse_filter = Control.MOUSE_FILTER_PASS

	if begin_cap_open:
		begin_cap_grab_region.toggle_open_endcap(true)
	if end_cap_open:
		end_cap_grab_region.toggle_open_endcap(true)

	await get_tree().process_frame
	if visible == false:
		visible = true
	
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

	populate_shotline_with_segments(
		unfilmed_sections,
		shotline_length,
		cur_pageline_label_height)

	#end_cap_mode = Line2D.LINE_CAP_BOX
	#begin_cap_mode = Line2D.LINE_CAP_BOX
	#line_body_grab_region.color = Color.TRANSPARENT
	begin_cap_grab_region.color = Color.TRANSPARENT
	end_cap_grab_region.color = Color.TRANSPARENT
	#line_body_grab_region.gui_input.connect(_on_line_body_gui_input)
	mouse_clicked_on_shotline.connect(screenplay_page_panel._on_shotline_clicked)
	mouse_released_on_shotline.connect(screenplay_page_panel._on_shotline_released)
	mouse_drag_on_shotline.connect(screenplay_page_panel._on_shotline_dragged)

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

func resize_on_hover() -> void:
	if is_hovered_over:
		update_line_width(hover_line_width)
	else:
		update_line_width(line_width)

func populate_shotline_with_segments(
	unfilmed_sections: Array[PagelineSection],
	total_shotline_length: int,
	line_label_height: float) -> void:
	
	var section_indices: Array = range(total_shotline_length)
	var unfilmed_indices: Array = []
	print("length: ", total_shotline_length)
	for section: PagelineSection in unfilmed_sections:
		for num: int in range(section.start_index.y, section.end_index.y + 1):
			unfilmed_indices.append(num)
	
	for idx: int in section_indices:
		if idx in unfilmed_sections:
			var new_squiggle_segment: ShotLineSegment2D = shotline_segment_scene.instantiate()
			segments_container.add_child(new_squiggle_segment)
		else:
			var new_segment: ShotLineSegment2D = shotline_segment_scene.instantiate()
			#await get_tree().process_frame
			if segments_container:
				segments_container.add_child(new_segment)
		# if this index is also in the unfilmed indices, add a squiggle segment to the segment container
		# else, add a straight segment to the segment container
		# also the section indices needs to be offset, to start at the Shotline's actual starting index ?

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

func _on_line_body_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			update_line_width(click_width)
			mouse_clicked_on_shotline.emit(self, event.button_index)
		else:
			mouse_released_on_shotline.emit(self, event.button_index)
			resize_on_hover()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_drag_on_shotline.emit(self)
