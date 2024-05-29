extends ColorRect

@onready var open_endcap: Node = %OpenEndCapLine2D
@onready var closed_endcap: Node = %ClosedEndCapLine2D

var is_open: bool = false

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
