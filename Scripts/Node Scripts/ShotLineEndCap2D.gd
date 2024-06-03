extends Line2D

class_name ShotLineEndCap2D

@export var shotline: ShotLine2DContainer

var cap_line_width_offset: float = 8
var cap_line_height_offset: float = 10

enum ENDCAP_TYPE {
	FLAT,
	CONTINUED,
}

func set_endcap_points(start_point: Vector2, endcap_type: ENDCAP_TYPE) -> void:
	var left_end: Vector2 = Vector2(start_point.x - cap_line_width_offset, 0)
	var right_end: Vector2 = Vector2(start_point.x + cap_line_width_offset, 0)
	var middle_point: Vector2 = Vector2(0, cap_line_height_offset)
	set_points([middle_point, left_end, middle_point, right_end])

func _ready() -> void:
	width = 4
	