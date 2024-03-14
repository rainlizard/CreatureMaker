extends Control

func set_title(setStr):
	%Title.text = setStr

func set_panel_width(newWidth):
	%PanelContainer.size.x = newWidth
	%PanelContainer.position = -%PanelContainer.size/2.0

func set_dialog_text(setStr):
	%Label.text = setStr

func _on_button_pressed():
	queue_free()
