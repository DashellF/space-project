extends Control
# so far, so good. UI matches up. However, the 2d planet circles are not drawing...
@onready var space_root: Node3D = get_node("/root/Space") 
@onready var sun_node: Node3D = space_root.get_node("Sun")  
@onready var planet_nodes: Array[Node3D] = [
	space_root.get_node("Mercury_O/Mercury"),
	space_root.get_node("Venus_O/Venus"),
	space_root.get_node("Earth_O/Earth"),
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


var ui_visible := false
var view_scale := 0.001
var min_scale := 0.0001
var max_scale := 200
var center_offset := Vector2.ZERO
var dragging := false
var edge_margin := 50.0 # pixels
var last_drag_pos := Vector2.ZERO

func _ready():
	hide() # Start hidden
	#_calculate_initial_scale()

#func _calculate_initial_scale():
	#var max_distance := 0.0
	#var sun_pos_3d = sun_node.global_position
	#
	#for planet in planet_nodes:
		#var planet_pos_3d = planet.global_position - sun_pos_3d
		#var distance = Vector2(planet_pos_3d.x, planet_pos_3d.z).length()
		#if distance > max_distance:
			#max_distance = distance
	#
	# scale to fit with margins
	#if max_distance > 0:
		#var min_dimension = min(size.x, size.y)
		#view_scale = (min_dimension - edge_margin * 2) / (max_distance * 2)
func _process(_delta):
	if ui_visible:
		queue_redraw()

func _draw():
	if !ui_visible:
		return
	
	var center = size / 2 + center_offset
	var sun_pos_3d = sun_node.global_position
	draw_circle(center, 20 * view_scale, Color.YELLOW)
	
	for i in planet_nodes.size():
		var planet = planet_nodes[i]
		var data = planet_data[i]
		var planet_pos_3d = planet.global_position - sun_pos_3d
		var planet_pos_2d = Vector2(planet_pos_3d.x, planet_pos_3d.z) * view_scale + center
		var orbit_radius = Vector2(planet_pos_3d.x, planet_pos_3d.z).length() * view_scale
		draw_arc(center, orbit_radius, 0, 2 * PI, 100, Color(1, 1, 1, 0.2), 1.0)
		draw_circle(planet_pos_2d + Vector2(data["size"] * view_scale, 0), data["size"] * view_scale, data["color"])
		if data.get("ring", false):
			draw_arc(planet_pos_2d + Vector2(data["size"] * view_scale, 0), data["size"] * view_scale * 1.5, 0, 2 * PI, 30, 
				Color(0.8, 0.8, 0.6, 0.5), 2.0 * view_scale)
		var font = get_theme_default_font()
		var font_size = get_theme_default_font_size()
		draw_string(font, planet_pos_2d + Vector2(data["size"] * view_scale, 0), 
			data["name"], HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)

func _input(event):
	# U key toggle
	if event.is_action_pressed("ui_toggle_solar_map"):
		ui_visible = !ui_visible
		show() if ui_visible else hide()
	
	# zooming
	if ui_visible:
		if Input.is_action_just_pressed("k_key"):
			view_scale = clamp(view_scale * 1.1, min_scale, max_scale)
		elif Input.is_action_just_pressed("l_key"):
			view_scale = clamp(view_scale * 0.9, min_scale, max_scale)
		
		# panning/dragging
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT:
				dragging = event.pressed
				if dragging:
					last_drag_pos = event.position
		elif event is InputEventMouseMotion and dragging:
			center_offset += event.position - last_drag_pos
			last_drag_pos = event.position
