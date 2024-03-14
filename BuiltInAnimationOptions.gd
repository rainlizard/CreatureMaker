extends OptionButton
@onready var oPoserFrame = Nodelist.list["oPoserFrame"]
@onready var oMessage = Nodelist.list["oMessage"]
@onready var oFrameManager = Nodelist.list["oFrameManager"]

var aniPlayer

# Called when the node enters the scene tree for the first time.
func fill_items():
	clear() # Delete previous items
	
	aniPlayer = oPoserFrame.model_get_part("AnimationPlayer")
	if aniPlayer == null:
		return
	
	add_item("") # Need a blank animation so you can do your own
	for i in aniPlayer.get_animation_list():
		add_item(i)


func _on_item_selected(index):
	if aniPlayer == null:
		oMessage.quick("aniPlayer is null")
		return
	
	var skele = oPoserFrame.model_get_part("Skeleton3D")
	if skele == null:
		oMessage.quick("No skeleton found.")
		return
	
	# Need to reset bones whenever switching animation
	skele.reset_bone_poses()
	
	if index == 0:
		aniPlayer.stop(true)
		return
	
	var menuOptionString = get_item_text(index)
	aniPlayer.play(menuOptionString)


func _on_built_in_anim_slider_value_changed(value):
	if aniPlayer == null:
		return
	if aniPlayer.assigned_animation == "":
		return
	aniPlayer.pause()
	aniPlayer.seek(value * aniPlayer.current_animation_length, true)
	oFrameManager.current_frame_copies_poser()
