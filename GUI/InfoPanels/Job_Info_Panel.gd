extends MarginContainer

onready var JobInfoTabContainer = $"TabContainer"

onready var StatusIconTexture = $"TabContainer/Details/ScrollContainer/MarginContainer/VBoxContainer/MainInfo/HBoxContainer/Icon"

onready var NameLabel = $"TabContainer/Details/ScrollContainer/MarginContainer/VBoxContainer/MainInfo/HBoxContainer/MarginContainer/VBoxContainer/NameLabel"
onready var StatusLabel = $"TabContainer/Details/ScrollContainer/MarginContainer/VBoxContainer/MainInfo/HBoxContainer/MarginContainer/VBoxContainer/StatusLabel"
onready var TypeLabel = $"TabContainer/Details/ScrollContainer/MarginContainer/VBoxContainer/MainInfo/HBoxContainer/MarginContainer/VBoxContainer/TypeLabel"
onready var CreatorLabel = $"TabContainer/Details/ScrollContainer/MarginContainer/VBoxContainer/MainInfo/HBoxContainer/MarginContainer/VBoxContainer/CreatorLabel"
onready var TimeCreatedLabel = $"TabContainer/Details/ScrollContainer/MarginContainer/VBoxContainer/MainInfo/HBoxContainer/MarginContainer/VBoxContainer/TimeCreatedLabel"

onready var JobProgressBar = $"TabContainer/Details/ScrollContainer/MarginContainer/VBoxContainer/progress/HBoxContainer/MarginContainer/VBoxContainer/JobProgressBar"
onready var ActiveClientsLabel = $"TabContainer/Details/ScrollContainer/MarginContainer/VBoxContainer/progress/HBoxContainer/MarginContainer/VBoxContainer/ActiveClientsLabel"
onready var TimeRenderedLabel = $"TabContainer/Details/ScrollContainer/MarginContainer/VBoxContainer/progress/HBoxContainer/MarginContainer/VBoxContainer/TimeRenderedLabel"
onready var TimeRemainingLabel = $"TabContainer/Details/ScrollContainer/MarginContainer/VBoxContainer/progress/HBoxContainer/MarginContainer/VBoxContainer/TimeRemainingLabel"

onready var SceneFileLabel = $"TabContainer/Details/ScrollContainer/MarginContainer/VBoxContainer/files/HBoxContainer/MarginContainer/VBoxContainer/HBoxContainer/SceneFileLabel"
onready var OutputFilesLabel = $"TabContainer/Details/ScrollContainer/MarginContainer/VBoxContainer/files/HBoxContainer/MarginContainer/VBoxContainer/HBoxContainer2/OutputFilesLabel"

onready var ChunkTimeGraph = $"TabContainer/Graphs/ChunkTimeGraph"

var current_displayed_job_id


func _ready():
	RaptorRender.register_job_info_panel(self)


func reset_to_first_tab():
	JobInfoTabContainer.current_tab = 0

func set_tab(tab_number):
	JobInfoTabContainer.current_tab = tab_number


func update_job_info_panel(job_id):
	
	current_displayed_job_id = job_id
	
	var selected_job = RaptorRender.rr_data.jobs[job_id]
	
	
	#################
	#  Status Section
	#################
	
	
	# name
	NameLabel.text = selected_job["name"]
	
	
	
	var status = selected_job["status"]
	
	# Status Icon
	var icon = ImageTexture.new()
	
	match status:
		"1_rendering": icon.load("res://GUI/icons/job_status/200x100/job_status_rendering_200x100.png")
		"2_queued":    icon.load("res://GUI/icons/job_status/200x100/job_status_queued_200x100.png")
		"3_error":     icon.load("res://GUI/icons/job_status/200x100/job_status_error_200x100.png")
		"4_paused":    icon.load("res://GUI/icons/job_status/200x100/job_status_paused_200x100.png")
		"5_finished":  icon.load("res://GUI/icons/job_status/200x100/job_status_finished_200x100.png")
		"6_cancelled": icon.load("res://GUI/icons/job_status/200x100/job_status_cancelled_200x100.png")
		
	StatusIconTexture.set_texture(icon)
	
	
	# Status text
	match status:
		"1_rendering": StatusLabel.text = "Status:  Rendering"
		"2_queued":    StatusLabel.text = "Status:  Queued"
		"3_error":     StatusLabel.text = "Status:  Error"
		"4_paused":    StatusLabel.text = "Status:  Paused"
		"5_finished":  StatusLabel.text = "Status:  Finished"
		"6_cancelled": StatusLabel.text = "Status:  Cancelled"
		
		
	
	# type
	TypeLabel.text = "Type:  " + selected_job["type"]
	
	# creator
	CreatorLabel.text = "Creator:  " + selected_job["creator"]
	
	# time created
	TimeCreatedLabel.text = "Created:  " + TimeFunctions.time_stamp_to_date_as_string( selected_job["time_created"], 2)
	
	
	
	
	###################
	#  Progress Section
	###################
	
	
	var chunk_counts = JobFunctions.get_chunk_counts_TotalFinishedActive(job_id)
	var progress = float(chunk_counts[1]) / float(chunk_counts[0])
	
	# Progress bar
	JobProgressBar.set_chunks(chunk_counts[0], chunk_counts[1], chunk_counts[2])
	JobProgressBar.show_progress()
	
	match status:
		"4_paused": JobProgressBar.job_status = "paused"
		"6_cancelled": JobProgressBar.job_status = "cancelled"
		_: JobProgressBar.job_status = "normal" # everything else
	
	JobProgressBar.match_color_to_status()
	
	# active clients
	var active_clients = 0
				
	for client in RaptorRender.rr_data.clients.keys():
		if RaptorRender.rr_data.clients[client].current_job_id == job_id:
			active_clients += 1
	ActiveClientsLabel.text = "Active Clients:  " + String( active_clients)
	
	# time rendered
	TimeRenderedLabel.text = "Time rendered:  " + TimeFunctions.seconds_to_string( selected_job["render_time"], 2 )
	
	# time remaining
	if progress > 0:
		TimeRemainingLabel.text = "Time remaining:  " + TimeFunctions.seconds_to_string( int( (selected_job["render_time"] * 1 / progress) - selected_job["render_time"]), 2 )
	else:
		TimeRemainingLabel.text = "Time remaining:  "
		


	###################
	#  Files Section
	###################
	
	# Scene File
	SceneFileLabel.text = "Scene File:   " + selected_job["scene_directory"]
	
	# Scene File
	OutputFilesLabel.text = "Output Files:   " + selected_job["output_directory"]

	
	
	
	################
	#  update Graphs
	################
	
	ChunkTimeGraph.set_job_id(job_id)
	
	
	
func _on_OpenSceneFolderButton_pressed():
	JobFunctions.open_folder( RaptorRender.rr_data.jobs[current_displayed_job_id].scene_directory )


func _on_OpenOutputFolderButton_pressed():
	JobFunctions.open_folder( RaptorRender.rr_data.jobs[current_displayed_job_id].output_directory )
