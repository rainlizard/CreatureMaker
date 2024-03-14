extends Button
@onready var oPoserFrame = Nodelist.list["oPoserFrame"]

var camera_perspective = 1

func _ready():
	await get_tree().process_frame
	set_perspective(camera_perspective)

func _on_pressed():
	camera_perspective = int(fmod(camera_perspective+1, 2))
	set_perspective(camera_perspective)

func set_perspective(val):
	match int(val):
		0:
			text = "Side"
			oPoserFrame.set_camera_rotation(Vector3(0,270,0))
		1:
			text = "Front"
			oPoserFrame.set_camera_rotation(Vector3(0,0,0))
