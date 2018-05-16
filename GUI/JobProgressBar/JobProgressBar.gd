extends MarginContainer


onready var BarActive = $"ColorRect_active"
onready var BarFinished = $"ColorRect_finished"



var chunks_total = 3
var chunks_finished = 1
var chunks_active = 1


func _ready():
	
	show_progress()



func set_chunks (total, finished, active):
	chunks_total = total
	chunks_finished = finished
	chunks_active = active
	
	
	
func show_progress():
	
	var total_bar_size = rect_min_size.x
	
	var bar_active_size = total_bar_size * (chunks_active + chunks_finished) / chunks_total 
	
	BarActive.rect_min_size.x = bar_active_size
	
	
	
	var bar_finished_size = total_bar_size * chunks_finished / chunks_total 
	
	BarFinished.rect_min_size.x = bar_finished_size
	
	
	
	
#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass


