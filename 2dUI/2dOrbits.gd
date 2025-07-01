extends Control

@onready var space_root: Node3D = get_node("/root/Space") 
@onready var sun_node: Node3D = space_root.get_node("Sun")  
@onready var sun_texture: Texture2D = preload("res://2dUI/planet pngs/b4fe772749bfdb184cfac3cad9e030a3.png")
@onready var planet_nodes: Array[Node3D] = [
	space_root.get_node("rocket"),
	space_root.get_node("Mercury_O/Mercury"),
	space_root.get_node("Venus_O/Venus"),
	space_root.get_node("Earth_O/Earth"),
	space_root.get_node("Mars_O/Mars"),
	space_root.get_node("Jupiter_O/Jupiter"),
	space_root.get_node("Saturn_O/Saturn"),
	space_root.get_node("Uranus_O/Uranus"),
	space_root.get_node("Neptune_O/Neptune")
]

var predicted_ellipse := {
	"a": 0.0,
	"e": 0.0,
	"offset_theta": 0.0,
	"theta_range": 0.0,
	"active": false
}

var planet_textures: Dictionary = {
	"Rocket": preload("res://2dUI/rocket-start-up-launcher.png"),
	"Mercury": preload("res://2dUI/planet pngs/42daa67829b564a1659432529f299dd6.png"),
	"Venus": preload("res://2dUI/planet pngs/bc30731f4f6ce9b58e072855cbf3d9f1.png"),
	"Earth": preload("res://2dUI/planet pngs/5daf8d18e990798ae9b1b31d393bee9d.png"),
	"Mars": preload("res://2dUI/planet pngs/3ee9a901bc508a4e396f024e45020fde.png"),
	"Jupiter": preload("res://2dUI/planet pngs/e108e930cfe5e1357a45c434d358eca2.png"),
	"Saturn": preload("res://2dUI/planet pngs/7ebf9be67c1a399f790da9d9cc0a9e6d.png"),
	"Uranus": preload("res://2dUI/planet pngs/5189a741170de2ed50284d6101c672e3.png"),
	"Neptune": preload("res://2dUI/planet pngs/ea0e780cf59d9383b20cf02ddb15d328.png")
}

var planet_data := [
	{"name": "Rocket", "size": 10, "color": Color(0.7, 0.7, 0.7)},
	{"name": "Mercury", "size": 10, "color": Color(0.7, 0.7, 0.7)},
	{"name": "Venus", "size": 15, "color": Color(0.9, 0.6, 0.2)},
	{"name": "Earth", "size": 12, "color": Color(0.2, 0.4, 0.8)},
	{"name": "Mars", "size": 40, "color": Color(0.8, 0.3, 0.2)},
	{"name": "Jupiter", "size": 40, "color": Color(0.8, 0.6, 0.4)},
	{"name": "Saturn", "size": 200, "color": Color(0.9, 0.8, 0.5), "ring": true},
	{"name": "Uranus", "size": 500, "color": Color(0.6, 0.8, 0.9)},
	{"name": "Neptune", "size": 600, "color": Color(0.2, 0.4, 0.9)}
]

var ui_visible := false
var view_scale := 0.001
var min_scale := 0.0001
var max_scale := 200
var center_offset := Vector2.ZERO
var dragging := false
var edge_margin := 50.0
var last_drag_pos := Vector2.ZERO

func _ready():
	var rocket = space_root.get_node("rocket")
	if rocket:
		rocket.connect("ellipse_parameters", Callable(self, "_on_ellipse_parameters"))
	global.connect("hours_updated", Callable(self, "update_positions_from_time"))
	hide()

func _on_ellipse_parameters(a: float, e: float, offset_theta: float, theta_range: float):
	predicted_ellipse = {
		"a": a,
		"e": e,
		"offset_theta": offset_theta,
		"theta_range": theta_range,
		"active": true
	}
	queue_redraw()

