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
	
	# trick to calculate the correct size of the popup, so it doesn't display outside of the windo when invoked
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
	
	self.set_item_disabled(0, true)  # Pause Job Deffered
	self.set_item_disabled(1, true)  # Pause Job Immediately
	self.set_item_disabled(2, true)  # Resume Job
	self.set_item_disabled(4, true)  # Cancel Job Permanently
	self.set_item_disabled(6, true)  # Configure Job
	self.set_item_disabled(7, true)  # Reset Job Error count
	self.set_item_disabled(9, true)  # Resubmit Job
	self.set_item_disabled(11, true)  # Open Output Folder
	self.set_item_disabled(12, true)  # Open Scene Folder
	self.set_item_disabled(14, true)  # Remove Job
	
	
	var selected_ids = RaptorRender.JobsTable.get_selected_ids()
	
	for selected in selected_ids:
		
		var status =  RaptorRender.rr_data.jobs[selected].status
		
		# Pause Job	
		if status == "1_rendering":
			self.set_item_disabled(0, false)
			self.set_item_disabled(1, false)
		
		# Resume Job
		if status == "4_paused":
			self.set_item_disabled(2, false)
			
		# Cancel Job Permanently
		if status == "1_rendering" or status == "2_queued" or status == "3_error" or status == "4_paused":
			self.set_item_disabled(4, false)
			
		# Configure Job
		if status == "2_queued" or status == "3_error" or status == "4_paused":
			self.set_item_disabled(6, false)
		
		# Reset Job Error count
		if status == "6_cancelled":
			self.set_item_disabled(7, false)
			
		# Resubmit Job
		self.set_item_disabled(9, false)
		
		# Open Output Folder
		self.set_item_disabled(11, false)
			
		# Open Scene Folder
		self.set_item_disabled(12, false)
		
		# Remove Job
		self.set_item_disabled(14, false)




