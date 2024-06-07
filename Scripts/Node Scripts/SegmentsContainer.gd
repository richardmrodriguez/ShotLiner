extends VBoxContainer

var last_hovered_segment: ShotLineSegment2D
var shotline_container: ShotLine2DContainer
#var counter: int = 0

signal on_hovered(segment: ShotLineSegment2D)

func _on_segment_hovered(segment: ShotLineSegment2D) -> void:
	if last_hovered_segment != segment:
		#counter = 0
		last_hovered_segment = segment
		on_hovered.emit(last_hovered_segment)
		print(segment.get_index())

	#
	#counter += 1

func _ready() -> void:
	shotline_container = get_parent()
	