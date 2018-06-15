extends Node



func time_stamp_with_time_zone():
	var time_zone = OS.get_time_zone_info()
	var time_stamp = OS.get_unix_time() + time_zone.bias * 60
	return time_stamp


func time_stamp_to_date_as_string(unix_time_stamp, display_mode):
	var date = OS.get_datetime_from_unix_time( unix_time_stamp)
	
	var str_date = ""
	
	match display_mode:
		1: str_date = "%04d-%02d-%02d  %02d:%02d:%02d" % [date.year, date.month, date.day, date.hour, date.minute, date.second]
		2: str_date = "%02d.%02d.%04d  %02d:%02d:%02d" % [date.day, date.month, date.year, date.hour, date.minute, date.second]
	return str_date
	
	
func time_elapsed_as_string(unix_time_stamp_start, unix_time_stamp_end, display_mode):
	
	var elapsed = unix_time_stamp_end - unix_time_stamp_start
	
	var days = elapsed / 86400
	var hours = (elapsed / 3600) % 24
	var minutes = (elapsed / 60) % 60
	var seconds = elapsed % 60
	
	var str_elapsed = ""
	
	match display_mode:
		1: str_elapsed = "%02d:%02d:%02d:%02d" % [days, hours, minutes, seconds]
		2:
			if days > 0: str_elapsed += String(days) + " d  "
			if hours > 0: str_elapsed += String(hours) + " h  "
			if minutes > 0: str_elapsed += String(minutes) + " min  "
			if seconds > 0: str_elapsed += String(seconds) + " sec"
			
	
	return str_elapsed
	
	
func seconds_to_string(sec, display_mode):
	
	var days = sec / 86400
	var hours = (sec / 3600) % 24
	var minutes = (sec / 60) % 60
	var seconds = sec % 60
	
	var str_sec = ""
	
	match display_mode:
		1: str_sec = "%02d:%02d:%02d:%02d" % [days, hours, minutes, seconds]
		2: 
			if days > 0: str_sec += String(days) + " d  "
			if hours > 0: str_sec += String(hours) + " h  "
			if minutes > 0: str_sec += String(minutes) + " min  "
			if seconds > 0: str_sec += String(seconds) + " sec"

	return str_sec
	