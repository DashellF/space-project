extends MeshInstance3D

@export var rotation_speed := -0.3643   # Radians per hour   -0.3643
var custom_axis: Vector3

func _ready():
	if not global.is_connected("timespeed_updated", Callable(self, "_on_timespeed_updated")):
		global.connect("timespeed_updated", Callable(self, "_on_timespeed_updated"))
	var tilt_angle = deg_to_rad(97.8) # check if this axial tilt degree is right.
	var tilt_basis = Basis(Vector3.RIGHT, tilt_angle)
	transform.basis = tilt_basis
	custom_axis = transform.basis * Vector3.UP

func _process(delta):
	var angle = rotation_speed * delta
	rotate(custom_axis, angle)

func _on_timespeed_updated(new_value: float):
	rotation_speed = -0.3643 * global.timeSpeed
	
