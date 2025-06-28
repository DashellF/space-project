extends Camera3D

var freecamera := false
var time := false
var moon := false
var titleScreen := true

signal time_scale_updated(new_scale)
var min_time_scale := 0.1
var max_time_scale := 10.0
var time_scale_step := 0.1

var earth_luna_view = false
var horizontal_lock_view := false
var horizontal_view_height := 120 
var mouse := true

var move_speed := 10.0
var target_speed := 10.0
var speed_acceleration := 5.0

var mouse_sensitivity := 0.003
var rotation_x := 0.0
var rotation_y := 0.0

var orbit_angle_y := 0.0
var orbit_distance := 100.0
var orbit_distances := []

var offsets := [
	Vector3(-700, 250, -700),
	Vector3(-5, 2.5, 5),
	Vector3(-10, 5, 10),
	Vector3(-10, 5, 10),
	Vector3(-5, 2.5, 5),
	Vector3(-80, 40, 80),
	Vector3(-80, 40, 80),
	Vector3(-40, 20, 40),
	Vector3(-40, 20, 40),
]

var planets := []
var orbit_lines := []
var logo
var i := 0
var earth_moon := []
var earth_moon_offset := []
var mars_moons := []
var mars_moons_offset := []
var earth_luna_view_offset = Vector3(0,124,0)
var cam_loc := []
var k := 0
var planets_names := [
	"Sol", "Mercury", "Venus", "Earth", "Mars", "Jupiter", "Saturn", "Uranus", "Neptune"
]
signal planet_num(planet)

@export var follow_speed: float = 5.0

var target: Node3D
var orbit_target: Node3D  # the actual node we orbit around (planet center node)

func _ready():
	await get_tree().process_frame
	
	if mouse:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	logo = get_node("../TITLE")
	orbit_lines = [
	get_node("../Sun"),  # Assuming Sun has no orbital line
	get_node("../Mercury_O/MEOrbLine"),
	get_node("../Venus_O/VEOrbLine"),
	get_node("../Earth_O/EAOrbLine"),
	get_node("../Mars_O/MAOrbLine"),
	get_node("../Jupiter_O/JUOrbLine"),
	get_node("../Saturn_O/SAOrbLine"),
	get_node("../Uranus_O/UROrbLine"),
	get_node("../Neptune_O/NEOrbLine")
]
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
	"../Mars_O/MAOrbLine"
	for o in offsets:
		orbit_distances.append(o.length())

	earth_moon = [get_node("../Earth_O/Earth/Earth Moon")]
	earth_moon_offset = [Vector3(-1.1, 1.3, 1.3)]
	mars_moons = [
		get_node("../Mars_O/Mars/phobos"),
		get_node("../Mars_O/Mars/deimos")
	]
	mars_moons_offset = [
		Vector3.ZERO,
		Vector3.ZERO
	]


func _set_orbit_target(planet_node: Node3D):
	# Try to find a "Center" child node to orbit around for accurate center
	if planet_node.has_node("Center"):
		orbit_target = planet_node.get_node("Center")
	else:
		orbit_target = planet_node




