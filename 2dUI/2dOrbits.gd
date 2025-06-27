extends Control


@onready var space_root: Node3D = get_node("/root/Space")  # Your root 3D scene
@onready var sun_node: Node3D = space_root.get_node("Sun")  # Sun is child of Space
@onready var planet_nodes: Array[Node3D] = [
	space_root.get_node("Mercury_O/Mercury"),
	space_root.get_node("Venus_O/Venus"),
	space_root.get_node("Earth_OEarth"),
	space_root.get_node("Mars_O/Mars"),
	space_root.get_node("Jupiter_O/Jupiter"),
	space_root.get_node("Saturn_O/Saturn"),
	space_root.get_node("Uranus_O/Uranus"),
	space_root.get_node("Neptune_O/Neptune")
]

var planet_data := [
	{"name": "Mercury", "size": 8, "color": Color(0.7, 0.7, 0.7)},
	{"name": "Venus", "size": 12, "color": Color(0.9, 0.6, 0.2)},
	{"name": "Earth", "size": 12, "color": Color(0.2, 0.4, 0.8)},
	{"name": "Mars", "size": 10, "color": Color(0.8, 0.3, 0.2)},
	{"name": "Jupiter", "size": 20, "color": Color(0.8, 0.6, 0.4)},
	{"name": "Saturn", "size": 18, "color": Color(0.9, 0.8, 0.5), "ring": true},
	{"name": "Uranus", "size": 16, "color": Color(0.6, 0.8, 0.9)},
	{"name": "Neptune", "size": 16, "color": Color(0.2, 0.4, 0.9)}
]

# Display settings
var scale_factor := 0.01	# Scale down 3D positions to 2D
var min_scale := 0.005
var max_scale := 0.05
var show_paths := true
var ui_visible := false	# Changed from 'visible' to avoid conflict
var target_scale_margin := 0.9

func _ready():
	calculate_auto_scale()
	set_process(true)
	hide()
func calculate_auto_scale():
	if !sun_node || planet_nodes.is_empty(): return
	
	var max_distance: float = 0.0
	for planet_3d in planet_nodes:
		if planet_3d:
			var distance: float = (planet_3d.global_position - sun_node.global_position).length()
			max_distance = max(max_distance, distance)
	
	if max_distance > 0:
		var screen_size: Vector2 = get_rect().size
		var smallest_dimension: float = min(screen_size.x, screen_size.y)
		var screen_radius: float = smallest_dimension * 0.5 * target_scale_margin
		scale_factor = screen_radius / max_distance
func _process(_delta):
	if ui_visible:
		queue_redraw()

func _draw():
	if !ui_visible || !sun_node: return
	
	var center := get_rect().size / 2
	var sun_pos_3d := sun_node.global_position - space_root.global_position
	var sun_pos_2d := _convert_3d_to_2d(sun_pos_3d)
	
	# Draw Sun
	draw_circle(center, 30, Color(0.9, 0.8, 0.1))
	
	# Draw planets
	for i in min(planet_data.size(), planet_nodes.size()):
		var planet = planet_data[i]
		var planet_3d = planet_nodes[i]
		
		if !planet_3d: continue
		
		var planet_pos_3d: Vector3 = planet_3d.global_position - sun_node.global_position
		var planet_pos_2d := center + Vector2(
	planet_pos_3d.x * scale_factor,  # X coordinate (float)
	-planet_pos_3d.z * scale_factor   # Z coordinate (flipped and scaled)
)

		if show_paths:
			var orbit_radius: float = (planet_pos_3d - sun_pos_3d).length() * scale_factor
			draw_arc(center, orbit_radius, 0, TAU, 100, Color(0.3, 0.3, 0.3, 0.2), 1.0)
		
		# Draw planet
		draw_circle(planet_pos_2d, planet.size, planet.color)
		
		# Draw ring for Saturn
		if planet.get("ring", false):
			draw_arc(planet_pos_2d, planet.size * 1.5, 0, TAU, 30, Color(0.8, 0.7, 0.6), 2.0)
		
		# Draw name
		var font = get_theme_default_font()
		draw_string(font, planet_pos_2d + Vector2(planet.size + 5, 0), planet.name, 
			   HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color.WHITE)

func _convert_3d_to_2d(pos_3d: Vector3) -> Vector2:
	var center := get_rect().size / 2
	return center + Vector2(pos_3d.x, -pos_3d.z) * scale_factor

func _input(event):
	# Toggle with U key
	if event.is_action_pressed("ui_toggle_solar_map"):
		ui_visible = !ui_visible
		show() if ui_visible else hide()
	
	# Zoom controls
	if ui_visible and event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			scale_factor = clamp(scale_factor * 1.1, min_scale, max_scale)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			scale_factor = clamp(scale_factor * 0.9, min_scale, max_scale)
