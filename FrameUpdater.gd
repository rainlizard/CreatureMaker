extends Node
@onready var oSelectCurrentAnimation = Nodelist.list["oSelectCurrentAnimation"]
@onready var oFpOffsetPicker = Nodelist.list["oFpOffsetPicker"]
@onready var oTdOffsetPicker = Nodelist.list["oTdOffsetPicker"]
@onready var oFrameManager = Nodelist.list["oFrameManager"]

func simple_redraw(frame_index):
	for i in Anim.data[oSelectCurrentAnimation.selected][Anim.TD_FRAMEGROUP].size():
		var td_fg = Anim.data[oSelectCurrentAnimation.selected][Anim.TD_FRAMEGROUP][i]
		var fp_fg = Anim.data[oSelectCurrentAnimation.selected][Anim.FP_FRAMEGROUP][i]
		var td_frame = td_fg.get_frame(frame_index)
		var fp_frame = fp_fg.get_frame(frame_index)
		
		if td_frame:
			update_frame_region_fast(td_frame, td_fg, frame_index)
		if fp_frame:
			update_frame_region_fast(fp_frame, fp_fg, frame_index)

func update_frame_region_fast(frame, fg, frame_index):
	if frame_index > 0:
		var previous_frame = fg.get_frame(frame_index - 1)
		var previous_vtex = previous_frame.get_node("%FinalTrimmedViewportSprite")
		var finalViewport = frame.get_node("%FinalTrimmedViewport")
		var finalSprite = frame.get_node("%FinalTrimmedViewportSprite")
		
		
		finalSprite.region_enabled = true
		finalSprite.region_rect = previous_vtex.region_rect
		finalViewport.size = previous_vtex.region_rect.size
		frame.update_panel_size()
		frame.set_update_mode(SubViewport.UPDATE_ONCE)

func update_frame_region_rect(frame, region_rect):
	var finalViewport = frame.get_node("%FinalTrimmedViewport")
	var finalSprite = frame.get_node("%FinalTrimmedViewportSprite")
	
	
	finalSprite.region_enabled = true
	finalSprite.region_rect = region_rect
	finalViewport.size = region_rect.size
	
	frame.update_panel_size()

func redraw_frames():
	print("redraw_frames")
	update_and_trim_frames(oSelectCurrentAnimation.selected)

func redraw_all_frames():
	print("redraw_all_frames")
	for ani in Anim.data.size():
		update_and_trim_frames(ani)

func update_and_trim_frames(ani):
	update_viewports_for_animation(ani)
	call_deferred("trim_and_update_frames_for_animation", ani)

func update_viewports_for_animation(ani):
	var CODETIME_START = Time.get_ticks_msec()
	print("update_viewports_for_animation " + str(ani) + " (updating next frame)")
	update_framegroups(Anim.data[ani][Anim.TD_FRAMEGROUP])
	update_framegroups(Anim.data[ani][Anim.FP_FRAMEGROUP])
	print('update_viewports_for_animation ' + str(ani) + ': ' + str(Time.get_ticks_msec() - CODETIME_START) + 'ms')

func update_framegroups(framegroups):
	for fg in framegroups:
		if not is_instance_valid(fg):
			continue
		for frame in fg.get_children():
			if frame.name == "PoserFrame":
				continue
			frame.set_update_mode(SubViewport.UPDATE_ONCE)

func trim_and_update_frames_for_animation(ani):
	var CODETIME2_START = Time.get_ticks_msec()
	await RenderingServer.frame_post_draw
	print('awaiting update_viewports_for_animation ' + str(ani) + ' to finish: ' + str(Time.get_ticks_msec() - CODETIME2_START) + 'ms')
	
	var CODETIME_START = Time.get_ticks_msec()
	trim_empty_space_for_animation(ani, Anim.TD_FRAMEGROUP)
	trim_empty_space_for_animation(ani, Anim.FP_FRAMEGROUP)
	print('trim_empty_space_for_animation ' + str(ani) + ': ' + str(Time.get_ticks_msec() - CODETIME_START) + 'ms')
	
	call_deferred("update_viewports_for_animation", ani)
	if ani == oSelectCurrentAnimation.selected:
		call_deferred("update_spinboxes_and_aspect_ratio")

