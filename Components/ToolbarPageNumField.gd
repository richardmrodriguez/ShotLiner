extends LineEdit

var last_valid_page_num: String = ""

func _ready() -> void:
	EventStateManager.toolbar_page_num_field = self
	text_submitted.connect(EventStateManager._on_page_num_field_entered)

func update_text(new_text: String) -> void:
	#TODO: Add some actual gatekeeping;
	# only update the text and change the page number

	# if the new text is a correct nominal page number
	#or, if its' close, choose the closest number
	#i.e. page 6 was deleted, but the user enters page 6, it will go to page 5 instead
	# Or of 6A or 6B exists, go to that page instead
	var valid: bool = true
	if valid:
		text = new_text
	else:
		text = last_valid_page_num