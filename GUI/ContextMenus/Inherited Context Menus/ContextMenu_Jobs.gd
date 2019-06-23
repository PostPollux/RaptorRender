extends PopupMenu

func _ready():
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
	self.add_item("Open Output Directory", 11, 0)
	self.add_item("Open Scene Directory", 12, 0)
	self.add_separator()
	self.add_item("Remove Job", 14, 0)
	
	# trick to calculate the correct size of the popup, so it doesn't display outside of the window when invoked
	self.visible = true
	self.visible = false



func set_item_names():
	
	if RaptorRender.JobsTable.get_selected_ids().size() <= 1:
		self.set_item_text(0, "Pause Job Deffered")
		self.set_item_text(1, "Pause Job Immediately")
		self.set_item_text(2, "Resume Job")
		self.set_item_text(4, "Cancel Job Permanently")
		self.set_item_text(6, "Configure Job")
		self.set_item_text(7, "Reset Job Error count")
		self.set_item_text(9, "Resubmit Job paused")
		self.set_item_text(11, "Open Output Directory")
		self.set_item_text(12, "Open Scene Directory")
		self.set_item_text(14, "Remove Job")
	else:
		self.set_item_text(0, "Pause Jobs Deffered")
		self.set_item_text(1, "Pause Jobs Immediately")
		self.set_item_text(2, "Resume Jobs")
		self.set_item_text(4, "Cancel Jobs Permanently")
		self.set_item_text(6, "Configure Jobs")
		self.set_item_text(7, "Reset Job Error Counts")
		self.set_item_text(9, "Resubmit Jobs paused")
		self.set_item_text(11, "Open Output Directories")
		self.set_item_text(12, "Open Scene Directories")
		self.set_item_text(14, "Remove Jobs")



func enable_disable_items():
	
	self.set_item_disabled(0, true)  # pause job deffered
	self.set_item_disabled(1, true)  # pause job immediately
	self.set_item_disabled(2, true)  # resume job
	self.set_item_disabled(4, true)  # cancel job permanently
	self.set_item_disabled(6, true)  # configure job
	self.set_item_disabled(7, true)  # reset job error count
	self.set_item_disabled(9, true)  # resubmit job paused
	self.set_item_disabled(11, true)  # open output folder
	self.set_item_disabled(12, true)  # open scene folder
	self.set_item_disabled(14, true)  # remove job
	
	
	var selected_ids = RaptorRender.JobsTable.get_selected_ids()
	
	for selected in selected_ids:
		
		var status =  RaptorRender.rr_data.jobs[selected].status
		
		if status == RRStateScheme.job_rendering:
			self.set_item_disabled(0, false) # pause job deffered
			self.set_item_disabled(1, false) # pause job immediately
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
		self.set_item_disabled(11, false) # open output folder
		self.set_item_disabled(12, false) # open scene folder
		self.set_item_disabled(14, false) # remove job




