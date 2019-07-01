extends Node

var job_type_settings_path : String

var current_processing_job : int
var current_processing_chunk : int
var current_processing_try : int

var current_amount_of_frame_successes : int  = 0
var current_amount_of_critical_errors : int = 0
var chunk_success_detected : bool = false


# Called when the node enters the scene tree for the first time.
func _ready():
	job_type_settings_path = OS.get_user_data_dir() + "/JobTypeSettings/"
	
	RenderLogValidator.connect("success_detected", self, "success_detected")
	RenderLogValidator.connect("frame_success_detected", self, "frame_success_detected")
	RenderLogValidator.connect("critical_error_detected", self, "critical_error_detected")


func critical_error_detected():
	
	current_amount_of_critical_errors += 1
	RaptorRender.rr_data.jobs[current_processing_job].errors += 1
	RaptorRender.rr_data.jobs[current_processing_job].chunks[current_processing_chunk].tries[current_processing_try].status = RRStateScheme.try_error
	RaptorRender.rr_data.jobs[current_processing_job].chunks[current_processing_chunk].tries[current_processing_try].time_stopped = OS.get_unix_time()
	RaptorRender.rr_data.jobs[current_processing_job].chunks[current_processing_chunk].status = RRStateScheme.chunk_queued
	
	var chunk_counts : Array = JobFunctions.get_chunk_counts_TotalFinishedActive(current_processing_job)
		
	# change status only, if there are no active chunks left
	if chunk_counts[2] == 0:
		
		# set job status to "queued" if no active chunks are left
		RaptorRender.rr_data.jobs[current_processing_job].status = RRStateScheme.job_queued



func success_detected():
	
	if !chunk_success_detected and current_amount_of_critical_errors == 0:
		var current_tries_count : int = RaptorRender.rr_data.jobs[current_processing_job].chunks[current_processing_chunk].tries.keys().size()
		RaptorRender.rr_data.jobs[current_processing_job].chunks[current_processing_chunk].status = RRStateScheme.chunk_finished
		
		# set time stopped and status of try
		RaptorRender.rr_data.jobs[current_processing_job].chunks[current_processing_chunk].tries[current_tries_count].time_stopped = OS.get_unix_time()
		RaptorRender.rr_data.jobs[current_processing_job].chunks[current_processing_chunk].tries[current_tries_count].status = RRStateScheme.try_finished
		
		var chunk_counts : Array = JobFunctions.get_chunk_counts_TotalFinishedActive(current_processing_job)
		
		# change status only, if there are no active chunks left
		if chunk_counts[2] == 0:
			
			# set job status to "finished" if all chunks are finished
			if chunk_counts[0] == chunk_counts[1]:
				RaptorRender.rr_data.jobs[current_processing_job].status = RRStateScheme.job_finished
			else:
				RaptorRender.rr_data.jobs[current_processing_job].status = RRStateScheme.job_queued
				
		# set job status to "paused" if all active chunks of a "paused deffered" job have finished
		if RaptorRender.rr_data.jobs[current_processing_job].status == RRStateScheme.job_rendering_paused_deferred and chunk_counts[2] == 0:
			RaptorRender.rr_data.jobs[current_processing_job].status = RRStateScheme.job_paused
			
	chunk_success_detected = true


func frame_success_detected():
	current_amount_of_frame_successes += 1
	
	var amount_of_chunk_frames : int = RaptorRender.rr_data.jobs[current_processing_job].chunks[current_processing_chunk].frame_end - RaptorRender.rr_data.jobs[current_processing_job].chunks[current_processing_chunk].frame_start + 1
	
	if current_amount_of_frame_successes == amount_of_chunk_frames:
		success_detected()





func start_junk(job_id : int, chunk_id : int, try_id : int):
	
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
	
	job_type_settings.load( job_type_settings_path + "/local/" + job_type + "/" + job_type_version + ".cfg")
	
	
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
		
		if not specific_setting.ends_with("_type") and not specific_setting.ends_with("_default"):
			if RaptorRender.rr_data.jobs[job_id].SpecificJobSettings.has(specific_setting):
				
				specific_setting_value = String(RaptorRender.rr_data.jobs[job_id].SpecificJobSettings[specific_setting])
				cmd_string = cmd_string.replace( "$(" + specific_setting + ")", specific_setting_value)
		
			else:
				specific_setting_value = job_type_settings.get_value("SpecificJobSettings", specific_setting, "")
				cmd_string = cmd_string.replace( "$(" + specific_setting + ")", specific_setting_value)
	
	# build a reasonable log file name
	log_file_name = String(job_id) + "_chunk_" + String(chunk_id) + "_try_" + String(try_id)
	
	# load the correct job type settings file for the validation of the coming render process
	RenderLogValidator.load_job_type_settings_CRP(job_type, job_type_version)
	
	# now invoke the render process with the freshly created commandline string
	CommandLineManager.start_render_process( cmd_string, log_file_name)
	