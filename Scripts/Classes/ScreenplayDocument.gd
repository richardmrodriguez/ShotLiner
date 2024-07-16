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

# This merely splits an array of FNLineGDs into smaller arrays. 
# It then returns an array of those page arrays. This does not construct a ScreenplayPage object.
func split_fnline_array_into_page_groups(fnlines: Array) -> Array[PageContent]:
	var page_counter := 0
	var cur_pages: Array[PageContent] = []
	cur_pages.append(PageContent.new())

	for ln: FNLineGD in fnlines:
		if ln.string.begins_with("=="):
			page_counter += 1
			continue

		if (cur_pages.size() < page_counter + 1):
			cur_pages.append(PageContent.new())
			#print("uh oh stinky", cur_pages.size())
		
		if ln.fn_type.begins_with("Title") or ln.fn_type.begins_with("Sec"):
			continue
		var cur_page := cur_pages[- 1]
		if cur_page is PageContent:
			ln.uuid = EventStateManager.uuid_util.v4()
			cur_page.lines.append(ln)

	return cur_pages

func get_pdfline_from_uuid(uuid: String) -> PDFLineFN:
	var index: Vector2i = get_pdfline_vector_from_uuid(uuid)
	return pages[index.x].pdflines[index.y]

func get_pdfline_vector_from_uuid(uuid: String) -> Vector2i:
	for page: PageContent in pages:
		if page.pdflines:
			for line: PDFLineFN in page.pdflines:
				if line.LineUUID == uuid:
					return Vector2i(pages.find(page), page.lines.find(line))
	return Vector2i( - 1, 999) # a page will probably not ever have 999 lines on it...

func get_shotline_from_uuid(uuid: String) -> Shotline:
	for shotline: Shotline in shotlines:
		if shotline.shotline_uuid == uuid:
			return shotline
	return null

func get_array_of_fnlines_from_start_and_end_uuids(start: String, end: String) -> Array[FNLineGD]:
	var found_start: bool = false
	var found_end: bool = false

	var array: Array[FNLineGD] = []

	for page: PageContent in pages:
		if found_end:
			break
		
		for line: FNLineGD in page.lines:
			if line.uuid == start:
				found_start = true
			if not found_start:
				continue
			array.append(line)
			if line.uuid == end:
				found_end = true
				break
	
	return array