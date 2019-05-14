#////////////////////#
# CommandlineManager #
#////////////////////#

# This script handles 
# - execute a commandline render instruction in a separate processes and redirect it's output into a file
# - continuously read and monitor the output file while rendering to detect errors and successes
# - abort rendering by killing the process



extends Node



var invoke_render_pid : int 

var current_redirected_output_file : File
var current_commandline_instructions : String

var file_pointer_position : int = 0

var read_redirected_output_file_thread : Thread


var log_data_dir_str : String

var currently_rendering : bool = false

var get_cmd_line_output_timer : Timer 




func _ready():
	
	# save user data directory to a variable
	log_data_dir_str = OS.get_user_data_dir() + "/logs/"
	
	
	# create logs directory if it doesn't exist yet
	var log_data_dir : Directory = Directory.new()
	
	if !log_data_dir.dir_exists(log_data_dir_str):
		log_data_dir.make_dir(log_data_dir_str)
		
	
	# create timer to constantly read the current output log in a specific interval 
	get_cmd_line_output_timer = Timer.new()
	get_cmd_line_output_timer.name = "Command Line Output Timer"
	get_cmd_line_output_timer.wait_time = 1
	get_cmd_line_output_timer.connect("timeout",self,"_on_get_cmd_line_output_timer_timeout")
	var root_node : Node = get_tree().get_root().get_node("RaptorRenderMainScene")
	if root_node != null:
		root_node.add_child(get_cmd_line_output_timer)
	


func _on_get_cmd_line_output_timer_timeout():
	
	pass


func start_render_process (cmdline_instruction : String, output_file_name : String):
	
	if currently_rendering:
		kill_current_render_process()
		
	else:
		var output : Array = []
		var arguments : Array = ["-c", cmdline_instruction + " > " + log_data_dir_str + output_file_name + ".txt 2>&1"]
		
		invoke_render_pid = OS.execute("bash", arguments, false, output) # important to make this non blocking
		
		current_commandline_instructions = cmdline_instruction
		
		currently_rendering = true
		
		get_cmd_line_output_timer.start()




func check_if_render_process_is_running() -> bool:
	
	# this will retun 0 if the process exists, and something else, if it doesn't exist
	var output : Array = []
	var arguments : Array = ["-c","kill -0 " + String(invoke_render_pid) + " && echo \"$?\""]
	OS.execute("bash", arguments, true, output)
	
	if output[0].begins_with("0"):
		currently_rendering = true
		return true
	else:
		currently_rendering = false
		get_cmd_line_output_timer.stop()
		return false




func kill_current_render_process():
	
	get_cmd_line_output_timer.stop()
	
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

