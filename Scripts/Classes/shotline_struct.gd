extends Node

class_name Shotline

var visual_line: Line2D
var start_index: int
var end_index: int
var x_position: float

var unfilmed_sections: Array[Dictionary] # sections[index]["section_start"] = 14

var shotline_node: ShotLine2D

var shotline_uuid: String

# Metadata
var scene_number: String
var shot_number: String
var shot_type: String
var shot_subtype: String
var setup_number: String
var group: String
var tags: String

var _tags_as_arr: Array[String]

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
