extends Button
@onready var oLoadModelFileDialog = Nodelist.list["oLoadModelFileDialog"]
@onready var oFrameManager = Nodelist.list["oFrameManager"]
@onready var oMessage = Nodelist.list["oMessage"]
@onready var oCurrentlyLoadedModelName = Nodelist.list["oCurrentlyLoadedModelName"]
@onready var oLoadTexture = Nodelist.list["oLoadTexture"]
@onready var oBuiltInAnimationOptions = Nodelist.list["oBuiltInAnimationOptions"]
@onready var oFrameUpdater = Nodelist.list["oFrameUpdater"]

var model_scene
var model_data
var model_path = ""


func _on_pressed():
	oLoadModelFileDialog.popup_centered()


func _on_load_model_file_dialog_file_selected(path):
	var loadModelErrState = load_model(path)
	if loadModelErrState == ERR_FILE_NOT_FOUND:
		oMessage.quick("Model file not found: " + path)
	elif loadModelErrState == ERR_FILE_UNRECOGNIZED:
		var ext = path.get_extension().to_lower()
		oMessage.quick("Unsupported model file format: " + ext)
	elif loadModelErrState == ERR_FILE_CORRUPT:
		oMessage.quick("Failed to load model file: " + path)


func load_model(path):
	Useful.delete_import_files(path)

	if not FileAccess.file_exists(path):
		return ERR_FILE_NOT_FOUND

	var file = FileAccess.open(path, FileAccess.READ)
	if file != null:
		model_data = file.get_buffer(file.get_length())
		file.close()
	else:
		return ERR_FILE_CORRUPT

	var gltf_doc = GLTFDocument.new()
	var gltf_state = GLTFState.new()
	var ext = path.get_extension().to_lower()

	if ext == "glb" or ext == "gltf":
		var err = gltf_doc.append_from_buffer(model_data, "", gltf_state, 0)
		if err != OK:
			return ERR_FILE_CORRUPT
	else:
		return ERR_FILE_UNRECOGNIZED


	var generatedNode = gltf_doc.generate_scene(gltf_state)
	if generatedNode != null:
		var mscn = PackedScene.new()
		mscn.pack(generatedNode)
		model_scene = mscn
	else:
		model_scene = null

	var successState = true
	if model_scene == null or not model_scene is PackedScene:
		successState = false

	if not successState:
		model_scene = null
		model_path = ""
		oCurrentlyLoadedModelName.text = ""
		return FAILED

	model_path = path
	oMessage.quick("Loaded model: " + str(path))
	oCurrentlyLoadedModelName.text = path.get_file()
	oLoadTexture.unload_texture()
	oFrameManager.new_frames()
	oFrameManager.set_up_poser()
	oBuiltInAnimationOptions.fill_items()

	return OK
