class_name ScreenplayDocument

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
