extends Command

class_name ResizeShotlineCommand

var is_moved_endcap_begincap: bool

var y_drag_delta: float

var old_shotline_start_uuid: String
var old_shotline_end_uuid: String

var new_shotline_end_uuid: String
var new_shotline_start_uuid: String

var shotline_uuid: String

var new_start_end_set: bool = false

func _init(_params: Array) -> void:
	is_moved_endcap_begincap = _params[0]
	var shotline: Shotline = _params[1]
	y_drag_delta = _params[2]

	old_shotline_start_uuid = shotline.start_uuid
	old_shotline_end_uuid = shotline.end_uuid

	shotline_uuid = shotline.shotline_uuid

func execute() -> bool:
	var shotline: Shotline = ScreenplayDocument.get_shotline_from_uuid(shotline_uuid)
	if shotline == null:
		return false
	var uuid_to_resize_to: String = ""
	if new_start_end_set:
		if is_moved_endcap_begincap:
			uuid_to_resize_to = new_shotline_start_uuid
		else:
			uuid_to_resize_to = new_shotline_end_uuid
	shotline.shotline_node.update_length_from_endcap_drag(is_moved_endcap_begincap, y_drag_delta, uuid_to_resize_to)
	if not new_start_end_set:
		new_shotline_start_uuid = shotline.start_uuid
		new_shotline_end_uuid = shotline.end_uuid
		new_start_end_set = true

	return true

func undo() -> bool:
	var shotline: Shotline = ScreenplayDocument.get_shotline_from_uuid(shotline_uuid)
	if shotline == null:
		return false
	if not shotline.shotline_node: # WTF is this if block???
		# FIXME: This block is supposed to handle the case where resizing a shotline results in that shotline being
		# erased from the current page (i.e. resizing a multipage shotline so that it does not exist on this page)
		# But this seems probably very wrong; 
		shotline.start_uuid = old_shotline_start_uuid
		shotline.end_uuid = old_shotline_end_uuid

		var create_shotline_cmd: CreateShotLineCommand = CreateShotLineCommand.new([shotline])
		create_shotline_cmd.execute()
	else:
		var old_uuid: String = ""
		if is_moved_endcap_begincap:
			old_uuid = old_shotline_start_uuid
		else:
			old_uuid = old_shotline_end_uuid
			
		shotline.shotline_node.update_length_from_endcap_drag(is_moved_endcap_begincap, -y_drag_delta, old_uuid)
		
	return true
