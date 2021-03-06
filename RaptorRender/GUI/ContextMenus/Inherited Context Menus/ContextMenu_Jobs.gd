extends PopupMenu

### PRELOAD RESOURCES
var AutoScalingPopupBasRes = preload("res://RaptorRender/GUI/AutoScalingPopup/AutoScalingPopupBase.tscn")
var InfoPopupContentRes = preload("res://RaptorRender/GUI/AutoScalingPopup/Content/InfoPopupContent/InfoPopupContent.tscn")

### SIGNALS

### ONREADY VARIABLES

### EXPORTED VARIABLES

### VARIABLES
var temp_ids : Array



########## FUNCTIONS ##########


func _ready() -> void:
	self.add_item("Pause Job Deffered", 0, 0)
	self.add_item("Pause Job Immediately", 1, 0)
	self.add_item("Resume Job", 2, 0)
	self.add_separator()
	self.add_item("Cancel Job Permanently", 4, 0)
	self.add_separator()
	self.add_item("Configure Job", 6, 0)
	self.add_item("Reset Job Error count", 7, 0)
	self.add_separator()
	
	self.add_item("Resubmit Job paused", 9, 0)
	self.add_separator()
	self.add_item("Open Output Directories", 11, 0)
	self.add_item("Open Scene Directory", 12, 0)
	self.add_separator()
	self.add_item("Remove Job", 14, 0)
	
	# trick to calculate the correct size of the popup, so it doesn't display outside of the window when invoked
	self.visible = true
	self.visible = false
	
	set_item_names()



func set_item_names() -> void:
	
	if RaptorRender.JobsTable.get_selected_ids().size() <= 1:
		#self.set_item_text(0, "Pause Job Deffered")
		self.set_item_text(0, "JOB_CONTEXT_MENU_1") # Pause Job Deffered
		self.set_item_text(1, "JOB_CONTEXT_MENU_2") # Pause Job Immediately
		self.set_item_text(2, "JOB_CONTEXT_MENU_3") # Resume Job
		self.set_item_text(4, "JOB_CONTEXT_MENU_4") # Cancel Job Permanently
		self.set_item_text(6, "JOB_CONTEXT_MENU_5") # Configure Job
		self.set_item_text(7, "JOB_CONTEXT_MENU_6") # Reset Job Error count
		self.set_item_text(9, "JOB_CONTEXT_MENU_7") # Resubmit Job paused
		self.set_item_text(11, "JOB_CONTEXT_MENU_8") # Open Output Directories
		self.set_item_text(12, "JOB_CONTEXT_MENU_9") # Open Scene Directory
		self.set_item_text(14, "JOB_CONTEXT_MENU_10") # Remove Job
	else:
		self.set_item_text(0, "JOB_CONTEXT_MENU_11") # Pause Jobs Deffered
		self.set_item_text(1, "JOB_CONTEXT_MENU_12") # Pause Jobs Immediately
		self.set_item_text(2, "JOB_CONTEXT_MENU_13") # Resume Jobs
		self.set_item_text(4, "JOB_CONTEXT_MENU_14") # Cancel Jobs Permanently
		self.set_item_text(6, "JOB_CONTEXT_MENU_15") # Configure Jobs
		self.set_item_text(7, "JOB_CONTEXT_MENU_16") # Reset Job Error Counts
		self.set_item_text(9, "JOB_CONTEXT_MENU_17") # Resubmit Jobs paused
		self.set_item_text(11, "JOB_CONTEXT_MENU_18") # Open Output Directories
		self.set_item_text(12, "JOB_CONTEXT_MENU_19") # Open Scene Directories
		self.set_item_text(14, "JOB_CONTEXT_MENU_20") # Remove Jobs



