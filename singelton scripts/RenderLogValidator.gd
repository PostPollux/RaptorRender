#////////////////////#
# RenderLogValidator #
#////////////////////#

# This script handles 
# 


extends Node

signal error_detected
signal critical_error_detected
signal frame_success_detected
signal success_detected



# crp: current render process
var job_type_settings_CRP : ConfigFile

var possible_critical_error_strings_CRP : Array
var critical_error_exclude_strings_CRP : Array
var possible_error_strings_CRP : Array
var possible_warning_strings_CRP : Array
var possible_frame_success_strings_CRP : Array
var possible_success_strings_CRP: Array


var job_type_settings_HIGHLIGHT : ConfigFile

var possible_critical_error_strings_HIGHLIGHT : Array
var critical_error_exclude_strings_HIGHLIGHT : Array
var possible_error_strings_HIGHLIGHT : Array
var possible_warning_strings_HIGHLIGHT : Array
var possible_frame_success_strings_HIGHLIGHT : Array
var possible_success_strings_HIGHLIGHT: Array




func _ready():
	job_type_settings_CRP = ConfigFile.new()
	job_type_settings_HIGHLIGHT = ConfigFile.new()
	
	load_job_type_settings_CRP()
	load_job_type_settings_HIGHLIGHT()




func load_job_type_settings_CRP():
	
	job_type_settings_CRP.load("/home/johannes/git_projects/RaptorRender/JobTypes/Blender.cfg")
		
	possible_critical_error_strings_CRP = job_type_settings_CRP.get_value("RenderLogValidation", "critical_error_log", "").split(";;",false)
	critical_error_exclude_strings_CRP = job_type_settings_CRP.get_value("RenderLogValidation", "critical_error_exclude_log", "").split(";;",false)
	possible_frame_success_strings_CRP = job_type_settings_CRP.get_value("RenderLogValidation", "frame_success_log", "").split(";;",false)
	possible_success_strings_CRP = job_type_settings_CRP.get_value("RenderLogValidation", "success_log", "").split(";;",false)



func load_job_type_settings_HIGHLIGHT():
	
	job_type_settings_HIGHLIGHT.load("/home/johannes/git_projects/RaptorRender/JobTypes/Blender.cfg")
		
	possible_critical_error_strings_HIGHLIGHT = job_type_settings_HIGHLIGHT.get_value("RenderLogValidation", "critical_error_log", "").split(";;",false)
	critical_error_exclude_strings_HIGHLIGHT = job_type_settings_HIGHLIGHT.get_value("RenderLogValidation", "critical_error_exclude_log", "").split(";;",false)
	possible_error_strings_HIGHLIGHT = job_type_settings_HIGHLIGHT.get_value("RenderLogValidation", "error_log", "").split(";;",false)
	possible_warning_strings_HIGHLIGHT = job_type_settings_HIGHLIGHT.get_value("RenderLogValidation", "warning_log", "").split(";;",false)
	possible_frame_success_strings_HIGHLIGHT = job_type_settings_HIGHLIGHT.get_value("RenderLogValidation", "frame_success_log", "").split(";;",false)
	possible_success_strings_HIGHLIGHT = job_type_settings_HIGHLIGHT.get_value("RenderLogValidation", "success_log", "").split(";;",false)
	





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
					
					if check_critical_against_exclusion(line, critical_error_exclude_strings_HIGHLIGHT, job_type_settings_HIGHLIGHT):
						return "[color=#" + RRColorScheme.log_critical_error_ignored + "]" + line + "[/color]"
						
					return "[color=#" + RRColorScheme.log_critical_error + "]" + line + "[/color]"
		
		# ends with
		2: 
			for string in possible_critical_error_strings_HIGHLIGHT:
				
				if line.ends_with( string ):
					
					if check_critical_against_exclusion(line, critical_error_exclude_strings_HIGHLIGHT, job_type_settings_HIGHLIGHT):
						return "[color=#" + RRColorScheme.log_critical_error_ignored + "]" + line + "[/color]"
					
					return "[color=#" + RRColorScheme.log_critical_error + "]" + line + "[/color]"
		
		# contains
		3:
			for string in possible_critical_error_strings_HIGHLIGHT:
				
				if line.find( string ) > -1:
					if check_critical_against_exclusion(line, critical_error_exclude_strings_HIGHLIGHT, job_type_settings_HIGHLIGHT):
						return "[color=#" + RRColorScheme.log_critical_error_ignored + "]" + line + "[/color]"
					
					return "[color=#" + RRColorScheme.log_critical_error + "]" + line + "[/color]"
		
		# exactly matches
		4:
			for string in possible_critical_error_strings_HIGHLIGHT:
				
				if line == string:
					if check_critical_against_exclusion(line, critical_error_exclude_strings_HIGHLIGHT, job_type_settings_HIGHLIGHT):
						return "[color=#" + RRColorScheme.log_critical_error_ignored + "]" + line + "[/color]"
					
					return "[color=#" + RRColorScheme.log_critical_error + "]" + line + "[/color]"
		
		# regex
		5:
			pass
	
	
	
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
			pass
	
	
	
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
			pass
	
	
	
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
			pass
	
	
	
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
			pass
	
	
	return line






func validate_log_line(line : String):
	
	##### critical error validation #####
	
	match job_type_settings_CRP.get_value("RenderLogValidation", "critical_error_log_pattern_type", 0): 
		
		# not set
		0:
			pass
		
		# starts with
		1:
			for string in possible_critical_error_strings_CRP:
				
				if line.begins_with( string ):
					if !check_critical_against_exclusion(line, critical_error_exclude_strings_CRP, job_type_settings_CRP):
						emit_signal("critical_error_detected")
						print ("critical error detected!")
		
		# ends with
		2: 
			for string in possible_critical_error_strings_CRP:
				
				if line.ends_with( string ):
					if !check_critical_against_exclusion(line, critical_error_exclude_strings_CRP, job_type_settings_CRP):
						emit_signal("critical_error_detected")
						print ("critical error detected!")
		
		# contains
		3:
			for string in possible_critical_error_strings_CRP:
				
				if line.find( string ) > -1:
					if !check_critical_against_exclusion(line, critical_error_exclude_strings_CRP, job_type_settings_CRP):
						emit_signal("critical_error_detected")
						print ("critical error detected!")
		
		# exactly matches
		4:
			for string in possible_critical_error_strings_CRP:
				
				if line == string:
					if !check_critical_against_exclusion(line, critical_error_exclude_strings_CRP, job_type_settings_CRP):
						emit_signal("critical_error_detected")
						print ("critical error detected!")
		
		# regex
		5:
			pass
	
	
	
	
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
			pass
	
	
	
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
			pass
			






func check_critical_against_exclusion(line : String, critical_error_exclusion_strings : Array, job_type_settings : ConfigFile) -> bool:
	
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
			pass
	
	
	return false

