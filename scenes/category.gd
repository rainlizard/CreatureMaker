@tool
extends VBoxContainer

@export var set_text:String:
	set(val):
		$Label.text = val
		set_text = val
	get:
		return set_text
