extends Node3D

@export var orbit_radius: float = 94471 #radius
@export var orbit_speed: float = -0.000716 # radians per hour   (actual)

var angle := deg_to_rad(100.4643) #Thanks Caltech calculator!
var mesh: Node3D

var xcoord := 0.0
var zcoord := 0.0

func _ready():
	if not global.is_connected("hours_updated", Callable(self, "_on_hours_updated")):
		global.connect("hours_updated", Callable(self, "_on_hours_updated"))
	if not global.is_connected("timespeed_updated", Callable(self, "_on_timespeed_updated")):
		global.connect("timespeed_updated", Callable(self, "_on_timespeed_updated"))


	mesh = $Earth
	_update_orbit_position()

func _on_hours_updated(new_value: float):
	angle = deg_to_rad(100.4643) + orbit_speed * new_value
	
func _on_timespeed_updated(new_value: float):
	orbit_speed = -0.000716 * global.timeSpeed

func _process(delta):
	angle += orbit_speed * delta
	_update_orbit_position()

func _update_orbit_position():
	var x = orbit_radius * cos(angle) + xcoord
	var z = orbit_radius * sin(angle) + zcoord
	mesh.transform.origin = Vector3(x, 0, z)
	
#I know they also have a tilt but I didn't implement that either yet
