extends Button
@onready var oCopyPasteCodeWindow = Nodelist.list["oCopyPasteCodeWindow"]
@onready var oCreatureNameLineEdit = Nodelist.list["oCreatureNameLineEdit"]
@onready var oCopyPasteTextEdit = Nodelist.list["oCopyPasteTextEdit"]
@onready var oMessage = Nodelist.list["oMessage"]
@onready var oExportSpritesFileDialog = Nodelist.list["oExportSpritesFileDialog"]
@onready var oSelectCurrentAnimation = Nodelist.list["oSelectCurrentAnimation"]
@onready var oFrameManager = Nodelist.list["oFrameManager"]
@onready var oSetAutoOpenExportDir = Nodelist.list["oSetAutoOpenExportDir"]
@onready var oFrameUpdater = Nodelist.list["oFrameUpdater"]

var remember_last_filename = ""

const unchanged_paste_text = "
[sprites]
Stand = <replace>_STAND
Ambulate = <replace>_WALK
Drag = <replace>_WALK
Attack = <replace>_ATTACK
Dig = 0
Smoke = 0
Relax = 0
PrettyDance = 0
GotHit = <replace>_HIT
PowerGrab = <replace>_PICKEDUP
GotSlapped = <replace>_SLAPPED
Celebrate = <replace>_CELEBRATE
Sleep = <replace>_LAIRSLEEP
EatChicken = <replace>_EATCHICKEN
Torture = <replace>_TORTURE
Scream = <replace>_COMPLAIN
DropDead = <replace>_DYING
DeadSplat = 946
GFX18 = 20
QuerySymbol = <replace>_PORTRAIT
HandSymbol = <replace>_ICON
GFX21 = 20
"

func _ready():
	oCopyPasteCodeWindow.visible = false

func _on_pressed():
	oExportSpritesFileDialog.current_path = Settings.PATH_DK_DIR.path_join("/fxdata/")
	
	if remember_last_filename == "":
		oExportSpritesFileDialog.current_file = "creature_" + oCreatureNameLineEdit.text.to_lower() + ".zip"
	else:
		oExportSpritesFileDialog.current_file = remember_last_filename
	
	oExportSpritesFileDialog.popup_centered()


func _on_export_sprites_file_dialog_file_selected(output_zip_filepath):
	
	remember_last_filename = output_zip_filepath.get_file()
	
	var creatureName = oCreatureNameLineEdit.text.to_upper()
	if creatureName == "":
		oMessage.quick("Export error: Set creature name first")
		return
	oMessage.quick("Saving...")
	
	print("CREATURE NAME: " + creatureName)
	
	var spriteSections = []
	var working_dir = OS.get_user_data_dir().path_join("zip_up")
	delete_files_and_folders(working_dir) # Make sure working directory is definitely clear
	
	var count_images_exported = 0
	
	#######################
	for frame in get_tree().get_nodes_in_group("Frame"):
		oFrameUpdater.apply_settings_to_specific_frame(frame)
	oFrameUpdater.redraw_all_frames()
	await RenderingServer.frame_post_draw
	#######################
	
	
	for ani in Anim.data.size():
		var tdFrameGroups = Anim.data[ani][Anim.TD_FRAMEGROUP]
		var fpFrameGroups = Anim.data[ani][Anim.FP_FRAMEGROUP]
		var aniName = Anim.data[ani][Anim.NAME]
		var rotatable = Anim.data[ani][Anim.ROTATABLE]
		var initialFaceDir = Anim.data[ani][Anim.INITIAL_FACEDIR]
		
		
		var td_files = []
		td_files.clear()
		var fp_files = []
		fp_files.clear()
		
		var td_offset = null
		var fp_offset = null
		var frames_for_this_anim = 0
		
		for td_or_fp in 2:
			
			var frameGroups
			var perspectiveName = ""
			
			var numberOfRotations = 1
			if rotatable == true:
				numberOfRotations = 5
			
			match td_or_fp:
				0:
					perspectiveName = "td"
					frameGroups = tdFrameGroups
				1:
					perspectiveName = "fp"
					frameGroups = fpFrameGroups
			
			var subdir = aniName.to_lower() + "_" + perspectiveName
			
			for rot in numberOfRotations:
				var inner_files = []
				var frameGroup = frameGroups[rot]
				
				for frameIndex in frameGroup.get_child_count():
					var frame = frameGroup.get_child(frameIndex)
					var degrees = Anim.degreesArray[initialFaceDir + rot]
					var camRot = frame.get_camera_rotation()
					#frame.set_camera_rotation(Vector3(camRot.x,degrees,camRot.y))
					
					var img = frame.get_final_viewport().get_texture().get_image()
					
					# stand_fp_rotation1_frame01.png
					
					var construct_name = ""
					construct_name += "rotation" + str(rot+1).pad_zeros(2) # This "rot" should not be "initalFaceDir+rot"
					construct_name += "_"
					construct_name += "frame" + str(frameIndex+1).pad_zeros(2)
					construct_name += ".png"
					
					var makeDir = DirAccess.open("user://")
					makeDir.make_dir_recursive(working_dir.path_join(subdir))
					
					img.save_png(working_dir.path_join(subdir).path_join(construct_name))
					count_images_exported += 1
					frames_for_this_anim += 1
					inner_files.append({"file":subdir.path_join(construct_name)})
					
					# Establish the offset, only needs to be done once (per anim framegroup)
					match td_or_fp:
						0:
							if td_offset == null:
								td_offset = Useful.uvpos_to_pixelpos(Anim.data[ani][Anim.TD_OFFSET], frame.get_final_viewport().size)
						1:
							if fp_offset == null:
								fp_offset = Useful.uvpos_to_pixelpos(Anim.data[ani][Anim.FP_OFFSET], frame.get_final_viewport().size)
				
				match td_or_fp:
					0: td_files.append(inner_files)
					1: fp_files.append(inner_files)
		
		if frames_for_this_anim > 0:
			var section_name = creatureName+"_"+aniName.to_upper()
			spriteSections.append(generate_section(section_name, rotatable, fp_offset.x, fp_offset.y, td_offset.x, td_offset.y, fp_files, td_files))
		
		# Don't make the current animation invisible
		#if oSelectCurrentAnimation.selected != ani:
			#tdFrameGroup.visible = false
			#fpFrameGroup.visible = false
	
	oCopyPasteTextEdit.text = unchanged_paste_text.replace("<replace>", creatureName)
	
	# Reset rotation back to what it's expected to be
	#for frame in get_tree().get_nodes_in_group("AnimationFrame"):
		#var camRot = frame.get_camera_rotation()
		#frame.set_camera_rotation(Vector3(camRot.x,oFrameManager.current_degrees_for_rotatable,camRot.y))
	
	#for frame in get_tree().get_nodes_in_group("AnimationFrame"):
		#frame.iModelViewport.render_target_update_mode = SubViewport.UPDATE_WHEN_VISIBLE
		#frame.iRenderPassViewport.render_target_update_mode = SubViewport.UPDATE_WHEN_VISIBLE
		#frame.iFinalViewport.render_target_update_mode = SubViewport.UPDATE_WHEN_VISIBLE
	
	oMessage.quick("Compressed " + str(count_images_exported) + " images to: " + str(output_zip_filepath))
	
	# Create sprites.json file
	var spritesJsonFile = FileAccess.open(working_dir.path_join("sprites.json"), FileAccess.WRITE)
	spritesJsonFile.store_string(JSON.stringify(spriteSections, "\t", false)) # false for 'sort keys'
	spritesJsonFile = null # FileAccess is closed.
	
	
	var iconSections = generate_icon_sections()
	# Create icons.json file
	var iconsJsonFile = FileAccess.open(working_dir.path_join("icons.json"), FileAccess.WRITE)
	iconsJsonFile.store_string(JSON.stringify(iconSections, "\t", false)) # false for 'sort keys'
	iconsJsonFile = null # FileAccess is closed.
	
	# Create new zip file
	create_zip_archive(working_dir, output_zip_filepath)
	# Delete the directory we zipped up
	delete_files_and_folders(working_dir)
	
	oCopyPasteCodeWindow.popup_centered()
	if oSetAutoOpenExportDir.setting_value == true:
		OS.shell_open(output_zip_filepath.get_base_dir())

