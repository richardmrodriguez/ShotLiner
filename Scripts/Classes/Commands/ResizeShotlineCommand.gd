extends Command

var old_shotline_start_uuid: String
var old_shotline_end_uuid: String

var new_shotline_start_uuid: String
var new_shotline_end_uuid: String

var shotline_uuid: String

func execute() -> bool:
    return false

func undo() -> bool:
    return true