extends PanelContainer
@onready var oFrameManager = Nodelist.list["oFrameManager"]
@onready var oLoadModel = Nodelist.list["oLoadModel"]
@onready var oSetLightDistance = Nodelist.list["oSetLightDistance"]
@onready var oSetLightAngle = Nodelist.list["oSetLightAngle"]
@onready var oMessage = Nodelist.list["oMessage"]
@onready var oSetImageScale = Nodelist.list["oSetImageScale"]
@onready var oSetModelScale = Nodelist.list["oSetModelScale"]
@onready var oSelectCurrentAnimation = Nodelist.list["oSelectCurrentAnimation"]
@onready var oLoadTexture = Nodelist.list["oLoadTexture"]

var gltfNodes = []
var localModel
# PoserFrame
var holding_click_to_rotate_model = false

var secondPassMat = preload("res://scenes/second_pass_material.tres")
var scnPosePoint = preload("res://PosePoint.tscn")
var current_pose_point_selected = null

var firstPersonScaleAdjustment = 0.85 # This is just how the game is.

var modelViewportToUse
var iField
var iLights
var iCameraRotationY
var iCameraRotationX
var iCameraClip
var iCamera3D


#func _input(_event):
	#if Input.is_action_just_pressed("ui_down"):
		#var findMeshInstance3D = model_get_part("MeshInstance3D")
		#if is_instance_valid(findMeshInstance3D) == false: return
		#print(findMeshInstance3D.mesh.get("surface_0/material").albedo_texture)

func initialize(add_to_groups):
	for group in add_to_groups:
		add_to_group(group)
	
	setup_node_structure()
	
	flash_select(false)
	
	# Clear previous model node and bone poser nodes. (For PoserFrame)
	for i in iField.get_children():
		i.queue_free()
	
	if oLoadModel.model_scene == null or not oLoadModel.model_scene is PackedScene:
		if name != "PoserFrame":
			oMessage.quick("No model data")
		return

	localModel = oLoadModel.model_scene.instantiate()
	iField.add_child(localModel)
	
	link_model_nodes()
	
	setup_viewport_textures()
	
	if name == "PoserFrame":
		init_bone_posers()
		# Enlarge the posing container to cover most area. This adjusts the ModelViewport also.
		%PosingContainer.stretch = true
		%DisplayFrameUi.visible = false
		custom_minimum_size = Vector2(64,64) # Needs to solve a bug when you resize the poser frame to be too tiny, it spams godot console with errors.
		#%AnimationPlayerForPoserFrame.initialize_anims()
	else:
		%PosingContainer.queue_free()
		hide_light_meshes()
	
	if name == "PoserFrame":
		var oBuiltInAnimationOptions = Nodelist.list["oBuiltInAnimationOptions"]
		print("TEST: " + str(oBuiltInAnimationOptions.aniPlayer))
	
	add_second_pass_material()
	#set_resolution(Vector2(254, 254))
	
	# Just for prettier loading
	modulate.a = 0
	#await RenderingServer.frame_post_draw
	await get_tree().process_frame
	modulate.a = 1

func add_second_pass_material():
	for mat in get_all_surface_materials():
		mat.next_pass = secondPassMat

func set_shader_3d_parameter(para, val):
	for mat in get_all_surface_materials():
		mat.next_pass.set_shader_parameter(para, val)

func set_model_texture(newTex):
	for mat in get_all_surface_materials():
		mat.albedo_texture = newTex

func get_all_surface_materials():
	var array = []
	for mInstance in model_get_all_parts("MeshInstance3D"):
		var m = mInstance.mesh
		for surfID in m.get_surface_count():
			var mat = m.surface_get_material(surfID)
			if mat != null:
				array.append(mat)
	return array

func hide_light_meshes():
	for light in get_lights():
		light.get_node("MeshInstance3D").visible = false

