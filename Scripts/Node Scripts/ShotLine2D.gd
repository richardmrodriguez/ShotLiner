extends Line2D

class_name ShotLine2D

@onready var shot_number_label: Label = $ShotNumber
@onready var screenplay_page_panel: Panel = get_parent()
@onready var line_body_grab_region: ColorRect = $ColorRect
@onready var begin_cap_grab_region: ColorRect = %BeginCapGrabRegion
@onready var end_cap_grab_region: ColorRect = %EndCapGrabRegion

@export var color_rect_width: float = 12
@export var click_width: float = 12
@export var hover_line_width: float = 10
@export var line_width: float = 4
@export var cap_grab_region_height: float = 6

var shotline_struct_reference: Shotline
var is_hovered_over: bool = false
var cap_line_width_offset: float = 8

var true_start_pos: Vector2 = Vector2(0, 0)
var true_end_pos: Vector2 = Vector2(0, 0)

signal mouse_clicked_on_shotline(shotline2D: ShotLine2D, button_index: int)
signal mouse_released_on_shotline(shotline2D: ShotLine2D, button_index: int)
signal mouse_drag_on_shotline(shotline_node: ShotLine2D)

func _init() -> void:
	visible = false

func _ready() -> void:
	await get_tree().process_frame
	if visible == false:
		visible = true
	align_grab_regions()
	align_shot_number_label()
	update_shot_number_label()
	width = line_width

	begin_cap_grab_region.get_child(0).default_color = Color.SEA_GREEN
	end_cap_grab_region.get_child(0).default_color = Color.SEA_GREEN

	#end_cap_mode = Line2D.LINE_CAP_BOX
	#begin_cap_mode = Line2D.LINE_CAP_BOX
	line_body_grab_region.color = Color.TRANSPARENT
	begin_cap_grab_region.color = Color.TRANSPARENT
	end_cap_grab_region.color = Color.TRANSPARENT
	line_body_grab_region.gui_input.connect(_on_line_body_gui_input)
	mouse_clicked_on_shotline.connect(screenplay_page_panel._on_shotline_clicked)
	mouse_released_on_shotline.connect(screenplay_page_panel._on_shotline_released)
	mouse_drag_on_shotline.connect(screenplay_page_panel._on_shotline_dragged)

func get_begin_cap_points(start_point: Vector2) -> Array[Vector2]:
	var left_end: Vector2 = Vector2(start_point.x - cap_line_width_offset, start_point.y)
	var right_end: Vector2 = Vector2(start_point.x + cap_line_width_offset, start_point.y)

	return [left_end, right_end, start_point]

func get_end_cap_points(end_point: Vector2) -> Array[Vector2]:
	var left_end: Vector2 = Vector2(end_point.x - cap_line_width_offset, end_point.y)
	var right_end: Vector2 = Vector2(end_point.x + cap_line_width_offset, end_point.y)

	return [end_point, left_end, right_end]

func align_shot_number_label() -> void:
	#await get_tree().process_frame
	var x: float = true_start_pos.x
	var y: float = true_start_pos.y
	shot_number_label.position = Vector2(
		x - (0.5 * shot_number_label.get_rect().size.x),
		y - (shot_number_label.get_rect().size.y + 8)
		)

func align_grab_regions() -> void:
	#await get_tree().process_frame
	var line_length: float = true_end_pos.y - true_start_pos.y

	line_body_grab_region.position = Vector2(
		true_start_pos.x - (0.5 * color_rect_width),
		true_start_pos.y
		)
	line_body_grab_region.size = Vector2(
		color_rect_width,
		line_length
		)

	begin_cap_grab_region.position = Vector2(
		true_start_pos.x - (0.5 * color_rect_width),
		true_start_pos.y - (begin_cap_grab_region.size.y)
		)
	begin_cap_grab_region.size = Vector2(
		color_rect_width,
		cap_grab_region_height
		)

	end_cap_grab_region.position = Vector2(
		true_start_pos.x - (0.5 * color_rect_width),
		true_end_pos.y - (begin_cap_grab_region.size.y)
		)
	end_cap_grab_region.size = Vector2(
		color_rect_width,
        cap_grab_region_height
		)

func update_shot_number_label() -> void:
	if shotline_struct_reference.scene_number == null:
		print("funny null shot numbers")
		return
	var shotnumber_string: String = str(shotline_struct_reference.scene_number) + "." + str(shotline_struct_reference.shot_number)
	shot_number_label.text = shotnumber_string

func resize_on_hover() -> void:
	if is_hovered_over:
		width = hover_line_width
	else:
		width = line_width

func _on_line_body_gui_input(event: InputEvent) -> void:
		
	if event is InputEventMouseButton:
		if event.pressed:
			width = click_width
			mouse_clicked_on_shotline.emit(self, event.button_index)
		else:
			mouse_released_on_shotline.emit(self, event.button_index)
			resize_on_hover()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_drag_on_shotline.emit(self)
		#print("please god help me")
		#if is_dragging_shotline:
		#	print(cur_selected_shotline.shotline_node.global_position)
		#	cur_selected_shotline.shotline_node.global_position = (
		#		cur_mouse_global_position_delta + get_global_mouse_position()
		#	)
