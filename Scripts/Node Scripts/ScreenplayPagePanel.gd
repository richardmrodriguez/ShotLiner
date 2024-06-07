extends Panel

signal shotline_hovered_over(shotline_node: ShotLine2DContainer)
signal shotline_clicked(shotline_node: ShotLine2DContainer, button_index: int)
signal shotline_released(shotline_node: ShotLine2DContainer, button_index: int)
signal shotline_mouse_drag(shotline_node: ShotLine2DContainer)

@onready var page: Node = get_parent()

var last_hovered_shotline: ShotLine2DContainer
