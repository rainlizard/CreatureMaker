extends HBoxContainer
@onready var oFrameManager = Nodelist.list["oFrameManager"]
@onready var oFrameUpdater = Nodelist.list["oFrameUpdater"]

func _ready():
	add_to_group("StoredSetting")
	setting_value = default_value
	$Label.text = checkboxText

var setting_value : bool:
	set(val):
		setting_value = val
		get_node("CheckBox").button_pressed = val
		
		if setting_value == default_value:
			$Label.self_modulate.a = 0.25
		else:
			$Label.self_modulate.a = 1.00
	get:
		return setting_value

func apply_to_frame(frame):
	var val = setting_value
	match name:
		"":
			pass

@export var checkboxText : String:
	set(val):
		checkboxText = val
		$Label.text = val
	get:
		return checkboxText

@export var default_value : bool:
	set(val):
		default_value = val
	get:
		return default_value

func _on_check_box_toggled(button_pressed):
	setting_value = button_pressed
	oFrameUpdater.setting_manually_changed()
