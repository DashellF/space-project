extends MeshInstance3D

@export var rotation_speed := 0.3899  # Radians per hour
var custom_axis: Vector3

func _ready():
	var y_rot = deg_to_rad(270)
	var z_rot = deg_to_rad(28.3)

	# start with UP axis
	var axis = Vector3.UP
	
	var y_basis = Basis(Vector3.UP, y_rot)
	axis = y_basis * axis 

	var z_basis = Basis(Vector3.RIGHT, z_rot)
	axis = z_basis * axis  

	custom_axis = axis.normalized()

func _process(delta):
	var angle = rotation_speed * delta
	var q = Quaternion(custom_axis, angle)
	global_transform.basis = Basis(q) * global_transform.basis
