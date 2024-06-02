class_name PagelineSection

var start_index_uuid: String
var end_index_uuid: String

var start_index: Vector2i
var end_index: Vector2i

## These positions are only updated when being drawn on a page, and should not be referenced otherwiese.
var _start_position: Vector2
var _end_position: Vector2