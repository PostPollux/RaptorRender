extends MarginContainer


### PRELOAD RESOURCES

### SIGNALS
signal cancel_pressed
signal ok_pressed
signal popup_shown
signal popup_hidden

### ONREADY VARIABLES

### EXPORTED VARIABLES

### VARIABLES
var popup_base : AutoScalingPopup




########## FUNCTIONS ##########


func cancel_pressed() -> void:
	emit_signal("cancel_pressed")

func ok_pressed() -> void:
	emit_signal("ok_pressed")

func popup_shown() -> void:
	emit_signal("popup_shown")

func popup_hidden() -> void:
	emit_signal("popup_hidden")
