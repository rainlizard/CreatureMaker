extends PanelContainer

@onready var oFrameManager = Nodelist.list["oFrameManager"]
@onready var oSelectCurrentAnimation = Nodelist.list["oSelectCurrentAnimation"]
var mouse_is_on_panel = false

func _on_height_compare_button_pressed():
	%HeightComparison.visible = !%HeightComparison.visible
	if %HeightComparison.visible == true:
		oFrameManager.set_framegroup_rotation(0)

func _ready():
	for i in %AllHeightImages.get_children():
		if i is TextureRect:
			i.gui_input.connect(_on_gui_input.bind(i))

func _process(delta):
	if visible == false: return

	var current_anim_data = Anim.data[oSelectCurrentAnimation.selected]
	var current_fp_framegroup = current_anim_data[Anim.FP_FRAMEGROUP][0]
	var childNode = current_fp_framegroup.get_frame(0)

	if is_instance_valid(childNode):
		var original_texture = childNode.get_display_frame_texture()
		var trimmed_texture = trim_texture(original_texture)
		%CompareImage.texture = trimmed_texture
	
	
	# Check the mouse position and scroll the ScrollContainer
	if mouse_is_on_panel == true:
		var mouse_position = get_local_mouse_position()
		var scroll_speed = 2500  # Adjust the scroll speed as needed
		if mouse_position.x < size.x * 0.05:  # Left side of the panel
			%HeightCompareScrollContainer.scroll_horizontal -= scroll_speed * delta
		elif mouse_position.x > size.x * 0.95:  # Right side of the panel
			%HeightCompareScrollContainer.scroll_horizontal += scroll_speed * delta
	


func _on_gui_input(event, i):
	if event is InputEventMouseMotion:
		%AllHeightImages.move_child(%CompareImage, i.get_index())

func trim_texture(texture: Texture2D) -> Texture2D:
	var image = texture.get_image()
	var trimmed_texture

	if image:
		var used_rect = image.get_used_rect()
		if used_rect.size.x > 0:
			var trimmed_image = image.get_region(used_rect)
			if trimmed_image:
				trimmed_texture = ImageTexture.create_from_image(trimmed_image)

	return trimmed_texture


func _on_mouse_entered():
	mouse_is_on_panel = true


func _on_mouse_exited():
	mouse_is_on_panel = false
