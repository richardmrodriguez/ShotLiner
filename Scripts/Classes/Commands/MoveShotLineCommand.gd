extends Command

class_name MoveShotLineCommand

var shotline_uuid: String
var prev_x_position: float
var new_x_position: float
var prev_global_pos: Vector2

func _init(_params: Array) -> void:
    var shotline: Shotline = _params.front()
    shotline_uuid = shotline.shotline_uuid
    new_x_position = _params.back()
    prev_x_position = shotline.x_position

func execute() -> bool:
    for sl in ScreenplayDocument.shotlines:
        if sl.shotline_uuid == shotline_uuid:
            sl.x_position = new_x_position
            sl.shotline_node.global_position = Vector2(sl.x_position, sl.shotline_node.global_position.y)
            return true
    print("bruh")
    return false

func undo() -> bool:
    for sl in ScreenplayDocument.shotlines:
        if sl.shotline_uuid == shotline_uuid:
            sl.x_position = prev_x_position
            sl.shotline_node.global_position = Vector2(sl.x_position, sl.shotline_node.global_position.y)

            return true

    return false