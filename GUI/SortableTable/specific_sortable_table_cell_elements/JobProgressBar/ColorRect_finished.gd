extends ColorRect

var color_finished : Color = RRColorScheme.state_finished_or_online
var color_finished_paused :Color = RRColorScheme.state_paused
var color_finished_cancelled :Color = RRColorScheme.state_offline_or_cancelled

func _ready():
	self.color = color_finished

func set_color_finished ():
	self.color = color_finished
	
func set_color_paused ():
	self.color = color_finished_paused

func set_color_cancelled ():
	self.color = color_finished_cancelled

