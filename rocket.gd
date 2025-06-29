# rocket.gd
extends Node3D

# — exported so you can tweak these in the Inspector —
@export var planet_index: int = 3                # which planet to orbit when NOT traveling
@export var orbit_radii := [
	1600,  # SUN
	10,    # MERCURY
	15,    # VENUS
	20,    # EARTH
	10,    # MARS
	200,   # JUPITER
	160,   # SATURN
	70,    # URANUS
	70     # NEPTUNE
]
@export var circular_orbit_speed: float = 0.5    # radians per second (tweak as desired)

# — internal state —
var planets: Array[Node3D]
var angle: float = 0.0

# traveling‐mode state
var traveling := false
var start_id := 0
var end_id := 0
var transfer_elapsed := 0.0
var transfer_duration := 0.0
var a := 0.0
var e := 0.0
var center := Vector3.ZERO

func _ready():
	# grab your planet nodes (must match your scene tree!)
	planets = [
	get_node("../Sun"),
	get_node("../Mercury_O"),
	get_node("../Venus_O"),
	get_node("../Earth_O"),
	get_node("../Mars_O"),
	get_node("../Jupiter_O"),
	get_node("../Saturn_O"),
	get_node("../Uranus_O"),
	get_node("../Neptune_O")
]
	
	# connect the mission launch signal
	var mc = get_node_or_null("../Control/Big panel/Main Box/SelectUI")
	if mc:
		mc.connect("launch_mission", Callable(self, "_on_launch_mission"))

	# we need the global hours for circular orbit positions
	global.connect("hours_updated", Callable(self, "_on_hours_updated"))
	
	set_process(true)


func _on_launch_mission(s_id: int, e_id: int) -> void:
	# begin the transfer!
	start_id = s_id
	end_id   = e_id
	traveling = true
	transfer_elapsed = 0.0

	# 1) compute your two radii (in meters, per your scale)
	var r1 = orbit_radii[start_id]
	var r2 = orbit_radii[end_id]

	# 2) Hohmann transfer ellipse parameters
	a = (r1 + r2) * 0.5
	e = (r2 - r1) / (r2 + r1)
	var b = a * sqrt(1.0 - e*e)

	# 3) approximate HALF‐PERIMETER via Ramanujan, so it's already the transfer arc-length
	var half_perim = PI * (3*(a + b) - sqrt((3*a + b)*(a + 3*b))) / 2.0

	
	var speed_scaled = 17.5  # m per second (thousands of miles per hour)
	transfer_duration = half_perim / speed_scaled

	# 5) figure the two ellipse foci centers by sampling each planet's position 
	#    at departure_time and arrival_time:
	var dep_time = global.HOURSFROMBASETIME
	var arr_time = dep_time + transfer_duration

	var start_xy = planets[start_id]._get_position_in_time(dep_time)
	var end_xy   = planets[end_id]._get_position_in_time(arr_time)

	var start_pos = Vector3(start_xy[0], 0, start_xy[1])
	var end_pos   = Vector3(end_xy[0], 0, end_xy[1])

	# ellipse center is midpoint
	center = (start_pos + end_pos) * 0.5

	# immediately snap rocket to periapsis (theta=0)
	global_position = start_pos


func _process(delta: float) -> void:
	if traveling:
		transfer_elapsed += delta
		# done?
		if transfer_elapsed >= transfer_duration:
			traveling = false
			# lock into circular orbit around destination
			planet_index = end_id
			return

		# compute fraction 0→1 along half‐ellipse
		var frac = transfer_elapsed / transfer_duration
		var theta = lerp(0.0, PI, frac)

		# polar radius for the ellipse
		var r = a * (1.0 - e*e) / (1.0 + e * cos(theta))
		var x = r * cos(theta) - a * e
		var z = r * sin(theta)

		global_position = center + Vector3(x, 0, z)
	else:
		# simple circular orbit around planet_index
		angle += circular_orbit_speed * delta
		var hrs = global.HOURSFROMBASETIME
		var pos2d = planets[planet_index]._get_position_in_time(hrs)
		var planet_pos = Vector3(pos2d[0], 0, pos2d[1])
		var R = orbit_radii[planet_index]
		position = planet_pos + Vector3(R * cos(angle), 0, R * sin(angle))


# update of nothing for rocket, but required to keep your global hours hooked up
func _on_hours_updated(new_h: float) -> void:
	# no internal rocket state depends on raw hours here
	pass
