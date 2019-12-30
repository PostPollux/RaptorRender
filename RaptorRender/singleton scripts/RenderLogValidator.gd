#////////////////////#
# RenderLogValidator #
#////////////////////#

# This script holds functions to detect errors, validate and colorize single log lines of the render process or already finished log files.
# The rules for the validation first have to be loaded from a .cfg file for the respective renderer.
# There are very similar functions all over this script. One named as "CRP" (Current Render Process) and the other named as "HIGHLIGHT". That's to ensure, that it is possible that your machine can simultaneously render and validat the output, while also show colorized log outputs of other jobs with other validation rules in the interface.
# The CRP functions only send signals on successes or error detection, while the HIGHLIGHT functions return a colorized string.



extends Node


### PRELOAD RESOURCES

### SIGNALS
signal software_start_success_detected
signal error_detected
signal critical_error_detected
signal frame_success_detected
signal frame_name_detected(type, extracted_string)
signal success_detected

### ONREADY VARIABLES

### EXPORTED VARIABLES

### VARIABLES

# CRP: current render process
var job_type_settings_CRP : ConfigFile

var software_start_success_strings_CRP : Array
var critical_error_strings_CRP : Array
var critical_error_exclude_strings_CRP : Array
var frame_success_strings_CRP : Array
var success_strings_CRP: Array

var software_start_success_regex_CRP : RegEx
var critical_error_regex_CRP : RegEx
var critical_error_exclude_regex_CRP : RegEx
var frame_success_regex_CRP : RegEx
var frame_name_detect_regex_CRP : RegEx
var success_regex_CRP : RegEx

# Highlight: used to colorize log lines
var job_type_settings_HIGHLIGHT : ConfigFile

var software_start_success_strings_HIGHLIGHT : Array
var critical_error_strings_HIGHLIGHT : Array
var critical_error_exclude_strings_HIGHLIGHT : Array
var error_strings_HIGHLIGHT : Array
var warning_strings_HIGHLIGHT : Array
var frame_success_strings_HIGHLIGHT : Array
var success_strings_HIGHLIGHT: Array

var software_start_success_regex_HIGHLIGHT : RegEx
var critical_error_regex_HIGHLIGHT : RegEx
var critical_error_exclude_regex_HIGHLIGHT : RegEx
var error_regex_HIGHLIGHT : RegEx
var warning_regex_HIGHLIGHT : RegEx
var frame_success_regex_HIGHLIGHT : RegEx
var success_regex_HIGHLIGHT : RegEx

# vars to check if software started successfully. Will be reset automatically on each config load.
var CRP_software_start_success_detected : bool = false 
var HIGHLIGHT_software_start_success_detected : bool = false





########## FUNCTIONS ##########


func _ready() -> void:
	job_type_settings_CRP = ConfigFile.new()
	job_type_settings_HIGHLIGHT = ConfigFile.new()
	
	software_start_success_regex_CRP = RegEx.new()
	critical_error_regex_CRP = RegEx.new()
	critical_error_exclude_regex_CRP = RegEx.new()
	frame_success_regex_CRP = RegEx.new()
	frame_name_detect_regex_CRP = RegEx.new()
	success_regex_CRP = RegEx.new()
	
	software_start_success_regex_HIGHLIGHT = RegEx.new()
	critical_error_regex_HIGHLIGHT = RegEx.new()
	critical_error_exclude_regex_HIGHLIGHT = RegEx.new()
	error_regex_HIGHLIGHT = RegEx.new()
	warning_regex_HIGHLIGHT = RegEx.new()
	frame_success_regex_HIGHLIGHT = RegEx.new()
	success_regex_HIGHLIGHT = RegEx.new()





