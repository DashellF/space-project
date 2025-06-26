extends HBoxContainer

@export var camera_path: NodePath
@onready var camera: Camera3D = get_node(camera_path) if camera_path else null

func _ready():
	await get_tree().process_frame
	if !camera:
		camera = get_viewport().get_camera_3d()
		if !camera:
			push_error("No camera found")
			return
	else:
		printerr("camera not found :<")

	camera = get_viewport().get_camera_3d()

	$SlowerButton.pressed.connect(_on_slower_pressed)
	$FasterButton.pressed.connect(_on_faster_pressed)
	camera.time_scale_updated.connect(_update_speed_label)
	_update_speed_label(Engine.time_scale)
func _on_slower_pressed():
	camera._change_time_scale(-0.1)
func _on_faster_pressed():
	camera._change_time_scale(0.1)

func _update_speed_label(new_scale: float):
	$SpeedLabel.text = "Speed: %.1fx" % new_scale
		
