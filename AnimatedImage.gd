extends TextureRect
@onready var oSelectCurrentAnimation = Nodelist.list["oSelectCurrentAnimation"]
@onready var oFrameManager = Nodelist.list["oFrameManager"]

var animation_frame_count = 0
var current_frame_index = 0
var time_spent_on_frame = 0
var frame_length = 0.075
var blankTex = ImageTexture.new()

func _ready():
	construct_blank_img()

func _process(delta):
	var current_anim_data = Anim.data[oSelectCurrentAnimation.selected]
	var framesNode:Node
	if name == "TdAnimatedImage":
		framesNode = current_anim_data[Anim.TD_FRAMEGROUP][oFrameManager.current_rotation]
	elif name == "FpAnimatedImage":
		framesNode = current_anim_data[Anim.FP_FRAMEGROUP][oFrameManager.current_rotation]

	animation_frame_count = framesNode.frame_count()

	if animation_frame_count <= 0:
		clear_tex()
	else:
		time_spent_on_frame += delta
		if time_spent_on_frame >= frame_length:
			time_spent_on_frame = 0
			current_frame_index = fmod(current_frame_index + 1.0, animation_frame_count)
			current_frame_index = int(current_frame_index)

			var childNode = framesNode.get_frame(current_frame_index)
			if is_instance_valid(childNode):
				texture = childNode.get_display_frame_texture()

func construct_blank_img():
	var img = Image.create(9, 9, false, Image.FORMAT_RGBA8)
	img.fill(Color(0,0,0,1))
	blankTex = ImageTexture.create_from_image(img)

func clear_tex():
	texture = blankTex

func set_texture_anim_to_first_frame(): # Important when switching between animations. Helps with correct offset values.
	var framesNode:Node
	var current_anim_data = Anim.data[oSelectCurrentAnimation.selected]
	if name == "TdAnimatedImage":
		framesNode = current_anim_data[Anim.TD_FRAMEGROUP][oFrameManager.current_rotation]
		
	elif name == "FpAnimatedImage":
		framesNode = current_anim_data[Anim.FP_FRAMEGROUP][oFrameManager.current_rotation]
	
	animation_frame_count = framesNode.frame_count()
	if animation_frame_count <= 0:
		clear_tex()
	else:
		var childNode = framesNode.get_frame(0)
		if is_instance_valid(childNode):
			texture = childNode.get_display_frame_texture()

func update_aspect_ratio_for_trimmed_image():
	if name == "TdAnimatedImage":
		var frameGroup = Anim.data[oSelectCurrentAnimation.selected][Anim.TD_FRAMEGROUP][oFrameManager.current_rotation]
		if frameGroup.frame_count() > 0:
			var frame = frameGroup.get_frame(0)
			%TdAnimatedAspectRatio.ratio = frame.get_aspect_ratio()
			#%TdOffsetPicker.update_offset_marker_position()
			#%TdOffsetPicker.queue_redraw()
	elif name == "FpAnimatedImage":
		var frameGroup = Anim.data[oSelectCurrentAnimation.selected][Anim.FP_FRAMEGROUP][oFrameManager.current_rotation]
		if frameGroup.frame_count() > 0:
			var frame = frameGroup.get_frame(0)
			%FpAnimatedAspectRatio.ratio = frame.get_aspect_ratio()
			#%FpOffsetPicker.update_offset_marker_position()
			#%FpOffsetPicker.queue_redraw()
