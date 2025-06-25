extends Node

var curr_minutes := 0.0 
var year := 2025
var month := 1
var day := 1
var hour := 0
var minute := 0
var updated_time := ""  

var days_in_month := {
	1: 31, 2: 28, 3: 31, 4: 30, 5: 31, 6: 30,
	7: 31, 8: 31, 9: 30, 10: 31, 11: 30, 12: 31
}

func is_leap_year(y: int) -> bool:
	return (y % 4 == 0 and y % 100 != 0) or (y % 400 == 0)

func update_days_in_february():
	days_in_month[2] = 29 if is_leap_year(year) else 28

func advance_minute():
	minute += 1
	if minute >= 60:
		minute = 0
		advance_hour()

func advance_hour():
	hour += 1
	if hour >= 24:
		hour = 0
		advance_day()

func advance_day():
	day += 1
	update_days_in_february()
	if day > days_in_month[month]:
		day = 1
		month += 1
		if month > 12:
			month = 1
			year += 1

func get_formatted_time() -> String:
	return "%02d/%02d/%04d  %02d:%02d" % [month, day, year, hour, minute]

func _ready():
	set_process(true)
	update_days_in_february()

func _process(delta):
	# with one second of real time = one hour of in-game time,
	curr_minutes += delta * 60
	while curr_minutes >= 1.0:
		curr_minutes -= 1.0
		advance_minute()
	updated_time = get_formatted_time()
