extends Node

func uvpos_to_pixelpos(uv_pos, resolution):
	var pixelPosition = Vector2(resolution) * uv_pos
	pixelPosition = Vector2(floor(pixelPosition.x), floor(pixelPosition.y))
	pixelPosition.x = clamp(pixelPosition.x, 0, resolution.x-1)
	pixelPosition.y = clamp(pixelPosition.y, 0, resolution.y-1)
	return pixelPosition

func delete_import_files(path):
	var baseDir = path.get_base_dir()
	var deletePath = baseDir.path_join(path.get_file()+".import")
	
	var s = DirAccess.open(baseDir)
	s.remove(deletePath)
	#OS.move_to_trash(path)

#func _process(delta):
	#if Input.is_action_just_pressed("ui_accept"):
		#for frame in get_tree().get_nodes_in_group("Frame"):
			#if frame.is_visible_in_tree() == true:
				#var effects_viewport_texture = frame.get_node("%FinalTrimmedViewport").get_texture()
				#var image = effects_viewport_texture.get_image()
				#image.save_png(str(frame.get_index()) + ".png")
