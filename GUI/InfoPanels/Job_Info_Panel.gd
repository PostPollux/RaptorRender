extends MarginContainer

onready var JobInfoTabContainer = $"TabContainer"

onready var StatusIconTexture = $"TabContainer/Details/MarginContainer/VBoxContainer/MainInfo/HBoxContainer/Icon"

onready var NameLabel = $"TabContainer/Details/MarginContainer/VBoxContainer/MainInfo/HBoxContainer/MarginContainer/VBoxContainer/NameLabel"
onready var StatusLabel = $"TabContainer/Details/MarginContainer/VBoxContainer/MainInfo/HBoxContainer/MarginContainer/VBoxContainer/StatusLabel"
onready var TimeRenderedLabel = $"TabContainer/Details/MarginContainer/VBoxContainer/MainInfo/HBoxContainer/MarginContainer/VBoxContainer/TimeRenderedLabel"
onready var TimeRemainingLabel = $"TabContainer/Details/MarginContainer/VBoxContainer/MainInfo/HBoxContainer/MarginContainer/VBoxContainer/TimeRemainingLabel"


func _ready():
	RaptorRender.register_job_info_panel(self)
	

func reset_to_first_tab():
	JobInfoTabContainer.current_tab = 0


func update_job_info_panel(job_id):
	
	var selected_job = RaptorRender.rr_data.jobs[job_id]
	
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
	
	
	# Status
	
	match status:
		"1_rendering": StatusLabel.text = "Status:  Rendering"
		"2_queued":    StatusLabel.text = "Status:  Queued"
		"3_error":     StatusLabel.text = "Status:  Error"
		"4_paused":    StatusLabel.text = "Status:  Paused"
		"5_finished":  StatusLabel.text = "Status:  Finished"
		"6_cancelled": StatusLabel.text = "Status:  Cancelled"
		
		
	# Render Time and Time Remaining
	
	TimeRenderedLabel.text = "Time rendered:  " + TimeFunctions.seconds_to_string( selected_job["render_time"], 2 )
	
	var chunk_counts = JobFunctions.get_chunk_counts_TotalFinishedActive(job_id)
	var progress = float(chunk_counts[1]) / float(chunk_counts[0])
	print(progress)
	
	if progress > 0:
		TimeRemainingLabel.text = "Time remaining:  " + TimeFunctions.seconds_to_string( int( (selected_job["render_time"] * 1 / progress) - selected_job["render_time"]), 2 )
	else:
		TimeRemainingLabel.text = "Time remaining:  "
		