extends ColorRect

export (Color) var color_finished = Color("73ae43")
export (Color) var color_finished_paused = Color("838383")
export (Color) var color_finished_cancelled = Color("181818")

func _ready():
	self.color = color_finished
	
func set_color_paused ():
	self.color = color_finished_paused

func set_color_cancelled ():
	self.color = color_finished_cancelled