func _on_ContextMenu_index_pressed(index):
	
	match index:
		
		0:  # Pause Job	Deffered
			
			var selected_ids = RaptorRender.JobsTable.get_selected_ids()
			
			for selected in selected_ids:
				
				var status =  RaptorRender.rr_data.jobs[selected].status
				
				if status == RRStateScheme.job_rendering or status == RRStateScheme.job_queued or status == RRStateScheme.job_error:
					
					RaptorRender.rr_data.jobs[selected].status = RRStateScheme.job_rendering_paused_deferred
					
					# cancle active chunks
					for chunk in RaptorRender.rr_data.jobs[selected].chunks.keys():
						var chunk_status : String = RaptorRender.rr_data.jobs[selected].chunks[chunk].status
						if chunk_status == RRStateScheme.chunk_queued:
							RaptorRender.rr_data.jobs[selected].chunks[chunk].status = RRStateScheme.chunk_paused
			
			RaptorRender.JobsTable.refresh()
			
			
			
		1:  # Pause Job	Immediately
			
			var selected_ids = RaptorRender.JobsTable.get_selected_ids()
			
			for selected in selected_ids:
				
				var status =  RaptorRender.rr_data.jobs[selected].status
				
				if status == RRStateScheme.job_rendering or status == RRStateScheme.job_queued or status == RRStateScheme.job_error or status == RRStateScheme.job_paused:
					
					# remove Clients from Job
					for client in RaptorRender.rr_data.clients.keys():
						if RaptorRender.rr_data.clients[client].current_job_id == selected:
							RaptorRender.rr_data.clients[client].current_job_id = -1
							RaptorRender.rr_data.clients[client].status = RRStateScheme.client_available
							
							# cancel render process TODO (temporarily)
							if GetSystemInformation.unique_client_id == client:
								CommandLineManager.kill_current_render_process()
					
					# cancle active chunks
					for chunk in RaptorRender.rr_data.jobs[selected].chunks.keys():
						var chunk_status : String = RaptorRender.rr_data.jobs[selected].chunks[chunk].status
						if chunk_status == RRStateScheme.chunk_rendering or chunk_status == RRStateScheme.chunk_queued:
							RaptorRender.rr_data.jobs[selected].chunks[chunk].status = RRStateScheme.chunk_paused
							
					# Set Status to paused
					RaptorRender.rr_data.jobs[selected].status = RRStateScheme.job_paused
					
				
			RaptorRender.JobsTable.refresh()
			RaptorRender.ClientsTable.refresh()
			
			
				
		2:  # Resume Job
			
			var selected_ids = RaptorRender.JobsTable.get_selected_ids()
			
			for selected in selected_ids:
				
				var status =  RaptorRender.rr_data.jobs[selected].status
				
				if status == RRStateScheme.job_paused:
					
					RaptorRender.rr_data.jobs[selected].status = RRStateScheme.job_queued
					
					# queue all paused chunks
					for chunk in RaptorRender.rr_data.jobs[selected].chunks.keys():
						if RaptorRender.rr_data.jobs[selected].chunks[chunk].status == RRStateScheme.chunk_paused:
							RaptorRender.rr_data.jobs[selected].chunks[chunk].status = RRStateScheme.chunk_queued
			
			RaptorRender.JobsTable.refresh()
			
			
			
		3:  # Separator
			pass	
			
			
		
		4:  # Cancel Job Permanently
			var selected_ids = RaptorRender.JobsTable.get_selected_ids()
			
			for selected in selected_ids:
				
				var status =  RaptorRender.rr_data.jobs[selected].status
				
				if status == RRStateScheme.job_rendering or status == RRStateScheme.job_queued or status == RRStateScheme.job_error or status == RRStateScheme.job_paused:
					
					# remove Clients from Job
					for client in RaptorRender.rr_data.clients.keys():
						if RaptorRender.rr_data.clients[client].current_job_id == selected:
							RaptorRender.rr_data.clients[client].current_job_id = -1
							RaptorRender.rr_data.clients[client].status = RRStateScheme.client_available
							
							# cancel render process TODO (temporarily)
							if GetSystemInformation.unique_client_id == client:
								CommandLineManager.kill_current_render_process()
							
							
					# cancle active chunks
					for chunk in RaptorRender.rr_data.jobs[selected].chunks.keys():
						var chunk_status : String = RaptorRender.rr_data.jobs[selected].chunks[chunk].status
						if chunk_status == RRStateScheme.chunk_rendering or chunk_status == RRStateScheme.chunk_queued:
							RaptorRender.rr_data.jobs[selected].chunks[chunk].status = RRStateScheme.chunk_cancelled
					
					# Set Status to cancelled
					RaptorRender.rr_data.jobs[selected].status = RRStateScheme.job_cancelled
					
					
				
			RaptorRender.JobsTable.refresh()
			RaptorRender.ClientsTable.refresh()
			
			
		
		5:  # Separator
			pass		
			
			
			
		6:  # Configure Job
			RaptorRender.NotificationSystem.add_error_notification("Error", "Not implemented yet!", 5)
		
		
		
		7:  # Reset Job Error count
			var selected_ids = RaptorRender.JobsTable.get_selected_ids()
			
			for selected in selected_ids:
				
				RaptorRender.rr_data.jobs[selected].errors = 0
				
			RaptorRender.JobsTable.refresh()
			
			
			
			
		8:  # Separator
			pass
			
			
		9:  # Resubmit Job paused
			var selected_ids = RaptorRender.JobsTable.get_selected_ids()
			
			for selected in selected_ids:
				
				var job_to_resubmit = str2var( var2str(RaptorRender.rr_data.jobs[selected]) ) # conversion is needed to copy the dict. Otherwise you only get a reference
				
				# set job status to paused
				job_to_resubmit.status = RRStateScheme.job_paused
				
				# requeue all chunks
				for chunk in job_to_resubmit.chunks.keys():
					job_to_resubmit.chunks[chunk].status = RRStateScheme.chunk_queued
				
				# create a new job id
				var max_id = 0
				for job in RaptorRender.rr_data.jobs.keys():
					max_id = max(max_id, int(job))
				
				RaptorRender.rr_data.jobs[max_id + 1 ] = job_to_resubmit
				
				
			RaptorRender.JobsTable.refresh()
			
			
			
		10:  # Separator
			pass
			
			
			
		11:  # Open Output Folder
			var selected_ids = RaptorRender.JobsTable.get_selected_ids()
			
			for selected in selected_ids:
				
				JobFunctions.open_folder( RaptorRender.rr_data.jobs[selected].output_directory )
		
		
		
		12:  # Open Scene Folder
			var selected_ids = RaptorRender.JobsTable.get_selected_ids()
			
			for selected in selected_ids:
				var scene_path : String = RaptorRender.rr_data.jobs[selected].scene_path.get_base_dir()
				JobFunctions.open_folder( scene_path )
		
		
		
		
		13:  # Separator
			pass
			
			
			
		14:  # Remove Job
			
			var selected_ids = str2var( var2str( RaptorRender.JobsTable.get_selected_ids() ))  # str2var hack needed to make sure it's not just a reference. Because the reference would change as rows get deleted...
			
			for selected in selected_ids:
				
				# remove Clients from Job
				for client in RaptorRender.rr_data.clients.keys():
					if RaptorRender.rr_data.clients[client].current_job_id == selected:
						RaptorRender.rr_data.clients[client].current_job_id = -1
						RaptorRender.rr_data.clients[client].status = RRStateScheme.client_available
				
				# cancle active chunks
				for chunk in RaptorRender.rr_data.jobs[selected].chunks.keys():
					var chunk_status : String = RaptorRender.rr_data.jobs[selected].chunks[chunk].status
					if chunk_status == RRStateScheme.chunk_rendering or chunk_status == RRStateScheme.chunk_queued:
						RaptorRender.rr_data.jobs[selected].chunks[chunk].status = RRStateScheme.chunk_cancelled
						
				# cancel render process
				CommandLineManager.kill_current_render_process()
				
				# Remove the job from the database
				RaptorRender.rr_data.jobs.erase(selected)
				
				# remove the row from the table
				RaptorRender.JobsTable.remove_row(selected)
				
				
				
			# hide the Jobs Info Panel
			RaptorRender.JobsTable.clear_selection()
			RaptorRender.JobInfoPanel.visible = false
			RaptorRender.JobInfoPanel.reset_to_first_tab()
			
			
			# RaptorRender.JobsTable.refresh()
			RaptorRender.ClientsTable.refresh()
