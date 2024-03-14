extends HBoxContainer
@onready var oScreen = Nodelist.list["oScreen"]
@onready var oPoserFrame = Nodelist.list["oPoserFrame"]
@onready var oSetCameraZoom = Nodelist.list["oSetCameraZoom"]
@onready var oFrameManager = Nodelist.list["oFrameManager"]
@onready var oFrameUpdater = Nodelist.list["oFrameUpdater"]
@onready var oLoadTexture = Nodelist.list["oLoadTexture"]

func _ready():
	add_to_group("StoredSetting")
	setting_value = default_value
	_on_renamed()

var setting_value = 0 :
	set(val):
		val = clamp(val, minimum_value, maximum_value)
		if fmod(slider_step,1.0) == 0: # treat val as Integer if slider_step is a whole number, important for "match" functions
			val = int(val)
		
		setting_value = val
		if $Slider.is_connected("value_changed",_on_slider_value_changed):
			$Slider.value_changed.disconnect(_on_slider_value_changed)
		$Slider.value = val
		$Slider.value_changed.connect(_on_slider_value_changed)
		
		if $LineEdit.has_focus() == false:
			update_line_edit_text(val)
		
		match name:
			"SetScreenScale":
				oScreen.SCREEN_SCALE = setting_value
			"SetPoserSize":
				oPoserFrame.set_bone_posers_size(setting_value)
		
		if setting_value == default_value:
			$Label.self_modulate.a = 0.25
		else:
			$Label.self_modulate.a = 1.00
		
	get:
		return setting_value

func apply_to_frame(frame):
		match name:
			#"SetFirstPersonSize":
				#if frame.is_in_group("FirstPersonFrame"):
					#frame.firstPersonScaleAdjustment = setting_value
					#frame.set_camera_zoom(oSetCameraZoom.get_node("Slider").value)
			"SetTdDegrees":
				if frame.is_in_group("TopDownFrame"):
					var existing_rotation = frame.get_camera_rotation()
					frame.set_camera_rotation(Vector3(-setting_value,existing_rotation.y,existing_rotation.z))
			"SetModelScale":
				if is_instance_valid(frame.localModel):
					frame.set_model_image_scale()
			"SetImageScale":
				if is_instance_valid(frame.localModel):
					frame.set_model_image_scale()
			"SetLightCount":
				frame.set_light_count(setting_value)
			"SetLightDistance":
				for light in frame.get_lights():
					frame.set_lights_ring_position()
			"SetLightAngle":
				for light in frame.get_lights():
					frame.set_lights_ring_position()
			"SetLightEnergy":
				for light in frame.get_lights():
					light.light_energy = setting_value
			"SetSelfShadowing":
				for light in frame.get_lights():
					light.shadow_opacity = setting_value
			"SetOmniRange":
				for light in frame.get_lights():
					light.omni_range = setting_value
			"SetOmniAttenuation":
				for light in frame.get_lights():
					light.omni_attenuation = setting_value
			"SetLightSize":
				for light in frame.get_lights():
					light.light_size = setting_value
			"SetLightSpecular":
				for light in frame.get_lights():
					light.light_specular = setting_value
			"SetCameraClip": frame.set_camera_clip(setting_value)
			"SetCameraZoom": frame.set_camera_zoom(setting_value)
			"SetOutlineIntensity": frame.get_node("%EffectsViewportSprite").material.set_shader_parameter("outline_intensity", setting_value)
			#"SetMSAA": frame.set_msaa(setting_value)
