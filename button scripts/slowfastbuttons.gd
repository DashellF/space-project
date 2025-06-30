extends HBoxContainer

func _ready():
	$SlowerButton.pressed.connect(_on_slower_pressed)
	$FasterButton.pressed.connect(_on_faster_pressed)
	global.timespeed_updated.connect(_update_speed_label)

	# Connect LineEdit signal
	$SpeedLabel.text_submitted.connect(_on_speed_label_entered)
	$SpeedLabel.focus_exited.connect(_on_speed_label_focus_exited)  # optional: commit on focus loss

	_update_speed_label(global.timeSpeed)

func _on_slower_pressed():
	global._speed_change_time(-0.1)

func _on_faster_pressed():
	global._speed_change_time(0.1)

func _update_speed_label(new_scale: float):
	$SpeedLabel.text = "%.1f" % new_scale

func _on_speed_label_entered(new_text: String):
	_process_speed_input(new_text)

func _on_speed_label_focus_exited():
	_process_speed_input($SpeedLabel.text)

func _process_speed_input(new_text: String):
	if new_text.is_valid_float():
		var new_value: float = new_text.to_float()
		var delta: float = new_value - global.timeSpeed
		global._speed_change_time(delta)
	else:
		_update_speed_label(global.timeSpeed)
