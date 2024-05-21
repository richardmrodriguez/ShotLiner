extends Control

class_name TextInputField

@export var field_label: String
@export var field_placeholder: String
@export var field_text: String
@export var field_category: FIELD_CATEGORY

enum FIELD_TYPE {
	LINE,
	MULTILINE
}

enum FIELD_CATEGORY {
	SCENE_NUM,
	SHOT_NUM,
	SHOT_TYPE,
	SHOT_SUBTYPE,
	SETUP_NUM,
	GROUP,
	TAGS
}
@export var chosen_field_type: FIELD_TYPE

@onready var label: Label = $VBox/Label
@onready var line_edit: LineEdit = $VBox/LineEdit
@onready var vbox: VBoxContainer = $VBox

signal text_changed(text: String, field_category: FIELD_CATEGORY)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	focus_mode = Control.FOCUS_ALL
	label.focus_mode = Control.FOCUS_ALL
	label.text = field_label
	line_edit.text_changed.connect(field_text_changed)
	if chosen_field_type == FIELD_TYPE.MULTILINE:
		vbox.remove_child(line_edit)
		var textedit: TextEdit = TextEdit.new()
		textedit.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_MINSIZE)
		vbox.add_child(textedit)
		textedit.text = field_text
		textedit.custom_minimum_size = Vector2(0, 35)
		textedit.placeholder_text = field_placeholder
	else:
		line_edit.text = field_text
		line_edit.placeholder_text = field_placeholder

func _on_line_edit_gui_input(event: InputEvent) -> void:
	if event.is_released():
		if event is InputEventKey:
			if event.keycode == KEY_TAB:
				print("Tabbed")

func field_text_changed(new_text: String) -> void:
	text_changed.emit(new_text, field_category)

func focus_on_field() -> void:
	line_edit.grab_focus()

func set_text(text: String) -> void:
	line_edit.text = text

func get_text(text: String) -> String:
	return line_edit.text