func trim_empty_space_for_animation(ani, perspective):
	var anim_data = Anim.data[ani]
	var framegroups = anim_data[perspective]
	
	var CODETIME_CALC = Time.get_ticks_msec()
	var max_used_rect = calculate_max_used_rect(framegroups)
	var stringPerspective
	if perspective == 1: stringPerspective = "Top Down"
	if perspective == 2: stringPerspective = "First Person"
	print('calculate_max_used_rect for perspective ' + str(stringPerspective) + ': ' + str(Time.get_ticks_msec() - CODETIME_CALC) + 'ms')
	
	for fg in framegroups:
		if not is_instance_valid(fg):
			continue
		
		for frame in fg.get_children():
			update_frame_region_rect(frame, max_used_rect)
	
	update_resolution_size_label(perspective, max_used_rect)

func calculate_max_used_rect(framegroups):
	var perfectly_cropped = Rect2()
	var first_iteration = true
	for fg in framegroups:
		if not is_instance_valid(fg):
			continue
		for frame in fg.get_children():
			var effects_viewport_texture = frame.get_node("%EffectsViewport").get_texture()
			var image = effects_viewport_texture.get_image()
			if image:
				var used_rect = image.get_used_rect()
				if first_iteration:
					perfectly_cropped = used_rect
					first_iteration = false
				else:
					perfectly_cropped = perfectly_cropped.merge(used_rect)
	
	# Rotation needs equal space on left and right (relative to center) to rotate properly. This also mimics what's found in the extracted graphics "FXGraphics-14".
	var viewport_width = 254
	var wide_rect = Rect2()
	if perfectly_cropped.position.x > viewport_width-perfectly_cropped.end.x: # Determine which side of the frame is closer.
		# Golem pokes out more towards right side of frame:
		wide_rect.position.x = viewport_width - perfectly_cropped.end.x
		wide_rect.end.x = perfectly_cropped.end.x
	else:
		# Thorny Dragon pokes out more towards left side of frame:
		wide_rect.position.x = perfectly_cropped.position.x
		wide_rect.end.x = viewport_width - perfectly_cropped.position.x
	
	wide_rect.size.y = perfectly_cropped.size.y
	wide_rect.position.y = perfectly_cropped.position.y
	return wide_rect


func update_resolution_size_label(perspective, max_used_rect):
	var resolution_size_label
	match perspective:
		Anim.FP_FRAMEGROUP:
			resolution_size_label = Nodelist.list["oFpResolutionSizeLabel"]
		Anim.TD_FRAMEGROUP:
			resolution_size_label = Nodelist.list["oTdResolutionSizeLabel"]
	
	if resolution_size_label:
		resolution_size_label.text = str(max_used_rect.size.x) + " x " + str(max_used_rect.size.y)

func update_spinboxes_and_aspect_ratio():
	var CODETIME_START = Time.get_ticks_msec()
	%TdAnimatedImage.update_aspect_ratio_for_trimmed_image()
	%FpAnimatedImage.update_aspect_ratio_for_trimmed_image()
	await get_tree().process_frame # Have to wait for the container aspect ratio to change the aspect ratio of the image.
	oFpOffsetPicker.update_spinboxes()
	oTdOffsetPicker.update_spinboxes()
	print('update_spinboxes: ' + str(Time.get_ticks_msec() - CODETIME_START) + 'ms')

func setting_manually_changed():
	apply_settings_to_current_animation_frames()
	redraw_frames()

func apply_settings_to_current_animation_frames():
	if oFrameManager.currentTDFrameGroup == null: return
	for i in Anim.data[oSelectCurrentAnimation.selected][Anim.TD_FRAMEGROUP].size():
		var td_fg = Anim.data[oSelectCurrentAnimation.selected][Anim.TD_FRAMEGROUP][i]
		var fp_fg = Anim.data[oSelectCurrentAnimation.selected][Anim.FP_FRAMEGROUP][i]
		for frame in td_fg.get_children():
			apply_settings_to_specific_frame(frame)
		for frame in fp_fg.get_children():
			apply_settings_to_specific_frame(frame)
	
	var pFrame = get_tree().get_first_node_in_group("PoserFrame")
	if pFrame: apply_settings_to_specific_frame(pFrame) # When changing model size

func apply_settings_to_specific_frame(frame):
	for id in get_tree().get_nodes_in_group("StoredSetting"):
		id.apply_to_frame(frame)
