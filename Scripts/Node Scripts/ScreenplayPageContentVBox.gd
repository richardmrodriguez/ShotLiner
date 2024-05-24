extends VBoxContainer
var last_line_uuid: String = ""
signal screenplay_line_hovered_over(last_line_uuid: String)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var children := get_children()
		for screenplay_line in children:
			if screenplay_line is Label:
				if screenplay_line.get_global_rect().has_point(event.global_position):
					for subchild in screenplay_line.get_children():
						subchild.visible = true
					var cur_child_uuid: String = screenplay_line.fnline.uuid
					if last_line_uuid != cur_child_uuid:
						last_line_uuid = cur_child_uuid
						screenplay_line_hovered_over.emit(cur_child_uuid)
						#print(screenplay_line.get_index(), "   ", screenplay_line.fnline.fn_type)
				else:
					for subchild in screenplay_line.get_children():
						screenplay_line.get_child(0).visible = false
