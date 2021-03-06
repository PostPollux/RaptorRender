#////////////////#
# ChunkTimeGraph #
#////////////////#

# The ChunkTimeGraph is the ChunkTimeBarGraph plus an additional info box 
# that shows some infos for the hovered chunk.
# This script mainly handles the filling of the info box.


extends MarginContainer

### PRELOAD RESOURCES

### SIGNALS

### ONREADY VARIABLES 
onready var HeadingLabel : Label = $"VBoxContainer/HeaderContainer/HeadingLabel"
onready var BarGraph = $"VBoxContainer/ChunkTimeBarGraph"
onready var ChunkNameLabel : Label = $"VBoxContainer/ClipContainer/ChunkInfoBox/VBoxContainer/HBoxContainer/ChunkNameLabel"
onready var ChunkClientLabel : Label = $"VBoxContainer/ClipContainer/ChunkInfoBox/VBoxContainer/HBoxContainer2/ChunkClientLabel"
onready var ChunkRendertimeLabel : Label = $"VBoxContainer/ClipContainer/ChunkInfoBox/VBoxContainer/HBoxContainer3/ChunkRendertimeLabel"
onready var ChunkTriesLabel : Label = $"VBoxContainer/ClipContainer/ChunkInfoBox/VBoxContainer/HBoxContainer4/ChunkTriesLabel"
onready var ChunkNameValueLabel : Label = $"VBoxContainer/ClipContainer/ChunkInfoBox/VBoxContainer/HBoxContainer/ChunkNameValueLabel"
onready var ChunkClientValueLabel : Label = $"VBoxContainer/ClipContainer/ChunkInfoBox/VBoxContainer/HBoxContainer2/ChunkClientValueLabel"
onready var ChunkRendertimeValueLabel : Label = $"VBoxContainer/ClipContainer/ChunkInfoBox/VBoxContainer/HBoxContainer3/ChunkRendertimeValueLabel"
onready var ChunkTriesValueLabel : Label = $"VBoxContainer/ClipContainer/ChunkInfoBox/VBoxContainer/HBoxContainer4/ChunkTriesValueLabel"
onready var ChunkInfoBox = $"VBoxContainer/ClipContainer/ChunkInfoBox"
onready var GraphOptions = $"GraphOptions"
onready var AccumulateTriesCheckBox : CheckBox = $"GraphOptions/MarginContainer/VBoxContainer/AccumulateTriesCheckBox"

### EXPORTED VARIABLES

### VARIABLES
var job_id : int = -1
var hovered_chunk : int





########## FUNCTIONS ##########



func _ready() -> void:
	
	GraphOptions.visible = false
	
	HeadingLabel.text = "JOB_CHUNK_TIME_GRAPH_1" # Chunk Time Graph
	
	ChunkNameLabel.text = "JOB_CHUNK_TIME_GRAPH_2" # Chunk
	ChunkClientLabel.text = "JOB_CHUNK_TIME_GRAPH_3" # Client
	ChunkRendertimeLabel.text = "JOB_CHUNK_TIME_GRAPH_4" # Time
	ChunkTriesLabel.text = "JOB_CHUNK_TIME_GRAPH_5" # Tries
	
	AccumulateTriesCheckBox.text = "JOB_CHUNK_TIME_GRAPH_6" # Accumulate Tries
	
	# connect signals
	BarGraph.connect("chunk_hovered", self, "fill_chunk_info_box")


func set_job_id(job_ID : int) -> void:
	job_id = job_ID
	BarGraph.job_id = job_ID
	
	
