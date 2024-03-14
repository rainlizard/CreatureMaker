extends Control
@onready var oFrameManager = Nodelist.list["oFrameManager"]
@onready var oTdOffsetX = Nodelist.list["oTdOffsetX"]
@onready var oTdOffsetY = Nodelist.list["oTdOffsetY"]
@onready var oFpOffsetX = Nodelist.list["oFpOffsetX"]
@onready var oFpOffsetY = Nodelist.list["oFpOffsetY"]
@onready var oSelectCurrentAnimation = Nodelist.list["oSelectCurrentAnimation"]
var oAnimatedImage

var holding_click = false

var offset_marker_position = Vector2.ZERO

var offset_marker_visible : bool:
	set(val):
		offset_marker_visible = val
		queue_redraw()
	get:
		return offset_marker_visible

func _on_show_picker_button_pressed():
	offset_marker_visible = !offset_marker_visible


func _ready():
	oAnimatedImage = get_parent()
	oAnimatedImage.gui_input.connect(_on_gui_input)
	oAnimatedImage.resized.connect(_on_resized)
	connect_spinbox_signals()

func _on_gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed == true:
			holding_click = true
		else: # Button released
			holding_click = false
	
	if holding_click == true:
		if name == "TdOffsetPicker":
			Anim.data[oSelectCurrentAnimation.selected][Anim.TD_OFFSET] = pos_to_uvpos(event.position)
		elif name == "FpOffsetPicker":
			Anim.data[oSelectCurrentAnimation.selected][Anim.FP_OFFSET] = pos_to_uvpos(event.position)
		update_spinboxes()
		queue_redraw()

func _on_resized():
	update_offset_marker_position()

func update_offset_marker_position():
	var uvpos
	if name == "TdOffsetPicker":
		uvpos = Anim.data[oSelectCurrentAnimation.selected][Anim.TD_OFFSET]
	elif name == "FpOffsetPicker":
		uvpos = Anim.data[oSelectCurrentAnimation.selected][Anim.FP_OFFSET]
	var resolution = Vector2(1,1)
	if oAnimatedImage.texture != null:
		resolution = oAnimatedImage.texture.get_image().get_size()
	var pixelpos = Useful.uvpos_to_pixelpos(uvpos, resolution)
	offset_marker_position = pixelpos_to_pos(pixelpos)

func update_spinboxes():
	disconnect_spinbox_signals()
	var res = Vector2(1,1)
	if oAnimatedImage.texture != null:
		res = oAnimatedImage.texture.get_image().get_size()
	
	if name == "TdOffsetPicker":
		var maxPixelPos = Useful.uvpos_to_pixelpos(Vector2(1.0, 1.0), res)
		oTdOffsetX.max_value = maxPixelPos.x
		oTdOffsetY.max_value = maxPixelPos.y
		var pixelPos = Useful.uvpos_to_pixelpos(Anim.data[oSelectCurrentAnimation.selected][Anim.TD_OFFSET], res)
		oTdOffsetX.value = pixelPos.x
		oTdOffsetY.value = pixelPos.y
	elif name == "FpOffsetPicker":
		var maxPixelPos = Useful.uvpos_to_pixelpos(Vector2(1.0, 1.0), res)
		oFpOffsetX.max_value = maxPixelPos.x
		oFpOffsetY.max_value = maxPixelPos.y
		var pixelPos = Useful.uvpos_to_pixelpos(Anim.data[oSelectCurrentAnimation.selected][Anim.FP_OFFSET], res)
		oFpOffsetX.value = pixelPos.x
		oFpOffsetY.value = pixelPos.y
	connect_spinbox_signals()
	
	offset_marker_visible = true
	update_offset_marker_position()
	queue_redraw()

func _on_td_offset_x_value_changed(value):
	Anim.data[oSelectCurrentAnimation.selected][Anim.TD_OFFSET].x = value / oTdOffsetX.max_value
	update_spinboxes()

func _on_td_offset_y_value_changed(value):
	Anim.data[oSelectCurrentAnimation.selected][Anim.TD_OFFSET].y = value / oTdOffsetY.max_value
	update_spinboxes()

func _on_fp_offset_x_value_changed(value):
	Anim.data[oSelectCurrentAnimation.selected][Anim.FP_OFFSET].x = value / oFpOffsetX.max_value
	update_spinboxes()

func _on_fp_offset_y_value_changed(value):
	Anim.data[oSelectCurrentAnimation.selected][Anim.FP_OFFSET].y = value / oFpOffsetY.max_value
	update_spinboxes()

func connect_spinbox_signals():
	if name == "TdOffsetPicker":
		oTdOffsetX.value_changed.connect(_on_td_offset_x_value_changed)
		oTdOffsetY.value_changed.connect(_on_td_offset_y_value_changed)
	elif name == "FpOffsetPicker":
		oFpOffsetX.value_changed.connect(_on_fp_offset_x_value_changed)
		oFpOffsetY.value_changed.connect(_on_fp_offset_y_value_changed)

func disconnect_spinbox_signals():
	if name == "TdOffsetPicker":
		oTdOffsetX.value_changed.disconnect(_on_td_offset_x_value_changed)
		oTdOffsetY.value_changed.disconnect(_on_td_offset_y_value_changed)
	elif name == "FpOffsetPicker":
		oFpOffsetX.value_changed.disconnect(_on_fp_offset_x_value_changed)
		oFpOffsetY.value_changed.disconnect(_on_fp_offset_y_value_changed)

func pos_to_uvpos(pos):
	pos.x = clamp(pos.x, 0, oAnimatedImage.size.x)
	pos.y = clamp(pos.y, 0, oAnimatedImage.size.y)
	return pos / oAnimatedImage.size

func pixelpos_to_pos(pixelpos):
	var res = Vector2(1,1)
	if oAnimatedImage.texture != null:
		res = oAnimatedImage.texture.get_image().get_size()
	var sizeInPixels = res
	var percentPos = Vector2(pixelpos) / Vector2(sizeInPixels)
	var pos = (percentPos * oAnimatedImage.size) + (oAnimatedImage.size / (Vector2(sizeInPixels) * 2))
	return pos

func _draw():
	if offset_marker_visible:
		var radius = 5
		draw_circle(offset_marker_position, radius, Color(1, 0, 0, 1))
