extends Control

var offset = Vector2(16,8)#-35)
var displayTimer = 0

func _ready():
	visible = false

func _process(_delta):
	if visible == true:
		global_position = get_global_mouse_position() + offset

#func _process(delta):
#	if displayTimer > 0:
#		visible = true
#		displayTimer -= delta
#		global_position = get_global_mouse_position() + offset
#	else:
#		visible = false

func set_text(txt):
	#print(txt)
	#displayTimer = 0.01 # Time
	$PanelContainer/HBoxContainer/Label.text = txt
	if txt == "":
		visible = false
	else:
		visible = true

func get_text():
	return $PanelContainer/HBoxContainer/Label.text