func load_job_type_settings_CRP(job_type : String, job_type_version : String) -> bool:
	
	var settings_file_path : String =  RRPaths.job_types_default_path + job_type + "/" + job_type_version + ".cfg"
	var file_check : File = File.new()
	
	if not file_check.file_exists(settings_file_path):
		var error_msg : String = tr("MSG_ERROR_11") + "\n" + job_type + "/" + job_type_version
		if RaptorRender.NotificationSystem != null:
			RaptorRender.NotificationSystem.add_error_notification(tr("MSG_ERROR_1"), error_msg, 10) # The following job type configuration file could not be loaded:
		return false
	
	
	# reset software start success detected
	CRP_software_start_success_detected = false
	
	job_type_settings_CRP.load(settings_file_path )
		
	if job_type_settings_CRP.get_value("RenderLogValidation", "software_start_success_pattern_type", 0) != 5:
		software_start_success_strings_CRP = job_type_settings_CRP.get_value("RenderLogValidation", "software_start_success", "").replace("''","\"" ).split(";;",false)
	else:
		var regex_str : String = job_type_settings_CRP.get_value("RenderLogValidation", "software_start_success", "").replace("''","\"" )
		software_start_success_regex_CRP.compile( regex_str )
	
	if job_type_settings_CRP.get_value("RenderLogValidation", "critical_error_log_pattern_type", 0) != 5:
		critical_error_strings_CRP = job_type_settings_CRP.get_value("RenderLogValidation", "critical_error_log", "").replace("''","\"" ).split(";;",false)
	else:
		var regex_str : String = job_type_settings_CRP.get_value("RenderLogValidation", "critical_error_log", "").replace("''","\"" )
		critical_error_regex_CRP.compile( regex_str )
	
	if job_type_settings_CRP.get_value("RenderLogValidation", "critical_error_exclude_log_pattern_type", 0) != 5:
		critical_error_exclude_strings_CRP = job_type_settings_CRP.get_value("RenderLogValidation", "critical_error_exclude_log", "").replace("''","\"" ).split(";;",false)
	else:
		var regex_str : String = job_type_settings_CRP.get_value("RenderLogValidation", "critical_error_exclude_log", "").replace("''","\"" )
		critical_error_exclude_regex_CRP.compile( regex_str )
	
	if job_type_settings_CRP.get_value("RenderLogValidation", "frame_success_log_pattern_type", 0) != 5:
		frame_success_strings_CRP = job_type_settings_CRP.get_value("RenderLogValidation", "frame_success_log", "").replace("''","\"" ).split(";;",false)
	else:
		var regex_str : String = job_type_settings_CRP.get_value("RenderLogValidation", "frame_success_log", "").replace("''","\"" )
		frame_success_regex_CRP.compile( regex_str )
	
	var frame_detect_regex_str : String = job_type_settings_CRP.get_value("RenderLogValidation", "frame_name_detect_pattern", "").replace("''","\"" )
	frame_name_detect_regex_CRP.compile( frame_detect_regex_str )
	
	if job_type_settings_CRP.get_value("RenderLogValidation", "success_log_pattern_type", 0) != 5:
		success_strings_CRP = job_type_settings_CRP.get_value("RenderLogValidation", "success_log", "").replace("''","\"" ).split(";;",false)
	else:
		var regex_str : String = job_type_settings_CRP.get_value("RenderLogValidation", "success_log", "").replace("''","\"" )
		success_regex_CRP.compile( regex_str )
		
	return true



