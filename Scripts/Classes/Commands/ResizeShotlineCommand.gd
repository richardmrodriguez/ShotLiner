extends Command

class_name ResizeShotlineCommand

var is_moved_endcap_begincap: bool

var y_drag_delta: float

var old_shotline_start_uuid: String
var old_shotline_end_uuid: String

var old_start_page_idx: int
var old_end_page_idx: int

var shotline_uuid: String

func _init(_params: Array) -> void:
    is_moved_endcap_begincap = _params[0]
    var shotline: Shotline = _params[1]
    y_drag_delta = _params[2]

    old_shotline_start_uuid = shotline.start_uuid
    old_shotline_end_uuid = shotline.end_uuid
    old_start_page_idx = shotline.start_page_index
    old_end_page_idx = shotline.end_page_index

    shotline_uuid = shotline.shotline_uuid

func execute() -> bool:

    var shotline: Shotline = ScreenplayDocument.get_shotline_from_uuid(shotline_uuid)
    if shotline == null:
        return false
    shotline.shotline_node.update_length_from_endcap_drag(is_moved_endcap_begincap, y_drag_delta)
    return true

func undo() -> bool:
    var shotline: Shotline = ScreenplayDocument.get_shotline_from_uuid(shotline_uuid)
    if shotline == null:
        return false
    if not shotline.shotline_node:
        shotline.start_uuid = old_shotline_start_uuid
        shotline.end_uuid = old_shotline_end_uuid
        shotline.start_page_index = old_start_page_idx
        shotline.end_page_index = old_end_page_idx

        var create_shotline_cmd: CreateShotLineCommand = CreateShotLineCommand.new([shotline])
        create_shotline_cmd.execute()
    else:
        shotline.shotline_node.update_length_from_endcap_drag(is_moved_endcap_begincap, -y_drag_delta)
    return true