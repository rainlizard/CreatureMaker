@tool # Important for IncludeOnExport
extends Node
const VERSION = "0.08"

func _ready():
	DisplayServer.window_set_title("CreatureMaker v" + str(VERSION))
