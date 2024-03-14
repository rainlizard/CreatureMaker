extends Node

var creaturemaker_path = ""
var settings_file_path = ""
var config = ConfigFile.new()

enum {
	SET = 0,
	GET = 1,
}

var PATH_EXECUTABLE = ""
var PATH_DK_DIR = ""

var listOfSettings = [
	"path_executable",
]


func set_paths(exe_path):
	PATH_EXECUTABLE = exe_path
	PATH_DK_DIR = exe_path.get_base_dir()


func _init():
	if OS.has_feature("standalone") == true:
		# Create settings.cfg next to creaturemaker.exe
		creaturemaker_path = OS.get_executable_path().get_base_dir()
	else:
		creaturemaker_path = ""


func initialize_settings():
	settings_file_path = creaturemaker_path.path_join("settings.cfg")
	var loadError = config.load(settings_file_path)
	if loadError != OK:
		var saveError = config.save(settings_file_path)
		
		if saveError != OK:
			var oMessage = Nodelist.list["oMessage"]
			oMessage.big("Error", "Cannot create settings.cfg: Error "+ str(saveError) + "\n" + "Please exit the program and move the CreatureMaker directory elsewhere.")
			return
	
	read_all()
	
	executable_stuff()


func executable_stuff():
	# If previous path_executable is no longer valid (maybe it was deleted)
	if config.has_section_key("settings", "path_executable") == true:
		var file = FileAccess.open(PATH_EXECUTABLE, FileAccess.READ)
		if !file:
			config.erase_section_key("settings", "path_executable")
	
	# Choose executable path upon first starting
	if config.has_section_key("settings", "path_executable") == false:
		var oChooseDkExe = $'../Main/ChooseDkExe'
		oChooseDkExe.popup_centered()


func read_all():
	# Read all
	var CODETIME_START = Time.get_ticks_msec()
	for i in listOfSettings:
		if config.has_section_key("settings", i) == true:
			var value = config.get_value("settings", i)
			if value != null:
				game_setting(SET, i, value)
	print('Read all settings in: ' + str(Time.get_ticks_msec() - CODETIME_START) + 'ms')


func game_setting(doWhat, stringSetting, value):
	match stringSetting:
		"path_executable":
			if doWhat == SET: set_paths(value)
			if doWhat == GET: return PATH_EXECUTABLE
	
	if doWhat == SET:
		config.set_value("settings", stringSetting, value)
		config.save(settings_file_path)

