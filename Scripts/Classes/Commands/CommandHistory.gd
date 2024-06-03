extends Node

#class_name CommandHistory

var history: Array[Command] = []
var command_index: int = 0
const max_size: int = 1000

func _ready() -> void:
	history.resize(max_size)

func add_command(command: Command) -> int:
	if not command:
		return - 1
	if not command.execute():
		return - 1
		
	while history.size() > max_size:
		history.pop_front()
	
	history[command_index] = command
	history.resize(command_index + 1)
	history.resize(max_size)
	if command_index < max_size:
		command_index += 1
	return 0

func undo() -> int:
	if command_index - 1 < 0:
		print("Not undoing...")
		return - 1
	command_index -= 1
	history[command_index].undo()
	return 0

func redo() -> int:
	if not history[command_index]:
		return - 1
	if command_index + 1 > max_size - 1:
		return - 1
	var command_to_redo: Command = history[command_index]
	command_to_redo.execute()
	command_index += 1
	return 0

func get_next_command() -> Command:
	if command_index + 1 < max_size:
		return history[command_index + 1]
	return null