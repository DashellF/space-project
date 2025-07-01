extends Node3D

signal ellipse_parameters(a: float, e: float, offset_theta: float, theta_range: float)

@export var planet_index: int = 3
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
@export var circular_orbit_speed: float = 0.5
@onready var mesh = self
var last_position: Vector3
var planets: Array[Node3D]
var angle: float = 0.0
var speed = 175
var _ellipse_a = 0.0
var _ellipse_e = 0.0
var _ellipse_c = 0.0
var _ellipse_center = Vector2.ZERO
var _ellipse_rotation = 0.0
var delta_theta_total
var traveling := false
var start_id := 0
var end_id := 0


var R1
var R2
var theta1
var theta2
var mu = 6.7237 * pow(10,13)  # gravity of the sun in miles³/hour²
var center := Vector3.ZERO

var total_transfer_time := 0.0
var elapsed_transfer_time := 0.0
var rockettag
var _ellipse_offset_theta = 0.0

func get_current_orbit_params() -> Dictionary:
	return {
		"traveling": traveling,
		"a": _ellipse_a,
		"e": _ellipse_e,
		"offset_theta": _ellipse_offset_theta,
		"elapsed_time": elapsed_transfer_time,
		"total_time": total_transfer_time,
		"theta_range": delta_theta_total,
		"planet_index": planet_index,
		"circular_orbit_speed": circular_orbit_speed,
		"angle": angle
	}


func _ready():
	rockettag = get_node("Rocket_tag")
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

	var mc = get_node_or_null("../Control/Big panel/Main Box/SelectUI")
	if mc:
		mc.connect("launch_mission", Callable(self, "_on_launch_mission"))

	global.connect("hours_updated", Callable(self, "_on_hours_updated"))
	if not global.is_connected("timespeed_updated", Callable(self, "_on_timespeed_updated")):
		global.connect("timespeed_updated", Callable(self, "_on_timespeed_updated"))
	set_process(true)
	last_position = position


func _on_launch_mission(s_id: int, e_id: int) -> void:
	start_id = s_id
	end_id = e_id
	rockettag.position.x = 5
	R1 = planets[start_id].orbit_radius
	R2 = planets[end_id].orbit_radius
	theta1 = planets[start_id].angle
	var theta2_s = planets[end_id].angle

	# Compute final angle based on how long the transfer takes
	theta2 = compute_theta2_after_transfer(R1, R2, theta1, theta2_s, mu, speed)

	# True angle difference
	delta_theta_total = fmod(theta2 - theta1 + TAU, TAU)

	# Semi-major axis and eccentricity for Hohmann ellipse
	var a = (R1 + R2) / 2.0
	var e = abs(R2 - R1) / (R1 + R2)
	emit_signal("ellipse_parameters", a, e, theta1, delta_theta_total)
	var arc_length = 0.0
	var steps = 1000
	var delta_theta = delta_theta_total / steps
	var prev_theta = 0.0
	var prev_r = a * (1 - e * e) / (1 + e * cos(prev_theta))

	for i in range(1, steps + 1):
		var theta = i * delta_theta
		var r = a * (1 - e * e) / (1 + e * cos(theta))
		var x1 = prev_r * cos(prev_theta)
		var y1 = prev_r * sin(prev_theta)
		var x2 = r * cos(theta)
		var y2 = r * sin(theta)
		arc_length += sqrt(pow(x2 - x1, 2) + pow(y2 - y1, 2))
		prev_theta = theta
		prev_r = r

	# Setup transfer
	total_transfer_time = arc_length / speed
	elapsed_transfer_time = 0.0
	traveling = true

	# Store values for the process
	_ellipse_a = a
	_ellipse_e = e
	_ellipse_offset_theta = theta1


