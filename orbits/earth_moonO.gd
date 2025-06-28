extends Node3D

@export var orbit_radius: float = 238.9
@export var orbit_speed: float = -0.00958
@onready var orbiting_body: Node3D = $"Earth Moon"

var angle := deg_to_rad(301.5374)

func _ready() -> void:
	if not global.is_connected("hours_updated", Callable(self, "_on_hours_updated")):
		global.connect("hours_updated", Callable(self, "_on_hours_updated"))
	if not global.is_connected("timespeed_updated", Callable(self, "_on_timespeed_updated")):
		global.connect("timespeed_updated", Callable(self, "_on_timespeed_updated"))

		
func _process(delta):
	angle += orbit_speed * delta
	_update_orbit_position()

func _on_hours_updated(new_value: float):
	angle = deg_to_rad(301.5374) + orbit_speed * new_value

func _on_timespeed_updated(new_value: float):
	orbit_speed = -0.00958 * global.timeSpeed

func _update_orbit_position():
	var x = orbit_radius * cos(angle)
	var z = orbit_radius * sin(angle)
	orbiting_body.global_position = global_position + Vector3(x, 0, z)
	
#I know they also have a tilt but I didn't implement that either yet
