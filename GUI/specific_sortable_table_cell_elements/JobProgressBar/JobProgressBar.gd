extends MarginContainer


onready var BarActive = $"ColorRect_active"
onready var BarFinished = $"ColorRect_finished"
onready var ProgressLabel = $"ProgressLabel"

var CellContainer
var in_sortable_table = false

var chunks_total = 3
var chunks_finished = 1
var chunks_active = 1
var job_status = "normal"

func _ready():
	
	# only connect the size to the parent cell if it is part of a Sortable Table
	if in_sortable_table:
		CellContainer = get_parent().get_parent()
		CellContainer.connect("resized", self, "resize")
		# set correct size
		rect_min_size.x = CellContainer.rect_min_size.x - 5
		
	match_color_to_status()
	show_progress()
	
	
	
func resize():
	# set correct size
	rect_min_size.x = CellContainer.rect_min_size.x - 5
	show_progress()
	

func set_chunks (total, finished, active):
	chunks_total = total
	chunks_finished = finished
	chunks_active = active
	
	
func match_color_to_status():
	match job_status:
		"normal": BarFinished.set_color_finished()
		"paused": BarFinished.set_color_paused()
		"cancelled": BarFinished.set_color_cancelled()
	
	
func show_progress():
	
	
	var total_bar_size = rect_min_size.x - 4  # 4 because of margin left and right
	
	var bar_active_size = total_bar_size * (chunks_active + chunks_finished) / chunks_total 
	
	BarActive.rect_min_size.x = bar_active_size
	
	
	
	var bar_finished_size = float(total_bar_size) * float(chunks_finished) / float(chunks_total) 
	
	BarFinished.rect_min_size.x = bar_finished_size 
	
	
	ProgressLabel.text = String( int( float(chunks_finished) / float(chunks_total) * 100.0 ) ) + " %"
	
	



