extends HBoxContainer

class_name ToolBar

enum TOOLBAR_BUTTON {
	PREV_PAGE,
	NEXT_PAGE,
	DRAW,
	DRAW_SQUIGGLE,
	ERASE,
	SELECT,
	MOVE,
	SAVE_SHOTLINE_FILE,
	LOAD_SHOTLINE_FILE,
	EXPORT_SPREADSHEET,
	OPEN_SCREENPLAY_FILE,
}

signal toolbar_button_pressed(toolbar_button: TOOLBAR_BUTTON)
signal layout_test_pressed(toggle: bool)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EventStateManager.toolbar_node = self

func _on_prev_pg_pressed() -> void:
	toolbar_button_pressed.emit(TOOLBAR_BUTTON.PREV_PAGE)
func _on_next_pg_pressed() -> void:
	toolbar_button_pressed.emit(TOOLBAR_BUTTON.NEXT_PAGE)

func _on_load_pressed() -> void:
	toolbar_button_pressed.emit(TOOLBAR_BUTTON.LOAD_SHOTLINE_FILE)
func _on_save_pressed() -> void:
	toolbar_button_pressed.emit(TOOLBAR_BUTTON.SAVE_SHOTLINE_FILE)

func _on_eraser_pressed() -> void:
	toolbar_button_pressed.emit(TOOLBAR_BUTTON.ERASE)

func _on_draw_pressed() -> void:
	toolbar_button_pressed.emit(TOOLBAR_BUTTON.DRAW)

func _on_export_pressed() -> void:
	toolbar_button_pressed.emit(TOOLBAR_BUTTON.EXPORT_SPREADSHEET)

func _on_move_pressed() -> void:
	toolbar_button_pressed.emit(TOOLBAR_BUTTON.MOVE)

func _on_test_layout_toggled(toggled_on: bool) -> void:
	layout_test_pressed.emit(toggled_on)

func _on_undo_pressed() -> void:
	CommandHistory.undo()

func _on_redo_pressed() -> void:
	CommandHistory.redo()