func setup_node_structure():
	if name == "PoserFrame":
		var getModelViewport = get_node_or_null("AspectRatioContainer/ModelViewport")
		if getModelViewport != null: # This function can be called a second time, so don't try to reparent again
			var getPosingContainer = get_node("AspectRatioContainer/PosingContainer")
			getModelViewport.reparent(getPosingContainer)
			modelViewportToUse = get_node("AspectRatioContainer/PosingContainer/ModelViewport")
			%SelectableArea.queue_free()
	else:
		modelViewportToUse = get_node("AspectRatioContainer/ModelViewport")
	
	iField = modelViewportToUse.get_node("Field")
	iLights = modelViewportToUse.get_node("Lights")
	iCameraRotationY = modelViewportToUse.get_node("CameraRotationY")
	iCameraRotationX = modelViewportToUse.get_node("CameraRotationY/CameraRotationX")
	iCameraClip = modelViewportToUse.get_node("CameraRotationY/CameraRotationX/CameraClip")
	iCamera3D = modelViewportToUse.get_node("CameraRotationY/CameraRotationX/CameraClip/Camera3D")

func setup_viewport_textures():
	%EffectsViewportSprite.texture = modelViewportToUse.get_texture()
	%FinalTrimmedViewportSprite.texture = %EffectsViewport.get_texture()
	%DisplayFrameUi.texture = %FinalTrimmedViewport.get_texture()

func get_display_frame_texture():
	return %DisplayFrameUi.texture

func set_camera_rotation(camRot):
	iCameraRotationX.rotation_degrees.x = camRot.x
	iCameraRotationY.rotation_degrees.y = camRot.y

func get_camera_rotation():
	var existing_rotation = Vector3(iCameraRotationX.rotation_degrees.x, iCameraRotationY.rotation_degrees.y, 0)
	return existing_rotation

func set_camera_clip(val):
	iCameraClip.position.z = val

func set_background_colour(col):
	%BackgroundColour.color = col

func get_environment():
	return modelViewportToUse.world_3d.environment

func set_camera_zoom(val):
	# Godot cannot go below this size
	if val <= 0.00001:
		val = 0.00002
	
	iCamera3D.size = val
	
	if is_in_group("FirstPersonFrame"):
		iCamera3D.size *= firstPersonScaleAdjustment

func set_model_image_scale():
	if name == "PoserFrame":
		print("set_model_image_scale")

	var getModelScale = oSetModelScale.setting_value
	var getImageScale = oSetImageScale.setting_value
	var v
	if name == "PoserFrame":
		v = getModelScale
	else:
		v = getModelScale * getImageScale
	localModel.scale = Vector3(v, v, v)

#func set_msaa(val):
	#match val:
		#0: modelViewportToUse.msaa_3d = Viewport.MSAA_DISABLED
		#1: modelViewportToUse.msaa_3d = Viewport.MSAA_2X
		#2: modelViewportToUse.msaa_3d = Viewport.MSAA_4X
		#3: modelViewportToUse.msaa_3d = Viewport.MSAA_8X



func set_bone_posers_colour(col):
	for id in get_tree().get_nodes_in_group("PosePoint"):
		id.get_node("MeshInstance3D").mesh.material.albedo_color = col

func set_bone_posers_size(val):
	for id in get_tree().get_nodes_in_group("PosePoint"):
		id.get_node("MeshInstance3D").scale = Vector3(val, val, val)

func link_model_nodes():
	gltfNodes.clear()
	localModel.propagate_call("add_to_group", ["gltf_node"], true)
	for i in get_tree().get_nodes_in_group("gltf_node"):
		gltfNodes.append(i)
	localModel.propagate_call("remove_from_group", ["gltf_node"], true)

func init_bone_posers():
	var findSkeleton3D = model_get_part("Skeleton3D")
	
	if is_instance_valid(findSkeleton3D) == false:
		return
	
	for i in findSkeleton3D.get_bone_count():
		var p = scnPosePoint.instantiate()
		p.bone_index = i
		p.skeleton_node = findSkeleton3D
		p.frame_parent = self
		iField.add_child(p)

