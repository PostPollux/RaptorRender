extends Node


### PRELOAD RESOURCES

### SIGNALS

### ONREADY VARIABLES

### EXPORTED VARIABLES

### VARIABLES
var time_zone : Dictionary





########## FUNCTIONS ##########


func _ready():
	time_zone = OS.get_time_zone_info()



func time_stamp_to_date_as_string(unix_time_stamp : int, display_mode : int, correct_by_timezone : bool) -> String:
	
	if correct_by_timezone:
		unix_time_stamp = unix_time_stamp + (time_zone.bias * 60)
	
	var date : Dictionary = OS.get_datetime_from_unix_time( unix_time_stamp)
	
	var str_date : String = ""
	
	match display_mode:
		1: str_date = "%04d-%02d-%02d  %02d:%02d:%02d" % [date.year, date.month, date.day, date.hour, date.minute, date.second]
		2: str_date = "%02d.%02d.%04d  %02d:%02d:%02d" % [date.day, date.month, date.year, date.hour, date.minute, date.second]
	return str_date


func time_elapsed_as_string(unix_time_stamp_start : int, unix_time_stamp_end : int, display_mode : int) -> String:
	
	var elapsed : int = unix_time_stamp_end - unix_time_stamp_start
	
	var days : int  = elapsed / 86400
	var hours : int = (elapsed / 3600) % 24
	var minutes : int = (elapsed / 60) % 60
	var seconds : int = elapsed % 60
	
	var str_elapsed : String = ""
	
	match display_mode:
		1: str_elapsed = "%02d:%02d:%02d:%02d" % [days, hours, minutes, seconds]
		2:
			if days > 0: str_elapsed += String(days) + " d  "
			if days > 0 or hours > 0: str_elapsed += String(hours) + " h  "
			if hours > 0 or minutes > 0: str_elapsed += String(minutes) + " min  "
			if minutes > 0 or seconds > 0: str_elapsed += String(seconds) + " sec"
		3:
			if days > 0: str_elapsed += String(days) + " d  "
			if days > 0 or hours > 0: str_elapsed += String(hours) + " h  "
			if hours > 0 or minutes > 0: str_elapsed += String(minutes) + " m  "
			if minutes > 0 or seconds > 0: str_elapsed += String(seconds) + " s"
			
	
	return str_elapsed.strip_edges()


func seconds_to_string(sec : int, display_mode : int) -> String:
	
	var days : int = sec / 86400
	var hours : int = (sec / 3600) % 24
	var minutes : int  = (sec / 60) % 60
	var seconds : int = sec % 60
	
	var str_sec : String = ""
	
	match display_mode:
		1: str_sec = "%02d:%02d:%02d:%02d" % [days, hours, minutes, seconds]
		2: 
			if days > 0: str_sec += String(days) + " d  "
			if days > 0 or hours > 0: str_sec += String(hours) + " h  "
			if hours > 0 or minutes > 0: str_sec += String(minutes) + " min  "
			if minutes > 0 or seconds > 0: str_sec += String(seconds) + " sec"
		3: 
			if days > 0: str_sec += String(days) + " d  "
			if days > 0 or hours > 0: str_sec += String(hours) + " h  "
			if hours > 0 or minutes > 0: str_sec += String(minutes) + " m  "
			if minutes > 0 or seconds > 0: str_sec += String(seconds) + " s"

	return str_sec.strip_edges()
