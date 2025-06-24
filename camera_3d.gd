extends Camera3D

var offsets = [
	Vector3(-40, 20, 40),  # NEPTUNE
	Vector3(-40, 20, 40),  # URANUS
	Vector3(-80, 40, 80),  # SATURN
	Vector3(-80, 40, 80),  # JUPITER
	Vector3(-5, 2.5, 5),  # MARS
	Vector3(-10, 5, 10),  # EARTH
	Vector3(-10, 5, 10),  # VENUS
	Vector3(-5, 2.5, 5),  # MERCURY
	Vector3(-700, 250, -700)  # SUN
]
var planets = []  #  fill in _ready() to make sure everything is loaded

@export var follow_speed: float = 5.0 

var i = 0
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

func _process(delta):
	if target:
		var desired_position = target.global_transform.origin + offset
		global_transform.origin = global_transform.origin.lerp(desired_position, delta * follow_speed)
		look_at(target.global_transform.origin, Vector3.UP)
	
	if Input.is_action_just_pressed("up_arrow"):
		i = (i + 1) % offsets.size()
		offset = offsets[i]
		target = planets[i]

	if Input.is_action_just_pressed("down_arrow"):
		i = (i - 1 + offsets.size()) % offsets.size()
		offset = offsets[i]
		target = planets[i]
