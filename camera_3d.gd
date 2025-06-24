extends Camera3D

# Free camera settings
var freecamera := false
var time := false

var move_speed := 10.0
var target_speed := 10.0
var speed_acceleration := 5.0  # How quickly move_speed catches up to target_speed

var mouse_sensitivity := 0.003
var rotation_x := 0.0  # pitch
var rotation_y := 0.0  # yaw

# Planet offset configuration
var offsets := [
	Vector3(-40, 20, 40),  # NEPTUNE
	Vector3(-40, 20, 40),  # URANUS
	Vector3(-80, 40, 80),  # SATURN
	Vector3(-80, 40, 80),  # JUPITER
	Vector3(-5, 2.5, 5),   # MARS
	Vector3(-10, 5, 10),   # EARTH
	Vector3(-10, 5, 10),   # VENUS
	Vector3(-5, 2.5, 5),   # MERCURY
	Vector3(-700, 250, -700)  # SUN
]
var planets := []

@export var follow_speed: float = 5.0

var i := 0
var offset: Vector3
var target: MeshInstance3D


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	planets = [
		get_node("../orbit8/Neptune"),
		get_node("../orbit7/Uranus"),
		get_node("../orbit6/Saturn"),
		get_node("../orbit5/Jupiter"),
		get_node("../orbit4/Mars"),
		get_node("../orbit/Earth"),
		get_node("../orbit2/Venus"),
		get_node("../orbit3/Mercury"),
		get_node("../Sun")
	]

	offset = offsets[i]
	target = planets[i]


func _input(event):
	if event is InputEventMouseButton and event.pressed:
		# Scroll wheel: either affects time_scale or camera speed
		if time:
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				Engine.time_scale = clamp(Engine.time_scale * 1.1, 0.1, 10.0)
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				Engine.time_scale = clamp(Engine.time_scale / 1.1, 0.1, 10.0)
		elif freecamera:
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				target_speed = clamp(target_speed * 1.2, 1.0, 100000.0)
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				target_speed = clamp(target_speed / 1.2, 1.0, 100000.0)

	if freecamera and event is InputEventMouseMotion:
		# Adjust sensitivity based on time scale to avoid wild jumps
		var effective_sensitivity := mouse_sensitivity / Engine.time_scale
		rotation_y -= event.relative.x * effective_sensitivity
		rotation_x -= event.relative.y * effective_sensitivity
		rotation_x = clamp(rotation_x, deg_to_rad(-90), deg_to_rad(90))
		rotation = Vector3(rotation_x, rotation_y, 0)


func _process(delta):
	if target:
		var desired_position = target.global_transform.origin + offset
		global_transform.origin = global_transform.origin.lerp(desired_position, delta * follow_speed)
		look_at(target.global_transform.origin, Vector3.UP)

	if !freecamera:
		if Input.is_action_just_pressed("up_arrow") and !time:
			i = (i + 1) % offsets.size()
			offset = offsets[i]
			target = planets[i]
		if Input.is_action_just_pressed("down_arrow") and !time:
			i = (i - 1 + offsets.size()) % offsets.size()
			offset = offsets[i]
			target = planets[i]
	else:
		move_speed = lerp(move_speed, target_speed, delta * speed_acceleration)

		var direction := Vector3.ZERO
		if Input.is_action_pressed("up_arrow"):
			direction -= transform.basis.z
		if Input.is_action_pressed("down_arrow"):
			direction += transform.basis.z
		if Input.is_action_pressed("left_arrow"):
			direction -= transform.basis.x
		if Input.is_action_pressed("right_arrow"):
			direction += transform.basis.x

		direction = direction.normalized()
		# Decouple movement from time_scale for consistent control
		position += direction * move_speed * delta / Engine.time_scale


	# T key toggles time control mode
	if Input.is_action_just_pressed("t_key"):
		time = true
	if Input.is_action_just_released("t_key"):
		time = false

	# F key toggles free camera mode
	if Input.is_action_just_pressed("f_key") and !time:
		freecamera = !freecamera
		if freecamera:
			target = null
		else:
			target = planets[i]
