extends Node3D

@export var orbit_radius: float = 2778100.0 # radius in whatever units you're using
@export var orbit_speed: float = -0.00000435 # radians per hour

var angle := deg_to_rad(358.7831) # convert starting angle to radians
var mesh: Node3D

var xcoord := 0.0
var zcoord := 0.0

func _ready():
	if not global.is_connected("hours_updated", Callable(self, "_on_hours_updated")):
		global.connect("hours_updated", Callable(self, "_on_hours_updated"))
	if not global.is_connected("timespeed_updated", Callable(self, "_on_timespeed_updated")):
		global.connect("timespeed_updated", Callable(self, "_on_timespeed_updated"))
		
	mesh = $Neptune
	_update_orbit_position()

func _on_hours_updated(new_value: float):
	angle = deg_to_rad(358.7831) + orbit_speed * new_value
	
func _on_timespeed_updated(new_value: float):
	orbit_speed = -0.00000435 * global.timeSpeed

func _process(delta):
	#angle += orbit_speed * delta
	angle = fmod(angle + orbit_speed * delta, TAU)
	_update_orbit_position()

func _update_orbit_position():
	var x = orbit_radius * cos(angle) + xcoord
	var z = orbit_radius * sin(angle) + zcoord
	mesh.global_transform.origin = Vector3(x, 0, z)
