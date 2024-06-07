extends Node

# TODO: This struct handles DOCUMENT-WIDE data such as:
# - All Pages
# - Scenes
# - Registered Tags
# - etc.

var document_name: String
var characters: Array # list of character names
var registered_tags: Array[String]

var pages: Array[PageContent]
var scenes: Array[ScreenplayScene]
var shotlines: Array[Shotline]

@onready var page_node: ScreenplayPage
# TODO: Shotlines can span multiple pages, so their data structs need to be stored on a document level;
# When rendering a new page, it must check if a shotline is "partial" 
#   - if it only begins, only ends, or spans through the entirety of a page,
#   the Shotline2D should render for the appropriate amound which a line covers
# When creating a new shotline, dragging the Shotline past the first or last Documentline make it a "partial" or multipage Shotline

# This Struct could also have some functions to retrieve data such as:
#   - How many Scenes or Shots contain a certain element:
#       - Character
#       - Prop
#       - Location 
func load_screenplay(filename: String) -> String:
	var file := FileAccess.open(filename, FileAccess.READ)
	var content := file.get_as_text()
	return content

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

func get_fnline_index_from_uuid(uuid: String) -> Vector2i:
	for page: PageContent in pages:
		for line: FNLineGD in page.lines:
			if line.uuid == uuid:
				return Vector2i(pages.find(page), page.lines.find(line))
	return Vector2i(0, 999) # a page will probably not ever have 999 lines on it...