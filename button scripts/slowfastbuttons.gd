extends HBoxContainer

func _ready():
	$SlowerButton.pressed.connect(_on_slower_pressed)
	$FasterButton.pressed.connect(_on_faster_pressed)
	global.timespeed_updated.connect(_update_speed_label)
	_update_speed_label(global.timeSpeed)
	
func _on_slower_pressed():
	global._speed_change_time(-0.1)
	
func _on_faster_pressed():
	global._speed_change_time(0.1)

func _update_speed_label(new_scale: float):
	$SpeedLabel.text = "Speed: %.1fx" % new_scale
		