func _on_ContextMenu_index_pressed(index):
	
	match index:
		
		0:  # Pause Job	Deffered
			
			var selected_ids = RaptorRender.JobsTable.get_selected_ids()
			
			for selected in selected_ids:
				
				var status =  RaptorRender.rr_data.jobs[selected].status
				
				if status == "1_rendering" or status == "2_queued" or status == "3_error":
					
					RaptorRender.rr_data.jobs[selected].status = "4_paused"
			
			RaptorRender.JobsTable.refresh()
			
			
			
		1:  # Pause Job	Immediately
			
			var selected_ids = RaptorRender.JobsTable.get_selected_ids()
			
			for selected in selected_ids:
				
				var status =  RaptorRender.rr_data.jobs[selected].status
				
				if status == "1_rendering" or status == "2_queued" or status == "3_error" or status == "4_paused":
					
					# remove Clients from Job
					for client in RaptorRender.rr_data.clients.keys():
						if RaptorRender.rr_data.clients[client].current_job_id == selected:
							RaptorRender.rr_data.clients[client].current_job_id = ""
							RaptorRender.rr_data.clients[client].status = "2_available"
					
					# cancle active chunks
					for chunk in RaptorRender.rr_data.jobs[selected].chunks.keys():
						if RaptorRender.rr_data.jobs[selected].chunks[chunk].status == "active":
							RaptorRender.rr_data.jobs[selected].chunks[chunk].status = "queued"
							
					# Set Status to paused
					RaptorRender.rr_data.jobs[selected].status = "4_paused"
				
			RaptorRender.JobsTable.refresh()
			RaptorRender.ClientsTable.refresh()
			
			
				
		2:  # Resume Job
			
			var selected_ids = RaptorRender.JobsTable.get_selected_ids()
			
			for selected in selected_ids:
				
				var status =  RaptorRender.rr_data.jobs[selected].status
				
				if status == "4_paused":
					
					RaptorRender.rr_data.jobs[selected].status = "2_queued"
			
			RaptorRender.JobsTable.refresh()
			
			
			
		3:  # Separator
			pass	
			
			
		
		4:  # Cancel Job Permanently
			var selected_ids = RaptorRender.JobsTable.get_selected_ids()
			
			for selected in selected_ids:
				
				var status =  RaptorRender.rr_data.jobs[selected].status
				
				if status == "1_rendering" or status == "2_queued" or status == "3_error" or status == "4_paused":
					
					# remove Clients from Job
					for client in RaptorRender.rr_data.clients.keys():
						if RaptorRender.rr_data.clients[client].current_job_id == selected:
							RaptorRender.rr_data.clients[client].current_job_id = ""
							RaptorRender.rr_data.clients[client].status = "2_available"
							
					# cancle active chunks
					for chunk in RaptorRender.rr_data.jobs[selected].chunks.keys():
						if RaptorRender.rr_data.jobs[selected].chunks[chunk].status == "active":
							RaptorRender.rr_data.jobs[selected].chunks[chunk].status = "queued"
					
					# Set Status to cancelled
					RaptorRender.rr_data.jobs[selected].status = "6_cancelled"
				
			RaptorRender.JobsTable.refresh()
			RaptorRender.ClientsTable.refresh()
			
			
		
		5:  # Separator
			pass		
			
			
			
		6:  # Configure Job
			print ("Configure Job - Not Implemented yet!")
		
		
		
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
				job_to_resubmit.status = "4_paused"
				
				# requeue all chunks
				for chunk in job_to_resubmit.chunks.keys():
					job_to_resubmit.chunks[chunk].status = "queued"
				
				# create a new job id
				var max_id = 0
				for job in RaptorRender.rr_data.jobs.keys():
					max_id = max(max_id, int(job))
				
				RaptorRender.rr_data.jobs[String( max_id + 1 )] = job_to_resubmit
				
				
			RaptorRender.JobsTable.refresh()
			
			
			
		10:  # Separator
			pass
			
			
		11:  # Open Output Folder
			var selected_ids = RaptorRender.JobsTable.get_selected_ids()
			var platform = OS.get_name()
			
			match platform:
				
				# Linux
				"X11" :
					
					for selected in selected_ids:
						
						var output_path = RaptorRender.rr_data.jobs[selected].output_directory
						output_path = output_path.replace("\\","/") # convert path to unix style
						
						var output_directory = Directory.new()
						
						if	output_directory.dir_exists( output_path ):
							
							var arguments = [output_path]
							var execute_output =[]
							OS.execute("xdg-open", arguments, false, execute_output)
							
						else:
							print ("Directory does not exist!")
				
				
				# Windows
				"Windows" :
					
					for selected in selected_ids:
						
						var output_path = RaptorRender.rr_data.jobs[selected].output_directory
						output_path = output_path.replace("/","\\") # convert path windows style
						
						var output_directory = Directory.new()
						
						if	output_directory.dir_exists( output_path ):
							
							var arguments = [output_path]
							var execute_output =[]
							OS.execute("explorer", arguments, false, execute_output)
							
						else:
							print ("Directory does not exist!")
				
				
				# Mac OS
				"OSX" :
					
					for selected in selected_ids:
						
						var output_path = RaptorRender.rr_data.jobs[selected].output_directory
						output_path = output_path.replace("\\","/") # convert path to unix style
						
						var output_directory = Directory.new()
						
						if	output_directory.dir_exists( output_path ):
							
							var arguments = [output_path]
							var execute_output =[]
							OS.execute("open", arguments, false, execute_output)
							
						else:
							print ("Directory does not exist!")
		
		
		
		12:  # Open Scene Folder
			var selected_ids = RaptorRender.JobsTable.get_selected_ids()
			var platform = OS.get_name()
			
			match platform:
				
				# Linux
				"X11" :
					
					for selected in selected_ids:
						
						var output_path = RaptorRender.rr_data.jobs[selected].scene_directory
						output_path = output_path.replace("\\","/") # convert path to unix style
						
						var output_directory = Directory.new()
						
						if	output_directory.dir_exists( output_path ):
							
							var arguments = [output_path]
							var execute_output =[]
							OS.execute("xdg-open", arguments, false, execute_output)
							
						else:
							print ("Directory does not exist!")
				
				
				# Windows
				"Windows" :
					
					for selected in selected_ids:
						
						var output_path = RaptorRender.rr_data.jobs[selected].scene_directory
						output_path = output_path.replace("/","\\") # convert path windows style
						
						var output_directory = Directory.new()
						
						if	output_directory.dir_exists( output_path ):
							
							var arguments = [output_path]
							var execute_output =[]
							OS.execute("explorer", arguments, false, execute_output)
							
						else:
							print ("Directory does not exist!")
					
					
				# Mac OS
				"OSX" :
					
					for selected in selected_ids:
						
						var output_path = RaptorRender.rr_data.jobs[selected].scene_directory
						output_path = output_path.replace("\\","/") # convert path to unix style
						
						var output_directory = Directory.new()
						
						if	output_directory.dir_exists( output_path ):
							
							var arguments = [output_path]
							var execute_output =[]
							OS.execute("open", arguments, false, execute_output)
							
						else:
							print ("Directory does not exist!")
		
		
		
		13:  # Separator
			pass
			
			
			
		14:  # Remove Job
			
			var selected_ids = str2var( var2str( RaptorRender.JobsTable.get_selected_ids() ))  # str2var hack needed to make sure it's not just a reference. Because the reference would change as rows get deleted...
			
			for selected in selected_ids:
				
				# remove Clients from Job
				for client in RaptorRender.rr_data.clients.keys():
					if RaptorRender.rr_data.clients[client].current_job_id == selected:
						RaptorRender.rr_data.clients[client].current_job_id = ""
						RaptorRender.rr_data.clients[client].status = "2_available"
					
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