#				"SetSnapVerticesToPixel": frame.set_snap_vertices(setting_value)
#				"SetSnapTransformsToPixel": frame.set_snap_transforms(setting_value)
			"SetAmbientLightEnergy": frame.get_environment().ambient_light_energy = setting_value
			#"SetModelPositionX":
				#if is_instance_valid(frame.localModel):
					#frame.localModel.position.x = setting_value
			"SetModelPositionY":
				if is_instance_valid(frame.localModel):
					frame.localModel.position.y = setting_value
			"SetTonemapMode": frame.get_environment().tonemap_mode = setting_value
			"SetTonemapExposure": frame.get_environment().tonemap_exposure = setting_value
			"SetTonemapWhite": frame.get_environment().tonemap_white = setting_value
			"SetDenoiseDifference": frame.get_node("%EffectsViewportSprite").material.set_shader_parameter("denoise_difference", setting_value)
			"SetSobelIntensity": frame.get_node("%EffectsViewportSprite").material.set_shader_parameter("sobel_intensity", setting_value)
			"SetSobelThreshold": frame.get_node("%EffectsViewportSprite").material.set_shader_parameter("sobel_threshold", setting_value)
			"SetDitherStrength": frame.get_node("%EffectsViewportSprite").material.set_shader_parameter("dither_strength", setting_value)
			"SetReduceNoise": frame.set_shader_3d_parameter("reduce_noise",setting_value)
			"SetEdgeDepthThreshold": frame.set_shader_3d_parameter("edge_depth_threshold", setting_value)
			"SetEdgeNormalThreshold": frame.set_shader_3d_parameter("edge_normal_threshold", setting_value)
			"SetEdgeHighlightStrength": frame.set_shader_3d_parameter("edge_highlight_strength", setting_value)
			"SetEdgeShadowStrength": frame.set_shader_3d_parameter("edge_shadow_strength", setting_value)
			"SetSsilRadius": frame.get_environment().ssil_radius = setting_value
			"SetSsilIntensity": frame.get_environment().ssil_intensity = setting_value
			"SetSsilSharpness": frame.get_environment().ssil_sharpness = setting_value
			"SetSsilNormalRejection": frame.get_environment().ssil_normal_rejection = setting_value
			"SetSsaoRadius": frame.get_environment().ssao_radius = setting_value
			"SetSsaoIntensity": frame.get_environment().ssao_intensity = setting_value
			"SetSsaoPower": frame.get_environment().ssao_power = setting_value
			"SetSsaoDetail": frame.get_environment().ssao_detail = setting_value
			"SetSsaoHorizon": frame.get_environment().ssao_horizon = setting_value
			"SetSsaoSharpness": frame.get_environment().ssao_sharpness = setting_value
			"SetSsaoLightAffect": frame.get_environment().ssao_light_affect = setting_value
			"SetSsaoAoChannelAffect": frame.get_environment().ssao_ao_channel_affect = setting_value

@export var slider_visible : bool = true:
	set(val):
		slider_visible = val
		$Slider.visible = val
	get:
		return slider_visible

@export var default_value : float = 0.5:
	set(val):
		default_value = val
	get:
		return default_value

@export var adjust_instantly : bool = true

@export var slider_step : float = 0.01:
	set(val):
		slider_step = val
		$Slider.step = val
	get:
		return slider_step

@export var minimum_value : float = 0.0:
	set(val):
		minimum_value = val
		$Slider.min_value = val
	get:
		return minimum_value

@export var maximum_value : float = 1.0:
	set(val):
		maximum_value = val
		$Slider.max_value = val
	get:
		return maximum_value

func _on_renamed():
	if is_instance_valid($Label):
		var baseName = name.trim_prefix("Set")
		baseName = baseName.to_snake_case()
		baseName = baseName.replace("_", " ")
		baseName = baseName.substr(0, 1).capitalize() + baseName.substr(1)
		$Label.text = baseName

func _input(event):
	if is_instance_valid(get_viewport().gui_get_focus_owner()) == false: return
	if get_viewport().gui_get_focus_owner() != $LineEdit: return
	
	if (event.is_action("ui_left") or event.is_action("ui_down")) and event.is_pressed():
		adjust_setting_manually(setting_value-slider_step)
		update_line_edit_text(setting_value)
		$LineEdit.caret_column = $LineEdit.text.length()
		get_viewport().set_input_as_handled()
	
	if (event.is_action("ui_right") or event.is_action("ui_up")) and event.is_pressed():
		adjust_setting_manually(setting_value+slider_step)
		update_line_edit_text(setting_value)
		$LineEdit.caret_column = $LineEdit.text.length()
		get_viewport().set_input_as_handled()


func _on_LineEdit_focus_exited():
	adjust_setting_manually(float($LineEdit.text))

func _on_line_edit_text_changed(new_text):
	adjust_setting_manually(float(new_text))
#	if $LineEdit.has_focus() and setting_value == 0:
#		$LineEdit.text = ""

func _on_line_edit_text_submitted(new_text):
	$LineEdit.release_focus()

func _on_slider_value_changed(value):
	if adjust_instantly == true:
		adjust_setting_manually(value)
	
	update_line_edit_text(value)
	$LineEdit.caret_column = $LineEdit.text.length()
	$LineEdit.grab_focus()

func _on_Slider_drag_ended(_value_has_changed):
	adjust_setting_manually($Slider.value)

func update_line_edit_text(val):
	var rememberCaret = $LineEdit.caret_column
	$LineEdit.text = str(val)
	if slider_step < 0.01:
		$LineEdit.text = $LineEdit.text.pad_decimals(3)
	elif slider_step < 0.1:
		$LineEdit.text = $LineEdit.text.pad_decimals(2)
	elif slider_step < 1:
		$LineEdit.text = $LineEdit.text.pad_decimals(1)
	$LineEdit.caret_column = rememberCaret

func adjust_setting_manually(val):
	setting_value = val
	oFrameUpdater.setting_manually_changed()
