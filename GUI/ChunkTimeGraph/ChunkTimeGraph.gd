extends VBoxContainer

var job_id = ""
var chunk

# references to other nodes of sortable table
onready var BarGraph = $"BarGraph"
onready var ChunkNameLabel = $"ChunkInfoBox/MarginContainer/VBoxContainer/ChunkNameLabel"
onready var ChunkFramesLabel = $"ChunkInfoBox/MarginContainer/VBoxContainer/ChunkFramesLabel"
onready var ChunkClientLabel = $"ChunkInfoBox/MarginContainer/VBoxContainer/ChunkClientLabel"
onready var ChunkRendertimeLabel = $"ChunkInfoBox/MarginContainer/VBoxContainer/ChunkRendertimeLabel"
onready var ChunkTriesLabel = $"ChunkInfoBox/MarginContainer/VBoxContainer/ChunkTriesLabel"




func _ready():
	
	BarGraph.connect("chunk_hovered", self, "fill_chunk_info_box")


func set_job_id(job_ID):
	job_id = job_ID
	BarGraph.job_id = job_ID
	
	
func fill_chunk_info_box(chunk_number):
	
	chunk = chunk_number
	
	# chunk name
	ChunkNameLabel.text = "Chunk:  " + String (chunk_number)
	
	
	# chunk frames
	
	var first_chunk_frame = RaptorRender.rr_data.jobs[job_id].chunks[String(chunk_number)].frames[0]
	var last_chunk_frame = RaptorRender.rr_data.jobs[job_id].chunks[String(chunk_number)].frames[ RaptorRender.rr_data.jobs[job_id].chunks[String(chunk_number)].frames.size() - 1]
	
	if first_chunk_frame == last_chunk_frame:
		ChunkFramesLabel.text = "Frame: " + String(first_chunk_frame)
	else:
		ChunkFramesLabel.text = "Frames: " + String(first_chunk_frame) + " - " + String(last_chunk_frame)
	
	
	# chunk client
	if  RaptorRender.rr_data.jobs[job_id].chunks[String(chunk_number)].client == "":
		ChunkClientLabel.text = "Client:  None assigned yet" 
	else:
		ChunkClientLabel.text = "Client:  " + RaptorRender.rr_data.clients[ RaptorRender.rr_data.jobs[job_id].chunks[String(chunk_number)].client ].name
		
	
	# chunk render time
	var chunk_dict = RaptorRender.rr_data.jobs[job_id].chunks[String(chunk_number)]
	
	var chunk_rendertime = 0
	
	if chunk_dict.status == "5_finished": 
		chunk_rendertime =  chunk_dict.time_finished - chunk_dict.time_started
		ChunkRendertimeLabel.text = "Time rendered:  " + TimeFunctions.seconds_to_string(chunk_rendertime,3)
		
	elif chunk_dict.status == "1_rendering":
		chunk_rendertime = OS.get_unix_time() - chunk_dict.time_started
		ChunkRendertimeLabel.text = "Time rendered:  " + TimeFunctions.seconds_to_string(chunk_rendertime,3)
	
	else:
		ChunkRendertimeLabel.text =  "Time rendered:  -"
		
	
	
	
	# chunk tries
	
	ChunkTriesLabel.text = "Tries:  " + String( RaptorRender.rr_data.jobs[job_id].chunks[String(chunk_number)].number_of_tries)