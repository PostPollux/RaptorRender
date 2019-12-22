extends PopupMenu


### PRELOAD RESOURCES

### SIGNALS

### ONREADY VARIABLES

### EXPORTED VARIABLES

### VARIABLES




########## FUNCTIONS ##########


func _ready() -> void:
	self.add_item("Requeue Chunk", 0, 0)
	self.add_item("Mark as finished", 1, 0)
	
	# trick to calculate the correct size of the popup, so it doesn't display outside of the window when invoked
	self.visible = true
	self.visible = false
	
	set_item_names()



func set_item_names() -> void:
	
	if RaptorRender.ChunksTable.get_selected_ids().size() <= 1:
		self.set_item_text(0, "CHUNK_CONTEXT_MENU_1") # Requeue Chunk
		self.set_item_text(1, "CHUNK_CONTEXT_MENU_2") # Mark as finished
	else:
		self.set_item_text(0, "CHUNK_CONTEXT_MENU_3") # Requeue Chunks
		self.set_item_text(1, "CHUNK_CONTEXT_MENU_4") # Mark Chunks as finished


func enable_disable_items() -> void:
	
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





func _on_ContextMenu_index_pressed(index) -> void:
	
	match index:
		
		0:  # Requeue Chunk
			
			var selected_ids = RaptorRender.ChunksTable.get_selected_ids()
			
			for client in RRNetworkManager.management_gui_clients:
				RRNetworkManager.rpc_id(client, "update_chunk_states", RaptorRender.current_job_id_for_job_info_panel, selected_ids, RRStateScheme.chunk_queued)
			
			
			
		1:  # Mark as Finished
			
			var selected_ids = RaptorRender.ChunksTable.get_selected_ids()
			
			for client in RRNetworkManager.management_gui_clients:
				RRNetworkManager.rpc_id(client, "mark_chunks_as_finished", RaptorRender.current_job_id_for_job_info_panel, selected_ids)
			
	
	
	RaptorRender.JobsTable.refresh()
	RaptorRender.ClientsTable.refresh()
	RaptorRender.ChunksTable.refresh()

