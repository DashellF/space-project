extends Camera3D

# Free camera settings
var freecamera := false
var time := false
var moon := false


# timer-specific variables
signal time_scale_updated(new_scale)
var min_time_scale := 0.1
var max_time_scale := 10.0
var time_scale_step := 0.1

# earth-specific camera variables
var earth_luna_view = false
var horizontal_lock_view := false  # J key
var horizontal_view_height := 120 # height above Earth and Moon 
var mouse := false # no cursor

# velocity and acceleration
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
var i := 0
var earth_moon := []
var mars_moons := []
var earth_luna_view_offset = Vector3(0,124,0)
var cam_loc := []
var k := 0
var planets_names := [
	"Neptune",
	"Uranus",
	"Saturn",
	"Jupiter",
	"Mars",
	"Earth",
	"Venus",
	"Mercury",
	"Sol",
]
signal planet_num(planet)

@export var follow_speed: float = 5.0


var offset: Vector3
var target: Node3D


func _ready():
	await get_tree().process_frame
	
	if !mouse:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	planets = [
		get_node("../Neptune_O/Neptune"),
		get_node("../Uranus_O/Uranus"),
		get_node("../Saturn_O/Saturn"),
		get_node("../Jupiter_O/Jupiter"),
		get_node("../Mars_O/Mars"),
		get_node("../Earth_O/Earth"),
		get_node("../Venus_O/Venus"),
		get_node("../Mercury_O/Mercury"),
		get_node("../Sun")
	]
	
	earth_moon = [
		get_node("../Earth_O/Earth/Earth Moon")
	]
	cam_loc = [
		get_node("../Sun")
	]
	
	mars_moons = [
		get_node("../Mars_O/Mars/phobos"),
		get_node("../Mars_O/Mars/deimos")
	]

	offset = offsets[i]
	target = planets[i]

func _on_slower_button_pressed():
	_change_time_scale(-time_scale_step) 

func _on_faster_button_pressed():
	_change_time_scale(time_scale_step)

func _change_time_scale(step: float):
	var new_scale = clamp(Engine.time_scale + step, min_time_scale, max_time_scale)
	Engine.time_scale = new_scale
	emit_signal("time_scale_updated", new_scale)
	
	
	
	
func _input(event):
	if event is InputEventMouseButton:
		if event.pressed and time:
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				_change_time_scale(-time_scale_step)
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				_change_time_scale(time_scale_step)
		elif freecamera:
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				target_speed = clamp(target_speed * 1.2, 1.0, 100000.0)
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				target_speed = clamp(target_speed / 1.2, 1.0, 100000.0)

	elif event is InputEventMouseMotion and freecamera:
		# Adjust sensitivity based on time scale to avoid wild jumps
		var effective_sensitivity := mouse_sensitivity / Engine.time_scale
		rotation_y -= event.relative.x * effective_sensitivity
		rotation_x -= event.relative.y * effective_sensitivity
		rotation_x = clamp(rotation_x, deg_to_rad(-90), deg_to_rad(90))
		rotation = Vector3(rotation_x, rotation_y, 0)


func _process(delta):
	if target and i== 5 and horizontal_lock_view:
		var earth = planets[5]
		var moon = earth_moon[0]
		
		var midpoint = (earth.global_transform.origin + moon.global_transform.origin) * 0.5
		var desired_position = midpoint + Vector3(0, horizontal_view_height, 0)
		global_transform.origin = global_transform.origin.lerp(desired_position, delta * follow_speed)
		
		var earth_to_moon = moon.global_transform.origin - earth.global_transform.origin
		var right = -earth_to_moon.normalized().cross(Vector3.UP) # normalized flips the side of the planet and moon, this way the EARTH is on the LEFT
		look_at(midpoint, right) # 'up' is orbital right vector
	# H key	
	elif target and i == 5 and earth_luna_view:
		var earth = planets[5]
		var moon = earth_moon[0]
		# position camera midway between Earth and Moon
		var midpoint = (earth.global_transform.origin + moon.global_transform.origin) * 0.5
		var desired_position = midpoint + earth_luna_view_offset
		global_transform.origin = global_transform.origin.lerp(desired_position, delta * follow_speed)
		# look at the midpoint between Earth and Moon
		look_at(midpoint, Vector3.UP)
	elif target:  # regular view
		var desired_position = target.global_transform.origin + offset
		global_transform.origin = global_transform.origin.lerp(desired_position, delta * follow_speed)
		look_at(target.global_transform.origin, Vector3.UP)

	if !freecamera:
		if Input.is_action_just_pressed("up_arrow") and !time:
			if moon:
				if i == 5:
					k = (k + 1) % earth_moon.size() 
				elif i == 4:
					k = (k + 1) % mars_moons.size() 
			else:
				i = (i + 1) % offsets.size()
				offset = offsets[i]
				target = planets[i]
				emit_signal("planet_num", planets_names[i])
		if Input.is_action_just_pressed("down_arrow") and !time:
			if moon:
				if i == 5:
					k = (k - 1 + offsets.size()) % offsets.size()
			else:
				i = (i - 1 + offsets.size()) % offsets.size()
				offset = offsets[i]
				target = planets[i]
				emit_signal("planet_num", planets_names[i])
		if Input.is_action_just_pressed("left_arrow") and !time and i == 5:
			moon = true
			target = earth_moon[k]
		if Input.is_action_just_pressed("h_key") and !time and i==5:
			earth_luna_view = !earth_luna_view
			if earth_luna_view:
				# when entering Earth-Moon view, ensure that we're looking at Earth
				horizontal_lock_view = false
			# no need to change target when exiting, since we're already on the right target
		if Input.is_action_just_pressed("j_key") and !time and i == 5:
			horizontal_lock_view = !horizontal_lock_view
			if horizontal_lock_view:
				# disable other special views when in orbit view
				earth_luna_view = false
				
				
		if Input.is_action_just_pressed("left_arrow") and !time and i == 4:
			moon = true
			target = mars_moons[k]
		if Input.is_action_just_pressed("right_arrow") and !time and moon:
			moon = false
			target = planets[i]
			emit_signal("planet_num", planets_names[i])
			k = 0
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
	if Input.is_action_just_pressed("g_key"):
		mouse = !mouse
		if mouse:
			Input.mouse_mode= Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		
		


## Hi Dashell, lets work on these items: Name Tags, Orbit paths of diff planets, and Camera movement (freecam while spectating a particular planet)
