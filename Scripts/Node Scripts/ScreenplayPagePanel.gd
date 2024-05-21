extends Panel

signal shotline_hovered_over(shotline_idx: int)

var last_hovered_shotline: ShotLine2D
@onready var page: Node = get_parent()

signal shotline_clicked(shotline_node: ShotLine2D, button_index: int)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var children: Array[Node] = get_children()
		for shotline in children:
			if not shotline is ShotLine2D:
				continue
			if shotline.color_rect.get_global_rect().has_point(get_global_mouse_position()):
				if last_hovered_shotline != shotline:
					last_hovered_shotline = shotline
				print("Hovered over shotline from panel")

func _on_shotline_clicked(shotline2D: ShotLine2D, button_index: int) -> void:
	print(
		"Click detected in screenplay page panel | ",
		button_index,
		" | ",
		shotline2D.shotline_struct_idx
		)
	if button_index == 2:
		delete_shotline(shotline2D)
	
	shotline_clicked.emit(shotline2D, button_index)

func delete_shotline(shotline2D: ShotLine2D) -> void:
	var cur_shotlines_array: Array = page.shotlines_for_pages[page.current_page_number]
	cur_shotlines_array.remove_at(shotline2D.shotline_struct_idx)
	shotline2D.queue_free()