func load_job_type_settings_HIGHLIGHT(job_type : String, job_type_version : String) -> bool:
	
	var settings_file_path : String =  RRPaths.job_types_default_path + job_type + "/" + job_type_version + ".cfg"
	var file_check : File = File.new()
	
	if not file_check.file_exists(settings_file_path):
		var error_msg : String = tr("MSG_ERROR_11") + "\n" + job_type + "/" + job_type_version
		if RaptorRender.NotificationSystem != null:
			RaptorRender.NotificationSystem.add_error_notification(tr("MSG_ERROR_1"), error_msg, 10) # The following job type configuration file could not be loaded:
		return false
	
	# reset software start success detected
	HIGHLIGHT_software_start_success_detected = false
	
	job_type_settings_HIGHLIGHT.load( RRPaths.job_types_default_path + job_type + "/" + job_type_version + ".cfg" )
	
	if job_type_settings_HIGHLIGHT.get_value("RenderLogValidation", "software_start_success_pattern_type", 0) != 5:
		software_start_success_strings_HIGHLIGHT = job_type_settings_HIGHLIGHT.get_value("RenderLogValidation", "software_start_success", "").replace("''","\"" ).split(";;",false)
	else:
		var regex_str : String = job_type_settings_HIGHLIGHT.get_value("RenderLogValidation", "software_start_success", "").replace("''","\"" )
		software_start_success_regex_HIGHLIGHT.compile( regex_str )
		
	if job_type_settings_HIGHLIGHT.get_value("RenderLogValidation", "critical_error_log_pattern_type", 0) != 5:
		critical_error_strings_HIGHLIGHT = job_type_settings_HIGHLIGHT.get_value("RenderLogValidation", "critical_error_log", "").replace("''","\"" ).split(";;",false)
	else:
		var regex_str : String = job_type_settings_HIGHLIGHT.get_value("RenderLogValidation", "critical_error_log", "").replace("''","\"" )
		critical_error_regex_HIGHLIGHT.compile( regex_str )
	
	if job_type_settings_HIGHLIGHT.get_value("RenderLogValidation", "critical_error_exclude_log_pattern_type", 0) != 5:
		critical_error_exclude_strings_HIGHLIGHT = job_type_settings_HIGHLIGHT.get_value("RenderLogValidation", "critical_error_exclude_log", "").replace("''","\"" ).split(";;",false)
	else:
		var regex_str : String = job_type_settings_HIGHLIGHT.get_value("RenderLogValidation", "critical_error_exclude_log", "").replace("''","\"" )
		critical_error_exclude_regex_HIGHLIGHT.compile( regex_str )
	
	if job_type_settings_HIGHLIGHT.get_value("RenderLogValidation", "error_log_pattern_type", 0) != 5:
		error_strings_HIGHLIGHT = job_type_settings_HIGHLIGHT.get_value("RenderLogValidation", "error_log", "").replace("''","\"" ).split(";;",false)
	else:
		var regex_str : String = job_type_settings_HIGHLIGHT.get_value("RenderLogValidation", "error_log", "").replace("''","\"" )
		error_regex_HIGHLIGHT.compile( regex_str )
	
	if job_type_settings_HIGHLIGHT.get_value("RenderLogValidation", "warning_log_pattern_type", 0) != 5:
		warning_strings_HIGHLIGHT = job_type_settings_HIGHLIGHT.get_value("RenderLogValidation", "warning_log", "").replace("''","\"" ).split(";;",false)
	else:
		var regex_str : String = job_type_settings_HIGHLIGHT.get_value("RenderLogValidation", "warning_log", "").replace("''","\"" )
		warning_regex_HIGHLIGHT.compile( regex_str )
	
	if job_type_settings_HIGHLIGHT.get_value("RenderLogValidation", "frame_success_log_pattern_type", 0) != 5:
		frame_success_strings_HIGHLIGHT = job_type_settings_HIGHLIGHT.get_value("RenderLogValidation", "frame_success_log", "").replace("''","\"" ).split(";;",false)
	else:
		var regex_str : String = job_type_settings_HIGHLIGHT.get_value("RenderLogValidation", "frame_success_log", "").replace("''","\"" )
		frame_success_regex_HIGHLIGHT.compile( regex_str )
	
	if job_type_settings_HIGHLIGHT.get_value("RenderLogValidation", "success_log_pattern_type", 0) != 5:
		success_strings_HIGHLIGHT = job_type_settings_HIGHLIGHT.get_value("RenderLogValidation", "success_log", "").replace("''","\"" ).split(";;",false)
	else:
		var regex_str : String = job_type_settings_HIGHLIGHT.get_value("RenderLogValidation", "success_log", "").replace("''","\"" )
		success_regex_HIGHLIGHT.compile( regex_str )
		
	return true




