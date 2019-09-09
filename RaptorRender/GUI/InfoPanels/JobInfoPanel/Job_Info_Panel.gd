extends MarginContainer

class_name JobInfoPanel

### preload Resources
var OutputDirectoryHBoxRes = preload("res://RaptorRender/GUI/InfoPanels/JobInfoPanel/OutputDirectoryHBox.tscn")
var ThumbnailBoxRes = preload("res://RaptorRender/GUI/InfoPanels/JobInfoPanel/ImagePreview/ThumbnailBox.tscn")

### onready vars
onready var JobInfoTabContainer : TabContainer = $"TabContainer"

onready var StatusIconTexture = $"TabContainer/Details/ScrollContainer/MarginContainer/VBoxContainer/MainInfo/HBoxContainer/Icon"

onready var NameLabel : Label = $"TabContainer/Details/ScrollContainer/MarginContainer/VBoxContainer/MainInfo/HBoxContainer/MarginContainer/VBoxContainer/NameLabel"
onready var StatusLabel : Label = $"TabContainer/Details/ScrollContainer/MarginContainer/VBoxContainer/MainInfo/HBoxContainer/MarginContainer/VBoxContainer/StatusLabel"
onready var TypeLabel : Label = $"TabContainer/Details/ScrollContainer/MarginContainer/VBoxContainer/MainInfo/HBoxContainer/MarginContainer/VBoxContainer/TypeLabel"
onready var CreatorLabel : Label = $"TabContainer/Details/ScrollContainer/MarginContainer/VBoxContainer/MainInfo/HBoxContainer/MarginContainer/VBoxContainer/CreatorLabel"
onready var TimeCreatedLabel : Label = $"TabContainer/Details/ScrollContainer/MarginContainer/VBoxContainer/MainInfo/HBoxContainer/MarginContainer/VBoxContainer/TimeCreatedLabel"

onready var ProgressHeading : Label = $"TabContainer/Details/ScrollContainer/MarginContainer/VBoxContainer/progress/HBoxContainer/MarginContainer/VBoxContainer/ProgressHeading"
onready var FilesHeading : Label = $"TabContainer/Details/ScrollContainer/MarginContainer/VBoxContainer/files/HBoxContainer/MarginContainer/FilesVBox/FilesHeading"

onready var JobProgressBar = $"TabContainer/Details/ScrollContainer/MarginContainer/VBoxContainer/progress/HBoxContainer/MarginContainer/VBoxContainer/JobProgressBar"
onready var ActiveClientsLabel : Label = $"TabContainer/Details/ScrollContainer/MarginContainer/VBoxContainer/progress/HBoxContainer/MarginContainer/VBoxContainer/ActiveClientsLabel"
onready var TimeRenderedLabel : Label = $"TabContainer/Details/ScrollContainer/MarginContainer/VBoxContainer/progress/HBoxContainer/MarginContainer/VBoxContainer/TimeRenderedLabel"
onready var TimeRemainingLabel : Label = $"TabContainer/Details/ScrollContainer/MarginContainer/VBoxContainer/progress/HBoxContainer/MarginContainer/VBoxContainer/TimeRemainingLabel"

onready var FilesVBox : VBoxContainer = $"TabContainer/Details/ScrollContainer/MarginContainer/VBoxContainer/files/HBoxContainer/MarginContainer/FilesVBox"
onready var SceneFileLabel : Label = $"TabContainer/Details/ScrollContainer/MarginContainer/VBoxContainer/files/HBoxContainer/MarginContainer/FilesVBox/SourceFileHBox/SceneFileLabel"
onready var LogFilesLabel : Label = $"TabContainer/Details/ScrollContainer/MarginContainer/VBoxContainer/files/HBoxContainer/MarginContainer/FilesVBox/LogFilesHBox/LogFilesLabel"

onready var ChunkTimeGraph = $"TabContainer/Graphs/VSplitContainer/ChunkTimeGraph"
onready var ClientPieChart = $"TabContainer/Graphs/VSplitContainer/ClientPieChart"

