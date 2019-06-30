#////////////////////#
# RenderLogValidator #
#////////////////////#

# This script holds functions to detect errors, validate and colorize single log lines of the render process or already finished log files.
# The rules for the validation first have to be loaded from a .cfg file for the respective renderer.
# There are very similar functions all over this script. One named as "CRP" (Current Render Process) and the other named as "HIGHLIGHT". That's to ensure, that it is possible that your machine can simultaneously render and validat the output, while also show colorized log outputs of other jobs with other validation rules in the interface.
# The CRP functions only send signals on successes or error detection, while the HIGHLIGHT functions return a colorized string.



extends Node

signal error_detected
signal critical_error_detected
signal frame_success_detected
signal success_detected


var job_type_settings_path : String


# CRP: current render process
var job_type_settings_CRP : ConfigFile

var possible_critical_error_strings_CRP : Array
var critical_error_exclude_strings_CRP : Array
var possible_frame_success_strings_CRP : Array
var possible_success_strings_CRP: Array

var critical_error_regex_CRP : RegEx
var critical_error_exclude_regex_CRP : RegEx
var frame_success_regex_CRP : RegEx
var success_regex_CRP : RegEx



var job_type_settings_HIGHLIGHT : ConfigFile

var possible_critical_error_strings_HIGHLIGHT : Array
var critical_error_exclude_strings_HIGHLIGHT : Array
var possible_error_strings_HIGHLIGHT : Array
var possible_warning_strings_HIGHLIGHT : Array
var possible_frame_success_strings_HIGHLIGHT : Array
var possible_success_strings_HIGHLIGHT: Array

var critical_error_regex_HIGHLIGHT : RegEx
var critical_error_exclude_regex_HIGHLIGHT : RegEx
var error_regex_HIGHLIGHT : RegEx
var warning_regex_HIGHLIGHT : RegEx
var frame_success_regex_HIGHLIGHT : RegEx
var success_regex_HIGHLIGHT : RegEx


func _ready():
	job_type_settings_CRP = ConfigFile.new()
	job_type_settings_HIGHLIGHT = ConfigFile.new()
	
	critical_error_regex_CRP = RegEx.new()
	critical_error_exclude_regex_CRP = RegEx.new()
	frame_success_regex_CRP = RegEx.new()
	success_regex_CRP = RegEx.new()
	
	critical_error_regex_HIGHLIGHT = RegEx.new()
	critical_error_exclude_regex_HIGHLIGHT = RegEx.new()
	error_regex_HIGHLIGHT = RegEx.new()
	warning_regex_HIGHLIGHT = RegEx.new()
	frame_success_regex_HIGHLIGHT = RegEx.new()
	success_regex_HIGHLIGHT = RegEx.new()
	
	
	job_type_settings_path = OS.get_user_data_dir() + "/JobTypeSettings/"
	
	load_job_type_settings_CRP("Blender", "default")
	load_job_type_settings_HIGHLIGHT("Blender", "default")





func load_job_type_settings_CRP(job_type : String, job_type_version : String):
	
	job_type_settings_CRP.load( job_type_settings_path + "/local/" + job_type + "/" + job_type_version + ".cfg" )
		
	if job_type_settings_CRP.get_value("RenderLogValidation", "critical_error_log_pattern_type", 0) != 5:
		possible_critical_error_strings_CRP = job_type_settings_CRP.get_value("RenderLogValidation", "critical_error_log", "").replace("''","\"" ).split(";;",false)
	else:
		var regex_str : String = job_type_settings_CRP.get_value("RenderLogValidation", "critical_error_log", "").replace("''","\"" )
		critical_error_regex_CRP.compile( regex_str )
	
	if job_type_settings_CRP.get_value("RenderLogValidation", "critical_error_exclude_log_pattern_type", 0) != 5:
		critical_error_exclude_strings_CRP = job_type_settings_CRP.get_value("RenderLogValidation", "critical_error_exclude_log", "").replace("''","\"" ).split(";;",false)
	else:
		var regex_str : String = job_type_settings_CRP.get_value("RenderLogValidation", "critical_error_exclude_log", "").replace("''","\"" )
		critical_error_exclude_regex_CRP.compile( regex_str )
	
	if job_type_settings_CRP.get_value("RenderLogValidation", "frame_success_log_pattern_type", 0) != 5:
		possible_frame_success_strings_CRP = job_type_settings_CRP.get_value("RenderLogValidation", "frame_success_log", "").replace("''","\"" ).split(";;",false)
	else:
		var regex_str : String = job_type_settings_CRP.get_value("RenderLogValidation", "frame_success_log", "").replace("''","\"" )
		frame_success_regex_CRP.compile( regex_str )
	
	if job_type_settings_CRP.get_value("RenderLogValidation", "success_log_pattern_type", 0) != 5:
		possible_success_strings_CRP = job_type_settings_CRP.get_value("RenderLogValidation", "success_log", "").replace("''","\"" ).split(";;",false)
	else:
		var regex_str : String = job_type_settings_CRP.get_value("RenderLogValidation", "success_log", "").replace("''","\"" )
		success_regex_CRP.compile( regex_str )




