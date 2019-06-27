extends PopupMenu

func _ready():
	self.add_item("open log externally", 0, 0)
	self.add_item("open logs folder", 1, 0)
	
	# trick to calculate the correct size of the popup, so it doesn't display outside of the window when invoked
	self.visible = true
	self.visible = false
	
	set_item_names()



func set_item_names():
	self.set_item_text(0, "LOG_CONTEXT_MENU_1") # open log externally
	self.set_item_text(1, "LOG_CONTEXT_MENU_2") # open logs folder


func enable_disable_items():
	
	# diable all
	self.set_item_disabled(0, true)  # open log externally
	self.set_item_disabled(1, true)  # open logs folder
	
	# if not no file
	self.set_item_disabled(0, false)  # open log externally
	
	# always enable "open logs folder
	self.set_item_disabled(1, false)  # open logs folder




func _on_ContextMenu_index_pressed(index):
	
	var filename : String = String(RaptorRender.current_job_id_for_job_info_panel) + "_chunk_" + String(RaptorRender.current_chunk_id_for_job_info_panel) + "_try_" + String(RaptorRender.TryInfoPanel.currently_displayed_try_id) + ".txt"
	var filepath : String = OS.get_user_data_dir() + "/logs/" + filename
	
	match index:
		
		0:  # open log externally
			print (filepath)
			JobFunctions.open_file_externally(filepath)
			
			
		1:  # open logs folder
			JobFunctions.open_folder( OS.get_user_data_dir() + "/logs/" )



