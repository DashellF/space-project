extends Node3D

@export var orbit_radiusD: float = 14.580
@export var orbit_speedD: float = -0.2075
@onready var orbiting_bodyD: Node3D = $deimos
@export var orbit_radiusP: float = 5.826
@export var orbit_speedP: float = -0.8206
@onready var orbiting_bodyP: Node3D = $phobos

var angleD := deg_to_rad(18.6225)
var angleP := deg_to_rad(66.5134)

func _ready() -> void:
	if not global.is_connected("hours_updated", Callable(self, "_on_hours_updated")):
		global.connect("hours_updated", Callable(self, "_on_hours_updated"))
		
func _on_hours_updated(new_value: float):
	angleD = deg_to_rad(18.6225) + orbit_speedD * new_value
	angleP = deg_to_rad(66.5134) + orbit_speedP * new_value
	
func _process(delta):
	angleD += orbit_speedD * delta
	angleP += orbit_speedP * delta
	_update_orbit_position()

func _update_orbit_position():
	if orbiting_bodyD:
		var x = orbit_radiusD * cos(angleD)
		var z = orbit_radiusD * sin(angleD)
		orbiting_bodyD.global_position = global_position + Vector3(x, 0, z)
	if orbiting_bodyP:
		var x = orbit_radiusP * cos(angleP)
		var z = orbit_radiusP * sin(angleP)
		orbiting_bodyP.global_position = global_position + Vector3(x, 0, z)
