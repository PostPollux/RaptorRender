#////////////////#
# ChunkTimeGraph #
#////////////////#

# The ChunkTimeGraph is the ChunkTimeBarGraph plus an additional info box 
# that shows some infos for the hovered chunk.
# This script mainly handles the filling of the info box.


extends MarginContainer

var job_id : int = -1
var hovered_chunk : int

# references to other nodes of ChunkTimeGraph
onready var BarGraph = $"VBoxContainer/ChunkTimeBarGraph"
onready var ChunkNameLabel : Label = $"VBoxContainer/ClipContainer/ChunkInfoBox/VBoxContainer/HBoxContainer/ChunkNameValueLabel"
onready var ChunkClientLabel : Label = $"VBoxContainer/ClipContainer/ChunkInfoBox/VBoxContainer/HBoxContainer2/ChunkClientValueLabel"
onready var ChunkRendertimeLabel : Label = $"VBoxContainer/ClipContainer/ChunkInfoBox/VBoxContainer/HBoxContainer3/ChunkRendertimeValueLabel"
onready var ChunkTriesLabel : Label = $"VBoxContainer/ClipContainer/ChunkInfoBox/VBoxContainer/HBoxContainer4/ChunkTriesValueLabel"
onready var ChunkInfoBox = $"VBoxContainer/ClipContainer/ChunkInfoBox"
onready var GraphOptions = $"GraphOptions"




func _ready():
	
	GraphOptions.visible = false
	
	# connect signals
	BarGraph.connect("chunk_hovered", self, "fill_chunk_info_box")


func set_job_id(job_ID : int):
	job_id = job_ID
	BarGraph.job_id = job_ID
	
	
func fill_chunk_info_box(chunk_number : int):
	
	hovered_chunk = chunk_number
	
	# chunk name
	
	var first_chunk_frame : int = RaptorRender.rr_data.jobs[job_id].chunks[chunk_number].frame_start
	var last_chunk_frame : int = RaptorRender.rr_data.jobs[job_id].chunks[chunk_number].frame_end
	
	if first_chunk_frame == last_chunk_frame:
		ChunkNameLabel.text = String (chunk_number) + "  (Frame: " + String(first_chunk_frame) + ")"
	else:
		ChunkNameLabel.text = String (chunk_number) + "  (" +  String(first_chunk_frame) + " - " + String(last_chunk_frame) + ")" 
	
	
	# chunk client
	var number_of_tries : int = RaptorRender.rr_data.jobs[job_id].chunks[chunk_number].number_of_tries
	if number_of_tries > 0:
		if  RaptorRender.rr_data.jobs[job_id].chunks[chunk_number].tries[number_of_tries].client == -1:
			ChunkClientLabel.text = "-" 
		else:
			ChunkClientLabel.text = RaptorRender.rr_data.clients[ RaptorRender.rr_data.jobs[job_id].chunks[chunk_number].tries[number_of_tries].client ].name
	
	
	# chunk render time
	var chunk_dict : Dictionary = RaptorRender.rr_data.jobs[job_id].chunks[chunk_number]
	
	var chunk_rendertime : int = 0
	
	if chunk_dict.status == RRStateScheme.chunk_finished: 
		chunk_rendertime =  chunk_dict.tries[number_of_tries].time_finished - chunk_dict.tries[number_of_tries].time_started
		ChunkRendertimeLabel.text = TimeFunctions.seconds_to_string(chunk_rendertime,3)
		
	elif chunk_dict.status == RRStateScheme.chunk_rendering:
		chunk_rendertime = OS.get_unix_time() - chunk_dict.tries[number_of_tries].time_started
		ChunkRendertimeLabel.text = TimeFunctions.seconds_to_string(chunk_rendertime, 3)
	
	else:
		ChunkRendertimeLabel.text =  "-"
	
	
	# chunk tries
	
	ChunkTriesLabel.text = String( RaptorRender.rr_data.jobs[job_id].chunks[chunk_number].number_of_tries)



# reset labels if mouse leaves the graph
func _on_BarGraph_mouse_exited():
	ChunkNameLabel.text = ""
	ChunkClientLabel.text = "" 
	ChunkRendertimeLabel.text =  ""
	ChunkTriesLabel.text = ""




func _on_OptionsButton_pressed():
	if GraphOptions.visible:
		GraphOptions.visible = false
	else:
		GraphOptions.visible = true


func _on_AccumulateTriesCheckBox_toggled(button_pressed):
	GraphOptions.visible = false
	RaptorRender.NotificationSystem.add_error_notification(tr("MSG_ERROR_1"), tr("MSG_ERROR_2"), 5) # Not implemented yet

