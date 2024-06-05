extends ColorRect

class_name ShotLineSegment2D

@onready var straight_line: Node
@onready var jagged_line: Node

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_PASS
	straight_line = $StraightLine2D
	jagged_line = $JaggedLine2D
	set_straight_or_jagged(true)
	#color = Color.YELLOW

func set_straight_or_jagged(straight: bool) -> void:
	if straight:
		straight_line.visible = true
		jagged_line.visible = false
	else:
		straight_line.visible = false
		jagged_line.visible = true

func set_segment_height(height: float) -> void:
	custom_minimum_size = Vector2(size.x, height)
	straight_line.set_points(PackedVector2Array(
		[
			Vector2(0, 0),
			Vector2(0, height)
		]
		)
	)
	jagged_line.scale = Vector2(1, 100 / height)