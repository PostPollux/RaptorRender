#////////////////////#
# CommandlineManager #
#////////////////////#

# This script handles 
# - executing a commandline render instruction in a separate processes and redirect it's output into a file
# - continuously read and monitor the output file while rendering to detect errors and successes
# - abort rendering by killing the process


extends Node


### PRELOAD RESOURCES

### SIGNALS
signal render_process_exited
signal render_process_exited_without_software_start

### ONREADY VARIABLES

### EXPORTED VARIABLES

### VARIABLES
var platform : String # to decide which function to call depending on os

var invoked_render_pid : int = 999999999 # start value is just a big unrealistic number. Otherwise it would be 0 by default which is the main process which is a bit dangerous...

var log_data_path : String

var active_render_log_file : File
var current_commandline_instructions : String
var current_commandline_instructions_without_executable : String

var file_pointer_position : int = 0

var read_log_file_thread : Thread

var active_render_log_file_path : String

var currently_rendering : bool = false

var read_log_timer : Timer 

var delayed_exited_timer : Timer 




########## FUNCTIONS ##########


func _ready() -> void:
	
	# get current platform to call correct functions
	platform  = OS.get_name()
	
	# create the thread this script is using
	read_log_file_thread = Thread.new()
	
	# initialize file object
	active_render_log_file = File.new()
	
	# create timer to constantly read the current render log in a specific interval 
	read_log_timer = Timer.new()
	read_log_timer.name = "Read Log Timer"
	read_log_timer.wait_time = 1.0
	read_log_timer.connect("timeout",self,"start_read_log_file_thread")
	
	# create timer for sending the render_process_exited signal delayed
	delayed_exited_timer = Timer.new()
	delayed_exited_timer.name = "Delayed Exit Signal Timer"
	
	
	var root_node : Node = get_tree().get_root().get_node("RaptorRenderMainScene")
	if root_node != null:
		root_node.add_child(read_log_timer)
		root_node.add_child(delayed_exited_timer)
	
	RenderLogValidator.connect("critical_error_detected", self, "kill_current_render_process")


func start_read_log_file_thread() -> void:
	if read_log_file_thread.is_active():
		# stop here if already working
		return
		
	# start the thread	
	read_log_file_thread.start(self, "validate_log_file","")



func validate_log_file(args) -> void:
	
	if active_render_log_file.file_exists(active_render_log_file_path):
		
		active_render_log_file.open(active_render_log_file_path, File.READ)
		
		active_render_log_file.seek(file_pointer_position)
		
		
		while true:
			var line : String = active_render_log_file.get_line()
			
			var log_line_ok : bool = RenderLogValidator.validate_log_line(line)
			
			if not log_line_ok:
				kill_current_render_process()
				break
			
			# break loop if end of file is reached
			if active_render_log_file.eof_reached():
				file_pointer_position = active_render_log_file.get_position()
				break
	
	check_if_render_process_is_running()
	
	# call_deferred has to call another function in order to join the thread with the main thread. Otherwise it will just stay active.
	call_deferred("join_read_log_file_thread")


func join_read_log_file_thread() -> void:
	# this will effectively stop the thread
	read_log_file_thread.wait_to_finish()



func start_render_process (job_id : int, cmdline_instruction : String, cmdline_instruction_without_executable : String, full_log_file_path : String):
	
	if currently_rendering:
		kill_current_render_process()
	
	# create directories if they don't exist yet
	# set log directory
	var dir : Directory = Directory.new()
	log_data_path = RRPaths.get_job_log_path(job_id)
	var thumbnails_path : String = RRPaths.get_job_thumbnail_path(job_id)
	
	if !dir.dir_exists(log_data_path):
		dir.make_dir_recursive(log_data_path)
	
	if !dir.dir_exists(thumbnails_path):
		dir.make_dir_recursive(thumbnails_path)
	
	
	match platform:
		
		# Linux
		"X11" : 
			
			var output : Array = []
			var arguments : Array = ["-c", cmdline_instruction + " > " + full_log_file_path + " 2>&1"] # 2>&1  redirects the "stderr" stream (2) to the "stdout" stream (1). Otherwise the errors will not be included in the output file.
			
			# this will only be the process id of the process that starts the render process. Unfortunately we don't get the process id of the render process itself.
			invoked_render_pid = OS.execute("bash", arguments, false, output) # important to make this non blocking
			
		# Windows
		"Windows" :
			
			# unix style redirecting works in windows as well:  2>&1 redirects the "stderr" stream (2) to the "stdout" stream (1), so we can log both at the same time.
			# Unfortunately under windows the stdout and stderr outputs will be wildly mixed up in no chronological order if we use this unix style syntax. That's very problematic.
			# That's why we need another solution to save the outputs in a log file.
			# So instead we use a third-party software called "LoggingUtil" (https://github.com/lordmulder/LoggingUtil). It sits inbetween and correctly writes the logs files.
			var output : Array = []
			var arguments : Array = ['/C', RRPaths.windows_logging_util_path + " --plain-output --no-append --logfile " + full_log_file_path + " : " + cmdline_instruction ] 
			
			# this will only be the process id of the process that starts the render process. Unfortunately we don't get the process id of the render process itself.
			invoked_render_pid = OS.execute('CMD.exe', arguments, false, output) # important to make this non blocking
	
	
	print("executing: " + cmdline_instruction)
	
	current_commandline_instructions = cmdline_instruction
	current_commandline_instructions_without_executable = cmdline_instruction_without_executable
	
	currently_rendering = true
	
	active_render_log_file_path = full_log_file_path
	file_pointer_position = 0
	read_log_timer.start()




