extends Node3D

@export var orbit_radius: float = 67676 #radius
@export var orbit_speed: float = 0.00112 # radians per hour

var angle := 0.0
var mesh: MeshInstance3D

var xcoord := 0.0
var zcoord := 0.0

func _ready():
	
	mesh = $Venus
	_update_orbit_position()

func _process(delta):
	
	angle += orbit_speed * delta
	_update_orbit_position()

func _update_orbit_position():
	var x = orbit_radius * cos(angle) + xcoord
	var z = orbit_radius * sin(angle) + zcoord
	mesh.transform.origin = Vector3(x, 0, z)
	
