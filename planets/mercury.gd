extends MeshInstance3D

@export var rotation_speed := 0.00446  # Radians per hour
var custom_axis: Vector3

func _ready():
	if not global.is_connected("timespeed_updated", Callable(self, "_on_timespeed_updated")):
		global.connect("timespeed_updated", Callable(self, "_on_timespeed_updated"))
	var y_rot = deg_to_rad(0)
	var z_rot = deg_to_rad(0.0)

	# start with UP axis
	var axis = Vector3.UP
	
	var y_basis = Basis(Vector3.UP, y_rot)
	axis = y_basis * axis 

	var z_basis = Basis(Vector3.RIGHT, z_rot)
	axis = z_basis * axis  

	custom_axis = axis.normalized()
	
func _on_timespeed_updated(new_value: float):
	rotation_speed = 0.00446 * global.timeSpeed
	
func _process(delta):
	var angle = rotation_speed * delta
	var q = Quaternion(custom_axis, angle)
	global_transform.basis = Basis(q) * global_transform.basis
