extends Node


### PRELOAD RESOURCES

### SIGNALS

### ONREADY VARIABLES

### EXPORTED VARIABLES

### VARIABLES
var current_processing_job : int
var current_processing_chunk : int
var current_processing_try : int

var current_amount_of_frame_successes : int  = 0
var current_amount_of_critical_errors : int = 0
var chunk_success_detected : bool = false

var current_log_file_path : String = ""





########## FUNCTIONS ##########


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	RenderLogValidator.connect("success_detected", self, "success_detected")
	RenderLogValidator.connect("frame_success_detected", self, "frame_success_detected")
	RenderLogValidator.connect("critical_error_detected", self, "critical_error_detected")
	RenderLogValidator.connect("frame_name_detected", self, "frame_name_detected")
	CommandLineManager.connect("render_process_exited_without_software_start", self, "render_process_exited_without_software_start")



func render_process_exited_without_software_start() -> void:
	# this check makes sense, because if it misses the "software_start_successful" string for any reason while it actually started, it would throw an error after finishing the chunk correctly 
	if current_amount_of_frame_successes == 0:
		critical_error_detected()
	
	var log_file : File = File.new()
	
	# check if log file is empty (in some rare cases they error output can't be captured. So for this cases we want to add a hint in the logfile)
	if log_file.file_exists(current_log_file_path):
		log_file.open(current_log_file_path, File.READ_WRITE)
		
		var line_iterator : int = 0
		while true:
			var line : String = log_file.get_line()
			
			# break loop if end of file is reached
			if log_file.eof_reached():
				break
			
			if line_iterator > 0:
				break
				
			line_iterator += 1
		
		# handle empty  log file
		if line_iterator == 0:
			
			log_file.WRITE
			log_file.store_line("Raptor Render Error: " + tr("MSG_ERROR_18") ) # MSG_ERROR_18: The render process exited without writing anything to the log file. This happens in very rare cases. To find the error, please try to execute the command from above manually in your terminal.
		
		log_file.close()




func critical_error_detected() -> void:
	
	current_amount_of_critical_errors += 1
	
	for client in RRNetworkManager.management_gui_clients:
		RRNetworkManager.rpc_id(client, "chunk_error", current_processing_job, current_processing_chunk, current_processing_try, OS.get_unix_time())



func success_detected() -> void:
	
	# make sure the rendering process gets terminated when chunk success is detected. For some reason the none blocking process doesn't terminate it self anymore since Godot 3.2
	CommandLineManager.kill_current_render_process()
	
	if !chunk_success_detected and current_amount_of_critical_errors == 0:
		
		# set time stopped and status of try
		for client in RRNetworkManager.management_gui_clients:
			RRNetworkManager.rpc_id(client, "chunk_finished_successfully", current_processing_job, current_processing_chunk, current_processing_try, OS.get_unix_time())
		
	chunk_success_detected = true


func frame_success_detected() -> void:
	current_amount_of_frame_successes += 1
	
	var amount_of_chunk_frames : int = RaptorRender.rr_data.jobs[current_processing_job].chunks[current_processing_chunk].frame_end - RaptorRender.rr_data.jobs[current_processing_job].chunks[current_processing_chunk].frame_start + 1
	
	
	# Send success signal if amount of frame success signals have reached the amount of frames in the chunk. This is helpful, because some software doesn't have an output that indicates the completion of the job.
	#if current_amount_of_frame_successes == amount_of_chunk_frames:
	#	success_detected()


