@tool
extends LineEdit
@onready var oFrameManager = Nodelist.list["oFrameManager"]
@onready var oFrameUpdater = Nodelist.list["oFrameUpdater"]

func _ready():
	focus_exited.connect(_on_focus_exited)
	add_to_group("StoredSetting")
	setting_value = default_value

@export var default_value : String:
	set(val):
		default_value = val
	get:
		return default_value

var setting_value : String:
	set(val):
		setting_value = val
		text = val
		
		if setting_value == default_value:
			self_modulate.a = 0.25
		else:
			self_modulate.a = 1.00
		
	get:
		return setting_value

func apply_to_frame(frame):
	var val = setting_value
	match name:
		"":
			pass

func _on_check_box_toggled(button_pressed):
	adjust_setting_manually(button_pressed)

func _on_focus_exited():
	adjust_setting_manually(text)

func adjust_setting_manually(val):
	setting_value = val
	oFrameUpdater.setting_manually_changed()
