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
	
	self.add_item("Resubmit Job", 9, 0)
	self.add_separator()
	self.add_item("Open Output Folder", 11, 0)
	self.add_item("Open Scene Folder", 12, 0)
	self.add_separator()
	self.add_item("Remove Job", 14, 0)
	
	# trick to calculate the correct size of the popup, so it doesn't display outside of the windo when invoked
	self.visible = true
	self.visible = false


func set_item_names():
	
	if RaptorRender.TableJobs.get_selected_content_ids().size() <= 1:
		self.set_item_text(0, "Pause Job Deffered")
		self.set_item_text(1, "Pause Job Immediately")
		self.set_item_text(2, "Resume Job")
		self.set_item_text(4, "Cancel Job Permanently")
		self.set_item_text(6, "Configure Job")
		self.set_item_text(7, "Reset Job Error count")
		self.set_item_text(9, "Resubmit Job")
		self.set_item_text(11, "Open Output Folder")
		self.set_item_text(12, "Open Scene Folder")
		self.set_item_text(14, "Remove Job")
	else:
		self.set_item_text(0, "Pause Jobs Deffered")
		self.set_item_text(1, "Pause Jobs Immediately")
		self.set_item_text(2, "Resume Jobs")
		self.set_item_text(4, "Cancel Jobs Permanently")
		self.set_item_text(6, "Configure Jobs")
		self.set_item_text(7, "Reset Job Error Counts")
		self.set_item_text(9, "Resubmit Jobs")
		self.set_item_text(11, "Open Output Folders")
		self.set_item_text(12, "Open Scene Folders")
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
	
	
	var selected_ids = RaptorRender.TableJobs.get_selected_content_ids()
	
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
		if status != "6_cancelled":
			self.set_item_disabled(4, false)
			
		# Configure Job
		if status != "1_rendering":
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
		if status != "1_rendering":
			self.set_item_disabled(14, false)
	



	

func _on_ContextMenu_index_pressed(index):
	
	match index:
		
		0:  # Pause Job	Deffered
			
			var selected_ids = RaptorRender.TableJobs.get_selected_content_ids()
			
			for selected in selected_ids:
				
				var status =  RaptorRender.rr_data.jobs[selected].status
				
				if status == "1_rendering" or status == "2_queued":
					
					RaptorRender.rr_data.jobs[selected].status = "4_paused"
			
			RaptorRender.TableJobs.refresh()
			
			
			
		1:  # Pause Job	Immediately
			
			var selected_ids = RaptorRender.TableJobs.get_selected_content_ids()
			
			for selected in selected_ids:
				
				var status =  RaptorRender.rr_data.jobs[selected].status
				
				if status == "1_rendering" or status == "2_queued" or status == "4_paused":
					
					RaptorRender.rr_data.jobs[selected].status = "4_paused"
				
			RaptorRender.TableJobs.refresh()
			RaptorRender.TableClients.refresh()
			
			
				
		2:  # Resume Job
			
			var selected_ids = RaptorRender.TableJobs.get_selected_content_ids()
			
			for selected in selected_ids:
				
				var status =  RaptorRender.rr_data.jobs[selected].status
				
				if status == "4_paused":
					
					RaptorRender.rr_data.jobs[selected].status = "2_queued"
			
			RaptorRender.TableJobs.refresh()
			
			
			
		3:  # Separator
			pass	
			
			
		
		4:  # Cancel Job Permanently
			var selected_ids = RaptorRender.TableJobs.get_selected_content_ids()
			
			for selected in selected_ids:
				
				var status =  RaptorRender.rr_data.jobs[selected].status
				
				if status == "1_rendering" or status == "2_queued" or status == "4_paused":
					
					RaptorRender.rr_data.jobs[selected].status = "6_cancelled"
				
			RaptorRender.TableJobs.refresh()
			RaptorRender.TableClients.refresh()
			
			
		
		5:  # Separator
			pass		
			
			
			
		6:  # Configure Job
			print ("Configure Job - Not Implemented yet!")
		
		
		
		7:  # Reset Job Error count
			var selected_ids = RaptorRender.TableJobs.get_selected_content_ids()
			
			for selected in selected_ids:
	
				RaptorRender.rr_data.jobs[selected].errors = 0
				
			RaptorRender.TableJobs.refresh()
			
			
			
			
		8:  # Separator
			pass
			
			
		9:  # Resubmit Job
			print ( "Resubmit Job - not implemented yet")
			
			
			
		10:  # Separator
			pass
			
			
		11:  # Open Output Folder
			print ( "Open Output Folder - not implemented yet")
		
		
		
		12:  # Open Scene Folder
			print ( "Open Scene Folder - not implemented yet")
		
		
		
		13:  # Separator
			pass
			
			
			
		14:  # Remove Job
			
			var selected_ids = RaptorRender.TableJobs.get_selected_content_ids()
			
			for selected in selected_ids:
				
				RaptorRender.rr_data.jobs.erase(selected)
			
			RaptorRender.TableJobs.refresh()
			RaptorRender.TableClients.refresh()
