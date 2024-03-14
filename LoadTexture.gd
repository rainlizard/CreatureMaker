extends Button
@onready var oLoadTextureFileDialog = Nodelist.list["oLoadTextureFileDialog"]
@onready var oPoserFrame = Nodelist.list["oPoserFrame"]
@onready var oCurrentlyLoadedTextureName = Nodelist.list["oCurrentlyLoadedTextureName"]
@onready var oMessage = Nodelist.list["oMessage"]
@onready var oFrameUpdater = Nodelist.list["oFrameUpdater"]

var tex_original
var tex_data
var tex_path = ""

func _on_pressed():
	oLoadTextureFileDialog.popup_centered()


func _on_load_texture_file_dialog_file_selected(path):
	unload_texture()
	load_texture(path)
	oFrameUpdater.apply_settings_to_current_animation_frames()
	oFrameUpdater.redraw_frames()


func load_texture(path):
	Useful.delete_import_files(path)
	oCurrentlyLoadedTextureName.text = ""
	tex_path = path

	var file = FileAccess.open(path, FileAccess.READ)
	if file != null:
		tex_data = file.get_buffer(file.get_length())
		file.close()
	else:
		oMessage.quick("Failed to open texture file: " + path)
		unload_texture()
		return

	var img = Image.new()
	var img_load_error = img.load_png_from_buffer(tex_data)
	if img_load_error != OK:
		oMessage.quick("Failed to load texture data: " + path)
		unload_texture()
		return

	tex_original = ImageTexture.create_from_image(img)
	var successState = true

	if tex_original == null or not tex_original is ImageTexture:
		oMessage.quick("Failed to create texture from image: " + path)
		successState = false

	if not successState:
		unload_texture()
		return
	
	oMessage.quick("Loaded texture: " + path)
	oCurrentlyLoadedTextureName.text = path.get_file()
	
	for id in get_tree().get_nodes_in_group("Frame"):
		id.set_model_texture(tex_original)


#func _process(delta):
	#if Input.is_action_just_pressed("ui_accept"):
		#oTextureSprite2D.save_png("!test.png")

func unload_texture():
	tex_path = ""
	tex_data = null
	tex_original = null
	oCurrentlyLoadedTextureName.text = ""
	for id in get_tree().get_nodes_in_group("Frame"):
		id.set_model_texture(null)
