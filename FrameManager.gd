extends Node
@onready var oPoserFrame = Nodelist.list["oPoserFrame"]
@onready var oTdAnimatedImage = Nodelist.list["oTdAnimatedImage"]
@onready var oFpAnimatedImage = Nodelist.list["oFpAnimatedImage"]
@onready var oFrameScrollContainer = Nodelist.list["oFrameScrollContainer"]
@onready var oFlashingSelector = Nodelist.list["oFlashingSelector"]
@onready var oMessage = Nodelist.list["oMessage"]
@onready var oBottomPoserAndControls = Nodelist.list["oBottomPoserAndControls"]
@onready var oBottomBoneInfo = Nodelist.list["oBottomBoneInfo"]
@onready var oFrameLabelForPoser = Nodelist.list["oFrameLabelForPoser"]
@onready var oLoadModel = Nodelist.list["oLoadModel"]
@onready var oSelectCurrentAnimation = Nodelist.list["oSelectCurrentAnimation"]
@onready var oFpOffsetPicker = Nodelist.list["oFpOffsetPicker"]
@onready var oTdOffsetPicker = Nodelist.list["oTdOffsetPicker"]
@onready var oFrameUpdater = Nodelist.list["oFrameUpdater"]

var tex = null #preload("res://data/models/scaletex.png")
var current_rotation = 0
var frameGroupScn = preload("res://scenes/FrameGroup.tscn")

var currentTDFrameGroup:Node
var currentFPFrameGroup:Node

enum {
	TOP_DOWN,
	FIRST_PERSON,
}

func initial():
	new_frames()
	set_up_poser()

func new_frames():
	print("new_frames")
	oBottomPoserAndControls.visible = false
#	oBottomBoneInfo.visible = false
	# Clear frame data
	current_rotation = 0
	var animation_index = oSelectCurrentAnimation.selected
	for i in Anim.data[animation_index][Anim.TD_FRAMEGROUP].size():
		var td_fg = Anim.data[animation_index][Anim.TD_FRAMEGROUP][i]
		var fp_fg = Anim.data[animation_index][Anim.FP_FRAMEGROUP][i]
		if is_instance_valid(td_fg):
			td_fg.delete_all_frames()
			td_fg.get_parent().remove_child(td_fg)
			td_fg.queue_free()
		if is_instance_valid(fp_fg):
			fp_fg.delete_all_frames()
			fp_fg.get_parent().remove_child(fp_fg)
			fp_fg.queue_free()
	
	# New frame data
	for index in Anim.data.size():
		var rotatable = Anim.data[index][Anim.ROTATABLE]
		if rotatable:
			for i in range(Anim.degreesArray.size()):
				var td_fg = frameGroupScn.instantiate()
				var fp_fg = frameGroupScn.instantiate()
				td_fg.name = "Framegroup : " + Anim.data[index][Anim.NAME] + " : TD : Angle" + str(i)
				fp_fg.name = "Framegroup : " + Anim.data[index][Anim.NAME] + " : FP : Angle" + str(i)
				Anim.data[index][Anim.TD_FRAMEGROUP][i] = td_fg
				Anim.data[index][Anim.FP_FRAMEGROUP][i] = fp_fg
				oFrameScrollContainer.add_child(td_fg)
				oFrameScrollContainer.add_child(fp_fg)
		else:
			var td_fg = frameGroupScn.instantiate()
			var fp_fg = frameGroupScn.instantiate()
			td_fg.name = "Framegroup : " + Anim.data[index][Anim.NAME] + " : TD : Angle0"
			fp_fg.name = "Framegroup : " + Anim.data[index][Anim.NAME] + " : FP : Angle0"
			Anim.data[index][Anim.TD_FRAMEGROUP][0] = td_fg
			Anim.data[index][Anim.FP_FRAMEGROUP][0] = fp_fg
			oFrameScrollContainer.add_child(td_fg)
			oFrameScrollContainer.add_child(fp_fg)
	
	set_current_framegroups(Anim.data[animation_index][Anim.TD_FRAMEGROUP][0], Anim.data[animation_index][Anim.FP_FRAMEGROUP][0])

func set_up_poser():
	var defaultDegrees = 270
	oPoserFrame.initialize(["Frame", "PoserFrame"])
	oPoserFrame.set_camera_rotation(Vector3(0,defaultDegrees,0))
	oPoserFrame.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	oPoserFrame.size_flags_vertical = Control.SIZE_EXPAND_FILL