func create_zip_archive(source_folder_path: String, zip_file_path: String):
	var command
	var arguments = []

	match OS.get_name():
		"Windows":
			command = "data".path_join("minizip.exe")
			arguments = ["-o", zip_file_path, source_folder_path]
		"Linux":
			command = "sh"
			arguments = ["-c", "cd " + source_folder_path + " && zip -r " + zip_file_path + " ."]

	var output = Array()
	var err_output = Array()
	var exit_code = OS.execute(command, arguments, output, false, false)

	if exit_code == 0:
		print("Zip operation executed successfully")
		#print("Output: ", output)
	else:
		print("Zip operation failed")
		#print("Error output: ", output)


func delete_files_and_folders(path):
	# Delete existing file. Otherwise minizip appends files to the existing zip
	#var rm = DirAccess.open("user://")
	#var err = rm.remove(path)
	# OS.move_to_trash is working while DirAccess's remove() isn't, I don't know why.
	var err = OS.move_to_trash(path)
	print(err)
	print(path)



#	launch_powershell_script(working_dir, output_zip_filepath)


#func launch_powershell_script(source_folder_path: String, zip_file_path: String):
#	var command = "powershell.exe"
#	var arguments = [
#		"-ExecutionPolicy",
#		"Bypass",
#		"-File",
#		"data/zip_up.ps1",
#		"-sourceFolderPath",
#		source_folder_path,
#		"-zipFilePath",
#		zip_file_path
#	]
#
#	var output = Array()
#	var err_output = Array()
#	var exit_code = OS.execute(command, arguments, output, false, false)
#
#	if exit_code == 0:
#		print("Script executed successfully")
#		print("Output: ", output)
#	else:
#		print("Script execution failed")
#		print("Error output: ", output)


func generate_section(nameVar: String, rotatable: bool, fp_offset_x: int, fp_offset_y: int, td_offset_x: int, td_offset_y: int, fp: Array, td: Array) -> Dictionary:
	return {
		"name": nameVar,
		"rotatable": rotatable,
		"fp_offset_x": fp_offset_x,
		"fp_offset_y": fp_offset_y,
		"td_offset_x": td_offset_x,
		"td_offset_y": td_offset_y,
		"fp": fp,
		"td": td
	}

func generate_icon_sections():
	return [
		{
			"name": "BLAH_PORTRAIT",
			"file": [""]#["icons/creatr_portrt_tmage.png"]
		},
		{
			"name": "BLAH_ICON",
			"file": ["",""]#["icons/tmage_std.png", "icons/tmage_std_small.png"]
		}
	]