func load_job_type_settings_HIGHLIGHT(job_type : String, job_type_version : String):
	
	job_type_settings_HIGHLIGHT.load( job_type_settings_path + "/local/" + job_type + "/" + job_type_version + ".cfg" )
	
	if job_type_settings_HIGHLIGHT.get_value("RenderLogValidation", "critical_error_log_pattern_type", 0) != 5:
		possible_critical_error_strings_HIGHLIGHT = job_type_settings_HIGHLIGHT.get_value("RenderLogValidation", "critical_error_log", "").replace("''","\"" ).split(";;",false)
	else:
		var regex_str : String = job_type_settings_HIGHLIGHT.get_value("RenderLogValidation", "critical_error_log", "").replace("''","\"" )
		critical_error_regex_HIGHLIGHT.compile( regex_str )
	
	if job_type_settings_HIGHLIGHT.get_value("RenderLogValidation", "critical_error_exclude_log_pattern_type", 0) != 5:
		critical_error_exclude_strings_HIGHLIGHT = job_type_settings_HIGHLIGHT.get_value("RenderLogValidation", "critical_error_exclude_log", "").replace("''","\"" ).split(";;",false)
	else:
		var regex_str : String = job_type_settings_HIGHLIGHT.get_value("RenderLogValidation", "critical_error_exclude_log", "").replace("''","\"" )
		critical_error_exclude_regex_HIGHLIGHT.compile( regex_str )
	
	if job_type_settings_HIGHLIGHT.get_value("RenderLogValidation", "error_log_pattern_type", 0) != 5:
		possible_error_strings_HIGHLIGHT = job_type_settings_HIGHLIGHT.get_value("RenderLogValidation", "error_log", "").replace("''","\"" ).split(";;",false)
	else:
		var regex_str : String = job_type_settings_HIGHLIGHT.get_value("RenderLogValidation", "error_log", "").replace("''","\"" )
		error_regex_HIGHLIGHT.compile( regex_str )
	
	if job_type_settings_HIGHLIGHT.get_value("RenderLogValidation", "warning_log_pattern_type", 0) != 5:
		possible_warning_strings_HIGHLIGHT = job_type_settings_HIGHLIGHT.get_value("RenderLogValidation", "warning_log", "").replace("''","\"" ).split(";;",false)
	else:
		var regex_str : String = job_type_settings_HIGHLIGHT.get_value("RenderLogValidation", "warning_log", "").replace("''","\"" )
		warning_regex_HIGHLIGHT.compile( regex_str )
	
	if job_type_settings_HIGHLIGHT.get_value("RenderLogValidation", "frame_success_log_pattern_type", 0) != 5:
		possible_frame_success_strings_HIGHLIGHT = job_type_settings_HIGHLIGHT.get_value("RenderLogValidation", "frame_success_log", "").replace("''","\"" ).split(";;",false)
	else:
		var regex_str : String = job_type_settings_HIGHLIGHT.get_value("RenderLogValidation", "frame_success_log", "").replace("''","\"" )
		frame_success_regex_HIGHLIGHT.compile( regex_str )
	
	if job_type_settings_HIGHLIGHT.get_value("RenderLogValidation", "success_log_pattern_type", 0) != 5:
		possible_success_strings_HIGHLIGHT = job_type_settings_HIGHLIGHT.get_value("RenderLogValidation", "success_log", "").replace("''","\"" ).split(";;",false)
	else:
		var regex_str : String = job_type_settings_HIGHLIGHT.get_value("RenderLogValidation", "success_log", "").replace("''","\"" )
		success_regex_HIGHLIGHT.compile( regex_str )