var selected_frame_index:int = -1:
	set(val):
		if val > currentTDFrameGroup.frame_count()-1:
			val = -1
		selected_frame_index = val
		for frame in get_tree().get_nodes_in_group("Frame"):
			frame.flash_select(false)
		
		if selected_frame_index != -1:
			var tdFrame = get_selected_frame(TOP_DOWN)
			var fpFrame = get_selected_frame(FIRST_PERSON)
			skeleton_to_skeleton(tdFrame, oPoserFrame)
			skeleton_to_skeleton(fpFrame, oPoserFrame)
			if tdFrame != null: tdFrame.flash_select(true)
			if fpFrame != null: fpFrame.flash_select(true)
		
		if selected_frame_index == -1:
			oBottomPoserAndControls.visible = false
		else:
			oBottomPoserAndControls.visible = true
		
		oFrameLabelForPoser.text = "Frame " + str(1+selected_frame_index)
		
	get:
		return selected_frame_index

func set_current_framegroups(td_fg, fp_fg):
	var CODETIME_START = Time.get_ticks_msec()
	
	currentTDFrameGroup = td_fg
	currentFPFrameGroup = fp_fg
	
	# make other framegroups invisible
	for index in Anim.data.size():
		for fg in Anim.data[index][Anim.TD_FRAMEGROUP]:
			if is_instance_valid(fg):
				fg.visible = (fg == currentTDFrameGroup)
		for fg in Anim.data[index][Anim.FP_FRAMEGROUP]:
			if is_instance_valid(fg):
				fg.visible = (fg == currentFPFrameGroup)
	
	selected_frame_index = selected_frame_index # trigger setget
	
	print('set_current_framegroups: ' + str(Time.get_ticks_msec() - CODETIME_START) + 'ms')


func current_frame_copies_poser():
	if is_instance_valid(currentTDFrameGroup) == false or is_instance_valid(currentFPFrameGroup) == false: return
	
	var rotatable = Anim.data[oSelectCurrentAnimation.selected][Anim.ROTATABLE]
	
	if rotatable:
		for i in range(Anim.degreesArray.size()):
			var td_fg = Anim.data[oSelectCurrentAnimation.selected][Anim.TD_FRAMEGROUP][i]
			var fp_fg = Anim.data[oSelectCurrentAnimation.selected][Anim.FP_FRAMEGROUP][i]
			
			var tdFrame = td_fg.get_frame(selected_frame_index)
			var fpFrame = fp_fg.get_frame(selected_frame_index)
			
			skeleton_to_skeleton(oPoserFrame, tdFrame)
			skeleton_to_skeleton(oPoserFrame, fpFrame)
			tdFrame.set_update_mode(SubViewport.UPDATE_WHEN_VISIBLE)
			fpFrame.set_update_mode(SubViewport.UPDATE_WHEN_VISIBLE)
	else:
		var tdFrame = get_selected_frame(TOP_DOWN)
		var fpFrame = get_selected_frame(FIRST_PERSON)
		skeleton_to_skeleton(oPoserFrame, tdFrame)
		skeleton_to_skeleton(oPoserFrame, fpFrame)
		tdFrame.set_update_mode(SubViewport.UPDATE_WHEN_VISIBLE)
		fpFrame.set_update_mode(SubViewport.UPDATE_WHEN_VISIBLE)


func _on_add_frame_button_pressed():
	if is_instance_valid(currentTDFrameGroup) == false or is_instance_valid(currentFPFrameGroup) == false: return
	if oLoadModel.model_scene == null:
		oMessage.quick("Load a model first")
		return
	
	var tdFpArray = create_new_frame(oSelectCurrentAnimation.selected)
	print( currentTDFrameGroup.name )
	
	selected_frame_index = currentTDFrameGroup.frame_count()-1
	
	var CODETIME_START = Time.get_ticks_msec()
	if tdFpArray != null:
		for perspective in tdFpArray:
			for frameNode in perspective:
				oFrameUpdater.apply_settings_to_specific_frame(frameNode)
	print('apply_settings_to_specific_frame: ' + str(Time.get_ticks_msec() - CODETIME_START) + 'ms')
	
	if selected_frame_index > 0:
		oFrameUpdater.simple_redraw(selected_frame_index)
	else:
		oFrameUpdater.redraw_frames()
	#await get_tree().process_frame
	
	#for id in get_tree().get_nodes_in_group("Frame"):
	#	id.get_parent().visible = true