func draw_predicted_ellipse(center: Vector2):
	if !predicted_ellipse.active:
		return  
	var points = []
	var steps = 200
	var a = predicted_ellipse.a * view_scale
	var e = predicted_ellipse.e
	var offset_theta = predicted_ellipse.offset_theta
	var theta_range = predicted_ellipse.theta_range

	for i in range(steps + 1):
		var theta = theta_range * (i / float(steps))
		var r = a * (1 - e * e) / (1 + e * cos(theta))
		var x = r * cos(theta + offset_theta)
		var y = r * sin(theta + offset_theta)
		points.append(center + Vector2(x, y))
	
	for i in range(points.size() - 1):
		draw_line(points[i], points[i+1], Color(1, 1, 0, 0.5), 10.0)

func update_positions_from_time(hours: float):
	if !ui_visible:
		return
	
	var center = size / 2 + center_offset
	var sun_pos_3d = sun_node.global_position
	var rocket = space_root.get_node("rocket")
	
	if rocket:
		var params = rocket.get_current_orbit_params()
		if params["traveling"]:
			var t_frac = params["elapsed_time"] / params["total_time"]
			var theta = params["theta_range"] * t_frac
			var r = params["a"] * (1 - params["e"] * params["e"]) / (1 + params["e"] * cos(theta))
			predicted_ellipse = {
				"a": params["a"],
				"e": params["e"],
				"offset_theta": params["offset_theta"],
				"theta_range": params["theta_range"] / 2,
				"active": true
			}
		else:
			predicted_ellipse["active"] = false
	
	queue_redraw()

func _process(_delta):
	if ui_visible:
		queue_redraw()

func _draw():
	if !ui_visible:
		return
	
	var center = size / 2 + center_offset
	var sun_pos_3d = sun_node.global_position
	
	draw_predicted_ellipse(center)
	
	if sun_texture:
		var sun_scale := 30.0
		var tex_size = sun_texture.get_size() * view_scale * sun_scale
		var tex_position = center - tex_size / 2
		draw_texture_rect(sun_texture, Rect2(tex_position, tex_size), false)
	
	for i in planet_nodes.size():
		var planet = planet_nodes[i]
		var data = planet_data[i]
		var planet_pos_3d = planet.global_position - sun_pos_3d
		var planet_pos_2d = Vector2(planet_pos_3d.x, planet_pos_3d.z) * view_scale + center
		
		if data["name"] != "Rocket":
			var orbit_radius = Vector2(planet_pos_3d.x, planet_pos_3d.z).length() * view_scale
			draw_arc(center, orbit_radius, 0, 2 * PI, 100, Color(1, 1, 1, 0.2), 1.0)
		
		var texture = planet_textures.get(data["name"], null)
		if texture:
			var tex_size = texture.get_size() * view_scale * data["size"]
			var tex_pos = planet_pos_2d - tex_size / 2
			draw_texture_rect(texture, Rect2(tex_pos, tex_size), false)
		else:
			draw_circle(planet_pos_2d, data["size"] * view_scale, data["color"])

		if data.get("ring", false):
			draw_arc(planet_pos_2d + Vector2(data["size"] * view_scale, 0), 
				data["size"] * view_scale * 1.5, 0, 2 * PI, 30, 
				Color(0.8, 0.8, 0.6, 0.5), 2.0 * view_scale)
		
		draw_string(get_theme_default_font(), planet_pos_2d, data["name"], 
			HORIZONTAL_ALIGNMENT_LEFT, -1, get_theme_default_font_size())

func _input(event):
	if event.is_action_pressed("ui_toggle_solar_map"):
		ui_visible = !ui_visible
		show() if ui_visible else hide()
	
	if ui_visible:
		if Input.is_action_just_pressed("k_key"):
			view_scale = clamp(view_scale * 1.1, min_scale, max_scale)
		elif Input.is_action_just_pressed("l_key"):
			view_scale = clamp(view_scale * 0.9, min_scale, max_scale)
		
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT:
				dragging = event.pressed
				if dragging:
					last_drag_pos = event.position
		elif event is InputEventMouseMotion and dragging:
			center_offset += event.position - last_drag_pos
			last_drag_pos = event.position
