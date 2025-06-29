extends Node3D

@export var orbit_radius: float = 37231.0 #radius
@export var orbit_speed: float = -0.002966 # radians per hour

var angle := deg_to_rad(202.6582)
var mesh: Node3D

var x := orbit_radius
var z := 0.0

func _ready():
	if not global.is_connected("hours_updated", Callable(self, "_on_hours_updated")):
		global.connect("hours_updated", Callable(self, "_on_hours_updated"))
	if not global.is_connected("timespeed_updated", Callable(self, "_on_timespeed_updated")):
		global.connect("timespeed_updated", Callable(self, "_on_timespeed_updated"))
		
	mesh = $Mercury
	_update_orbit_position()

func _on_hours_updated(new_value: float):
	angle = deg_to_rad(202.6582) + orbit_speed * new_value
	
func _on_timespeed_updated(new_value: float):
	orbit_speed = -0.002966 * global.timeSpeed
func _get_position_in_time(hours):
	var newAngle = deg_to_rad(202.6582) + orbit_speed * hours
	var x = orbit_radius * cos(angle)
	var z = orbit_radius * sin(angle)
	return [x, z]
func _process(delta):
	angle += orbit_speed * delta
	_update_orbit_position()

func _update_orbit_position():
	x = orbit_radius * cos(angle)
	z = orbit_radius * sin(angle)
	mesh.transform.origin = Vector3(x, 0, z)
	
	
#I know they also have a tilt but I didn't implement that either yet
