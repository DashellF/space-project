extends Node3D

@export var orbit_radius: float = 477760 #radius
@export var orbit_speed: float = -0.0000607 # radians per hour

var angle := 78.0050
var mesh: MeshInstance3D

var xcoord := 0.0
var zcoord := 0.0

func _ready():
	
	mesh = $Jupiter
	_update_orbit_position()

func _process(delta):
	angle += orbit_speed * delta
	_update_orbit_position()

func _update_orbit_position():
	var x = orbit_radius * cos(angle) + xcoord
	var z = orbit_radius * sin(angle) + zcoord
	mesh.transform.origin = Vector3(x, 0, z)
	
#I know they also have a tilt but I didn't implement that either yet
