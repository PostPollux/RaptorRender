extends PopupMenu

func _ready():
	self.add_item("Requeue Chunk", 0, 0)
	self.add_item("Mark as finished", 1, 0)
	
	# trick to calculate the correct size of the popup, so it doesn't display outside of the window when invoked
	self.visible = true
	self.visible = false
	
	set_item_names()



func set_item_names():
	
	if RaptorRender.ChunksTable.get_selected_ids().size() <= 1:
		self.set_item_text(0, "CHUNK_CONTEXT_MENU_1") # Requeue Chunk
		self.set_item_text(1, "CHUNK_CONTEXT_MENU_2") # Mark as finished
	else:
		self.set_item_text(0, "CHUNK_CONTEXT_MENU_3") # Requeue Chunks
		self.set_item_text(1, "CHUNK_CONTEXT_MENU_4") # Mark Chunks as finished


func enable_disable_items():
	
	# diable all
	self.set_item_disabled(0, true)  # requeue chunk
	self.set_item_disabled(1, true)  # mark as finsihed
	
	
	var selected_ids = RaptorRender.ChunksTable.get_selected_ids()
	
	# now enable correct ones
	for selected in selected_ids:
		
		var status =  RaptorRender.rr_data.jobs[RaptorRender.current_job_id_for_job_info_panel].chunks[selected].status
		
		if status == RRStateScheme.chunk_rendering:
			self.set_item_disabled(0, false) # requeue chunk
			self.set_item_disabled(1, false) # mark as finsihed
		
		if status == RRStateScheme.chunk_queued:
			self.set_item_disabled(1, false) # mark as finsihed
		
		if status == RRStateScheme.chunk_error:
			self.set_item_disabled(0, false) # requeue chunk
			self.set_item_disabled(1, false) # mark as finsihed
		
		if status == RRStateScheme.chunk_paused:
			self.set_item_disabled(0, false) # requeue chunk
			self.set_item_disabled(1, false) # mark as finsihed
		
		if status == RRStateScheme.chunk_finished:
			self.set_item_disabled(0, false) # requeue chunk
		
		if status == RRStateScheme.chunk_cancelled:
			pass





func _on_ContextMenu_index_pressed(index):
	
	match index:
		
		0:  # Requeue Chunk
			
			var selected_ids = RaptorRender.ChunksTable.get_selected_ids()

			for selected in selected_ids:

				var status =  RaptorRender.rr_data.jobs[RaptorRender.current_job_id_for_job_info_panel].chunks[selected].status

				if status == RRStateScheme.chunk_rendering:
					
					var number_of_tries : int = RaptorRender.rr_data.jobs[RaptorRender.current_job_id_for_job_info_panel].chunks[selected].number_of_tries
					
					# cancel render process TODO (temporarily)
					if GetSystemInformation.unique_client_id ==  RaptorRender.rr_data.jobs[RaptorRender.current_job_id_for_job_info_panel].chunks[selected].tries[number_of_tries].client:
						CommandLineManager.kill_current_render_process()
					
					# change chunk status
					RaptorRender.rr_data.jobs[RaptorRender.current_job_id_for_job_info_panel].chunks[selected].status = RRStateScheme.chunk_queued
					
					# change try status
					RaptorRender.rr_data.jobs[RaptorRender.current_job_id_for_job_info_panel].chunks[selected].tries[number_of_tries].status = RRStateScheme.try_cancelled
					RaptorRender.rr_data.jobs[RaptorRender.current_job_id_for_job_info_panel].chunks[selected].tries[number_of_tries].time_stopped = OS.get_unix_time()
					
				elif status == RRStateScheme.chunk_paused or status == RRStateScheme.chunk_finished or status == RRStateScheme.chunk_error:
					# change status
					RaptorRender.rr_data.jobs[RaptorRender.current_job_id_for_job_info_panel].chunks[selected].status = RRStateScheme.chunk_queued

			
			
			
			
		1:  # Mark as Finished
			
			var selected_ids = RaptorRender.ChunksTable.get_selected_ids()
			
			for selected in selected_ids:
				
				var status =  RaptorRender.rr_data.jobs[RaptorRender.current_job_id_for_job_info_panel].chunks[selected].status
				
				var number_of_tries : int = RaptorRender.rr_data.jobs[RaptorRender.current_job_id_for_job_info_panel].chunks[selected].number_of_tries
					
				if status == RRStateScheme.chunk_rendering:
					
					# cancel render process TODO (temporarily)
					if GetSystemInformation.unique_client_id ==  RaptorRender.rr_data.jobs[RaptorRender.current_job_id_for_job_info_panel].chunks[selected].tries[number_of_tries].client:
						CommandLineManager.kill_current_render_process()
					
					# change try status
					RaptorRender.rr_data.jobs[RaptorRender.current_job_id_for_job_info_panel].chunks[selected].tries[number_of_tries].status = RRStateScheme.try_marked_as_finished
					RaptorRender.rr_data.jobs[RaptorRender.current_job_id_for_job_info_panel].chunks[selected].tries[number_of_tries].time_stopped = OS.get_unix_time()
					
				if status == RRStateScheme.chunk_rendering or status == RRStateScheme.chunk_paused or status == RRStateScheme.chunk_queued or status == RRStateScheme.chunk_error:
					
					# change status
					RaptorRender.rr_data.jobs[RaptorRender.current_job_id_for_job_info_panel].chunks[selected].status = RRStateScheme.chunk_finished
	
	
	
	RaptorRender.JobsTable.refresh()
	RaptorRender.ClientsTable.refresh()
	RaptorRender.ChunksTable.refresh()

