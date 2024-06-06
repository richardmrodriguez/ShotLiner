extends Command

class_name ToggleSegmentUnfilmedCommand

var last_unfilmed_state: bool
var pageline_uuid: String
var shotline_uuid: String
# TODO: Actually save the indices of unfilmed segments in the shotline struct

func _init(_params: Array) -> void:
	var segment: ShotLineSegment2D = _params.front()
	pageline_uuid = segment.pageline_uuid
	shotline_uuid = segment.shotline_container.shotline_struct_reference.shotline_uuid
	last_unfilmed_state = segment.is_straight

func execute() -> bool:
	var shotline_cont: ShotLine2DContainer = get_shotline_from_uuid(shotline_uuid)
	var segment: ShotLineSegment2D = get_current_segment_from_pageline_uuid(pageline_uuid, shotline_cont)
	
	segment.shotline_container.shotline_struct_reference.toggle_segment_filmed(segment.pageline_uuid, !last_unfilmed_state)
	segment.is_straight = !last_unfilmed_state
	segment.set_straight_or_jagged(!last_unfilmed_state)
	#print(segment.shotline_container.shotline_struct_reference.segments_filmed_or_unfilmed)
	return true

func undo() -> bool:
	var shotline_cont: ShotLine2DContainer = get_shotline_from_uuid(shotline_uuid)
	var segment: ShotLineSegment2D = get_current_segment_from_pageline_uuid(pageline_uuid, shotline_cont)
	
	segment.shotline_container.shotline_struct_reference.toggle_segment_filmed(segment.pageline_uuid, last_unfilmed_state)
	segment.is_straight = last_unfilmed_state
	segment.set_straight_or_jagged(last_unfilmed_state)
	return true

func get_shotline_from_uuid(shotline_id: String) -> ShotLine2DContainer:
	var page_panel: Node = EventStateManager.page_node.page_panel
	for child: Node in page_panel.get_children():
		if not child is ShotLine2DContainer:
			continue
		if child.shotline_struct_reference.shotline_uuid == shotline_id:
			return child
	return null

func get_current_segment_from_pageline_uuid(pageline_id: String, shotline_container: ShotLine2DContainer) -> ShotLineSegment2D:
	var segments_container: VBoxContainer = shotline_container.segments_container
	for child: Node in segments_container.get_children():
		if not child is ShotLineSegment2D:
			continue
		if child.pageline_uuid == pageline_id:
			return child
	
	return null
