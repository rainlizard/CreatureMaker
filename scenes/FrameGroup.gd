extends HBoxContainer

@onready var oFrameManager = Nodelist.list["oFrameManager"]
@onready var oSelectCurrentAnimation = Nodelist.list["oSelectCurrentAnimation"]

const frameScn = preload("res://Frame.tscn")

func add_frame():
	#print("add_frame - " + name )
	var createFrame = frameScn.instantiate()
	add_child(createFrame)
	return createFrame

func frame_count():
	return get_child_count()

func get_frame(idx):
	if idx < 0:
		return null
	if idx < get_child_count():
		return get_child(idx)
	return null

func delete_frame(idx:int):
	if idx == -1 or idx > frame_count() - 1:
		return

	var frame = get_child(idx)
	remove_child(frame)
	frame.queue_free()

func delete_all_frames():
	for frame in get_children():
		remove_child(frame)
		frame.queue_free()
