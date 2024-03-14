extends Button
@onready var oHelpWindow = Nodelist.list["oHelpWindow"]

func _on_pressed():
	oHelpWindow.popup_centered()
