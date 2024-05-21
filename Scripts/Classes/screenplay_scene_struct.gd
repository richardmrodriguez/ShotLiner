extends Node

class_name ScreenplayScene

var scene_num: String
var doc_start: Vector2i # Page number, line number
var doc_end: Vector2i # Page number, line number
var scene_location: String
var characters_in_scene: Array
var associated_tags: Array
var associated_shots: Array[Shotline]
var associated_setups: Array
