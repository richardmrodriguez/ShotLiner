extends Node

# TODO: Add support for more document wide metadata:
# - Scenes
# - Registered Tags
# - etc.

var document_name: String = ""
var characters: Array = [] # list of character names
var registered_tags: Array[String] = []

var pages: Array[PageContent] = []
var scenes: Array[ScreenplayScene] = []
var shotlines: Array[Shotline] = []

@onready var page_node: ScreenplayPage

# This Struct could also have some functions to retrieve data such as:
#   - How many Scenes or Shots contain a certain element:
#       - Character
#       - Prop
#       - Location 
func load_screenplay(filename: String) -> String:
	var file := FileAccess.open(filename, FileAccess.READ)
	var content := file.get_as_text()
	return content

func get_pages_from_pdfdocgd(pdf: PDFDocGD) -> Array[PageContent]:
	var pagearray: Array[PageContent] = []
	
	for page: PDFPage in pdf.PDFPages:
		var cur_page: PageContent = PageContent.new()
		for line: PDFLineFN in page.PDFLines:
			line.LineUUID = EventStateManager.uuid_util.v4()
			cur_page.pdflines.append(line)
		
		pagearray.append(cur_page)
	
	return pagearray

func get_pdfline_from_uuid(uuid: String) -> PDFLineFN:
	var index: Vector2i = get_pdfline_vector_from_uuid(uuid)
	return pages[index.x].pdflines[index.y]

func get_pdfline_vector_from_uuid(uuid: String) -> Vector2i:
	for page: PageContent in pages:
		if page.pdflines:
			for line: PDFLineFN in page.pdflines:
				if line.LineUUID == uuid:
					var result: Vector2i = Vector2i(pages.find(page), page.pdflines.find(line))
					assert((result.x != - 1 and result.y != - 1), "A - Could not find PDFLine Vector: " + str(result))
					return Vector2i(pages.find(page), page.pdflines.find(line))
	assert(false, "B - Could not find PDFLine Vector.")
	return Vector2i()

func get_shotline_from_uuid(uuid: String) -> Shotline:
	for shotline: Shotline in shotlines:
		if shotline.shotline_uuid == uuid:
			return shotline
	assert(false, "Could not find shotline with this UUID: " + uuid)
	return null

func get_array_of_pdflines_from_start_and_end_uuids(start: String, end: String) -> Array[PDFLineFN]:
	var found_start: bool = false
	var found_end: bool = false

	var array: Array[PDFLineFN] = []

	for page: PageContent in pages:
		if found_end:
			break
		
		for line: PDFLineFN in page.pdflines:
			if line.LineUUID == start:
				found_start = true
			if not found_start:
				continue
			array.append(line)
			if line.LineUUID == end:
				found_end = true
				break
	
	return array
