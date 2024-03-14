@tool # Important for IncludeOnExport
extends Node
const VERSION = "0.07"

func _ready():
	DisplayServer.window_set_title("CreatureMaker v" + str(VERSION))