func highlight_log_line(line : String) -> String:
	
	
	##### critical error validation #####
	
	match job_type_settings_HIGHLIGHT.get_value("RenderLogValidation", "critical_error_log_pattern_type", 0): 
		
		# not set
		0:
			pass
		
		# starts with
		1:
			for string in possible_critical_error_strings_HIGHLIGHT:
				
				if line.begins_with( string ):
					
					if check_critical_against_exclusion(line, critical_error_exclude_strings_HIGHLIGHT, critical_error_exclude_regex_HIGHLIGHT, job_type_settings_HIGHLIGHT):
						return "[color=#" + RRColorScheme.log_critical_error_ignored + "]" + line + "[/color]"
						
					return "[color=#" + RRColorScheme.log_critical_error + "]" + line + "[/color]"
		
		# ends with
		2: 
			for string in possible_critical_error_strings_HIGHLIGHT:
				
				if line.ends_with( string ):
					
					if check_critical_against_exclusion(line, critical_error_exclude_strings_HIGHLIGHT, critical_error_exclude_regex_HIGHLIGHT, job_type_settings_HIGHLIGHT):
						return "[color=#" + RRColorScheme.log_critical_error_ignored + "]" + line + "[/color]"
					
					return "[color=#" + RRColorScheme.log_critical_error + "]" + line + "[/color]"
		
		# contains
		3:
			for string in possible_critical_error_strings_HIGHLIGHT:
				
				if line.find( string ) > -1:
					if check_critical_against_exclusion(line, critical_error_exclude_strings_HIGHLIGHT, critical_error_exclude_regex_HIGHLIGHT, job_type_settings_HIGHLIGHT):
						return "[color=#" + RRColorScheme.log_critical_error_ignored + "]" + line + "[/color]"
					
					return "[color=#" + RRColorScheme.log_critical_error + "]" + line + "[/color]"
		
		# exactly matches
		4:
			for string in possible_critical_error_strings_HIGHLIGHT:
				
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
			for string in possible_error_strings_HIGHLIGHT:
				
				if line.begins_with( string ):
					return "[color=#" + RRColorScheme.log_error + "]" + line + "[/color]"
		
		# ends with
		2: 
			for string in possible_error_strings_HIGHLIGHT:
				
				if line.ends_with( string ):
					return "[color=#" + RRColorScheme.log_error + "]" + line + "[/color]"
		
		# contains
		3:
			for string in possible_error_strings_HIGHLIGHT:
				
				if line.find( string ) > -1:
					return "[color=#" + RRColorScheme.log_error + "]" + line + "[/color]"
		
		# exactly matches
		4:
			for string in possible_error_strings_HIGHLIGHT:
				
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
			for string in possible_warning_strings_HIGHLIGHT:
				
				if line.begins_with( string ):
					return "[color=#" + RRColorScheme.log_warning + "]" + line + "[/color]"
		
		# ends with
		2: 
			for string in possible_warning_strings_HIGHLIGHT:
				
				if line.ends_with( string ):
					return "[color=#" + RRColorScheme.log_warning + "]" + line + "[/color]"
		
		# contains
		3:
			for string in possible_warning_strings_HIGHLIGHT:
				
				if line.find( string ) > -1:
					return "[color=#" + RRColorScheme.log_warning + "]" + line + "[/color]"
		
		# exactly matches
		4:
			for string in possible_warning_strings_HIGHLIGHT:
				
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
			for string in possible_frame_success_strings_HIGHLIGHT:
				
				if line.begins_with( string ):
					return "[color=#" + RRColorScheme.log_success + "]" + line + "[/color]"
		
		# ends with
		2: 
			for string in possible_frame_success_strings_HIGHLIGHT:
				
				if line.ends_with( string ):
					return "[color=#" + RRColorScheme.log_success + "]" + line + "[/color]"
		
		# contains
		3:
			for string in possible_frame_success_strings_HIGHLIGHT:
				
				if line.find( string ) > -1:
					return "[color=#" + RRColorScheme.log_success + "]" + line + "[/color]"
		
		# exactly matches
		4:
			for string in possible_frame_success_strings_HIGHLIGHT:
				
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
			for string in possible_success_strings_HIGHLIGHT:
				
				if line.begins_with( string ):
					return "[color=#" + RRColorScheme.log_success + "]" + line + "[/color]"
		
		# ends with
		2: 
			for string in possible_success_strings_HIGHLIGHT:
				
				if line.ends_with( string ):
					return "[color=#" + RRColorScheme.log_success + "]" + line + "[/color]"
		
		# contains
		3:
			for string in possible_success_strings_HIGHLIGHT:
				
				if line.find( string ) > -1:
					return "[color=#" + RRColorScheme.log_success + "]" + line + "[/color]"
		
		# exactly matches
		4:
			for string in possible_success_strings_HIGHLIGHT:
				
				if line == string:
					return "[color=#" + RRColorScheme.log_success + "]" + line + "[/color]"
		
		# regex
		5:
			if success_regex_HIGHLIGHT.search(line):
				return "[color=#" + RRColorScheme.log_success + "]" + line + "[/color]"
	
	
	return line





