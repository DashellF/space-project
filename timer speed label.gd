extends Label

@export var camera: Camera3D

func _ready():
	await get_tree().process_frame
	if !camera:
		camera = get_viewport().get_camera_3d()  # Method 1: Active camera
		if !camera:
			camera = get_node("/root/Space/Camera3D")
	camera.connect("time_scale_updated", _on_time_scale_updated)
	_on_time_scale_updated(Engine.time_scale)
func _on_time_scale_updated(new_scale: float):
	text = "Speed: #0.1fx" % new_scale
