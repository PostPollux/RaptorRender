extends MarginContainer

class_name JobInfoPanel

onready var JobInfoTabContainer : TabContainer = $"TabContainer"

onready var StatusIconTexture = $"TabContainer/Details/ScrollContainer/MarginContainer/VBoxContainer/MainInfo/HBoxContainer/Icon"

onready var NameLabel : Label = $"TabContainer/Details/ScrollContainer/MarginContainer/VBoxContainer/MainInfo/HBoxContainer/MarginContainer/VBoxContainer/NameLabel"
onready var StatusLabel : Label = $"TabContainer/Details/ScrollContainer/MarginContainer/VBoxContainer/MainInfo/HBoxContainer/MarginContainer/VBoxContainer/StatusLabel"
onready var TypeLabel : Label = $"TabContainer/Details/ScrollContainer/MarginContainer/VBoxContainer/MainInfo/HBoxContainer/MarginContainer/VBoxContainer/TypeLabel"
onready var CreatorLabel : Label = $"TabContainer/Details/ScrollContainer/MarginContainer/VBoxContainer/MainInfo/HBoxContainer/MarginContainer/VBoxContainer/CreatorLabel"
onready var TimeCreatedLabel : Label = $"TabContainer/Details/ScrollContainer/MarginContainer/VBoxContainer/MainInfo/HBoxContainer/MarginContainer/VBoxContainer/TimeCreatedLabel"

onready var ProgressHeading : Label = $"TabContainer/Details/ScrollContainer/MarginContainer/VBoxContainer/progress/HBoxContainer/MarginContainer/VBoxContainer/ProgressHeading"
onready var FilesHeading : Label = $"TabContainer/Details/ScrollContainer/MarginContainer/VBoxContainer/files/HBoxContainer/MarginContainer/VBoxContainer/FilesHeading"

onready var JobProgressBar = $"TabContainer/Details/ScrollContainer/MarginContainer/VBoxContainer/progress/HBoxContainer/MarginContainer/VBoxContainer/JobProgressBar"
onready var ActiveClientsLabel : Label = $"TabContainer/Details/ScrollContainer/MarginContainer/VBoxContainer/progress/HBoxContainer/MarginContainer/VBoxContainer/ActiveClientsLabel"
onready var TimeRenderedLabel : Label = $"TabContainer/Details/ScrollContainer/MarginContainer/VBoxContainer/progress/HBoxContainer/MarginContainer/VBoxContainer/TimeRenderedLabel"
onready var TimeRemainingLabel : Label = $"TabContainer/Details/ScrollContainer/MarginContainer/VBoxContainer/progress/HBoxContainer/MarginContainer/VBoxContainer/TimeRemainingLabel"

onready var SceneFileLabel : Label = $"TabContainer/Details/ScrollContainer/MarginContainer/VBoxContainer/files/HBoxContainer/MarginContainer/VBoxContainer/HBoxContainer/SceneFileLabel"
onready var OutputFilesLabel : Label = $"TabContainer/Details/ScrollContainer/MarginContainer/VBoxContainer/files/HBoxContainer/MarginContainer/VBoxContainer/HBoxContainer2/OutputFilesLabel"
onready var LogFilesLabel : Label = $"TabContainer/Details/ScrollContainer/MarginContainer/VBoxContainer/files/HBoxContainer/MarginContainer/VBoxContainer/HBoxContainer3/LogFilesLabel"

onready var ChunkTimeGraph = $"TabContainer/Graphs/VSplitContainer/ChunkTimeGraph"
onready var ClientPieChart = $"TabContainer/Graphs/VSplitContainer/ClientPieChart"

var current_displayed_job_id : int


func _ready():
	RaptorRender.register_job_info_panel(self)
	
	translate_tabs()


func translate_tabs():
	JobInfoTabContainer.set_tab_title(0 , tr("JOB_DETAIL_1") ) # Details
	JobInfoTabContainer.set_tab_title(1 , tr("JOB_CHUNKS_1") ) # Chunks
	JobInfoTabContainer.set_tab_title(2 , tr("JOB_GRAPHS_1") ) # Graphs


func reset_to_first_tab():
	JobInfoTabContainer.current_tab = 0


func set_tab(tab_number : int):
	JobInfoTabContainer.current_tab = tab_number


func get_current_tab() -> int:
	return JobInfoTabContainer.current_tab


