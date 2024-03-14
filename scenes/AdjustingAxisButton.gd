extends Button

var axis_type = 0

func _ready():
	await get_tree().process_frame
	switch_axis(axis_type)

func _on_pressed():
	axis_type = int(fmod(axis_type+1, 3))
	switch_axis(axis_type)

func switch_axis(val):
	match int(val):
		0:
			text = "Adjust X axis"
			self_modulate = Color(1,0.5,0.5,1)
		1:
			text = "Adjust Y axis"
			self_modulate = Color(0.5,1,0.5,1)
		2:
			text = "Adjust Z axis"
			self_modulate = Color(0.5,0.5,1,1)
