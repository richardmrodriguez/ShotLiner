extends Command

class_name CreateShotLineCommand

var shotline_obj: Shotline
var shotline_uuid: String
var this_shotline_2D: ShotLine2DContainer
var page_panel: Node
var y_drag_delta: float
var prev_global_scene_num_nominal: String

func _init(_params: Array) -> void:
	shotline_obj = _params.front()
	page_panel = EventStateManager.page_node.page_panel
	shotline_uuid = shotline_obj.shotline_uuid
	prev_global_scene_num_nominal = EventStateManager.last_selected_scene_num_nominal
	#shotline_uuid = params.front().shotline_uuid

func execute() -> bool:
		
	# two steps:
	# 1. Add shotline object to shotlines array
	# 2. Add Shotline container to current page
	if not ScreenplayDocument.shotlines.has(shotline_obj):
		ScreenplayDocument.shotlines.append(shotline_obj)
	
	this_shotline_2D = shotline_obj.shotline_2D_scene.instantiate()
	page_panel.add_child(this_shotline_2D)
	this_shotline_2D.construct_shotline_node(shotline_obj)
	shotline_obj.shotline_node = this_shotline_2D
	EventStateManager.cur_selected_shotline = shotline_obj
	var scene_num_nominal: String = ScreenplayDocument.get_scene_num_from_global_line_idx(shotline_obj.get_start_idx())
	EventStateManager.last_selected_scene_num_nominal = scene_num_nominal
	shotline_obj.scene_number = EventStateManager.last_selected_scene_num_nominal
	# TODO: create a func in ScreenplayScene to get the current amount of shotlines that start
	# In a particular scene,
	# and especially the highest shot number of those shotlines
	#FIXME: 
	if EventStateManager.last_selected_scene_num_nominal != prev_global_scene_num_nominal:
		EventStateManager.last_shot_number = 1
	shotline_obj.shot_number = str(EventStateManager.last_shot_number)
	EventStateManager.last_shot_number += 1

	return true
	
func undo() -> bool:

	# to undo:
	# 1. get shotline container by uuid, queue free
	# 2. remove shotline obj from array by uuid
	if ScreenplayDocument.shotlines.has(shotline_obj):
		print("removing shotline node...")

		for shotline_container: Node in page_panel.get_children():
			if not shotline_container is ShotLine2DContainer:
				continue
			if shotline_container.shotline_obj.shotline_uuid == shotline_obj.shotline_uuid:
				page_panel.remove_child(shotline_container)
				shotline_container.queue_free()
		ScreenplayDocument.shotlines.erase(shotline_obj)

		return true
	return false
	#this_shotline_2D.queue_free()
