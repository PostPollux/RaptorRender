extends ColorRect


### PRELOAD RESOURCES

### SIGNALS

### ONREADY VARIABLES

### EXPORTED VARIABLES

### VARIABLES
var color_finished : Color = RRColorScheme.state_finished_or_online
var color_finished_paused : Color = RRColorScheme.state_paused
var color_finished_cancelled : Color = RRColorScheme.state_offline_or_cancelled





########## FUNCTIONS ##########


func _ready() -> void:
	self.color = color_finished

func set_color_finished () -> void:
	self.color = color_finished
	
func set_color_paused () -> void:
	self.color = color_finished_paused

func set_color_cancelled () -> void:
	self.color = color_finished_cancelled

