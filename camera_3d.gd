extends Camera3D

var move_speed := 10.0
var mouse_sensitivity := 0.003

var rotation_x := 0.0  # pitch
var rotation_y := 0.0  # yaw

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion:
		rotation_y -= event.relative.x * mouse_sensitivity
		rotation_x -= event.relative.y * mouse_sensitivity
		rotation_x = clamp(rotation_x, deg_to_rad(-90), deg_to_rad(90))
		rotation = Vector3(rotation_x, rotation_y, 0)

func _process(delta):
	var direction := Vector3.ZERO

	if Input.is_action_pressed("move_forward"):
		direction -= transform.basis.z
	if Input.is_action_pressed("move_backward"):
		direction += transform.basis.z
	if Input.is_action_pressed("move_left"):
		direction -= transform.basis.x
	if Input.is_action_pressed("move_right"):
		direction += transform.basis.x

	direction = direction.normalized()
	position += direction * move_speed * delta
