extends Node3D

@export var speed: float = 17.5
@export var delta_t: float = 0.1
@export var movement_paused: bool = false

var planet_distances = {
	1: 3, 2: 7, 3: 8, 4: 4,  # Inner planets
	5: 86, 6: 72, 7: 31, 8: 30 # Outer planets
}

@export var planet_nodes: Array[Node3D]
@export var SelectUI: VBoxContainer  

var a: float
var e: float
var b: float
var steps := 0
var current_step := 0
var moving := false
var orbit_center := Vector3.ZERO
var curr_start_id = 0
var curr_end_id = 0

func _ready():
	if SelectUI and SelectUI.has_signal("launch_mission"):
		SelectUI.launch_mission.connect(_on_launch_mission)
	visible = false  

func _on_launch_mission(start_id: int, end_id: int):
	if start_id not in planet_distances or end_id not in planet_distances:
		push_error("Invalid planet ID!")
		return
		
	var r1 = planet_distances[start_id]
	var r2 = planet_distances[end_id]
	a = (r1 + r2) / 2.0
	e = (r2 - r1) / (r2 + r1)
	b = a * sqrt(1.0 - e * e)

	global_position = planet_nodes[start_id - 1].global_position
	visible = true
	moving = true
	current_step = 0
	steps = int(PI * (3*(a+b) - sqrt((3*a+b)*(a+3*b))) / (speed * delta_t))
	curr_start_id=start_id
	curr_end_id=end_id
func _process(delta):
	if !moving or movement_paused: return
	
	if current_step >= steps:
		moving = false
		print("Arrived at planet ", planet_nodes[curr_end_id - 1].name)
		return
	

	var theta = lerp(0.0, PI, current_step / float(steps))
	var r = a * (1.0 - e*e) / (1.0 + e*cos(theta))
	global_position = orbit_center + Vector3(
		r * cos(theta) - a*e,
		0,
		r * sin(theta)
	)
	

	if current_step > 0:
		look_at(global_position + Vector3(0.1, 0, 0.1), Vector3.UP)
	
	current_step += 1
	await get_tree().create_timer(delta_t).timeout
