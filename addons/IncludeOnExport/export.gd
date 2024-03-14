@tool
extends EditorExportPlugin

var output_root_dir
var theExportFeatures
var getVer

func _export_begin(features, is_debug, export_path, flags):
	var getScript = load("res://autoload/Constants.gd") # Important to get the most updated string
	getVer = getScript.VERSION
	
	theExportFeatures = features
	output_root_dir = export_path.get_base_dir()
	# path variable is "D:/Godot/Export/CreatureMaker/Creature Maker.exe"
	
	# Recursively copy entire "res://data/" folder to path.get_base_dir()
	include_directory_with_export(export_path, "res://data/")
	include_directory_with_export(export_path, "res://models/")

func _export_end():
	print("CreatureMaker v" + getVer)
#	if OS.get_name() == "Windows":
#		zip_it_up(output_root_dir)

func include_directory_with_export(export_path, dir_to_include):
	export_path = export_path.get_base_dir()
	
	var dirsAndFilesArray = get_dir_contents(dir_to_include) # files
	var dirsArray = dirsAndFilesArray[0]
	var filesArray = dirsAndFilesArray[1]
	
	var asdf = DirAccess.open(export_path)
	
	for i in dirsArray:
		var aaa = asdf.get_current_dir().path_join(i.trim_prefix("res://"))
		asdf.make_dir_recursive(aaa)
	
	for i in filesArray:
		var aaa = asdf.get_current_dir().path_join(i.trim_prefix("res://"))
		asdf.copy(i, aaa)
		print("Copied to: " + aaa)


func get_dir_contents(rootPath):
	var files = []
	var directories = []
	var dir = DirAccess.open(rootPath)
	
	if dir:
		dir.list_dir_begin()
		_add_dir_contents(dir, directories, files)
		directories.append(rootPath) # Include the base directory in the list of directories as well
	else:
		push_error("An error occurred when trying to access the path.")

	return [directories, files]

func _add_dir_contents(dir: DirAccess, directories: Array, files: Array):
	var file_name = dir.get_next()

	while (file_name != ""):
		var path = dir.get_current_dir() + "/" + file_name

		if dir.current_is_dir():
			#print("Found directory: %s" % path)
			var subDir = DirAccess.open(path)
			subDir.list_dir_begin()
			directories.append(path)
			_add_dir_contents(subDir, directories, files)
		else:
			#print("Found file: %s" % path)
			if path.get_extension() != "import": # Ignore .import files
				files.append(path)

		file_name = dir.get_next()

	dir.list_dir_end()


#func zip_it_up(folder_to_zip_up):
#	print("zip it up!")
#	print(theExportFeatures)
#	var createFileName
#	if theExportFeatures.has("windows") == true: # On 3.5, it's capitalized "Windows", on 4.0 it's lowercase "windows"
#		createFileName = "CreatureMaker v" + getVer + ".zip"
#	else:
#		createFileName = "CreatureMakerLinux v" + getVer + ".zip"
#
#	var output_zip_filepath = folder_to_zip_up.get_base_dir().path_join(createFileName)
#	# Create new zip file
#	run_minizip(folder_to_zip_up, output_zip_filepath)
#	# Delete the directory we zipped up
#	#delete_files_and_folders(source_folder_path)
#
#	# Open the directory of the zip file we created
#	OS.shell_open(folder_to_zip_up.get_base_dir())
#
#func run_minizip(folder_to_zip_up: String, output_zip_filepath: String):
#	print("output_zip_filepath: " + output_zip_filepath)
#	print("folder_to_zip_up: " + folder_to_zip_up)
#
#	# Construct the command in parts for clarity
#	var command = ""
#	command += "cd /d \"" + folder_to_zip_up.get_base_dir() + "\""
#	command += " && "
#	command += ProjectSettings.globalize_path("res://addons/IncludeOnExport/minizip.exe") + " -o -i \"" + output_zip_filepath.get_base_dir().path_join(output_zip_filepath.get_file()) + "\" \"" + folder_to_zip_up.get_file() + "\""
#	print(command)
#
#	var output = Array()
#	var err_output = Array()
#	var exit_code = OS.execute("cmd.exe", ["/C", command], output)
#
#	if exit_code == 0:
#		print("Minizip executed successfully")
#		#print("Output: ", output)
#	else:
#		print("Minizip execution failed")
#		#print("Error output: ", output)
