extends Panel

signal shotline_hovered_over(shotline_idx: int)

var last_hovered_shotline: ShotLine2D
@onready var page: Node = get_parent()

signal shotline_clicked(shotline_node: ShotLine2D, button_index: int)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var children: Array[Node] = get_children()
		for shotline_node in children:
			if not shotline_node is ShotLine2D:
				continue
			if shotline_node.line_body_grab_region.get_global_rect().has_point(get_global_mouse_position()):
				if shotline_node.is_hovered_over == false:
					shotline_node.is_hovered_over = true
					shotline_node.resize_on_hover()
			else:
				if shotline_node.is_hovered_over == true:
					shotline_node.is_hovered_over = false
					shotline_node.resize_on_hover()

func _on_shotline_clicked(shotline2D: ShotLine2D, button_index: int) -> void:
	
	shotline_clicked.emit(shotline2D, button_index)

func delete_shotline(shotline2D: ShotLine2D, cur_shotlines_array: Array) -> void:
	#var cur_shotlines_array: Array = page.shotlines_for_pages[page.current_page_number]
	for sl: Node in cur_shotlines_array:
		if not sl is Shotline:
			continue
		if sl.shotline_uuid == shotline2D.shotline_struct_reference.shotline_uuid:

			cur_shotlines_array.erase(sl)
			break
	shotline2D.queue_free()