func update_job_info_panel(job_id : int):
	
	current_displayed_job_id = job_id
	
	if RaptorRender.rr_data.jobs.has(job_id):
		
		var selected_job : Dictionary = RaptorRender.rr_data.jobs[job_id]
		
		
		#################
		#  Status Section
		#################
		
		
		# name
		NameLabel.text = selected_job["name"]
		
		
		
		var status = selected_job["status"]
		
		match status:
			RRStateScheme.job_rendering : StatusIconTexture.set_modulate(RRColorScheme.state_active)
			RRStateScheme.job_rendering_paused_deferred : StatusIconTexture.set_modulate(RRColorScheme.state_paused_deferred)
			RRStateScheme.job_queued :    StatusIconTexture.set_modulate(RRColorScheme.state_queued)
			RRStateScheme.job_error :     StatusIconTexture.set_modulate(RRColorScheme.state_error)
			RRStateScheme.job_paused :    StatusIconTexture.set_modulate(RRColorScheme.state_paused)
			RRStateScheme.job_finished :  StatusIconTexture.set_modulate(RRColorScheme.state_finished_or_online)
			RRStateScheme.job_cancelled : StatusIconTexture.set_modulate(RRColorScheme.state_offline_or_cancelled)
		
		
		# Status text
		match status:
			RRStateScheme.job_rendering : StatusLabel.text = tr("JOB_DETAIL_2") + ":  " + tr("JOB_DETAIL_STATUS_1")
			RRStateScheme.job_rendering_paused_deferred : StatusLabel.text = tr("JOB_DETAIL_2") + ":  " + tr("JOB_DETAIL_STATUS_2")
			RRStateScheme.job_queued :    StatusLabel.text = tr("JOB_DETAIL_2") + ":  " + tr("JOB_DETAIL_STATUS_3")
			RRStateScheme.job_error :     StatusLabel.text = tr("JOB_DETAIL_2") + ":  " + tr("JOB_DETAIL_STATUS_4")
			RRStateScheme.job_paused :    StatusLabel.text = tr("JOB_DETAIL_2") + ":  " + tr("JOB_DETAIL_STATUS_5")
			RRStateScheme.job_finished :  StatusLabel.text = tr("JOB_DETAIL_2") + ":  " + tr("JOB_DETAIL_STATUS_6")
			RRStateScheme.job_cancelled : StatusLabel.text = tr("JOB_DETAIL_2") + ":  " + tr("JOB_DETAIL_STATUS_7")
			
			
		
		# type
		TypeLabel.text = tr("JOB_DETAIL_3") + ":  " + selected_job["type"] + " / " + selected_job["type_version"]
		
		# creator
		CreatorLabel.text = tr("JOB_DETAIL_4") + ":  " + selected_job["creator"]
		
		# time created
		TimeCreatedLabel.text = tr("JOB_DETAIL_5") + ":  " + TimeFunctions.time_stamp_to_date_as_string( selected_job["time_created"], 2, true)
		
		
		
		
		###################
		#  Progress Section
		###################
		
		ProgressHeading.text = "JOB_DETAIL_6" # Progress
		
		var chunk_counts = JobFunctions.get_chunk_counts_TotalFinishedActive(job_id)
		var progress = float(chunk_counts[1]) / float(chunk_counts[0])
		
		# Progress bar
		JobProgressBar.set_chunks(chunk_counts[0], chunk_counts[1], chunk_counts[2])
		JobProgressBar.show_progress()
		
		match status:
			RRStateScheme.job_paused : JobProgressBar.job_status = "paused"
			RRStateScheme.job_rendering_paused_deferred : JobProgressBar.job_status = "paused"
			RRStateScheme.job_cancelled : JobProgressBar.job_status = "cancelled"
			_: JobProgressBar.job_status = "normal" # everything else
		
		JobProgressBar.match_color_to_status()
		
		# active clients
		var active_clients = 0
					
		for client in RaptorRender.rr_data.clients.keys():
			if RaptorRender.rr_data.clients[client].current_job_id == job_id:
				active_clients += 1
		ActiveClientsLabel.text = tr("JOB_DETAIL_7") + ":  " + String( active_clients)
		
		# time rendered
		TimeRenderedLabel.text = tr("JOB_DETAIL_8") + ":  " + TimeFunctions.seconds_to_string( selected_job["render_time"], 2 )
		
		# time remaining
		if progress > 0:
			TimeRemainingLabel.text = tr("JOB_DETAIL_9") + ":  " + TimeFunctions.seconds_to_string( int( (selected_job["render_time"] * 1 / progress) - selected_job["render_time"]), 2 )
		else:
			TimeRemainingLabel.text = tr("JOB_DETAIL_9") + ":  "
			
	
	
		###################
		#  Files Section
		###################
		
		FilesHeading.text = "JOB_DETAIL_10" # Files
		
		# Scene File
		SceneFileLabel.text = tr("JOB_DETAIL_11") + ":   " + selected_job["scene_path"]
		
		# Output Files
		OutputFilesLabel.text = tr("JOB_DETAIL_12") + ":   " + selected_job["output_directory"]
		
		# Log Files
		LogFilesLabel.text = tr("JOB_DETAIL_13") + ":   " + RRPaths.get_job_log_path( selected_job["id"] )
		
		
		
		################
		#  update Graphs
		################
		
		ChunkTimeGraph.set_job_id(job_id)
		ClientPieChart.set_job_id(job_id)



func _on_OpenSceneFolderButton_pressed():
	var scene_path : String = RaptorRender.rr_data.jobs[current_displayed_job_id].scene_path.get_base_dir()
	JobFunctions.open_folder( scene_path )


func _on_OpenOutputFolderButton_pressed():
	JobFunctions.open_folder( RaptorRender.rr_data.jobs[current_displayed_job_id].output_directory )

func _on_OpenLogsFolderButton_pressed():
	JobFunctions.open_folder( RRPaths.get_job_log_path( RaptorRender.rr_data.jobs[current_displayed_job_id].id ) )
	

func _on_TabContainer_tab_selected(tab):
	
	# chunk list tab selected
	if tab == 1:
		RaptorRender.refresh_chunks_table( RaptorRender.current_job_id_for_job_info_panel )
	



