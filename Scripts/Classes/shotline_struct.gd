class_name Shotline

var shotline_2D_scene := preload ("res://Components/ShotLine2DContainer.tscn")

var start_page_index: int
var end_page_index: int
var start_uuid: String
var end_uuid: String
var x_position: float

var segments_filmed_or_unfilmed: Dictionary = {} # fnlineuuid: is_filmed_bool

var shotline_node: ShotLine2DContainer
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

func is_multipage() -> bool:
	if start_page_index != end_page_index:
		return true
	return false

func starts_on_earlier_page(page_idx: int) -> bool:
	if start_page_index < page_idx:
		return true
	return false

func starts_on_later_page(page_idx: int) -> bool:
	if start_page_index > page_idx:
		return true
	return false
	
func ends_on_earlier_page(page_idx: int) -> bool:
	if end_page_index < page_idx:
		return true
	return false

func ends_on_later_page(page_idx: int) -> bool:
	if end_page_index > page_idx:
		return true
	return false

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

func get_fnline_index_from_uuid(uuid: String) -> Vector2i:
	for page: PageContent in ScreenplayDocument.pages:
		for line: FNLineGD in page.lines:
			if line.uuid == uuid:
				return Vector2i(
					ScreenplayDocument.pages.find(page),
					page.lines.find(line))
	return Vector2i()

func toggle_segment_filmed(segment_uuid: String, setting: bool) -> void:
	segments_filmed_or_unfilmed[segment_uuid] = setting
	#print(segments_filmed_or_unfilmed)