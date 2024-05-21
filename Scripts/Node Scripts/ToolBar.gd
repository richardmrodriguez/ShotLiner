extends HBoxContainer

enum TOOLBAR_BUTTON {
	PREV_PAGE,
	NEXT_PAGE,
	DRAW,
	ERASER,
	SELECT_MOVE,
	SAVE_SHOTLINE_FILE,
	LOAD_SHOTLINE_FILE,
	OPEN_SCREENPLAY_FILE
}

signal toolbar_button_pressed(toolbar_button: TOOLBAR_BUTTON)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func _on_prev_pg_pressed() -> void:
	emit_signal("toolbar_button_pressed", TOOLBAR_BUTTON.PREV_PAGE)
func _on_next_pg_pressed() -> void:
	emit_signal("toolbar_button_pressed", TOOLBAR_BUTTON.NEXT_PAGE)

func _on_load_pressed() -> void:
	emit_signal("toolbar_button_pressed", TOOLBAR_BUTTON.LOAD_SHOTLINE_FILE)
func _on_save_pressed() -> void:
	emit_signal("toolbar_button_pressed", TOOLBAR_BUTTON.SAVE_SHOTLINE_FILE)

func _on_select_move_pressed() -> void:
	emit_signal("toolbar_button_pressed", TOOLBAR_BUTTON.SELECT_MOVE)

func _on_eraser_pressed() -> void:
	emit_signal("toolbar_button_pressed", TOOLBAR_BUTTON.ERASER)

func _on_draw_pressed() -> void:
	emit_signal("toolbar_button_pressed", TOOLBAR_BUTTON.DRAW)