extends Node3D

@export var r1: float = 3
@export var r2: float = 8
@export var speed: float = 17.5        # meters per second
@export var delta_t: float = 0.1       # seconds per update
@export var movement_paused: bool = false
@export var orbiting_planet_index: int = 3  # Default to Earth (index in planets array)

var planet_distances_for_orbit = [
	864, # SUN
	3,   # MERCURY
	7,   # VENUS
	8,   # EARTH
	4,   # MARS
	86,  # JUPITER
	72,  # SATURN
	31,  # URANUS
	30   # NEPTUNE
]

var planets := []

var a: float
var e: float
var b: float
var total_time: float
var steps: int
var current_step: int = 0
var moving: bool = true
var orbit_center: Vector3

func _ready():
	planets = [
		get_node("../Sun"),
		get_node("../Mercury_O/Mercury"),
		get_node("../Venus_O/Venus"),
		get_node("../Earth_O/Earth"),
		get_node("../Mars_O/Mars"),
		get_node("../Jupiter_O/Jupiter"),
		get_node("../Saturn_O/Saturn"),
		get_node("../Uranus_O/Uranus"),
		get_node("../Neptune_O/Neptune")
	]

	# Calculate ellipse parameters
	a = (r1 + r2) / 2.0
	e = (r2 - r1) / (r2 + r1)
	b = a * sqrt(1.0 - e * e)

	# Ramanujan approximation for half-ellipse arc length
	var ellipse_perimeter = PI * (3 * (a + b) - sqrt((3 * a + b) * (a + 3 * b))) / 2.0
	total_time = ellipse_perimeter / speed
	steps = int(total_time / delta_t)

	# Set orbit center to midpoint between both circular orbit centers
	var planet_pos = planets[orbiting_planet_index].global_position
	var orbit_radius = planet_distances_for_orbit[orbiting_planet_index]

	orbit_center = Vector3(planet_pos.x, 0, planet_pos.z)

	# Focus is on the left (per convention), so offset the ellipse to center on orbit_center
	var start_r = r1
	var theta = 0.0
	var r = a * (1.0 - e * e) / (1.0 + e * cos(theta))
	var x = r * cos(theta) - a * e
	var z = r * sin(theta)

	global_position = orbit_center + Vector3(x, 0, z)

	set_process(true)

func _process(delta):
	if movement_paused or not moving:
		return

	if current_step > steps:
		moving = false
		return

	var theta = lerp(0.0, PI, float(current_step) / float(steps))
	var r = a * (1.0 - e * e) / (1.0 + e * cos(theta))
	var x = r * cos(theta) - a * e
	var z = r * sin(theta)

	global_position = orbit_center + Vector3(x, 0, z)

	current_step += 1
	await get_tree().create_timer(delta_t).timeout
