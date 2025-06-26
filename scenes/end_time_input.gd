extends LineEdit

const TEMPLATE := "MM/DD/YYYY HH:MM"
const MASK := [0,1,3,4,6,7,8,9,11,12,14,15]  # Editable digit positions

const KEY_BACKSPACE := 4194308
const KEY_DELETE := 4194312
const KEY_LEFT := 4194319
const KEY_RIGHT := 4194321

var raw_digits := []  # Array of single-digit strings, max length MASK.size()

func _ready():
	raw_digits = []
	text = TEMPLATE
	# Start caret at first editable position
	caret_column = MASK[0]

func paste():
	# Disable pasting
	pass

func _gui_input(event):
	if event is InputEventKey and event.pressed:
		print("Key pressed:", event.keycode)
		match event.keycode:
			KEY_BACKSPACE:
				handle_backspace()
				accept_event()
			KEY_DELETE:
				handle_delete()
				accept_event()
			KEY_LEFT:
				move_caret(-1)
				accept_event()
			KEY_RIGHT:
				move_caret(1)
				accept_event()
			_:
				var sc = String.chr(event.unicode)
				if sc >= "0" and sc <= "9":
					handle_insert(sc)
					accept_event()
				else:
					accept_event()  # block everything else

func handle_insert(char: String):
	var raw_index = caret_pos_to_raw_index(caret_column)

	if raw_index >= MASK.size():
		# Caret beyond max editable, ignore
		return

	# Expand raw_digits with '0' placeholders if needed
	while raw_index >= raw_digits.size():
		var i = raw_digits.size()
		match i:
			0, 2:  # First digit of month or day
				raw_digits.append("0")
			1, 3:  # Second digit of month or day
				raw_digits.append("1")
			_:  # Year, hour, minute
				raw_digits.append("0")


	# Replace digit at raw_index
	raw_digits[raw_index] = char

	update_text()

	# Clamp values based on which part is edited
	var part = get_date_part(raw_index)
	match part:
		"month":
			clamp_month()
		"day":
			clamp_day()
		"hour":
			clamp_hour()
		"minute":
			clamp_minute()
		# "year" - add clamp_year() if you want

	# Move caret forward to the next editable position, skipping non-editable
	var next_raw_index = raw_index + 1
	if next_raw_index > MASK.size():
		next_raw_index = MASK.size()  # clamp to end
	caret_column = raw_index_to_caret_pos(next_raw_index)



func handle_backspace():
	print("Backspace called")
	var raw_index = caret_pos_to_raw_index(caret_column)
	if raw_index > 0:
		raw_index -= 1
		if raw_index < raw_digits.size():
			raw_digits.remove_at(raw_index)
			update_text()
		caret_column = raw_index_to_caret_pos(raw_index)

func handle_delete():
	var raw_index = caret_pos_to_raw_index(caret_column)
	if raw_index < raw_digits.size():
		raw_digits.remove_at(raw_index)
		update_text()
	caret_column = raw_index_to_caret_pos(raw_index)

func move_caret(dir: int):
	var new_pos = caret_column + dir
	while new_pos >= 0 and new_pos < text.length() and new_pos not in MASK:
		new_pos += dir
	if new_pos < 0:
		new_pos = MASK[0]
	elif new_pos >= text.length():
		new_pos = MASK[-1] + 1
	caret_column = new_pos

func update_text():
	var chars = TEMPLATE.split("")
	for i in range(raw_digits.size()):
		chars[MASK[i]] = raw_digits[i]
	text = "".join(chars)

# Map raw digit index to date/time part
func get_date_part(raw_index: int) -> String:
	if raw_index < 0 or raw_index >= MASK.size():
		return ""
	if raw_index in [0, 1]:
		return "month"
	elif raw_index in [2, 3]:
		return "day"
	elif raw_index in [4, 5, 6, 7]:
		return "year"
	elif raw_index in [8, 9]:
		return "hour"
	elif raw_index in [10, 11]:
		return "minute"
	return ""

func clamp_month():
	if raw_digits.size() < 2:
		return
	var month_str = raw_digits[0] + raw_digits[1]
	var month_val = int(month_str)
	if month_val < 1:
		month_val = 1
	elif month_val > 12:
		month_val = 12
	var fixed = str(month_val).pad_zeros(2)
	raw_digits[0] = fixed[0]
	raw_digits[1] = fixed[1]
	update_text()

func clamp_day():
	if raw_digits.size() < 4:
		return
	var day_str = raw_digits[2] + raw_digits[3]
	var day_val = int(day_str)
	if day_val < 1:
		day_val = 1
	elif day_val > 31:
		day_val = 31
	var fixed = str(day_val).pad_zeros(2)
	raw_digits[2] = fixed[0]
	raw_digits[3] = fixed[1]
	update_text()

func clamp_hour():
	if raw_digits.size() < 10:
		return
	var hour_str = raw_digits[8] + raw_digits[9]
	var hour_val = int(hour_str)
	if hour_val > 23:
		hour_val = 23
	var fixed = str(hour_val).pad_zeros(2)
	raw_digits[8] = fixed[0]
	raw_digits[9] = fixed[1]
	update_text()

func clamp_minute():
	if raw_digits.size() < 12:
		return
	var minute_str = raw_digits[10] + raw_digits[11]
	var minute_val = int(minute_str)
	if minute_val > 59:
		minute_val = 59
	var fixed = str(minute_val).pad_zeros(2)
	raw_digits[10] = fixed[0]
	raw_digits[11] = fixed[1]
	update_text()

func caret_pos_to_raw_index(caret_pos: int) -> int:
	var count = 0
	for pos in MASK:
		if pos < caret_pos:
			count += 1
	return count

func raw_index_to_caret_pos(raw_index: int) -> int:
	if raw_index >= MASK.size():
		return text.length()
	return MASK[raw_index]