func model_get_all_parts(nameOfPart):
	var array = []
	for i in gltfNodes:
		if i.is_class(nameOfPart):
			array.append(i)
	return array

func model_get_part(nameOfPart):
	for i in gltfNodes:
		if i.is_class(nameOfPart):
			return i

func get_final_viewport():
	return %FinalTrimmedViewport

func _on_selectable_area_gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed == true:
			if is_in_group("AnimationFrame"):
				oFrameManager.selected_frame_index = get_index()

func flash_select(enable):
	if enable == true:
		%FlashingSelectorAnimation.play()
		%FlashingSelector.self_modulate = Color(1, 1, 1, 1)
	else:
		%FlashingSelectorAnimation.stop()
		%FlashingSelector.self_modulate = Color(0, 0, 0, 0)

func set_light_count(numberOfLights):
	var lights = iLights.get_children()
	for i in lights.size():
		if i < numberOfLights:
			lights[i].visible = true
		else:
			lights[i].visible = false
	set_lights_ring_position()

func get_lights():
	return iLights.get_children()

func set_lights_ring_position():
	var angleInDegrees = oSetLightAngle.setting_value
	var lightDistance = oSetLightDistance.setting_value
	
	var lights = []
	for i in iLights.get_children():
		if i.visible == true:
			lights.append(i)

	var numberOfLights = lights.size()
	var offset = (PI / 2)
	for i in numberOfLights:
		if i == 0:
			# Position the first light directly overhead
			lights[i].position = Vector3(0, lightDistance, 0)
			lights[i].rotation_degrees = Vector3(-90, 0, 0)  # Point the light downwards
		else:
			# Position the remaining lights in a ring formation
			var angle = (2 * PI * (i - 1) / (numberOfLights - 1)) + offset
			var x = lightDistance * cos(angle) * sin(deg_to_rad(angleInDegrees))
			var z = lightDistance * sin(angle) * sin(deg_to_rad(angleInDegrees))
			var y = lightDistance * cos(deg_to_rad(angleInDegrees))
			lights[i].position = Vector3(x, y, z)

func _on_posing_container_gui_input(event):
	if name != "PoserFrame":
		return
	
	# If a pose point has been selected then exit
	if is_instance_valid(current_pose_point_selected) == true:
		holding_click_to_rotate_model = false
		return
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed == true:
			holding_click_to_rotate_model = true
		else:
			holding_click_to_rotate_model = false
	
	if event is InputEventMouseMotion:
		if holding_click_to_rotate_model == true:
			iCameraRotationX.rotation_degrees.x -= event.relative.y
			iCameraRotationY.rotation_degrees.y -= event.relative.x

func deselect_pose_point(nodeSelected):
	if current_pose_point_selected == nodeSelected:
		current_pose_point_selected = null

func select_pose_point(nodeSelected):
	current_pose_point_selected = nodeSelected



#● UPDATE_DISABLED = 0 #Do not update the render target.
#● UPDATE_ONCE = 1 #Update the render target once, then switch to UPDATE_DISABLED.
#● UPDATE_WHEN_VISIBLE = 2 #Update the render target only when it is visible. This is the default value.
#● UPDATE_WHEN_PARENT_VISIBLE = 3 #Update the render target only when its parent is visible.
#● UPDATE_ALWAYS = 4 #Always update the render target.
func set_update_mode(val):
	if name == "PoserFrame":
		val = SubViewport.UPDATE_ALWAYS
	%ModelViewport.render_target_update_mode = val
	%EffectsViewport.render_target_update_mode = val
	%FinalTrimmedViewport.render_target_update_mode = val


func update_panel_size():
	var aspectRatio = float(%FinalTrimmedViewport.size.x) / float(%FinalTrimmedViewport.size.y)
	%AspectRatioContainer.ratio = aspectRatio

func get_aspect_ratio():
	return %AspectRatioContainer.ratio
