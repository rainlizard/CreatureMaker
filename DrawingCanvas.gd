extends TextureRect
@onready var oMain = Nodelist.list["oMain"]

var imgCanvas = Image.new()
var texCanvas = ImageTexture.new()

func _ready():
	imgCanvas = Image.create(359, 198, false, Image.FORMAT_RGB8)
	texCanvas.set_image(imgCanvas)

var holdDraw = false
func _on_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed == true:
				holdDraw = true
			else:
				holdDraw = false
	
	if holdDraw == true:
		if event is InputEventMouseMotion:
			var mpos = (event.global_position-global_position) / oMain.SCREEN_SCALE
			imgCanvas.set_pixelv(mpos, Color(1,1,1,1))
			update_tex()

func update_tex():
	texCanvas.update(imgCanvas)
	texture = texCanvas
	
	for frame in get_tree().get_nodes_in_group("AnimationFrame"):
		frame.set_model_texture(texture)