# this will create a thumbnail image 
func frame_name_detected( type : int, extracted_string : String) -> void:
	
	# Thumbnail creation works fine with:
	# - .jpg
	# - .png (8 bit and 16 bit and transparency)
	# - .tga (also with transparency
	# - .exr ( in some configuration it looks off)
	
	var output_dirs_and_patterns : Array = RaptorRender.rr_data.jobs[current_processing_job].output_dirs_and_file_name_patterns
	
	var output_directory : String = ""
	var output_filename_pattern : String = ""
	
	if output_dirs_and_patterns.size() > 0:
		if output_dirs_and_patterns[0].size() > 0:
			output_directory = output_dirs_and_patterns[0][0]
			
			if output_dirs_and_patterns[0].size() > 1 and output_dirs_and_patterns[0][1].size() > 0:
				output_filename_pattern = output_dirs_and_patterns[0][1][0]
	
	var final_file_name : String = ""
	var final_dir_path : String = ""
	var final_full_path : String = ""

	# Create a thumbnail image
	var image : Image = Image.new()
	
	match type:
		
		# type 1: the extracted string is the whole filename with path. E.g:  /home/test/render_0010.png
		1 :
			extracted_string = extracted_string.replace("\\","/") # convert path to unix style
			final_file_name = extracted_string.right( extracted_string.find_last("/") + 1 )
			final_dir_path = extracted_string.left( extracted_string.find_last("/") + 1 )
			final_full_path = extracted_string
			
			# set output directory and output filename pattern if they are not set already
			var dir_already_known : bool = false
			var pattern_already_known : bool = false
			
			for dir in output_dirs_and_patterns:
				if dir.size() > 0:
					if dir[0] == final_dir_path:
						dir_already_known = true
							
						if dir.size() > 1:
							for pattern in dir[1]:
								var extracted_pattern : String = RRFunctions.replace_number_with_frame_number_placeholders(final_file_name)
								if pattern == extracted_pattern:
									pattern_already_known = true
			
			if !dir_already_known:
				RaptorRender.rr_data.jobs[current_processing_job].output_dirs_and_file_name_patterns.append( [final_dir_path,[RRFunctions.replace_number_with_frame_number_placeholders(final_file_name)]] )
			else:
				if !pattern_already_known:
					for dir in RaptorRender.rr_data.jobs[current_processing_job].output_dirs_and_file_name_patterns:
						if dir.size() > 0:
							if dir[0] == final_dir_path:
								if dir.size() > 1:
									dir[1].append( RRFunctions.replace_number_with_frame_number_placeholders(final_file_name) )
								else:
									dir.append( [RRFunctions.replace_number_with_frame_number_placeholders(final_file_name)] )
			
			
		# type 2: the extracted string is only the frame number without padding. E.g. "12" while the filename is: /home/test/render_012.png
		2 :
			if output_directory != "" and output_filename_pattern != "":
			
				var currently_finished_frame_number : int = int(extracted_string)
				final_file_name  =  RRFunctions.replace_frame_number_placeholders_with_number(output_filename_pattern, currently_finished_frame_number)
				final_dir_path = output_directory
				final_full_path = output_directory + final_file_name
	
	
	var file_test : File = File.new()
	
	if file_test.file_exists(final_full_path):
		
		if image.load(final_full_path) == 0:
			
			var max_thumbnail_size : Vector2 = Vector2(192,108)
			var scaled_down_size : Vector2 = RRFunctions.calculate_size_for_specific_box(image.get_size(), max_thumbnail_size)
			image.resize(scaled_down_size.x, scaled_down_size.y,Image.INTERPOLATE_CUBIC)
			
			var output_index : int = 0
			for dir in RaptorRender.rr_data.jobs[current_processing_job].output_dirs_and_file_name_patterns:
				if dir.size() > 0:
					if dir[0] == final_dir_path:
						break
				output_index += 1
					
			var save_path : String = RRPaths.get_job_thumbnail_path( current_processing_job ) + String(output_index) + "/"
			
			var path_check : Directory = Directory.new()
			if !path_check.dir_exists(save_path):
				path_check.make_dir(save_path)
			
			var final_file_name_without_extension : String = final_file_name.left( final_file_name.find_last("."))
			var save_path_full : String = save_path + RRFunctions.extract_frame_number_as_string(final_file_name_without_extension, true) + "_thn_" + final_file_name_without_extension + ".png"
			
			image.save_png( save_path_full )






