extends Control

# font size is basically point size, where 1pt is 1px
#scaling is a bit weird, but the following block basically lets you get the proper scaling based on the font size
# prefer integer scaling, and simply place the text using integer positions (round off the floating point precision)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var label: Label = Label.new()
	add_child(label)
	label.text = "1234567890" # 10 characters wide is about 1 inch

	var fontsize: int = 24
	label.add_theme_font_size_override("font_size", fontsize)
	await get_tree().process_frame
	print("Font size: ", fontsize)
	print("Label size: ", label.get_global_rect())
	print("Document scale factor: ", roundi(label.get_global_rect().size.x / 72))
