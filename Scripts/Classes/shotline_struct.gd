extends Node

class_name Shotline

var shotline_2D_scene := preload ("res://Components/ShotLine2D.tscn")

var visual_line: Line2D
var start_page_index: int
var end_page_index: int
var start_index: int
var end_index: int
var x_position: float

var unfilmed_sections: Array[Dictionary] # sections[index]["section_start"] = 14

var shotline_node: ShotLine2D
var shotline_uuid: String

# User - Facing Metadata
var scene_number: String
var shot_number: String
var shot_type: String
var shot_subtype: String
var setup_number: String
var group: String
var tags: String

var tags_as_arr: Array[String]

func print_self() -> void:
    pretty_print_properties(
        [scene_number,
        shot_number,
        shot_type,
        shot_subtype,
        setup_number,
        group,
        tags])
func pretty_print_properties(props: Array) -> void:
    for prop: Variant in props:
        print("- ", prop)

static func construct_shotline_node(
    shotline: Shotline,
    cur_screenplay_page_lines: Array,
    empty_shotline_2D: ShotLine2D
    ) -> ShotLine2D:
    var start_idx: int = shotline.start_index
    var end_idx: int = shotline.end_index
    var last_mouse_pos: float = shotline.x_position

    var real_start: int
    var real_end: int
    # This bit ensures that lines are always oriented to start at the top and end at the bottom
    if start_idx > end_idx:
        real_start = end_idx
        real_end = start_idx
    else:
        real_start = start_idx
        real_end = end_idx
    
    var screenplay_line_start: Label
    var screenplay_line_end: Label

    for spl: Label in cur_screenplay_page_lines:
        if spl is Label:
            if spl.line_index == real_start:
                screenplay_line_start = spl
                print("start line: ", spl.fnline.fn_type, " | ", spl.text, )
            if spl.line_index == real_end:
                screenplay_line_end = spl

    var screenplay_line_vertical_size: float = screenplay_line_start.get_rect().size.y

    # TODO: I don't know why the shotlines' vertical position is off by like 3 lines,
    # But it is and so, it needs the following offsets. Must investigate further.
    # However, I do like the effect of having there being 0.5x line height of
    # overhang for the start and end;
    var start_pos: Vector2 = Vector2(
        last_mouse_pos,
        screenplay_line_start.global_position.y - 4.5 * screenplay_line_vertical_size
        )
    var end_pos: Vector2 = Vector2(
        last_mouse_pos,
        screenplay_line_end.global_position.y - 3.5 * screenplay_line_vertical_size
        )

    print("Current shotline positions: ", start_pos.y, ", ", end_pos.y)

    var new_line2D: ShotLine2D = empty_shotline_2D
    new_line2D.shotline_struct_reference = shotline
    new_line2D.set_points([start_pos, end_pos])
    new_line2D.true_start_pos = start_pos
    new_line2D.true_end_pos = end_pos

    shotline.shotline_node = new_line2D

    return new_line2D