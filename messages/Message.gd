extends Control
@onready var oUiMessages = Nodelist.list["oUiMessages"]

var scnQuickMsg = preload('res://messages/QuickMsgInstance.tscn')
var scnBigMsg = preload('res://messages/BigMessageInstance.tscn')

func quick(string):
	var id = scnQuickMsg.instantiate()
	id.show_then_fade(string)
	$VBoxContainer.add_child(id)

func big(windowTitle,dialogText):
	var id = scnBigMsg.instantiate()
	oUiMessages.add_child(id)
	id.set_title(windowTitle)
	id.set_dialog_text(dialogText)
	
	# Don't go smaller than 250 pixels wide
	# For longer lines, put message checked two lines
	var newWidth = (dialogText.length()*20) * 0.5
	newWidth = clamp(newWidth, 300, 1280)
	id.set_panel_width(newWidth)




func rising_text(txt,txtColour,pos):
	var scene = preload('res://messages/RisingText.tscn')
	var id = scene.instantiate()
	id.text = txt
	id.position = pos
	id.set("theme_override_colors/font_color",txtColour)
	oUiMessages.add_child(id)
	
	var tween = get_tree().create_tween()
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(id, "position", Vector2(id.position.x,id.position.y-80), 1.5)
	
	var tweenFade = get_tree().create_tween()
	tweenFade.set_trans(Tween.TRANS_QUINT)
	tweenFade.set_ease(Tween.EASE_OUT)
	tweenFade.tween_property(id, "modulate", Color(1,1,1,1), 1.0)
	tweenFade.tween_property(id, "modulate", Color(1,1,1,0), 0.5)
	tween.tween_callback(id.queue_free)