func _process(delta):
	if !titleScreen:
		if Input.is_action_just_pressed("e_key"):
			get_tree().quit()
		if target and i == 3 and horizontal_lock_view:
			var earth = planets[3]
			var moon = earth_moon[0]
			var midpoint = (earth.global_transform.origin + moon.global_transform.origin) * 0.5
			var desired_position = midpoint + Vector3(0, horizontal_view_height, 0)
			global_transform.origin = global_transform.origin.lerp(desired_position, delta * follow_speed)
			var earth_to_moon = moon.global_transform.origin - earth.global_transform.origin
			var right = -earth_to_moon.normalized().cross(Vector3.UP)
			look_at(midpoint, right)
		elif target and i == 3 and earth_luna_view:
			var earth = planets[3]
			var moon = earth_moon[0]
			var midpoint = (earth.global_transform.origin + moon.global_transform.origin) * 0.5
			var desired_position = midpoint + earth_luna_view_offset
			global_transform.origin = global_transform.origin.lerp(desired_position, delta * follow_speed)
			look_at(midpoint, Vector3.UP)
		elif target and !freecamera and !horizontal_lock_view and !earth_luna_view:
			var planet_transform = target.global_transform

			if i == 0:
				# special case for the sun: place camera at a fixed offset away from sun center
				var sun_offset_distance = 1500.0  # tweak this to a comfortable distance
				var sun_camera_offset = Vector3(0, 500, sun_offset_distance)  # above and forward
				var desired_position = planet_transform.origin + sun_camera_offset
				global_transform.origin = global_transform.origin.lerp(desired_position, delta * follow_speed / Engine.time_scale)
				look_at(planet_transform.origin, Vector3.UP)
			else:
				# normal planets are positioned based on sun direction + rotations

				var sun_direction = (planets[0].global_transform.origin - planet_transform.origin).normalized()

				var horizontal_rotation_deg := -30  # front-on sunlight
				var horizontal_rotation_rad := deg_to_rad(horizontal_rotation_deg)
				var rotated_direction = sun_direction.rotated(Vector3.UP, horizontal_rotation_rad)

				var right_axis = rotated_direction.cross(Vector3.UP).normalized()
				if right_axis.length() < 0.001:
					right_axis = Vector3.RIGHT

				var vertical_rotation_deg := 15
				var vertical_rotation_rad := deg_to_rad(vertical_rotation_deg)
				rotated_direction = rotated_direction.rotated(right_axis, vertical_rotation_rad).normalized()

				var offset_distance = offsets[i].length()
				var camera_position = planet_transform.origin + rotated_direction * offset_distance

				global_transform.origin = global_transform.origin.lerp(camera_position, delta * follow_speed / Engine.time_scale)
				look_at(planet_transform.origin, Vector3.UP)
				
		if !freecamera:
			if Input.is_action_just_pressed("up_arrow") and !time:
				if moon:
					if i == 3:
						k = (k + 1) % earth_moon.size()
						target = earth_moon[k]
						_set_orbit_target(target)
					elif i == 4:
						k = (k + 1) % mars_moons.size()
						target = mars_moons[k]
						_set_orbit_target(target)
				else:
					if i != 0:
						orbit_lines[i].visible = false
					i = (i + 1) % planets.size()
					target = planets[i]
					_set_orbit_target(target)
					orbit_distance = orbit_distances[i]
					emit_signal("planet_num", planets_names[i])
					if i != 0:
						orbit_lines[i].visible = true
			if Input.is_action_just_pressed("down_arrow") and !time:
				if moon:
					if i == 3:
						k = (k - 1 + earth_moon.size()) % earth_moon.size()
						target = earth_moon[k]
						_set_orbit_target(target)
					elif i == 4:
						k = (k - 1 + mars_moons.size()) % mars_moons.size()
						target = mars_moons[k]
						_set_orbit_target(target)
				else:
					if i != 0:
						orbit_lines[i].visible = false
					i = (i - 1 + planets.size()) % planets.size()
					target = planets[i]
					_set_orbit_target(target)
					orbit_distance = orbit_distances[i]
					emit_signal("planet_num", planets_names[i])
					if i != 0:
						orbit_lines[i].visible = true
			if Input.is_action_just_pressed("left_arrow") and !time:
				if i == 3:
					moon = true
					target = earth_moon[k]
					_set_orbit_target(target)
				elif i == 4:
					moon = true
					target = mars_moons[k]
					_set_orbit_target(target)
			if Input.is_action_just_pressed("h_key") and !time and i == 3:
				earth_luna_view = !earth_luna_view
				if earth_luna_view:
					horizontal_lock_view = false
			if Input.is_action_just_pressed("j_key") and !time and i == 3:
				horizontal_lock_view = !horizontal_lock_view
				if horizontal_lock_view:
					earth_luna_view = false
			if Input.is_action_just_pressed("right_arrow") and !time and moon:
				moon = false
				k = 0
				target = planets[i]
				_set_orbit_target(target)
				orbit_distance = orbit_distances[i]
				emit_signal("planet_num", planets_names[i])
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
			position += direction * move_speed * delta 
		if Input.is_action_just_pressed("t_key"):
			time = true
		if Input.is_action_just_released("t_key"):
			time = false

		if Input.is_action_just_pressed("f_key") and !time:
			freecamera = !freecamera
			if freecamera:
				target = null
			else:
				target = planets[i]
				_set_orbit_target(target)

		if Input.is_action_just_pressed("g_key") || Input.is_action_just_pressed("u_key"):
			mouse = !mouse
			if mouse:
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			else:
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
				
				
func _input(event):
	if titleScreen:
		if event is not InputEventMouseMotion:
			if event is not InputEventMouseButton:
				await get_tree().create_timer(0.1).timeout
				
				logo.visible = false
				var control = get_node("../Control")
				control.visible = true
				titleScreen = false
				target = planets[0]
				_set_orbit_target(target)
				orbit_distance = orbit_distances[0]
				emit_signal("planet_num", planets_names[0])
	else:
		if event is InputEventMouseButton:
			if event.pressed and time:
				if event.button_index == MOUSE_BUTTON_WHEEL_UP:
					global._speed_change_time(0.1)
				elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
					global._speed_change_time(-0.1)
			elif freecamera:
				if event.button_index == MOUSE_BUTTON_WHEEL_UP:
					target_speed = clamp(target_speed * 1.2, 1.0, 100000.0)
				elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
					target_speed = clamp(target_speed / 1.2, 1.0, 100000.0)

		elif event is InputEventMouseMotion and !mouse:
			var effective_sensitivity := mouse_sensitivity
			if freecamera:
				rotation_y -= event.relative.x * effective_sensitivity
				rotation_x -= event.relative.y * effective_sensitivity
				rotation_x = clamp(rotation_x, deg_to_rad(-90), deg_to_rad(90))
				rotation = Vector3(rotation_x, rotation_y, 0)
