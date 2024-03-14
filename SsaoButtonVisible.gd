extends Button
@onready var oSsaoContainer = Nodelist.list["oSsaoContainer"]

func _ready():
	_on_toggled(button_pressed)

func _on_toggled(button_pressed):
	oSsaoContainer.visible = button_pressed
