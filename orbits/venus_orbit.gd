extends Node3D

@export var orbit_radius: float = 67676.0 #radius
@export var orbit_speed: float = -0.001165 # radians per hour

var angle := deg_to_rad(55.3968)
var mesh: Node3D

var xcoord := 0.0
var zcoord := 0.0

func _ready():
	if not global.is_connected("hours_updated", Callable(self, "_on_hours_updated")):
		global.connect("hours_updated", Callable(self, "_on_hours_updated"))
		
	mesh = $Venus
	_update_orbit_position()

func _on_hours_updated(new_value: float):
	angle = deg_to_rad(55.3968) + orbit_speed * new_value
	
func _process(delta):
	angle += orbit_speed * delta
	_update_orbit_position()

func _update_orbit_position():
	var x = orbit_radius * cos(angle) + xcoord
	var z = orbit_radius * sin(angle) + zcoord
	mesh.transform.origin = Vector3(x, 0, z)
	