func start_chunk(job_id : int, chunk_id : int, try_id : int) -> void:
	
	chunk_success_detected = false
	current_amount_of_frame_successes = 0
	current_amount_of_critical_errors = 0
	
	current_processing_job = job_id
	current_processing_chunk = chunk_id
	current_processing_try = try_id

	var cmd_string : String = ""
	var log_file_name : String = ""
	
	
	# Load correct job type settings for setting up the command line string
	var job_type_settings : ConfigFile = ConfigFile.new()
	var job_type : String = RaptorRender.rr_data.jobs[job_id].type
	var job_type_version : String = RaptorRender.rr_data.jobs[job_id].type_version
	
	var settings_file_path : String =  RRPaths.job_types_default_path + job_type + "/" + job_type_version + ".cfg"
	job_type_settings.load( settings_file_path )
	
	
	# load the standard commandline defined in the .cfg file
	cmd_string = job_type_settings.get_value("JobTypeSettings", "commandline", "")
	
	
	# now replace all place holders and fill them with the correct data
	cmd_string = cmd_string.replace( "$(path_executable)", job_type_settings.get_value("JobTypeSettings", "path_executable", "") )
	cmd_string = cmd_string.replace( "$(path_scene)", RaptorRender.rr_data.jobs[job_id].scene_path )
	cmd_string = cmd_string.replace( "$(start)", String(RaptorRender.rr_data.jobs[job_id].chunks[chunk_id].frame_start) )
	cmd_string = cmd_string.replace( "$(end)", String(RaptorRender.rr_data.jobs[job_id].chunks[chunk_id].frame_end) )
	
	cmd_string = cmd_string.replace( "$(CPUs)", "0" ) # TODO
	
	var specific_job_type_settings : Array = job_type_settings.get_section_keys( "SpecificJobSettings" ) 
	
	for specific_setting in specific_job_type_settings:
		
		var specific_setting_value : String
		
		if specific_setting.find("__") == -1 :
			
			if RaptorRender.rr_data.jobs[job_id].SpecificJobSettings.has(specific_setting):
				
				specific_setting_value = String(RaptorRender.rr_data.jobs[job_id].SpecificJobSettings[specific_setting]).to_lower()
				
				if RaptorRender.rr_data.jobs[job_id].SpecificJobSettings.has(specific_setting + "__cmd_value"):
					var __cmd_value : String = String(RaptorRender.rr_data.jobs[job_id].SpecificJobSettings[specific_setting + "__cmd_value"])
					var __cmd_values : Array = __cmd_value.split(";;", true)
					
					if __cmd_values.size() == 3:
						var replacement : String = ""
							
						if specific_setting_value == "true":
							# use prefix + value
							if __cmd_values[0] == "":
								replacement = __cmd_values[1]
							else:
								replacement = __cmd_values[0] + " " + __cmd_values[1]
						else:
							# use substitue
							replacement = __cmd_values[2]
							
						cmd_string = cmd_string.replace( "$(" + specific_setting + ")", replacement)
						
					else:
						# error msg: "Each __cmd_value string has to be splittable into 3 parts. Make sure prefix, value and substitute are correctly devided by „;;“. Problematic definition:"
						var error_message : String = tr("MSG_ERROR_15") + "\n\n" + specific_setting + "__cmd_value"
						RaptorRender.NotificationSystem.add_error_notification(tr("MSG_ERROR_1"), error_message, 10)
						return
						
				else:
					# error msg: "The __cmd_value definition is missing in your job. It‘s mandatory that you define this for each specific setting. Missing:"
					var error_message : String = tr("MSG_ERROR_14") + "\n\n" + specific_setting + "__cmd_value"
					RaptorRender.NotificationSystem.add_error_notification(tr("MSG_ERROR_1"), error_message, 10)
					return
					
			else:
				# error msg: "The following specific job setting is defined in your job type configuration file, but it is not present in your job you are trying to run:"
				var error_message : String = tr("MSG_ERROR_13") + "\n\n" + specific_setting
				RaptorRender.NotificationSystem.add_error_notification(tr("MSG_ERROR_1"), error_message, 10)
				return
			
			
	
	# build a reasonable log file name
	log_file_name = "chunk_" + String(chunk_id) + "_try_" + String(try_id)
	current_log_file_path = RRPaths.get_job_log_path(job_id) + log_file_name + ".txt"
	
	# load the correct job type settings file for the validation of the coming render process
	RenderLogValidator.load_job_type_settings_CRP(job_type, job_type_version)
	
	# add cmd value to try information
	RRNetworkManager.rpc("update_try_cmd", job_id, chunk_id, try_id, cmd_string)
	
	# when we want to kill a process later on we will have to search in the pids for this command line string. As the path can change, for example if the executable is a shell script that links to another location, we should rather search for a string without the executable path.
	var cmd_string_without_executable : String = cmd_string.replace(job_type_settings.get_value("JobTypeSettings", "path_executable", ""), "").dedent()
	
	# now invoke the render process with the freshly created commandline string
	CommandLineManager.start_render_process(job_id, cmd_string, cmd_string_without_executable, current_log_file_path)
	