# this function will validate a logline and emit corresponding signals like errors or successes. The function will also return "false" if there was a critical error detected in that line.
func validate_log_line(line : String) -> bool:
	
	##### critical error validation #####
	
	match job_type_settings_CRP.get_value("RenderLogValidation", "critical_error_log_pattern_type", 0): 
		
		# not set
		0:
			pass
		
		# starts with
		1:
			for string in possible_critical_error_strings_CRP:
				
				if line.begins_with( string ):
					if !check_critical_against_exclusion(line, critical_error_exclude_strings_CRP, critical_error_exclude_regex_CRP, job_type_settings_CRP):
						emit_signal("critical_error_detected")
						print ("critical error detected!")
						return false
		
		# ends with
		2: 
			for string in possible_critical_error_strings_CRP:
				
				if line.ends_with( string ):
					if !check_critical_against_exclusion(line, critical_error_exclude_strings_CRP, critical_error_exclude_regex_CRP, job_type_settings_CRP):
						emit_signal("critical_error_detected")
						print ("critical error detected!")
						return false	
		
		# contains
		3:
			for string in possible_critical_error_strings_CRP:
				
				if line.find( string ) > -1:
					if !check_critical_against_exclusion(line, critical_error_exclude_strings_CRP, critical_error_exclude_regex_CRP, job_type_settings_CRP):
						emit_signal("critical_error_detected")
						print ("critical error detected!")
						return false
		
		# exactly matches
		4:
			for string in possible_critical_error_strings_CRP:
				
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
			for string in possible_frame_success_strings_CRP:
				
				if line.begins_with( string ):
					emit_signal("frame_success_detected")
					print ("frame success detected!")
		
		# ends with
		2: 
			for string in possible_frame_success_strings_CRP:
				
				if line.ends_with( string ):
					emit_signal("frame_success_detected")
					print ("frame success detected!")
		
		# contains
		3:
			for string in possible_frame_success_strings_CRP:
				
				if line.find( string ) > -1:
					emit_signal("frame_success_detected")
					print ("frame success detected!")
		
		# exactly matches
		4:
			for string in possible_frame_success_strings_CRP:
				
				if line == string:
					emit_signal("frame_success_detected")
					print ("frame success detected!")
		
		# regex
		5:
			if frame_success_regex_CRP.search(line):
				emit_signal("frame_success_detected")
				print ("frame_success detected!")
	
	
	
	##### success validation #####
	
	match job_type_settings_CRP.get_value("RenderLogValidation", "success_log_pattern_type", 0): 
		# not set
		0:
			pass
		
		# starts with
		1:
			for string in possible_success_strings_CRP:
				
				if line.begins_with( string ):
					emit_signal("success_detected")
					print ("success detected!")
		
		# ends with
		2: 
			for string in possible_success_strings_CRP:
				
				if line.ends_with( string ):
					emit_signal("success_detected")
					print ("success detected!")
		
		# contains
		3:
			for string in possible_success_strings_CRP:
				
				if line.find( string ) > -1:
					emit_signal("success_detected")
					print ("success detected!")
		
		# exactly matches
		4:
			for string in possible_success_strings_CRP:
				
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

