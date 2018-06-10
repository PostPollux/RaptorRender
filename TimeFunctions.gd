extends Node



func time_stamp_with_time_zone():
	var time_zone = OS.get_time_zone_info()
	var time_stamp = OS.get_unix_time() + time_zone.bias * 60
	return time_stamp


func time_stamp_to_date_as_string(unix_time_stamp):
	var date = OS.get_datetime_from_unix_time( unix_time_stamp)
	var str_date = "%04d-%02d-%02d %02d:%02d:%02d" % [date.year, date.month, date.day, date.hour, date.minute, date.second]
	print (str_date)
	
	
func time_elapsed_as_string(unix_time_stamp_start, unix_time_stamp_end):
	
	var elapsed = unix_time_stamp_end - unix_time_stamp_start
	
	var days = elapsed / 86400
	var hours = (elapsed / 3600) % 24
	var minutes = (elapsed / 60) % 60
	var seconds = elapsed % 60
	
	var str_elapsed = "%02d:%02d:%02d:%02d" % [days, hours, minutes, seconds]
	
	return str_elapsed
	
	

	

	