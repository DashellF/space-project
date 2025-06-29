extends MeshInstance3D

@export var r1: float = 1.0
@export var r2: float = 2.0
@export var speed: float = 17.5        # meters per second
@export var delta_t: float = 0.1       # seconds per update
@export var movement_paused: bool = false

var a: float
var e: float
var b: float
var total_time: float
var steps: int
var current_step: int = 0
var moving: bool = true

func _ready():
	a = (r1 + r2) / 2.0
	e = (r2 - r1) / (r2 + r1)
	b = a * sqrt(1.0 - e * e)

	# Approximate half-ellipse perimeter (Ramanujan)
	var ellipse_perimeter = PI * (3 * (a + b) - sqrt((3 * a + b) * (a + 3 * b))) / 2.0
	total_time = ellipse_perimeter / speed
	steps = int(total_time / delta_t)

	# Optional: center the whole path visually
	global_position = Vector3(r1, 0, 0)  # Start at θ = 0

	set_process(true)

func _process(delta):
	if movement_paused or not moving:
		return

	if current_step > steps:
		moving = false
		return

	var theta = lerp(0.0, PI, float(current_step) / float(steps))
	var r = a * (1.0 - e * e) / (1.0 + e * cos(theta))
	var x = r * cos(theta)
	var y = r * sin(theta)

	global_position = Vector3(x, 0, y)

	current_step += 1
	await get_tree().create_timer(delta_t).timeout
