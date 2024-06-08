extends ColorRect

@onready var open_endcap: Node = %OpenEndCapLine2D
@onready var closed_endcap: Node = %ClosedEndCapLine2D

var is_open: bool = false

var cap_region_is_hovered_over: bool = false

func _ready() -> void:
	pass

func toggle_open_endcap(open_state: bool=false) -> void:
	if open_state:
		is_open = true

		open_endcap.visible = true
		closed_endcap.visible = false
	else:
		is_open = false
		open_endcap.visible = false
		closed_endcap.visible = true

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if get_global_rect().has_point(get_global_mouse_position()):
			cap_region_is_hovered_over = true
			color = ShotLinerColors.content_color
		else:
			cap_region_is_hovered_over = false
			color = Color.TRANSPARENT
	if event is InputEventMouseButton:
		if get_global_rect().has_point(get_global_mouse_position()):
			if event.button_index == MOUSE_BUTTON_LEFT:
				if event.is_pressed():
					print("Endcap clicked on")
