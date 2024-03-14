extends Button
@onready var oSaveCreatureMakerDataFileDialog = Nodelist.list["oSaveCreatureMakerDataFileDialog"]
@onready var oMessage = Nodelist.list["oMessage"]
@onready var oLoadModel = Nodelist.list["oLoadModel"]
@onready var oLoadTexture = Nodelist.list["oLoadTexture"]
@onready var oLoadCreatureMaker = Nodelist.list["oLoadCreatureMaker"]


func _on_pressed():
	oSaveCreatureMakerDataFileDialog.current_dir = oLoadCreatureMaker.remember_save_load_creature_path
	oSaveCreatureMakerDataFileDialog.current_path = oLoadCreatureMaker.remember_save_load_creature_path
	oSaveCreatureMakerDataFileDialog.current_file = oLoadCreatureMaker.remember_save_load_creature_path.get_file()
	oSaveCreatureMakerDataFileDialog.popup_centered()

func _on_save_animation_file_dialog_file_selected(path):
	
	
	var cfg = ConfigFile.new()
	
	# Save model and save texture
	save_model_and_texture_files(path)
	
	for ani in Anim.data.size():
		var frameGroups = [Anim.data[ani][Anim.TD_FRAMEGROUP], Anim.data[ani][Anim.FP_FRAMEGROUP]]
		var aniName = Anim.data[ani][Anim.NAME]
		
		for frameGroup in frameGroups:
			for rotation in frameGroup.size():
				var framesArray = frameGroup[rotation].get_children()
				
				# Bones
				for frameNode in framesArray:
					var skele = frameNode.model_get_part("Skeleton3D")
					if skele != null:
						var frameNumber = frameNode.get_index()
						for boneIndex in skele.get_bone_count():
							var pose = skele.get_bone_pose(boneIndex)
							var boneName = skele.get_bone_name(boneIndex)
							cfg.set_value(aniName + "_" + str(frameNumber), boneName, pose)
		
		# Offsets
		var fp_offset = Anim.data[ani][Anim.FP_OFFSET]
		var td_offset = Anim.data[ani][Anim.TD_OFFSET]
		cfg.set_value(aniName + "_offset", "fp_offset", fp_offset)
		cfg.set_value(aniName + "_offset", "td_offset", td_offset)
	
	# Settings
	for id in get_tree().get_nodes_in_group("StoredSetting"):
		var settingName = id.name
		var settingVal = id.setting_value
		cfg.set_value("Settings", settingName, settingVal)
	
	var saveAnim = cfg.save(path)
	if saveAnim != OK:
		oMessage.quick("Error saving CreatureMaker data")
	else:
		oMessage.quick("Saved CreatureMaker data: " + str(path))
		oLoadCreatureMaker.remember_save_load_creature_path = path

func save_model_and_texture_files(path):
	print(path)
	var newFilename = path.get_file().get_basename()
	var baseDir = path.get_base_dir()
	
	for i in 2:
		var data
		var ext
		var typeName
		match i:
			0: # Texture
				data = oLoadTexture.tex_data
				ext = ".png"  # Assuming the texture is saved as PNG
				typeName = "texture"
			1: # Model
				data = oLoadModel.model_data
				ext = ".glb"  # Assuming the model is saved as glTF binary
				typeName = "model"

		var dest = baseDir.path_join(newFilename + ext)
		var file = FileAccess.open(dest, FileAccess.WRITE)
		if file != null:
			file.store_buffer(data)
			file.close()
			oMessage.quick("Saved " + typeName + " to: " + dest)
		else:
			oMessage.quick("Error saving file: " + dest)