onready var DirVBoxContainer : VBoxContainer = $"TabContainer/Images/VSplitContainer/DirScrollContainer/DirVBoxContainer"

### variables
var current_displayed_job_id : int
var output_dirs_and_file_name_patterns_nodes : Array


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
		
		# Log Files
		LogFilesLabel.text = tr("JOB_DETAIL_13") + ":   " + RRPaths.get_job_log_path( selected_job["id"] )
		
		# Output Files
		var outputs_difference : int = output_dirs_and_file_name_patterns_nodes.size() - selected_job["output_dirs_and_file_name_patterns"].size()
		
		if outputs_difference == 0: # if correct number of outputs is already there, just update the ones
			var count = 0
			for output_dir_node in output_dirs_and_file_name_patterns_nodes:
				output_dir_node.set_output_directory(selected_job["output_dirs_and_file_name_patterns"][count][0])
				count += 1
		else: # if not, clear everything and recreate it
			for output_directory_node in output_dirs_and_file_name_patterns_nodes:
				output_directory_node.queue_free()
			output_dirs_and_file_name_patterns_nodes.clear()
		
			for output_directory in selected_job["output_dirs_and_file_name_patterns"]:
				var output_directory_HBox = OutputDirectoryHBoxRes.instance()
				output_directory_HBox.output_directory = output_directory[0]
				output_dirs_and_file_name_patterns_nodes.append(output_directory_HBox)
				FilesVBox.add_child(output_directory_HBox)
		
		
		
		
		################
		#  update Graphs
		################
		
		ChunkTimeGraph.set_job_id(job_id)
		ClientPieChart.set_job_id(job_id)


# For performance reasons we only delete or create ThumbnailBox nodes when necessary and update the ones that are already there.
# It also helps not to loose the visual change on hover or selection caused by deleting and recreating the node.
func update_images_tab():
	
	# create or delete ThumbnailBox nodes
	var dir_difference : int = RaptorRender.rr_data.jobs[current_displayed_job_id].output_dirs_and_file_name_patterns.size() - DirVBoxContainer.get_children().size()
	
	if dir_difference > 0:
		# create that amount of ThumbnailBox nodes
		for i in range(0, dir_difference):
			var ThumbnailBox = ThumbnailBoxRes.instance()
			DirVBoxContainer.add_child(ThumbnailBox)
		
	if dir_difference < 0:
		# remove that amount of ThumbnailBox nodes
		var childs : Array = DirVBoxContainer.get_children()
		var child_count : int = childs.size()
		for i in range(1, abs(dir_difference) + 1):
			childs[child_count - i].self_destruct_as_soon_as_possible = true
	
	
	# update ThumbnailBox nodes
	var dircount : int = 0
	for dir in RaptorRender.rr_data.jobs[current_displayed_job_id].output_dirs_and_file_name_patterns:
		if dir.size() > 0:
			var ThumbnailBox = DirVBoxContainer.get_child(dircount)
			ThumbnailBox.image_directory = dir[0]
			ThumbnailBox.thumbnail_directory = RRPaths.get_job_thumbnail_path( RaptorRender.rr_data.jobs[current_displayed_job_id].id ) + String(dircount) + "/"
			if dir.size() > 1:
				ThumbnailBox.file_name_patterns = dir[1]
			ThumbnailBox.refresh_thumbnails()
			dircount += 1


func _on_OpenSceneFolderButton_pressed():
	var scene_path : String = RaptorRender.rr_data.jobs[current_displayed_job_id].scene_path.get_base_dir()
	JobFunctions.open_folder( scene_path )


func _on_OpenLogsFolderButton_pressed():
	JobFunctions.open_folder( RRPaths.get_job_log_path( RaptorRender.rr_data.jobs[current_displayed_job_id].id ) )
	

func _on_TabContainer_tab_selected(tab):
	
	# chunk list tab selected
	if tab == 1:
		RaptorRender.refresh_chunks_table( RaptorRender.current_job_id_for_job_info_panel )
	