func enable_disable_items() -> void:
	
	# disable all
	self.set_item_disabled(0, true)  # pause job deffered
	self.set_item_disabled(1, true)  # pause job immediately
	self.set_item_disabled(2, true)  # resume job
	self.set_item_disabled(4, true)  # cancel job permanently
	self.set_item_disabled(6, true)  # configure job
	self.set_item_disabled(7, true)  # reset job error count
	self.set_item_disabled(9, true)  # resubmit job paused
	self.set_item_disabled(11, true)  # open output directories
	self.set_item_disabled(12, true)  # open scene folder
	self.set_item_disabled(14, true)  # remove job
	
	
	var selected_ids = RaptorRender.JobsTable.get_selected_ids()
	
	# now enable correct ones
	for selected in selected_ids:
		
		var status =  RaptorRender.rr_data.jobs[selected].status
		
		if status == RRStateScheme.job_rendering:
			self.set_item_disabled(0, false) # pause job deffered
			self.set_item_disabled(1, false) # pause job immediately
			self.set_item_disabled(4, false) # cancel job permanently
			self.set_item_disabled(7, false) # reset job error count
		
		if status == RRStateScheme.job_rendering_paused_deferred:
			self.set_item_disabled(1, false) # pause job immediately
			self.set_item_disabled(2, false) # resume job
			self.set_item_disabled(4, false) # cancel job permanently
			self.set_item_disabled(7, false) # reset job error count
		
		if status == RRStateScheme.job_queued:
			self.set_item_disabled(1, false) # pause job immediately
			self.set_item_disabled(4, false) # cancel job permanently
		
		if status == RRStateScheme.job_error:
			self.set_item_disabled(4, false) # cancel job permanently
			self.set_item_disabled(7, false) # reset job error count
			
		
		if status == RRStateScheme.job_paused:
			self.set_item_disabled(2, false) # resume job
			self.set_item_disabled(4, false) # cancel job permanently
			self.set_item_disabled(6, false) # configure job
			self.set_item_disabled(7, false) # reset job error count
		
		if status == RRStateScheme.job_finished:
			self.set_item_disabled(7, false) # reset job error count
		
		if status == RRStateScheme.job_cancelled:
			self.set_item_disabled(7, false) # reset job error count
		
		
		# items that are always active
		self.set_item_disabled(9, false) # resubmit job paused
		self.set_item_disabled(11, false) # open output directories
		self.set_item_disabled(12, false) # open scene folder
		self.set_item_disabled(14, false) # remove job




