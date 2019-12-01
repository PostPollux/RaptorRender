extends Node


### PRELOAD RESOURCES

### SIGNALS

### ONREADY VARIABLES

### EXPORTED VARIABLES

### VARIABLES
var raptor_render_network_directory : String

var connected_server_id : int

var base_data_path : String

var jobs_data_path : String
var clients_data_path : String
var job_types_default_path : String





########## FUNCTIONS ##########


func _ready():
	set_directories("/home/johannes/Schreibtisch/", 1234567890)



func set_directories(base_path : String, server_id : int):
	
	raptor_render_network_directory = base_path
	
	connected_server_id = server_id
	
	# set paths
	base_data_path = raptor_render_network_directory + "RaptorRender_data/" + String(connected_server_id) + "/"
	
	jobs_data_path = base_data_path + "jobs_data/"
	clients_data_path = base_data_path + "clients_data/"
	
	job_types_default_path = base_data_path + "default_settings/" + "job_types/"
	
	
	# create directories if they don't exist
	var dir : Directory = Directory.new()
	
	if not dir.dir_exists(jobs_data_path):
		dir.make_dir_recursive(jobs_data_path)
	
	if not dir.dir_exists(clients_data_path):
		dir.make_dir_recursive(clients_data_path)
	
	if not dir.dir_exists(job_types_default_path):
		dir.make_dir_recursive(job_types_default_path)
		


func get_job_log_path(job_id : int) -> String:
	
	var path : String = jobs_data_path + "<id>/" + "logs/"
	path = path.replace("<id>", String(job_id))
	
	return path


func get_job_thumbnail_path(job_id : int) -> String:
	
	var path : String = jobs_data_path + "<id>/" + "thumbnails/"
	path = path.replace("<id>", String(job_id))
	
	return path