func create_new_frame(animation): # Also called by LoadCreatureMaker data
	var CODETIME_START = Time.get_ticks_msec()
	if oLoadModel.model_scene == null: return
	
	var tdFpArray = [[], []]
	var rotatable = Anim.data[animation][Anim.ROTATABLE]
	var initial_facedir = Anim.data[animation][Anim.INITIAL_FACEDIR]

	if rotatable:
		for i in range(Anim.degreesArray.size()):
			var rot = Anim.degreesArray[i]
			var td_fg = Anim.data[animation][Anim.TD_FRAMEGROUP][i]
			var fp_fg = Anim.data[animation][Anim.FP_FRAMEGROUP][i]

			var addedFrame = td_fg.add_frame()
			addedFrame.initialize(["Frame", "AnimationFrame", "TopDownFrame"])
			skeleton_to_skeleton(oPoserFrame, addedFrame)
			addedFrame.set_camera_rotation(Vector3(0, rot, 0))
			tdFpArray[0].append(addedFrame)

			var addedFrame2 = fp_fg.add_frame()
			addedFrame2.initialize(["Frame", "AnimationFrame", "FirstPersonFrame"])
			skeleton_to_skeleton(oPoserFrame, addedFrame2)
			addedFrame2.set_camera_rotation(Vector3(0, rot, 0))
			tdFpArray[1].append(addedFrame2)
	else:
		var rot = Anim.degreesArray[initial_facedir]
		var td_fg = Anim.data[animation][Anim.TD_FRAMEGROUP][0]
		var fp_fg = Anim.data[animation][Anim.FP_FRAMEGROUP][0]

		var addedFrame = td_fg.add_frame()
		addedFrame.initialize(["Frame", "AnimationFrame", "TopDownFrame"])
		skeleton_to_skeleton(oPoserFrame, addedFrame)
		addedFrame.set_camera_rotation(Vector3(0, rot, 0))
		tdFpArray[0].append(addedFrame)
		
		var addedFrame2 = fp_fg.add_frame()
		addedFrame2.initialize(["Frame", "AnimationFrame", "FirstPersonFrame"])
		skeleton_to_skeleton(oPoserFrame, addedFrame2)
		addedFrame2.set_camera_rotation(Vector3(0, rot, 0))
		tdFpArray[1].append(addedFrame2)
	
	print('create_new_frame: ' + str(Time.get_ticks_msec() - CODETIME_START) + 'ms')
	return tdFpArray


func skeleton_to_skeleton(fromFrame:Node, toFrame:Node):
	if is_instance_valid(fromFrame) == false: return
	if is_instance_valid(toFrame) == false: return
	
	var fromSkeleton = fromFrame.model_get_part("Skeleton3D")
	if fromSkeleton == null: return
	var toSkeleton = toFrame.model_get_part("Skeleton3D")
	if toSkeleton == null: return
	
	toSkeleton.reset_bone_poses() # Just in case. I think this helps.
	
	for i in range(fromSkeleton.get_bone_count()):
		var pose = fromSkeleton.get_bone_pose(i)
		toSkeleton.set_bone_pose_rotation(i, pose.basis.get_rotation_quaternion())
		toSkeleton.set_bone_pose_position(i, pose.origin)
		toSkeleton.set_bone_pose_scale(i, pose.basis.get_scale())


func _on_animation_speed_line_edit_value_changed(val):
	oTdAnimatedImage.frame_length = val
	oFpAnimatedImage.frame_length = val

func delete_frames_of_animation(animation_index):
	for i in Anim.data[animation_index][Anim.TD_FRAMEGROUP].size():
		var td_fg = Anim.data[animation_index][Anim.TD_FRAMEGROUP][i]
		var fp_fg = Anim.data[animation_index][Anim.FP_FRAMEGROUP][i]
		td_fg.delete_all_frames()
		fp_fg.delete_all_frames()

func _on_delete_frame_button_pressed():
	if selected_frame_index != -1:
		for i in Anim.data[oSelectCurrentAnimation.selected][Anim.TD_FRAMEGROUP].size():
			var td_fg = Anim.data[oSelectCurrentAnimation.selected][Anim.TD_FRAMEGROUP][i]
			var fp_fg = Anim.data[oSelectCurrentAnimation.selected][Anim.FP_FRAMEGROUP][i]
			td_fg.delete_frame(selected_frame_index)
			fp_fg.delete_frame(selected_frame_index)
		selected_frame_index = min(selected_frame_index, currentTDFrameGroup.frame_count() - 1)
	else:
		oMessage.quick("No frame selected")


func get_selected_frame(perspective):
	var framegroup
	match perspective:
		TOP_DOWN:
			framegroup = currentTDFrameGroup
		FIRST_PERSON:
			framegroup = currentFPFrameGroup
	
	if is_instance_valid(framegroup) == false:
		return null
	if selected_frame_index > framegroup.frame_count() - 1:
		return null
	
	return framegroup.get_frame(selected_frame_index)


func _on_rotate_frame_button_pressed():
	current_rotation += 1
	if current_rotation > 4:
		current_rotation = 0
	set_framegroup_rotation(current_rotation)

func set_framegroup_rotation(current_rotation):
	var td = Anim.data[oSelectCurrentAnimation.selected][Anim.TD_FRAMEGROUP][current_rotation]
	var fp = Anim.data[oSelectCurrentAnimation.selected][Anim.FP_FRAMEGROUP][current_rotation]
	set_current_framegroups(td, fp)
