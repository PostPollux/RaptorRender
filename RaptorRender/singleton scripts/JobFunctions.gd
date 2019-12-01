extends Node

### PRELOAD RESOURCES

### SIGNALS

### ONREADY VARIABLES

### EXPORTED VARIABLES

### VARIABLES





########## FUNCTIONS ##########


func get_chunk_counts_TotalFinishedActive(job_id) -> Array:

	var chunk_keys : Array = RaptorRender.rr_data.jobs[job_id].chunks.keys()
	
	var chunks_total : int = 0
	var chunks_finished : int = 0
	var chunks_active : int = 0
	
	for chunk_key in chunk_keys:
		var chunk_status : String = RaptorRender.rr_data.jobs[job_id].chunks[chunk_key].status
		match chunk_status:
			RRStateScheme.chunk_rendering : chunks_active += 1
			RRStateScheme.chunk_finished : chunks_finished += 1
		chunks_total += 1

	return [chunks_total, chunks_finished, chunks_active]




func open_folder(path : String):

	var platform : String = OS.get_name()
	
	match platform:
		
		# Linux
		"X11" :
			
			var corrected_path : String = path.replace("\\","/") # convert path to unix style
			
			var dir : Directory = Directory.new()
			
			if dir.dir_exists( corrected_path ):
				
				var arguments : Array = [corrected_path]
				var execute_output : Array =[]
				OS.execute("xdg-open", arguments, false, execute_output)
				
			else:
				RaptorRender.NotificationSystem.add_error_notification(tr("MSG_ERROR_1"), tr("MSG_ERROR_3"), 7) # Seems like directory does not exist!
		
		
		# Windows
		"Windows" :
			
			var corrected_path : String = path.replace("/","\\") # convert path windows style
			
			var dir : Directory = Directory.new()
			
			if dir.dir_exists( corrected_path ):
				
				var arguments : Array = [corrected_path]
				var execute_output : Array = []
				OS.execute("explorer", arguments, false, execute_output)
				
			else:
				RaptorRender.NotificationSystem.add_error_notification(tr("MSG_ERROR_1"), tr("MSG_ERROR_3"), 7) # Seems like directory does not exist!
		
		
		
		# Mac OS
		"OSX" :
			
			var corrected_path : String = path.replace("\\","/") # convert path to unix style
			
			var dir : Directory = Directory.new()
			
			if dir.dir_exists( corrected_path ):
				
				var arguments : Array = [corrected_path]
				var execute_output : Array = []
				OS.execute("open", arguments, false, execute_output)
				
			else:
				RaptorRender.NotificationSystem.add_error_notification(tr("MSG_ERROR_1"), tr("MSG_ERROR_3"), 7) # Seems like directory does not exist!



func open_file_externally(path : String):

	var platform : String = OS.get_name()
	
	match platform:
		
		# Linux
		"X11" :
			
			var corrected_path : String = path.replace("\\","/") # convert path to unix style
			
			var file : File = File.new()
			
			if file.file_exists( corrected_path ):
				
				var arguments : Array = [corrected_path]
				var execute_output : Array =[]
				OS.execute("xdg-open", arguments, false, execute_output)
				
			else:
				RaptorRender.NotificationSystem.add_error_notification(tr("MSG_ERROR_1"), tr("MSG_ERROR_4"), 7) # Seems like file does not exist!
		
		
		# Windows
		"Windows" :
			
			var corrected_path : String = path.replace("/","\\") # convert path windows style
			
			var file : File = File.new()
			
			if file.file_exists( corrected_path ):
				
				var arguments : Array = [corrected_path]
				var execute_output : Array = []
				OS.execute("explorer", arguments, false, execute_output)
				
			else:
				RaptorRender.NotificationSystem.add_error_notification(tr("MSG_ERROR_1"), tr("MSG_ERROR_4"), 7) # Seems like file does not exist!
		
		
		
		# Mac OS
		"OSX" :
			
			var corrected_path : String = path.replace("\\","/") # convert path to unix style
			
			var file : File = File.new()
			
			if file.file_exists( corrected_path ):
				
				var arguments : Array = [corrected_path]
				var execute_output : Array = []
				OS.execute("open", arguments, false, execute_output)
				
			else:
				RaptorRender.NotificationSystem.add_error_notification(tr("MSG_ERROR_1"), tr("MSG_ERROR_4"), 7) # Seems like file does not exist!