func highlight_log_line(line : String) -> String:
	
	##### software_start_success validation #####
	if not HIGHLIGHT_software_start_success_detected:
		match job_type_settings_HIGHLIGHT.get_value("RenderLogValidation", "software_start_success_pattern_type", 0): 
			
			# not set
			0:
				pass
			
			# starts with
			1:
				for string in software_start_success_strings_HIGHLIGHT:
					
					if line.begins_with( string ):
						return "[color=#" + RRColorScheme.log_software_start_success + "]" + line + " (software start detected)[/color]"
			
			# ends with
			2: 
				for string in software_start_success_strings_HIGHLIGHT:
					
					if line.ends_with( string ):
						return "[color=#" + RRColorScheme.log_software_start_success + "]" + line + " (software start detected)[/color]"
			
			# contains
			3:
				for string in software_start_success_strings_HIGHLIGHT:
					
					if line.find( string ) > -1:
						return "[color=#" + RRColorScheme.log_software_start_success + "]" + line + " (software start detected)[/color]"
			
			# exactly matches
			4:
				for string in software_start_success_strings_HIGHLIGHT:
					
					if line == string:
						return "[color=#" + RRColorScheme.log_software_start_success + "]" + line + " (software start detected)[/color]"
			
			# regex
			5:
				if software_start_success_regex_HIGHLIGHT.search(line):
					return "[color=#" + RRColorScheme.log_software_start_success + "]" + line + " (software start detected)[/color]"
	
	
	
	##### critical error validation #####
	
	match job_type_settings_HIGHLIGHT.get_value("RenderLogValidation", "critical_error_log_pattern_type", 0): 
		
		# not set
		0:
			pass
		
		# starts with
		1:
			for string in critical_error_strings_HIGHLIGHT:
				
				if line.begins_with( string ):
					
					if check_critical_against_exclusion(line, critical_error_exclude_strings_HIGHLIGHT, critical_error_exclude_regex_HIGHLIGHT, job_type_settings_HIGHLIGHT):
						return "[color=#" + RRColorScheme.log_critical_error_ignored + "]" + line + "[/color]"
						
					return "[color=#" + RRColorScheme.log_critical_error + "]" + line + "[/color]"
		
		# ends with
		2: 
			for string in critical_error_strings_HIGHLIGHT:
				
				if line.ends_with( string ):
					
					if check_critical_against_exclusion(line, critical_error_exclude_strings_HIGHLIGHT, critical_error_exclude_regex_HIGHLIGHT, job_type_settings_HIGHLIGHT):
						return "[color=#" + RRColorScheme.log_critical_error_ignored + "]" + line + "[/color]"
					
					return "[color=#" + RRColorScheme.log_critical_error + "]" + line + "[/color]"
		
		# contains
		3:
			for string in critical_error_strings_HIGHLIGHT:
				
				if line.find( string ) > -1:
					if check_critical_against_exclusion(line, critical_error_exclude_strings_HIGHLIGHT, critical_error_exclude_regex_HIGHLIGHT, job_type_settings_HIGHLIGHT):
						return "[color=#" + RRColorScheme.log_critical_error_ignored + "]" + line + "[/color]"
					
					return "[color=#" + RRColorScheme.log_critical_error + "]" + line + "[/color]"
		
		# exactly matches
		4:
			for string in critical_error_strings_HIGHLIGHT:
				
				if line == string:
					if check_critical_against_exclusion(line, critical_error_exclude_strings_HIGHLIGHT, critical_error_exclude_regex_HIGHLIGHT, job_type_settings_HIGHLIGHT):
						return "[color=#" + RRColorScheme.log_critical_error_ignored + "]" + line + "[/color]"
					
					return "[color=#" + RRColorScheme.log_critical_error + "]" + line + "[/color]"
		
		# regex
		5:
			if critical_error_regex_HIGHLIGHT.search(line):
				if check_critical_against_exclusion(line, critical_error_exclude_strings_HIGHLIGHT, critical_error_exclude_regex_HIGHLIGHT, job_type_settings_HIGHLIGHT):
						return "[color=#" + RRColorScheme.log_critical_error_ignored + "]" + line + "[/color]"
				
				return "[color=#" + RRColorScheme.log_critical_error + "]" + line + "[/color]"
	
	
	
	##### error validation #####
	
	match job_type_settings_HIGHLIGHT.get_value("RenderLogValidation", "error_log_pattern_type", 0): 
		
		# not set
		0:
			pass
		
		# starts with
		1:
			for string in error_strings_HIGHLIGHT:
				
				if line.begins_with( string ):
					return "[color=#" + RRColorScheme.log_error + "]" + line + "[/color]"
		
		# ends with
		2: 
			for string in error_strings_HIGHLIGHT:
				
				if line.ends_with( string ):
					return "[color=#" + RRColorScheme.log_error + "]" + line + "[/color]"
		
		# contains
		3:
			for string in error_strings_HIGHLIGHT:
				
				if line.find( string ) > -1:
					return "[color=#" + RRColorScheme.log_error + "]" + line + "[/color]"
		
		# exactly matches
		4:
			for string in error_strings_HIGHLIGHT:
				
				if line == string:
					return "[color=#" + RRColorScheme.log_error + "]" + line + "[/color]"
		
		# regex
		5:
			if error_regex_HIGHLIGHT.search(line):
				return "[color=#" + RRColorScheme.log_error + "]" + line + "[/color]"
			
	
	
	
	##### warning validation #####
	
	match job_type_settings_HIGHLIGHT.get_value("RenderLogValidation", "warning_log_pattern_type", 0): 
		
		# not set
		0:
			pass
		
		# starts with
		1:
			for string in warning_strings_HIGHLIGHT:
				
				if line.begins_with( string ):
					return "[color=#" + RRColorScheme.log_warning + "]" + line + "[/color]"
		
		# ends with
		2: 
			for string in warning_strings_HIGHLIGHT:
				
				if line.ends_with( string ):
					return "[color=#" + RRColorScheme.log_warning + "]" + line + "[/color]"
		
		# contains
		3:
			for string in warning_strings_HIGHLIGHT:
				
				if line.find( string ) > -1:
					return "[color=#" + RRColorScheme.log_warning + "]" + line + "[/color]"
		
		# exactly matches
		4:
			for string in warning_strings_HIGHLIGHT:
				
				if line == string:
					return "[color=#" + RRColorScheme.log_warning + "]" + line + "[/color]"
		
		# regex
		5:
			if warning_regex_HIGHLIGHT.search(line):
				return "[color=#" + RRColorScheme.log_warning + "]" + line + "[/color]"
	
	
	
	##### frame_success validation #####
	
	match job_type_settings_HIGHLIGHT.get_value("RenderLogValidation", "frame_success_log_pattern_type", 0): 
		
		# not set
		0:
			pass
		
		# starts with
		1:
			for string in frame_success_strings_HIGHLIGHT:
				
				if line.begins_with( string ):
					return "[color=#" + RRColorScheme.log_success + "]" + line + "[/color]"
		
		# ends with
		2: 
			for string in frame_success_strings_HIGHLIGHT:
				
				if line.ends_with( string ):
					return "[color=#" + RRColorScheme.log_success + "]" + line + "[/color]"
		
		# contains
		3:
			for string in frame_success_strings_HIGHLIGHT:
				
				if line.find( string ) > -1:
					return "[color=#" + RRColorScheme.log_success + "]" + line + "[/color]"
		
		# exactly matches
		4:
			for string in frame_success_strings_HIGHLIGHT:
				
				if line == string:
					return "[color=#" + RRColorScheme.log_success + "]" + line + "[/color]"
		
		# regex
		5:
			if frame_success_regex_HIGHLIGHT.search(line):
				return "[color=#" + RRColorScheme.log_success + "]" + line + "[/color]"
	
	
	
	##### success validation #####
	
	match job_type_settings_HIGHLIGHT.get_value("RenderLogValidation", "success_log_pattern_type", 0): 
		
		# not set
		0:
			pass
		
		# starts with
		1:
			for string in success_strings_HIGHLIGHT:
				
				if line.begins_with( string ):
					return "[color=#" + RRColorScheme.log_success + "]" + line + "[/color]"
		
		# ends with
		2: 
			for string in success_strings_HIGHLIGHT:
				
				if line.ends_with( string ):
					return "[color=#" + RRColorScheme.log_success + "]" + line + "[/color]"
		
		# contains
		3:
			for string in success_strings_HIGHLIGHT:
				
				if line.find( string ) > -1:
					return "[color=#" + RRColorScheme.log_success + "]" + line + "[/color]"
		
		# exactly matches
		4:
			for string in success_strings_HIGHLIGHT:
				
				if line == string:
					return "[color=#" + RRColorScheme.log_success + "]" + line + "[/color]"
		
		# regex
		5:
			if success_regex_HIGHLIGHT.search(line):
				return "[color=#" + RRColorScheme.log_success + "]" + line + "[/color]"
	
	
	
	# validate agains "Raptor Render Error"
	if line.find( "Raptor Render Error" ) > -1:
		return "[color=#" + RRColorScheme.log_critical_error + "]" + line + "[/color]"
	
	return line





