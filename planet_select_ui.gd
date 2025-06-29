extends VBoxContainer

signal launch_mission(start_id: int, end_id: int)
var start_id=0
var end_id=0
func _ready():
	
	$launch_button.pressed.connect(launch_pressed)
	print("hi!!")

func launch_pressed():
	var start_id = $start_dropdown.get_selected_id()
	var end_id = $end_dropdown.get_selected_id()
	
	if start_id == end_id:
		print("Error: Select different planets!")
		return
	
	launch_mission.emit(start_id, end_id)


func _on_end_dropdown_item_selected(index: int) -> void:
	pass


func _on_launch_button_pressed() -> void:
	pass 
