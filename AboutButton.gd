extends Button
@onready var oAboutWindow = Nodelist.list["oAboutWindow"]

func _on_pressed():
	oAboutWindow.popup_centered()