func _on_ContextMenu_index_pressed(index) -> void:
	
	match index:
		
		0:  # Pause Job Deffered
			
			var selected_ids = RaptorRender.JobsTable.get_selected_ids()
			
			for peer in RRNetworkManager.management_gui_clients:
				RRNetworkManager.rpc_id(peer, "update_job_states", selected_ids, RRStateScheme.job_rendering_paused_deferred)
			
			RaptorRender.JobsTable.refresh()
			
			
			
		1:  # Pause Job Immediately
			
			var selected_ids = RaptorRender.JobsTable.get_selected_ids()
			
			for peer in RRNetworkManager.management_gui_clients:
				RRNetworkManager.rpc_id(peer, "update_job_states", selected_ids, RRStateScheme.job_paused)
			
			RaptorRender.JobsTable.refresh()
			RaptorRender.ClientsTable.refresh()
			
			
			
		2:  # Resume Job
			
			var selected_ids = RaptorRender.JobsTable.get_selected_ids()
			
			for peer in RRNetworkManager.management_gui_clients:
				RRNetworkManager.rpc_id(peer, "update_job_states", selected_ids, RRStateScheme.job_queued)
			
			RaptorRender.JobsTable.refresh()
			
			
			
		3:  # Separator
			pass
			
			
		
		4:  # Cancel Job Permanently
			var selected_ids = RaptorRender.JobsTable.get_selected_ids()
			
			for peer in RRNetworkManager.management_gui_clients:
				RRNetworkManager.rpc_id(peer, "update_job_states", selected_ids, RRStateScheme.job_cancelled)
				
			RaptorRender.JobsTable.refresh()
			RaptorRender.ClientsTable.refresh()
			
			
		
		5:  # Separator
			pass
			
			
			
		6:  # Configure Job
			RaptorRender.NotificationSystem.add_error_notification(tr("MSG_ERROR_1"), tr("MSG_ERROR_2"), 5) # Not implemented yet
		
		
		
		7:  # Reset Job Error count
			var selected_ids = RaptorRender.JobsTable.get_selected_ids()
			
			for selected in selected_ids:
				
				for peer in RRNetworkManager.management_gui_clients:
					RRNetworkManager.rpc_id(peer, "reset_job_errors", selected)
				
			RaptorRender.JobsTable.refresh()
			
			
			
			
		8:  # Separator
			pass
			
			
		9:  # Resubmit Job paused
			var selected_ids = RaptorRender.JobsTable.get_selected_ids()
			
			for selected in selected_ids:
				
				var job_to_resubmit = RaptorRender.rr_data.jobs[selected].duplicate()
				
				# set job status to paused
				job_to_resubmit.status = RRStateScheme.job_paused
				
				# reset job errors
				job_to_resubmit.errors = 0
				
				# reset render time
				job_to_resubmit.render_time = 0
				
				# set time created time
				job_to_resubmit.time_created = OS.get_unix_time()
				
				# requeue all chunks
				for chunk in job_to_resubmit.chunks.keys():
					job_to_resubmit.chunks[chunk].status = RRStateScheme.chunk_queued
					
					# delete all chunk tries and errors
					job_to_resubmit.chunks[chunk].errors = 0
					job_to_resubmit.chunks[chunk].number_of_tries = 0
					job_to_resubmit.chunks[chunk].tries.clear()
					
				
				# create a new job id
				var job_id : int = RRFunctions.generate_job_id(job_to_resubmit.time_created, job_to_resubmit.name)
				
				# Add the job
				RRNetworkManager.rpc("add_job", job_id, job_to_resubmit)
				
			RaptorRender.JobsTable.refresh()
			
			
			
		10:  # Separator
			pass
			
			
			
		11:  # Open Output Directories
			var selected_ids = RaptorRender.JobsTable.get_selected_ids()
			
			for selected in selected_ids:
				for directory in RaptorRender.rr_data.jobs[selected].output_dirs_and_file_name_patterns:
					if directory.size() > 0:
						var output_path : String = directory[0]
						if output_path == "":
							RaptorRender.NotificationSystem.add_error_notification(tr("MSG_ERROR_1"), tr("MSG_ERROR_12"), 7) # The output path is unknown for this job!
						else:
							JobFunctions.open_folder( output_path )
		
		
		
		12:  # Open Scene Folder
			var selected_ids = RaptorRender.JobsTable.get_selected_ids()
			
			for selected in selected_ids:
				var scene_path : String = RaptorRender.rr_data.jobs[selected].scene_path.get_base_dir()
				JobFunctions.open_folder( scene_path )
		
		
		
		
		13:  # Separator
			pass
			
			
			
		14:  # Remove Job
			
			var selected_ids = RaptorRender.JobsTable.get_selected_ids().duplicate()  # duplicate of array needed because the reference would change as rows get deleted...
			temp_ids = selected_ids
			
			# create and show popup
			var root : Node = get_tree().get_root()
			var popup : AutoScalingPopup = AutoScalingPopupBasRes.instance()
			popup.shrinks_to_content_size = true
			popup.set_title("POPUP_INFO_1")
			popup.set_button_texts("POPUP_BUTTON_CANCEL","POPUP_BUTTON_CONTINUE")
			
			var popup_content = InfoPopupContentRes.instance()
			if selected_ids.size() == 1:
				popup_content.set_info_text(tr("POPUP_INFO_6").replace("{job_name}", RaptorRender.rr_data.jobs[selected_ids[0]].name))
			else:
				popup_content.set_info_text(tr("POPUP_INFO_7").replace("{number}", String(selected_ids.size())) )
			
			popup.set_content(popup_content)
			
			root.add_child(popup)
			popup.connect("ok_pressed", self, "delete_jobs")
			



func delete_jobs() -> void:
	
	for peer in RRNetworkManager.management_gui_clients:
		RRNetworkManager.rpc_id(peer, "remove_jobs", temp_ids)
	
	temp_ids.clear()
