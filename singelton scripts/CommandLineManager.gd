#////////////////////#
# CommandlineManager #
#////////////////////#

# This script handles 
# - executing a commandline render instruction in a separate processes and redirect it's output into a file
# - continuously read and monitor the output file while rendering to detect errors and successes
# - abort rendering by killing the process



extends Node



var invoke_render_pid : int 

var active_render_log_file : File
var current_commandline_instructions : String

var file_pointer_position : int = 0

var read_log_file_thread : Thread

var active_render_log_file_name : String

var log_data_dir_str : String

var currently_rendering : bool = false

var read_log_timer : Timer 


signal log_partly_read


func _ready():
	
	
	log_data_dir_str = OS.get_user_data_dir() + "/logs/"
	
	
	# create logs directory if it doesn't exist yet
	var log_data_dir : Directory = Directory.new()
	
	if !log_data_dir.dir_exists(log_data_dir_str):
		log_data_dir.make_dir(log_data_dir_str)
		
	# create the thread this script is using
	read_log_file_thread = Thread.new()
	
	# initialize file object
	active_render_log_file = File.new()
	
	# create timer to constantly read the current render log in a specific interval 
	read_log_timer = Timer.new()
	read_log_timer.name = "Read Log Timer"
	read_log_timer.wait_time = 1
	read_log_timer.connect("timeout",self,"_on_read_log_timer_timeout")
	var root_node : Node = get_tree().get_root().get_node("RaptorRenderMainScene")
	if root_node != null:
		root_node.add_child(read_log_timer)
	


func _on_read_log_timer_timeout():
	start_read_log_file_thread()


func start_read_log_file_thread():
	if read_log_file_thread.is_active():
		# stop here if already working
		return
		
	# start the thread	
	read_log_file_thread.start(self, "validate_log_file","")



func validate_log_file(args):
	
	var active_render_log_file_path : String = OS.get_user_data_dir() + "/logs/" + active_render_log_file_name + ".txt"
	
	var lines_read : String = ""
	
	if active_render_log_file.file_exists(active_render_log_file_path):
		
		active_render_log_file.open(active_render_log_file_path, 1)
		
		active_render_log_file.seek(file_pointer_position)
		
		
		while true:
			var line : String = active_render_log_file.get_line()
			
			RenderLogValidator.validate_log_line(line)
			
			
			line = RenderLogValidator.highlight_log_line(line)
			
			lines_read += line
			
			
			
			# break loop if end of file is reached
			if active_render_log_file.eof_reached():
				file_pointer_position = active_render_log_file.get_position()
				break
			
			# add new line break if end of file is not reached yet
			lines_read += "\n"
		
	
	emit_signal("log_partly_read", lines_read)
	
	# call_deferred has to call another function in order to join the thread with the main thread. Otherwise it will just stay active.
	call_deferred("join_read_log_file_thread")


func join_read_log_file_thread():
	# this will effectively stop the thread
	read_log_file_thread.wait_to_finish()



func start_render_process (cmdline_instruction : String, log_file_name : String):
	
	if currently_rendering:
		kill_current_render_process()
		
	else:
		var output : Array = []
		var arguments : Array = ["-c", cmdline_instruction + " > " + log_data_dir_str + log_file_name + ".txt 2>&1"]
		
		invoke_render_pid = OS.execute("bash", arguments, false, output) # important to make this non blocking
		
		current_commandline_instructions = cmdline_instruction
		
		currently_rendering = true
		
		active_render_log_file_name = log_file_name
		file_pointer_position = 0
		read_log_timer.start()




func check_if_render_process_is_running() -> bool:
	
	# this command will retun 0 if the process id exists, and something else, if it doesn't exist
	var output : Array = []
	var arguments : Array = ["-c","kill -0 " + String(invoke_render_pid) + " && echo \"$?\""]
	OS.execute("bash", arguments, true, output)
	
	if output[0].begins_with("0"):
		currently_rendering = true
		return true
	else:
		currently_rendering = false
		read_log_timer.stop()
		return false




func kill_current_render_process():
	
	read_log_timer.stop()
	
	OS.kill(invoke_render_pid)
	
	var output : Array = []
	var arguments : Array = ["-c","ps ax | grep \"" + current_commandline_instructions + "\""]
	OS.execute("bash", arguments, true, output)
			
	# split String in lines
	var splitted_output : Array = output[0].split('\n', false, 0)  
		
	for line in splitted_output:
		
		#split line by spaces
		var splitted_line : Array = line.split(' ', false, 0)
		var pid : int = int(splitted_line[0])
		OS.kill(pid)
	
	currently_rendering = false
