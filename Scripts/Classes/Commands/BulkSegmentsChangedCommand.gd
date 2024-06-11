extends Command

class_name BulkSegmentsChangedCommand

var prev_segments_state: Dictionary # shotline_uuid: {pageline_uuid: true/false} //// Nested Dictionary
var completed_cmds: Array[ToggleSegmentUnfilmedCommand] = []
var first_executed: bool = false

func _init(_params: Array) -> void:
    completed_cmds = _params.front()
    prev_segments_state = _params.back()

func execute() -> bool:
    if not (prev_segments_state or completed_cmds):
        return false
    # TODO: The array might be an empty array, the dict might be empty...etc
    if not first_executed:
        first_executed = true
        return true
    for cmd: ToggleSegmentUnfilmedCommand in completed_cmds:
        cmd.execute()
    return true

func undo() -> bool:
    if not (prev_segments_state or completed_cmds):
        print("uh on not undoing lmao!!!!!")
        return false

    for cmd: ToggleSegmentUnfilmedCommand in completed_cmds:
        cmd.undo()
    return true