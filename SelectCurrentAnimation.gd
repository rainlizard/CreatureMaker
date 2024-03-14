extends OptionButton

@onready var oRecommendationLabel = Nodelist.list["oRecommendationLabel"]
@onready var oRotateFrameButton = Nodelist.list["oRotateFrameButton"]
@onready var oFrameManager = Nodelist.list["oFrameManager"]
@onready var oTdOffsetX = Nodelist.list["oTdOffsetX"]
@onready var oTdOffsetY = Nodelist.list["oTdOffsetY"]
@onready var oFpOffsetX = Nodelist.list["oFpOffsetX"]
@onready var oFpOffsetY = Nodelist.list["oFpOffsetY"]
@onready var oTdAnimatedImage = Nodelist.list["oTdAnimatedImage"]
@onready var oFpAnimatedImage = Nodelist.list["oFpAnimatedImage"]
@onready var oTdOffsetPicker = Nodelist.list["oTdOffsetPicker"]
@onready var oFpOffsetPicker = Nodelist.list["oFpOffsetPicker"]
@onready var oFrameUpdater = Nodelist.list["oFrameUpdater"]

func _ready():
	print(Anim.data.size())
	for i in Anim.data.size():
		add_item(Anim.data[i][Anim.NAME], i)
		if Anim.data[i][Anim.FRAMECOUNT] == 0:
			set_item_disabled(i, true)

	# This will fix initial "recommended frames" label.
	await get_tree().process_frame
	_on_item_selected(0)


func _on_item_selected(index):
	print("--------------------")
	print("Switched to animation: ", Anim.data[index][Anim.NAME])
	oRecommendationLabel.text = "Recommended frames: " + str(Anim.data[index][Anim.FRAMECOUNT])

	if index == 3:  # Attack
		oRecommendationLabel.text = "Recommended frames: " + "2-8"

	if Anim.data[index][Anim.ROTATABLE] == true:
		oRotateFrameButton.disabled = false
	else:
		oRotateFrameButton.disabled = true
	
	var current_td_framegroup = Anim.data[index][Anim.TD_FRAMEGROUP][0]
	var current_fp_framegroup = Anim.data[index][Anim.FP_FRAMEGROUP][0]
	oFrameManager.set_current_framegroups(current_td_framegroup, current_fp_framegroup)
	oFrameUpdater.apply_settings_to_current_animation_frames()
	oFrameUpdater.redraw_frames()
	
	# Select the first frame
	oFrameManager.selected_frame_index = -1
	if current_fp_framegroup.frame_count() > 0:
		oFrameManager.selected_frame_index = 0
	oFrameManager.current_rotation = 0
	
	oFpAnimatedImage.set_texture_anim_to_first_frame()
	oTdAnimatedImage.set_texture_anim_to_first_frame()
	
	# Set the camera rotation of all frames (of selected anim), if it's not rotatable
	if Anim.data[index][Anim.ROTATABLE] == false:
		var initalFaceDir = Anim.data[index][Anim.INITIAL_FACEDIR]
		var newDegrees = Anim.degreesArray[initalFaceDir]

		for i in range(current_td_framegroup.frame_count()):
			var tdFrame = current_td_framegroup.get_frame(i)
			if tdFrame.is_visible_in_tree() == true:
				var existingDegrees = tdFrame.get_camera_rotation()
				tdFrame.set_camera_rotation(Vector3(existingDegrees.x, newDegrees, existingDegrees.y))

		for i in range(current_fp_framegroup.frame_count()):
			var fpFrame = current_fp_framegroup.get_frame(i)
			if fpFrame.is_visible_in_tree() == true:
				var existingDegrees = fpFrame.get_camera_rotation()
				fpFrame.set_camera_rotation(Vector3(existingDegrees.x, newDegrees, existingDegrees.y))


func _on_prev_anim_button_pressed():
	# Decrement the selection, skipping over disabled items
	var newSelection = selected
	newSelection -= 1
	if newSelection < 0:
		newSelection = get_item_count() - 1
	while is_item_disabled(newSelection) == true:
		newSelection -= 1
		if newSelection < 0:
			newSelection = get_item_count() - 1

	# Set the new selection
	select(newSelection)
	_on_item_selected(newSelection)


func _on_next_anim_button_pressed():
	# Increment the selection, skipping over disabled items
	var newSelection = selected
	newSelection += 1
	if newSelection >= get_item_count():
		newSelection = 0
	while is_item_disabled(newSelection) == true:
		newSelection += 1
		if newSelection >= get_item_count():
			newSelection = 0

	# Set the new selection
	select(newSelection)
	_on_item_selected(newSelection)
