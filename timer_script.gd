extends Label
var updated_time = ""

func _process(delta):
	text = global.updated_time  # Assuming TimeManager is your autoload name

	
