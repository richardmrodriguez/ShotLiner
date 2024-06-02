extends ColorRect

class_name ShotLineSegment2D

@onready var straight_line: Line2D = %StraightLine2D
@onready var jagged_line: Line2D = %JaggedLine2D

func _ready() -> void:
    jagged_line.visible = false