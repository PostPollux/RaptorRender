#////////////////////#
# ReadLogFileManager #
#////////////////////#

# This script handles the read process of a log file in a separate thread.
# Depending on the chunk status, it will automatically decide if a log file has to be read constantly or just once.
# It will read the log file, send it to RenderLogValidator.gd to colorize the lines correctly and when it reaches the end of file,
# it sends the "log_read_to_end_of_file" signal which carries the final string



extends Node


### PRELOAD RESOURCES

### SIGNALS
signal log_read_to_end_of_file
signal no_log_file_found

### ONREADY VARIABLES

### EXPORTED VARIABLES

### VARIABLES
var LogFile : File

var log_job_id : int
var log_chunk_id : int
var log_try_id : int

var read_log_file_thread : Thread

var read_log_timer : Timer 

var file_pointer_position : int = 0





########## FUNCTIONS ##########


# Called when the node enters the scene tree for the first time.
func _ready():

	# create the thread this script is using
	read_log_file_thread = Thread.new()
	
	# initialize file object
	LogFile = File.new()
	
	# create timer to constantly read the current render log in a specific interval (only used when the chunk is actively rendered)
	read_log_timer = Timer.new()
	read_log_timer.name = "Read Log Timer 2"
	read_log_timer.wait_time = 1
	read_log_timer.connect("timeout", self, "start_read_log_file_thread")
	var root_node : Node = get_tree().get_root().get_node("RaptorRenderMainScene")
	if root_node != null:
		root_node.add_child(read_log_timer)



func reset_file_pointer_position():
	file_pointer_position = 0


func stop_read_log_timer():
	read_log_timer.stop()


func read_log_file(job_id : int, chunk_id : int, try_id : int):
	log_job_id = job_id
	log_chunk_id = chunk_id
	log_try_id = try_id
	
	if log_job_id != 0 and log_chunk_id != 0 and log_try_id != 0:
		if RaptorRender.rr_data.jobs.has(log_job_id):
			# start timer to constantly look for updates when chunk status is "rendering" and we are looking at the last try
			if RaptorRender.rr_data.jobs[log_job_id].chunks[log_chunk_id].status == RRStateScheme.chunk_rendering and log_try_id == RaptorRender.rr_data.jobs[log_job_id].chunks[log_chunk_id].number_of_tries:
				read_log_timer.start()
				
			# otherwise just read it once
			else:
				start_read_log_file_thread()


func start_read_log_file_thread():
	if read_log_file_thread.is_active():
		# stop here if already working
		return
		
	# start the thread
	read_log_file_thread.start(self, "read_and_colorize_log_file","")



func read_and_colorize_log_file(args):
	
	
	
	# set RenderLogValidator to the corresponding software type to enable a correct log line colorization
	var job_type : String = RaptorRender.rr_data.jobs[log_job_id].type
	var job_type_version : String = RaptorRender.rr_data.jobs[log_job_id].type_version
	RenderLogValidator.load_job_type_settings_HIGHLIGHT(job_type, job_type_version)
	
	# generate correct file path
	var filename : String = "chunk_" + String(log_chunk_id) + "_try_" + String(log_try_id) + ".txt"
	var filepath : String = RRPaths.get_job_log_path(log_job_id) + filename
	
	var lines_read : String = ""
	
	if LogFile.file_exists(filepath):
		
		LogFile.open(filepath, 1)
		
		LogFile.seek(file_pointer_position)
		
		while true:
			var line : String = LogFile.get_line()
			
			line = RenderLogValidator.highlight_log_line(line)
			
			lines_read += line
			
			# break loop if end of file is reached
			if LogFile.eof_reached():
				file_pointer_position = LogFile.get_position()
				break
			
			# add new line break if end of file is not reached yet
			lines_read += "\n"
		
	else:
		emit_signal("no_log_file_found")
	
	emit_signal("log_read_to_end_of_file", lines_read)
		
	# call_deferred has to call another function in order to join the thread with the main thread. Otherwise it will just stay active.
	call_deferred("join_read_log_file_thread")



func join_read_log_file_thread():
	# this will effectively stop the thread
	read_log_file_thread.wait_to_finish()
