extends MeshInstance3D

@export var rotation_speed := 0.01069878985  # Radians per hour
var custom_axis: Vector3

func _ready():
	if not global.is_connected("timespeed_updated", Callable(self, "_on_timespeed_updated")):
		global.connect("timespeed_updated", Callable(self, "_on_timespeed_updated"))

	# start with UP axis
	var axis = Vector3.UP
	
	custom_axis = axis.normalized()
	
func _on_timespeed_updated(new_value: float):
	rotation_speed = 0.01069878985 * global.timeSpeed
	
func _process(delta):
	var angle = rotation_speed * delta
	var q = Quaternion(custom_axis, angle)
	global_transform.basis = Basis(q) * global_transform.basis
