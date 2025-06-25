extends Label

var currPlanet = "Neptune"

func _on_camera_3d_planet_num(planet: Variant) -> void:
	currPlanet = planet

func _process(delta):
	text = currPlanet
