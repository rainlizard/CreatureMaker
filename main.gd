extends Node2D
@onready var oFrameManager = Nodelist.list["oFrameManager"]
@onready var oChooseDkExe = Nodelist.list["oChooseDkExe"]
@onready var oMessage = Nodelist.list["oMessage"]
@onready var oLoadCreatureMaker = Nodelist.list["oLoadCreatureMaker"]

var isRunningFromEditor = false

func _enter_tree():
	print("CreatureMaker v"+Constants.VERSION)
	Nodelist.start(self)


func _ready():
	Nodelist.done()
	isRunningFromEditor = OS.has_feature("editor")
	
	oFrameManager.initial()
	
	Settings.initialize_settings()
	
	if isRunningFromEditor == true:
		for i in 50:
			await get_tree().process_frame
		#oLoadCreatureMaker._on_load_animation_file_dialog_file_selected("res://models/Vixen/Vixen.creature")
		oLoadCreatureMaker._on_load_animation_file_dialog_file_selected("res://models/ThornyDragon/ThornyDragon.creature")
		#oLoadCreatureMaker._on_load_animation_file_dialog_file_selected("res://models/Golem/Golem.creature")


# 1. Model
# 2. FrameManager needs to be setup after model
# 3. Animation needs to be loaded after model and FrameManager
# 4. Texture needs to be loaded after model and FrameManager


func _on_select_dk_executable_file_dialog_file_selected(path):
	Settings.game_setting(Settings.SET, "path_executable", path)
