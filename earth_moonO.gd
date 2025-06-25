extends MeshInstance3D

@export var orbit_radius: float = 238.9
@export var orbit_speed: float = -0.00958
@onready var orbiting_body: MeshInstance3D = $"Earth Moon"

var angle := 301.5374

func _process(delta):
	angle += orbit_speed * delta
	_update_orbit_position()

func _update_orbit_position():
	if orbiting_body:
		var x = orbit_radius * cos(angle)
		var z = orbit_radius * sin(angle)
		orbiting_body.global_position = global_position + Vector3(x, 0, z)
