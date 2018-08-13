extends Node

func get_chunk_counts_TotalFinishedActive(job_id):

	var chunk_keys = RaptorRender.rr_data.jobs[job_id].chunks.keys()
			
	var chunks_total = 0
	var chunks_finished = 0
	var chunks_active = 0
	
	for chunk_key in chunk_keys:
		var chunk_status = RaptorRender.rr_data.jobs[job_id].chunks[chunk_key].status
		match chunk_status:
			"active": chunks_active += 1
			"finished": chunks_finished += 1
		chunks_total += 1

	return [chunks_total, chunks_finished, chunks_active]




func open_folder(path):

	var platform = OS.get_name()
	
	match platform:
		
		# Linux
		"X11" :
			
			var corrected_path = path.replace("\\","/") # convert path to unix style
			
			var dir = Directory.new()
			
			if dir.dir_exists( corrected_path ):
				
				var arguments = [corrected_path]
				var execute_output =[]
				OS.execute("xdg-open", arguments, false, execute_output)
				
			else:
				RaptorRender.NotificationSystem.add_error_notification("Error", "Directory seems not to exist!", 7)
		
		
		# Windows
		"Windows" :
			
			var corrected_path = path.replace("/","\\") # convert path windows style
			
			var dir = Directory.new()
			
			if dir.dir_exists( corrected_path ):
				
				var arguments = [corrected_path]
				var execute_output =[]
				OS.execute("explorer", arguments, false, execute_output)
				
			else:
				RaptorRender.NotificationSystem.add_error_notification("Error", "Directory seems not to exist!", 7)
		
		
		
		# Mac OS
		"OSX" :
			
			var corrected_path = path.replace("\\","/") # convert path to unix style
			
			var dir = Directory.new()
			
			if dir.dir_exists( corrected_path ):
				
				var arguments = [corrected_path]
				var execute_output =[]
				OS.execute("open", arguments, false, execute_output)
				
			else:
				RaptorRender.NotificationSystem.add_error_notification("Error", "Directory seems not to exist!", 7)