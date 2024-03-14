extends Label
@onready var oBottomPoserAndControls = Nodelist.list["oBottomPoserAndControls"]
@onready var oFrameManager = Nodelist.list["oFrameManager"]
@onready var oLoadModel = Nodelist.list["oLoadModel"]

func _process(_delta):
	if is_instance_valid(oFrameManager.currentTDFrameGroup) == false or is_instance_valid(oFrameManager.currentFPFrameGroup) == false:
		return

	text = "Add a frame"

	if oLoadModel.model_scene == null:
		text = "Load a model or open data"

	if oFrameManager.currentTDFrameGroup.frame_count() > 0 and oFrameManager.currentFPFrameGroup.frame_count() > 0:
		if oBottomPoserAndControls.visible == false:
			text = "Click a frame to edit it"
		else:
			text = ""
