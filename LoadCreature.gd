extends Button

@onready var oFrameManager = Nodelist.list["oFrameManager"]
@onready var oLoadCreatureMakerDataFileDialog = Nodelist.list["oLoadCreatureMakerDataFileDialog"]
@onready var oMessage = Nodelist.list["oMessage"]
@onready var oSelectCurrentAnimation = Nodelist.list["oSelectCurrentAnimation"]
@onready var oLoadModel = Nodelist.list["oLoadModel"]
@onready var oLoadTexture = Nodelist.list["oLoadTexture"]
@onready var oFrameUpdater = Nodelist.list["oFrameUpdater"]

var remember_save_load_creature_path = ""

var load_bone_data = {}

func _on_pressed():
	oLoadCreatureMakerDataFileDialog.current_dir = remember_save_load_creature_path
	oLoadCreatureMakerDataFileDialog.current_path = remember_save_load_creature_path
	oLoadCreatureMakerDataFileDialog.current_file = remember_save_load_creature_path.get_file()
	oLoadCreatureMakerDataFileDialog.popup_centered()

func _on_load_animation_file_dialog_file_selected(path):
	var cfg = ConfigFile.new()
	var loadAnim = cfg.load(path)
	if loadAnim != OK:
		oMessage.quick("Error loading CreatureMaker data")
		return
	
	# Load Model and Texture files (before anything else)
	# Frames are cleared inside load_model()
	var errState = load_model_and_texture_files(path)

	if errState == OK:
		var CODETIME_LOAD_FRAMES_START = Time.get_ticks_msec()
		load_creature_file(cfg)
		print('Time to load frames from creature file: ' + str(Time.get_ticks_msec() - CODETIME_LOAD_FRAMES_START) + 'ms')
		oMessage.quick("Loaded CreatureMaker data: " + str(path))
		remember_save_load_creature_path = path



func load_creature_file(cfg):
	for ani in Anim.data.size():
		
		var aniName = Anim.data[ani][Anim.NAME]
		if not cfg.has_section(aniName + "_0"):
			if Anim.old_names.has(aniName):
				aniName = Anim.old_names[aniName]
			else:
				print("Animation not found in the configuration file: " + aniName)
				continue
		
		var frameNumber = 0
		while true:
			var section = aniName + "_" + str(frameNumber)
			if cfg.has_section(section):
				var boneList = cfg.get_section_keys(section)
				var tdFpArray = oFrameManager.create_new_frame(ani)
				if tdFpArray != null:
					for perspective in tdFpArray:
						for frameNode in perspective:
							var skele = frameNode.model_get_part("Skeleton3D")
							if skele != null:
								for boneName in boneList:
									var pose = cfg.get_value(section, boneName)
									var boneIndex = skele.find_bone(boneName)
									if boneIndex != -1:
										skele.set_bone_pose_rotation(boneIndex, pose.basis.get_rotation_quaternion())
										skele.set_bone_pose_position(boneIndex, pose.origin)
										skele.set_bone_pose_scale(boneIndex, pose.basis.get_scale())
				frameNumber += 1
				await get_tree().process_frame
			else:
				break

		# Offsets
		var fp_offset = cfg.get_value(aniName + "_offset", "fp_offset", Vector2i(0, 0))
		var td_offset = cfg.get_value(aniName + "_offset", "td_offset", Vector2i(0, 0))

		Anim.data[ani][Anim.FP_OFFSET] = fp_offset
		Anim.data[ani][Anim.TD_OFFSET] = td_offset

	# Settings
	var CODETIME_START = Time.get_ticks_msec()
	for id in get_tree().get_nodes_in_group("StoredSetting"):
		var settingName = id.name
		var cfgVal = cfg.get_value("Settings", settingName, id.default_value)
		if cfgVal != null:
			id.setting_value = cfgVal
	
	for frame in get_tree().get_nodes_in_group("Frame"):
		oFrameUpdater.apply_settings_to_specific_frame(frame)
	
	print('initial_settings_for_all_frames: ' + str(Time.get_ticks_msec() - CODETIME_START) + 'ms')
	oSelectCurrentAnimation._on_item_selected(oSelectCurrentAnimation.selected)

func load_model_and_texture_files(path):
	var fn = path.get_file().get_basename()
	var baseDir = path.get_base_dir()

	# Load model
	var loadModelErrState = oLoadModel.load_model(baseDir.path_join(fn + ".glb"))
	if loadModelErrState == ERR_FILE_NOT_FOUND:
		loadModelErrState = oLoadModel.load_model(baseDir.path_join(fn + ".gltf"))
	if loadModelErrState == ERR_FILE_NOT_FOUND:
		oMessage.quick("No .glb or .gltf model file found.")
		return FAILED
	if loadModelErrState == ERR_FILE_UNRECOGNIZED:
		oMessage.quick("Unsupported model file format: " + fn + ".glb or " + fn + ".gltf")
		return FAILED
	if loadModelErrState == ERR_FILE_CORRUPT:
		oMessage.quick("Failed to load model file: " + fn + ".glb or " + fn + ".gltf")
		return FAILED

	# Load texture
	oLoadTexture.load_texture(baseDir.path_join(fn + ".png"))

	return OK
