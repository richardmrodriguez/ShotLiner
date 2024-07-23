extends Command

class_name ResizeShotlineCommand

var is_moved_from_topcap: bool

var y_drag_delta: float

var old_shotline_start_uuid: String
var old_shotline_end_uuid: String

var new_shotline_end_uuid: String
var new_shotline_start_uuid: String

var last_uuid_resized_from: String
var was_inverted: bool = false

var shotline_uuid: String

var new_start_end_set: bool = false

var old_segments: Dictionary = {}

func _init(_params: Array) -> void:
	is_moved_from_topcap = _params[0]
	var shotline: Shotline = _params[1]
	y_drag_delta = _params[2]

	old_shotline_start_uuid = shotline.start_uuid
	old_shotline_end_uuid = shotline.end_uuid

	shotline_uuid = shotline.shotline_uuid
	old_segments = shotline.segments_filmed_or_unfilmed.duplicate(true)

# FIXME: Keep track of the old dictionary of segments so that the filmed and unfilmed sections can be restored upon undo

func execute() -> bool:
	var shotline: Shotline = ScreenplayDocument.get_shotline_from_uuid(shotline_uuid)
	assert(shotline, "Shotline not found.")
	var uuid_to_resize_to: String = ""
	if new_start_end_set:
		if not was_inverted:
			if is_moved_from_topcap:
				uuid_to_resize_to = new_shotline_start_uuid
			else:
				uuid_to_resize_to = new_shotline_end_uuid
		else:
			if is_moved_from_topcap:
				uuid_to_resize_to = new_shotline_end_uuid
			else:
				uuid_to_resize_to = new_shotline_start_uuid
	shotline.shotline_node.update_length_from_endcap_drag(is_moved_from_topcap, y_drag_delta, uuid_to_resize_to)
	
	if not new_start_end_set:
		new_shotline_start_uuid = shotline.start_uuid
		new_shotline_end_uuid = shotline.end_uuid

		if new_shotline_start_uuid == old_shotline_start_uuid:
			last_uuid_resized_from = old_shotline_end_uuid
		elif new_shotline_end_uuid == old_shotline_start_uuid:
			was_inverted = true
			last_uuid_resized_from = old_shotline_end_uuid
			
		elif new_shotline_end_uuid == old_shotline_end_uuid:
			last_uuid_resized_from = old_shotline_start_uuid
		elif new_shotline_start_uuid == old_shotline_end_uuid:
			was_inverted = true
			last_uuid_resized_from = old_shotline_start_uuid

		new_start_end_set = true

	return true

func undo() -> bool:
	var shotline: Shotline = ScreenplayDocument.get_shotline_from_uuid(shotline_uuid)
	assert(shotline, "Shotline not found.")

	if not shotline.shotline_node: # WTF is this if block???
		# FIXME: This block is supposed to handle the case where resizing a shotline results in that shotline being
		# erased from the current page (i.e. resizing a multipage shotline so that it does not exist on this page)
		# But this seems probably very wrong; 
		shotline.start_uuid = old_shotline_start_uuid
		shotline.end_uuid = old_shotline_end_uuid

		var create_shotline_cmd: CreateShotLineCommand = CreateShotLineCommand.new([shotline])
		create_shotline_cmd.execute()
	else:
		var resized_maybe_inverted: bool = is_moved_from_topcap
		if was_inverted:
			resized_maybe_inverted = not resized_maybe_inverted

		shotline.segments_filmed_or_unfilmed = old_segments.duplicate(true)
		shotline.shotline_node.update_length_from_endcap_drag(resized_maybe_inverted, y_drag_delta, last_uuid_resized_from)
		#shotline.shotline_node.construct_shotline_node(shotline)
		
	return true
