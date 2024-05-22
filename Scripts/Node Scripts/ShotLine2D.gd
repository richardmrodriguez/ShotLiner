extends Line2D

class_name ShotLine2D

var shotline_struct_reference: Shotline
@onready var shot_number_label: Label = $ShotNumber

@onready var screenplay_page_panel: Panel = get_parent()

@onready var color_rect: ColorRect = $ColorRect

signal mouse_clicked_on_shotline(shotline2D: ShotLine2D, button_index: int)
signal mouse_released_on_shotline(shotline2D: ShotLine2D, button_index: int)

# TODO: the color rect is a useful simple way to detect mouse movement, 
# and the Line2D can be used to create squiggly lines;
# This requires more functions that use the set_points function from the Line2D

func _ready() -> void:
    await align_mouse_detection_color_rect()
    await align_shot_number_label()
    update_shot_number_label()
    color_rect.color = Color.TRANSPARENT
    color_rect.gui_input.connect(_on_shape_input)
    mouse_clicked_on_shotline.connect(screenplay_page_panel._on_shotline_clicked)
    #mouse_released_on_shotline.connect(screenplay_page_panel._on_shotline_released)

func align_shot_number_label() -> void:
    await get_tree().process_frame
    var x: float = points[0].x
    var y: float = points[0].y
    shot_number_label.position = Vector2(
        x - (0.5 * shot_number_label.get_rect().size.x),
        y - shot_number_label.get_rect().size.y
        )

func align_mouse_detection_color_rect() -> void:
    await get_tree().process_frame
    var line_length: float = points[1].y - points[0].y
    color_rect.position = Vector2(points[0].x - (0.5 * width), points[0].y)
    color_rect.size = Vector2(width, line_length)

func update_shot_number_label() -> void:
    if shotline_struct_reference.scene_number == null:
        print("funny null shot numbers")
        return
    var shotnumber_string: String = str(shotline_struct_reference.scene_number) + "." + str(shotline_struct_reference.shot_number)
    shot_number_label.text = shotnumber_string

func _on_shape_input(event: InputEvent) -> void:
        
    if event is InputEventMouseButton:
        if event.pressed:
            mouse_clicked_on_shotline.emit(self, event.button_index)
