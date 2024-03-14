extends HBoxContainer
@onready var oPoserFrame = Nodelist.list["oPoserFrame"]
@onready var oFpAnimatedBack = Nodelist.list["oFpAnimatedBack"]
@onready var oTdAnimatedBack = Nodelist.list["oTdAnimatedBack"]
@onready var oFrameManager = Nodelist.list["oFrameManager"]
@onready var oFrameUpdater = Nodelist.list["oFrameUpdater"]

func _ready():
	add_to_group("StoredSetting")
	setting_value = default_value
	_on_renamed()

var setting_value : Color:
	set(val):
		setting_value = val
		get_node("ColorPickerButton").color = val
		match name:
			"SetUiBackgroundColour": RenderingServer.set_default_clear_color(setting_value)
		
		if setting_value == default_value:
			$Label.self_modulate.a = 0.25
		else:
			$Label.self_modulate.a = 1.00
	get:
		return setting_value

func apply_to_frame(frame):
		match name:
			"SetMinimumDark":
				frame.get_node("%EffectsViewportSprite").material.set_shader_parameter("minimum_dark_color", setting_value)
			"SetOutlineColor":
				frame.get_node("%EffectsViewportSprite").material.set_shader_parameter("outline_color", setting_value)
			"SetEdgeHighlightColor":
				frame.set_shader_3d_parameter("edge_highlight_color", setting_value)
			"SetEdgeShadowColor":
				frame.set_shader_3d_parameter("edge_shadow_color", setting_value)
			"SetFrameColour":
				frame.set_background_colour(setting_value)
				oTdAnimatedBack.color = setting_value
				oFpAnimatedBack.color = setting_value
			"SetPoserColour":
				frame.set_bone_posers_colour(setting_value)
			"SetLightColour":
				for light in frame.get_lights():
					light.light_color = setting_value
			"SetAmbientLightColour":
				frame.get_environment().ambient_light_color = setting_value


@export var default_value : Color:
	set(val):
		default_value = val
	get:
		return default_value

@export var edit_alpha : bool:
	set(val):
		var a = get_node_or_null("ColorPickerButton")
		if a == null:
			return
		a.edit_alpha = val

func _on_color_picker_button_color_changed(color):
	adjust_setting_manually(color)

func _on_renamed():
	if is_instance_valid($Label):
		var baseName = name.trim_prefix("Set")
		baseName = baseName.to_snake_case()
		baseName = baseName.replace("_", " ")
		baseName = baseName.substr(0, 1).capitalize() + baseName.substr(1)
		$Label.text = baseName

func adjust_setting_manually(val):
	setting_value = val
	oFrameUpdater.setting_manually_changed()
