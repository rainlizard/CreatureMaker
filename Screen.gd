extends Node
@onready var oSetScreenScale = Nodelist.list["oSetScreenScale"]


var baseSize = Vector2(2560, 1440)

var SCREEN_SCALE : float = 1.00:
	set(val):
		SCREEN_SCALE = val
		if val > 0:
			get_viewport().size_changed.disconnect(_on_screen_resized)
			get_viewport().content_scale_factor = val
			get_viewport().size_changed.connect(_on_screen_resized)
			print("Screen scale: " + str(val))
	get:
		return SCREEN_SCALE


func _enter_tree():
	var defaultWindowScreenPercent = Vector2(0.90, 0.90)
	if OS.has_feature("standalone") == true:
		defaultWindowScreenPercent = Vector2(0.90, 0.90)
	else:
		defaultWindowScreenPercent = Vector2(0.70, 0.70)
	
	var v = get_viewport()
	var newSize = Vector2(DisplayServer.screen_get_size()) * defaultWindowScreenPercent
	v.size = Vector2i(newSize)
	center_top_window()


func center_top_window():
	print(DisplayServer.window_get_safe_title_margins())
	var a = Vector2( (DisplayServer.screen_get_size()*0.5).x, DisplayServer.window_get_size_with_decorations().y - DisplayServer.window_get_size().y)
	var b = Vector2( (DisplayServer.window_get_size_with_decorations()*0.5).x, 0)
	DisplayServer.window_set_position(Vector2(DisplayServer.screen_get_position()) + a - b)
#func center_window():
	#DisplayServer.window_set_position(Vector2(DisplayServer.screen_get_position()) + DisplayServer.screen_get_size()*0.5 - DisplayServer.window_get_real_size()*0.5)

 # Very important to call this to update content_scale_factor because the act of going into fullscreen adjusts the window size.
func _ready():
	#Engine.max_fps = 60
	
	var v = get_viewport()
	v.content_scale_mode = v.CONTENT_SCALE_MODE_DISABLED
	v.content_scale_aspect = v.CONTENT_SCALE_ASPECT_IGNORE
	v.content_scale_size = baseSize
	v.size_changed.connect(_on_screen_resized)
	_on_screen_resized()


func _on_screen_resized():
	#var differenceFromBaseSize = Vector2(get_viewport().size) / baseSize
	#SCREEN_SCALE = min(differenceFromBaseSize.x,differenceFromBaseSize.y)
	SCREEN_SCALE = oSetScreenScale.setting_value

func _input(_event):
	if Input.is_action_just_pressed("toggle_fullscreen"):
		var w = get_viewport()
		if w.mode != Window.MODE_FULLSCREEN:
			w.mode = Window.MODE_FULLSCREEN
		else:
			w.mode = Window.MODE_WINDOWED
		_on_screen_resized()