func _process(delta: float) -> void:
	if traveling:
		elapsed_transfer_time += delta

		if elapsed_transfer_time >= total_transfer_time:
			traveling = false
			planet_index = end_id
			var hrs = global.HOURSFROMBASETIME
			var pos2d = planets[planet_index]._get_position_in_time(hrs)
			var planet_pos = Vector3(pos2d[0], 0, pos2d[1])
			var R = orbit_radii[planet_index]
			angle = 0
			position = planet_pos + Vector3(R, 0, 0)
			return

		# Compute how far along the ellipse we are (0 to 1)
		var t_frac = elapsed_transfer_time / total_transfer_time

		# Compute the true anomaly (angle along ellipse from θ1 to θ2)
		var theta = delta_theta_total * t_frac

		# Ellipse polar form: r(θ) = a(1 - e²) / (1 + e cos(θ))
		var r = _ellipse_a * (1 - _ellipse_e * _ellipse_e) / (1 + _ellipse_e * cos(theta))
		
		# Convert polar to Cartesian, offset by starting angle (rotate ellipse)
		var x = r * cos(theta + _ellipse_offset_theta)
		var y = r * sin(theta + _ellipse_offset_theta)

		# Update rocket position in space
		mesh.transform.origin = Vector3(x, 0, y)

	else:
		angle += circular_orbit_speed * delta
		var hrs = global.HOURSFROMBASETIME
		if planets[planet_index] == null:
			push_error("Planet at index %d is null" % planet_index)
			return
		var pos2d = planets[planet_index]._get_position_in_time(hrs)
		var planet_pos = Vector3(pos2d[0], 0, pos2d[1])
		var R = orbit_radii[planet_index]
		position = planet_pos + Vector3(R * cos(angle), 0, R * sin(angle))

	# Face direction of motion
	var velocity_dir = position - last_position
	if velocity_dir.length() > 0.001:
		var y_axis = velocity_dir.normalized()
		var z_axis = Vector3.FORWARD
		if abs(y_axis.dot(z_axis)) > 0.99:
			z_axis = Vector3.RIGHT  # avoid gimbal lock when moving in Z
		var x_axis = z_axis.cross(y_axis).normalized()
		z_axis = y_axis.cross(x_axis).normalized()
		
		var basis = Basis()
		basis.x = x_axis
		basis.y = y_axis
		basis.z = z_axis
		mesh.transform.basis = basis

	last_position = position



func solve_kepler(M: float, e: float, tol: float = 0.000001) -> float:
	var E = M
	for i in range(100):
		var f = E - e * sin(E) - M
		var f_prime = 1 - e * cos(E)
		var E_next = E - f / f_prime
		if abs(E_next - E) < tol:
			break
		E = E_next
	return E


func compute_theta2_after_transfer(R1: float, R2: float, theta1: float, theta2_start: float, mu: float, speed: float) -> float:
	var a = (R1 + R2) / 2.0
	var e = abs(R2 - R1) / (R1 + R2)
	var steps = 1000
	var arc_length = 0.0
	var delta_theta = PI / steps
	var prev_theta = 0.0
	var prev_r = a * (1 - pow(e, 2)) / (1 + e * cos(prev_theta))

	for i in range(1, steps + 1):
		var theta = i * delta_theta
		var r = a * (1 - pow(e, 2)) / (1 + e * cos(theta))
		var x1 = prev_r * cos(prev_theta)
		var y1 = prev_r * sin(prev_theta)
		var x2 = r * cos(theta)
		var y2 = r * sin(theta)
		arc_length += sqrt(pow(x2 - x1, 2) + pow(y2 - y1, 2))
		prev_theta = theta
		prev_r = r
	var transfer_time = arc_length / speed
	var omega = planets[end_id].orbit_speed
	var theta2_final = fmod(theta2_start + omega * transfer_time, TAU)
	return theta2_final


func _on_hours_updated(new_h: float) -> void:
	var time_advanced = new_h - global.HOURSFROMBASETIME
	if traveling:
		time_advanced = new_h - global.HOURSFROMBASETIME
		elapsed_transfer_time += time_advanced
		if elapsed_transfer_time > total_transfer_time:
			elapsed_transfer_time = total_transfer_time
			traveling = false
			planet_index = end_id
	else:
		angle += circular_orbit_speed * time_advanced
func _on_timespeed_updated(new_value: float) -> void:
	speed = 175 * new_value * global.timeSpeed
	circular_orbit_speed =  0.5 * new_value * global.timeSpeed