func fill_chunk_info_box(chunk_number : int) -> void:
	
	hovered_chunk = chunk_number
	
	var chunk_dict : Dictionary = RaptorRender.rr_data.jobs[job_id].chunks[chunk_number]
	var number_of_tries : int = chunk_dict.number_of_tries
	
	# chunk name
	
	var first_chunk_frame : int = chunk_dict.frame_start
	var last_chunk_frame : int = chunk_dict.frame_end
	
	if first_chunk_frame == last_chunk_frame:
		ChunkNameValueLabel.text = String (chunk_number) + "  (Frame: " + String(first_chunk_frame) + ")"
	else:
		ChunkNameValueLabel.text = String (chunk_number) + "  (" +  String(first_chunk_frame) + " - " + String(last_chunk_frame) + ")" 
	
	
	# chunk client
	if number_of_tries > 0:
		if BarGraph.accumulate_tries:
			
			# initialize client with the name of the client of the first try
			var client : String = RaptorRender.rr_data.clients[ chunk_dict.tries[1].client ].machine_properties.name
			for try in range(1, number_of_tries + 1):
				if RaptorRender.rr_data.clients[ chunk_dict.tries[try].client ].machine_properties.name != client:
					client = tr("JOB_CHUNK_TIME_GRAPH_8")
					
			ChunkClientValueLabel.text = client
			
		else:
			var client_id : int = chunk_dict.tries[number_of_tries].client
			if RaptorRender.rr_data.clients.has(client_id):
				ChunkClientValueLabel.text = RaptorRender.rr_data.clients[ client_id ].machine_properties.name
			else:
				ChunkClientValueLabel.text = tr("UNKNOWN")
	else:
		ChunkClientValueLabel.text = "-" 
	
	
	# chunk render time
	var chunk_rendertime : int = 0
	
	if chunk_dict.status == RRStateScheme.chunk_finished: 
		if number_of_tries > 0:
			if BarGraph.accumulate_tries:
				for try in range(1, number_of_tries + 1):
					chunk_rendertime +=  chunk_dict.tries[try].time_stopped - chunk_dict.tries[try].time_started
			else:
				chunk_rendertime =  chunk_dict.tries[number_of_tries].time_stopped - chunk_dict.tries[number_of_tries].time_started
		else:
			chunk_rendertime = 1
		
		if BarGraph.accumulate_tries and number_of_tries > 1:
			ChunkRendertimeValueLabel.text = TimeFunctions.seconds_to_string(chunk_rendertime,3) + " (" + tr("JOB_CHUNK_TIME_GRAPH_7") + ")"
		else:
			ChunkRendertimeValueLabel.text = TimeFunctions.seconds_to_string(chunk_rendertime,3)
			
	elif chunk_dict.status == RRStateScheme.chunk_rendering:
		
		if number_of_tries > 0:
			if BarGraph.accumulate_tries:
				for try in range(1, number_of_tries + 1):
					if chunk_dict.tries[try].status == RRStateScheme.try_rendering:
						chunk_rendertime +=  OS.get_unix_time() - chunk_dict.tries[try].time_started
					else:
						chunk_rendertime +=  chunk_dict.tries[try].time_stopped - chunk_dict.tries[try].time_started
		
		if BarGraph.accumulate_tries and number_of_tries > 1:
			ChunkRendertimeValueLabel.text = TimeFunctions.seconds_to_string(chunk_rendertime,3) + " (" + tr("JOB_CHUNK_TIME_GRAPH_7") + ")"
		else:
			ChunkRendertimeValueLabel.text = TimeFunctions.seconds_to_string(chunk_rendertime,3)
	
	else:
		ChunkRendertimeValueLabel.text =  "-"
	
	
	# chunk tries
	
	ChunkTriesValueLabel.text = String( RaptorRender.rr_data.jobs[job_id].chunks[chunk_number].number_of_tries)



# reset labels if mouse leaves the graph
func _on_BarGraph_mouse_exited() -> void:
	ChunkNameValueLabel.text = ""
	ChunkClientValueLabel.text = "" 
	ChunkRendertimeValueLabel.text =  ""
	ChunkTriesValueLabel.text = ""



func _on_OptionsButton_pressed() -> void:
	if GraphOptions.visible:
		GraphOptions.visible = false
	else:
		GraphOptions.visible = true


func _on_AccumulateTriesCheckBox_toggled(toggle_value) -> void:
	GraphOptions.visible = false
	BarGraph.accumulate_tries = toggle_value

