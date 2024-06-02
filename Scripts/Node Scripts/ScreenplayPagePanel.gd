extends Panel

signal shotline_hovered_over(shotline_node: ShotLine2D)
signal shotline_clicked(shotline_node: ShotLine2D, button_index: int)
signal shotline_released(shotline_node: ShotLine2D, button_index: int)
signal shotline_mouse_drag(shotline_node: ShotLine2D)

@onready var page: Node = get_parent()

var last_hovered_shotline: ShotLine2D

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var children: Array[Node] = get_children()
		for shotline_node in children:
			if not shotline_node is ShotLine2D:
				continue
			#if shotline_node.line_body_grab_region.get_global_rect().has_point(get_global_mouse_position()):
			#	if shotline_node.is_hovered_over == false:
			#		shotline_node.is_hovered_over = true
			#		shotline_node.resize_on_hover()
			#		shotline_hovered_over.emit(shotline_node)
			else:
				if shotline_node.is_hovered_over == true:
					shotline_node.is_hovered_over = false
					shotline_node.resize_on_hover()
					shotline_hovered_over.emit(shotline_node)

func _on_shotline_clicked(shotline2D: ShotLine2D, button_index: int) -> void:
	shotline_clicked.emit(shotline2D, button_index)

func _on_shotline_released(shotline_node: ShotLine2D, button_index: int) -> void:
	shotline_released.emit(shotline_node, button_index)

func _on_shotline_dragged(shotline_node: ShotLine2D) -> void:
	shotline_mouse_drag.emit(shotline_node)
