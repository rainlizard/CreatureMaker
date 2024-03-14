extends Node3D
@onready var oMouse3D = Nodelist.list["oMouse3D"]
@onready var oAdjustingAxisButton = Nodelist.list["oAdjustingAxisButton"]
@onready var oFrameManager = Nodelist.list["oFrameManager"]

var frame_parent:Node = null
var bone_index:int
var skeleton_node:Node

var dragging_type:int = 0:
	set(val):
		dragging_type = val
		if dragging_type == 0:
			frame_parent.deselect_pose_point(self)
		else:
			frame_parent.select_pose_point(self)
	get:
		return dragging_type

func _on_area_3d_input_event(_camera, event, _pos, _normal, _shape_idx):
	if event is InputEventMouseButton and event.pressed:
		if Input.is_action_pressed("dragging_modifier"):
			if event.button_index == MOUSE_BUTTON_LEFT:
				dragging_type = 2
		else:
			if event.button_index == MOUSE_BUTTON_LEFT:
				dragging_type = 1
		print('dragging')

func _input(event):
	if event is InputEventMouseButton and event.pressed == false:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if dragging_type == 1:
				dragging_type = 0
				print('dragging released')
			if dragging_type == 2:
				dragging_type = 0
				print('dragging released')
	
	if dragging_type > 0:
		if event is InputEventMouseMotion:
			if is_instance_valid(skeleton_node) == false: return
			
			var bone_rotation = skeleton_node.get_bone_pose_rotation(bone_index)
			var bone_global_pose = skeleton_node.get_bone_global_pose(bone_index)
			var bone_fully_global_transform = bone_global_pose * skeleton_node.global_transform
			var camera = get_viewport().get_camera_3d()
			var camera_global_transform = camera.get_global_transform()
			
			match dragging_type:
				1:
					# These commented lines are important! Do not delete!
					var new_rotation = rotate_bone(bone_rotation, event.relative, bone_fully_global_transform, camera_global_transform)
					skeleton_node.set_bone_pose_rotation(bone_index, new_rotation)
					
#					var new_rotation = rotate_bone2(bone_rotation, bone_global_pose, bone_fully_global_transform, camera_global_transform)
#					skeleton_node.set_bone_pose_rotation(bone_index, new_rotation)
				2:
					# This is a mess, but interesting.
					var mouse_position = skeleton_node.to_local(oMouse3D.global_transform.origin)
					var new_global_transform = Transform3D(bone_global_pose.basis, mouse_position)
					skeleton_node.set_bone_global_pose_override(bone_index, new_global_transform, 1.0, true)
			oFrameManager.current_frame_copies_poser()

func _process(_delta):
	if skeleton_node:
		var bone_transform = skeleton_node.global_transform * skeleton_node.get_bone_global_pose(bone_index)

		# Extract the position and rotation from the bone transform
		var bone_position = bone_transform.origin
		var bone_rotation = bone_transform.basis.orthonormalized()

		# Create a new Transform3D without scaling
		global_transform = Transform3D(bone_rotation, bone_position)


# Rotates the bone in the direction of mouse_relative_movement
# dragging_axis is 1 when left clicking and 2 when right clicking
func rotate_bone(bone_rotation : Quaternion, mouse_relative_movement : Vector2, bone_fully_global_transform : Transform3D, camera_global_transform : Transform3D):

	var angle_x = -mouse_relative_movement.y * 0.01  # rotate around x-axis
	var angle_y = -mouse_relative_movement.x * 0.01  # rotate around y-axis
	
	if angle_x == 0 && angle_y == 0:
		return bone_rotation

	#var camera_bone_transform = camera_global_transform * bone_fully_global_transform #camera_global_transform.affine_inverse() is unnecessary?

	var rotationVec = Vector3()
	match oAdjustingAxisButton.axis_type:
		0: # X
			rotationVec = Vector3(-1,0,0)
		1: # Y
			rotationVec = Vector3(0,-1,0)
		2: # Z
			rotationVec = Vector3(0,0,-1)
	
	var q_x = Quaternion(rotationVec.normalized(), angle_x)
	var q_y = Quaternion(rotationVec.normalized(), angle_y)
	
	return q_x * q_y * bone_rotation


#func rotate_bone2(bone_rotation:Quaternion, bone_global_pose:Transform3D, bone_fully_global_transform:Transform3D, camera_global_transform:Transform3D):
#	var mouse_position = skeleton_node.to_local(oMouse3D.global_transform.origin)
#
#	# Get the direction vector towards the mouse position
#	var direction = (mouse_position - bone_fully_global_transform.origin).normalized()
#
#	# Calculate the angle to rotate around the Y and X axis
#	var angle_y = atan2(direction.x, direction.z)
#	var angle_x = atan2(direction.y, direction.z)
#
#	# Create the new rotation quaternion
#	var q_y = Quaternion(Vector3(0, 1, 0), angle_y)
#	var q_x = Quaternion(Vector3(0, 0, -1), angle_x)
#	var new_rotation = q_y * q_x
#
#	# Return the new rotation quaternion
#	return new_rotation


#func mouse_to_rotation(start_pos: Vector2, end_pos: Vector2) -> Quaternion:
#	print('``````````````')
#	var from = trackball_map(start_pos)
#	var to = trackball_map(end_pos)
#	var angle = from.angle_to(to)
#	var axis = from.cross(to)
#	axis = axis.normalized()
#	print(axis)
#	#axis = Vector3(1,0,0)
#	return Quaternion(axis, angle)
#
#
#func trackball_map(point: Vector2, radius: float = 1.0) -> Vector3:
#	# Project the point onto the surface of the unit sphere
#	var p = Vector3(point.x, point.y, 0.0)
#	var dist = p.length()

#		p.z = sqrt(radius * radius - dist * dist)
#	else:
#		p.z = (radius * radius) / (2.0 * dist)
#	return p.normalized()
