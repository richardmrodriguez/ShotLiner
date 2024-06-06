extends VBoxContainer

var last_hovered_segment: ShotLineSegment2D
#var counter: int = 0

func _on_segment_hovered(segment: ShotLineSegment2D) -> void:
	if last_hovered_segment != segment:
		#counter = 0
		last_hovered_segment = segment
		#print(segment.get_index(), " | ", counter)
	#
	#counter += 1