# this function will validate a logline and emit corresponding signals like errors or successes. The function will also return "false" if there was a critical error detected in that line.
func validate_log_line(line : String) -> bool:
	
	var frame_success_detected : bool = false
	
	##### software_start_success validation #####
	if not CRP_software_start_success_detected:
		match job_type_settings_CRP.get_value("RenderLogValidation", "software_start_success_pattern_type", 0): 
			# not set
			0:
				pass
			
			# starts with
			1:
				for string in software_start_success_strings_CRP:
					
					if line.begins_with( string ):
						CRP_software_start_success_detected = true
						emit_signal("software_start_success_detected")
						print ("software start success detected!")
			
			# ends with
			2: 
				for string in software_start_success_strings_CRP:
					
					if line.ends_with( string ):
						CRP_software_start_success_detected = true
						emit_signal("software_start_success_detected")
						print ("software start success detected!")
			
			# contains
			3:
				for string in software_start_success_strings_CRP:
					
					if line.find( string ) > -1:
						CRP_software_start_success_detected = true
						emit_signal("software_start_success_detected")
						print ("software start success detected!")
			
			# exactly matches
			4:
				for string in software_start_success_strings_CRP:
					
					if line == string:
						CRP_software_start_success_detected = true
						emit_signal("software_start_success_detected")
						print ("software start success detected!")
			
			# regex
			5:
				if software_start_success_regex_CRP.search(line):
					CRP_software_start_success_detected = true
					emit_signal("software_start_success_detected")
					print ("software start success detected!")
		
		
	##### critical error validation #####
	
	match job_type_settings_CRP.get_value("RenderLogValidation", "critical_error_log_pattern_type", 0): 
		
		# not set
		0:
			pass
		
		# starts with
		1:
			for string in critical_error_strings_CRP:
				
				if line.begins_with( string ):
					if !check_critical_against_exclusion(line, critical_error_exclude_strings_CRP, critical_error_exclude_regex_CRP, job_type_settings_CRP):
						emit_signal("critical_error_detected")
						print ("critical error detected!")
						return false
		
		# ends with
		2: 
			for string in critical_error_strings_CRP:
				
				if line.ends_with( string ):
					if !check_critical_against_exclusion(line, critical_error_exclude_strings_CRP, critical_error_exclude_regex_CRP, job_type_settings_CRP):
						emit_signal("critical_error_detected")
						print ("critical error detected!")
						return false	
		
		# contains
		3:
			for string in critical_error_strings_CRP:
				
				if line.find( string ) > -1:
					if !check_critical_against_exclusion(line, critical_error_exclude_strings_CRP, critical_error_exclude_regex_CRP, job_type_settings_CRP):
						emit_signal("critical_error_detected")
						print ("critical error detected!")
						return false
		
		# exactly matches
		4:
			for string in critical_error_strings_CRP:
				
				if line == string:
					if !check_critical_against_exclusion(line, critical_error_exclude_strings_CRP, critical_error_exclude_regex_CRP, job_type_settings_CRP):
						emit_signal("critical_error_detected")
						print ("critical error detected!")
						return false
		
		# regex
		5:
			if critical_error_regex_CRP.search(line):
				if !check_critical_against_exclusion(line, critical_error_exclude_strings_CRP, critical_error_exclude_regex_CRP, job_type_settings_CRP):
					emit_signal("critical_error_detected")
					print ("critical error detected!")
					return false
	
	
	
	
	##### frame_success validation #####
	
	match job_type_settings_CRP.get_value("RenderLogValidation", "frame_success_log_pattern_type", 0): 
		# not set
		0:
			pass
		
		# starts with
		1:
			for string in frame_success_strings_CRP:
				
				if line.begins_with( string ):
					frame_success_detected = true
					emit_signal("frame_success_detected")
					print ("frame success detected!")
		
		# ends with
		2: 
			for string in frame_success_strings_CRP:
				
				if line.ends_with( string ):
					frame_success_detected = true
					emit_signal("frame_success_detected")
					print ("frame success detected!")
		
		# contains
		3:
			for string in frame_success_strings_CRP:
				
				if line.find( string ) > -1:
					frame_success_detected = true
					emit_signal("frame_success_detected")
					print ("frame success detected!")
		
		# exactly matches
		4:
			for string in frame_success_strings_CRP:
				
				if line == string:
					frame_success_detected = true
					emit_signal("frame_success_detected")
					print ("frame success detected!")
		
		# regex
		5:
			if frame_success_regex_CRP.search(line):
				frame_success_detected = true
				emit_signal("frame_success_detected")
				print ("frame_success detected!")
	
	
	if frame_success_detected:
		var frame_name_detect_type : int = job_type_settings_CRP.get_value("RenderLogValidation", "frame_name_detect_option", 0)
		if frame_name_detect_type != 0:
			var frame_name_match : RegExMatch = frame_name_detect_regex_CRP.search(line)
			
			if frame_name_match != null: # this check is very important. If RegExMatch is null, any code trying to do something with it would cancle the current render for some reason
				emit_signal("frame_name_detected", frame_name_detect_type, frame_name_match.get_string(0))
				print ("Frame name detected: " + frame_name_match.get_string(0))
	
	
	##### success validation #####
	
	match job_type_settings_CRP.get_value("RenderLogValidation", "success_log_pattern_type", 0): 
		# not set
		0:
			pass
		
		# starts with
		1:
			for string in success_strings_CRP:
				
				if line.begins_with( string ):
					emit_signal("success_detected")
					print ("success detected!")
		
		# ends with
		2: 
			for string in success_strings_CRP:
				
				if line.ends_with( string ):
					emit_signal("success_detected")
					print ("success detected!")
		
		# contains
		3:
			for string in success_strings_CRP:
				
				if line.find( string ) > -1:
					emit_signal("success_detected")
					print ("success detected!")
		
		# exactly matches
		4:
			for string in success_strings_CRP:
				
				if line == string:
					emit_signal("success_detected")
					print ("success detected!")
		
		# regex
		5:
			if success_regex_CRP.search(line):
				emit_signal("success_detected")
				print ("success detected!")
			
	
	return true






func check_critical_against_exclusion(line : String, critical_error_exclusion_strings : Array, critical_error_exclusion_regex : RegEx, job_type_settings : ConfigFile) -> bool:
	
	##### critical error exclusion validation #####
	
	match job_type_settings.get_value("RenderLogValidation", "critical_error_exclude_log_pattern_type", 0): 
		
		# not set
		0:
			pass
		
		# starts with
		1:
			for string in critical_error_exclusion_strings:
				
				if line.begins_with( string ):
					return true
		
		# ends with
		2: 
			for string in critical_error_exclusion_strings:
				
				if line.ends_with( string ):
					return true
		
		# contains
		3:
			for string in critical_error_exclusion_strings:
				
				if line.find( string ) > -1:
					return true
		
		# exactly matches
		4:
			for string in critical_error_exclusion_strings:
				
				if line == string:
					return true
		
		# regex
		5:
			if critical_error_exclusion_regex.search(line):
				return true
	
	
	return false

