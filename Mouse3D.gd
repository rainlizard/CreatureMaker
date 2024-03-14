extends Node3D


func _input(event):
	if event is InputEventMouseMotion:
		var vp = get_viewport()
		var camera = vp.get_camera_3d()
		var ray_origin = camera.project_ray_origin(event.position)
		var ray_normal = camera.project_ray_normal(event.position)
		var ray_end = ray_origin + ray_normal * 5.0 # set a maximum ray length
		position = ray_end
