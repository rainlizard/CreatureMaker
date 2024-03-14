@tool # Needed to enable the script to run in the editor
extends EditorPlugin

var button

func _enter_tree():
	# Create a new button in the editor
	button = Button.new()
	button.text = "AI"
	# Add the button to the toolbar
	add_control_to_container(EditorPlugin.CONTAINER_TOOLBAR, button)
	# Connect the button's pressed signal to a function
	button.pressed.connect(_on_button_pressed)

func _exit_tree():
	# Clean up
	if is_instance_valid(button):
		button.queue_free()

func _on_button_pressed():
	# List of file paths to process (relative to the Godot project root)
	var files = [
		"res://autoload/Anim.gd",
		"res://autoload/Constants.gd",
		"res://autoload/Nodelist.gd",
		"res://autoload/Settings.gd",
		"res://autoload/Useful.gd",
		"res://scenes/AdjustingAxisButton.gd",
		"res://scenes/AniAutoFillButton.gd",
		"res://scenes/CameraPerspectiveButton.gd",
		"res://scenes/FlashingSelector.gd",
		"res://scenes/FrameGroup.gd",
		"res://scenes/second_pass_material.gdshader",
		"res://scenes/SettingWithCheckbox.gd",
		"res://scenes/SettingWithColour.gd",
		"res://scenes/SettingWithLineEdit.gd",
		"res://scenes/SettingWithValue.gd",
		"res://Frame.gd",
		"res://FrameManager.gd",
		"res://FrameUpdater.gd",
		"res://AnimatedImage.gd",
		"res://BuiltInAnimationOptions.gd",
		"res://CenterTutorialLabel.gd",
		"res://CopyPasteCodeWindow.gd",
		"res://DrawingCanvas.gd",
		"res://ExportCreature.gd",
		"res://HeightComparison.gd",
		"res://LoadCreature.gd",
		"res://LoadModel.gd",
		"res://LoadTexture.gd",
		"res://main.gd",
		"res://Mouse3D.gd",
		"res://PosePoint.gd",
		"res://resolution_and_palette.gdshader",
		"res://SaveCreature.gd",
		"res://Screen.gd",
		"res://SelectCurrentAnimation.gd",
		"res://SsaoButtonVisible.gd",
		"res://Stage2.gdshader",
		"res://messages/BigMessageInstance.gd",
		"res://messages/CustomTooltip.gd",
		"res://messages/Message.gd",
		"res://messages/QuickMsgInstance.gd",
	]

	var all_content = ""

	for file_path in files:
		# Using FileAccess.open() to obtain a FileAccess object
		var file = FileAccess.open(file_path, FileAccess.READ)
		if file:
			var content = file.get_as_text()
			var separator = "-------------------\n# File: " + file_path + "\n"
			all_content += separator + "\n" + content + "\n"
			file.close()  # Close the FileAccess object when done
		else:
			printerr("File not found: ", file_path)

	# Set the combined content to the clipboard
	DisplayServer.clipboard_set(all_content)
	print("Content copied to clipboard.")