func check_if_render_process_is_running() -> bool:
	
	match platform:
		
		# Linux
		"X11" : 
			
			# this command will retun 0 if the process id exists, and something else, if it doesn't exist
			#var output : Array = []
			#var arguments : Array = ["-c","kill -0 " + String(invoked_render_pid) + " && echo \"$?\""]
			#OS.execute("bash", arguments, true, output)
			
			
			# get the list of all pids
			var output : Array = []
			var arguments : Array = ["-c","ps ax"]
			
			var get_all_pids_pid : int = OS.execute("bash", arguments, true, output)
			
			# split the resulting string in lines (each line one pid)
			var splitted_output : Array = output[0].split('\n', false, 0)  
			
			var num_of_found_processes : int = 0
			
			for pid_line in splitted_output:
				
				# now search in the pids for the command line without the executable path and count the number of matches.
				# Because for example if the executable is a shell script that links to another location, the path of the actual renderprocess might actually change while we would still search for the wrong one.
				if pid_line.find(current_commandline_instructions_without_executable) != -1:
					num_of_found_processes += 1
			
			# if we have less than two processes (the invoking + the actual render process) that contain the "command line" string in it's name, the render process has exited
			if num_of_found_processes > 1:
				currently_rendering = true
				return true
				
			else:
				currently_rendering = false
				
				if RenderLogValidator.CRP_software_start_success_detected:
					# This is delayed to make sure that the log validation has time to detect the success message before it starts a new render process and thus looking in the wrong log file
					# The delay has to be a bit bigger than the read_log_timer wait time
					delayed_detect_render_process_exited(1.2)
				else:
					read_log_timer.stop()
					emit_signal("render_process_exited_without_software_start")
				return false
				
	return false



func kill_current_render_process():
	
	read_log_timer.stop()
	
	# kill the process that started the render process
	OS.kill(invoked_render_pid)
	
	# Now find and kill the actual render process that has been invoked by "invoked_render_pid" process
	# First we get the list of all pids
	var output : Array = []
	var arguments : Array = ["-c","ps ax"]
	
	var get_all_pids_pid : int = OS.execute("bash", arguments, true, output)
	
	# split the resulting string in lines (each line one pid)
	var splitted_output : Array = output[0].split('\n', false, 0)  
		
	for pid_line in splitted_output:
		
		# We will have to search in the pids for the command line without the executable path. 
		# Because for example if the executable is a shell script that links to another location, the path of the actual renderprocess might actually change while we would still search for the wrong one.
		if pid_line.find(current_commandline_instructions_without_executable) != -1:
			
			# split line by spaces to extract the pid number
			var splitted_line : Array = pid_line.split(' ', false, 0)
			var pid : int = int(splitted_line[0])
			
			print("killing pid: " + String(pid))
			OS.kill(pid)
			emit_signal("render_process_exited")


# This is delayed to make sure that the log validation has time to detect the success message before it starts a new render process and thus looking in the wrong log file
func delayed_detect_render_process_exited(delay_sec : float):
	delayed_exited_timer.set_wait_time(delay_sec) # Set Timer's delay to "sec" seconds
	delayed_exited_timer.start() # Start the Timer counting down
	yield( delayed_exited_timer, "timeout") # Wait for the timer to wind down
	
	# Stuff to happen when delay hit the timeout
	read_log_timer.stop()
	currently_rendering = false
	emit_signal("render_process_exited")
