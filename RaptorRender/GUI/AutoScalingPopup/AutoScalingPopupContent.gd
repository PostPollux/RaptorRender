extends MarginContainer


### PRELOAD RESOURCES

### SIGNALS
signal cancel_pressed
signal ok_pressed
signal popup_shown
signal popup_hided

### ONREADY VARIABLES

### EXPORTED VARIABLES

### VARIABLES





########## FUNCTIONS ##########


func cancel_pressed() -> void:
	emit_signal("cancel_pressed")

func ok_pressed() -> void:
	emit_signal("ok_pressed")

func popup_shown() -> void:
	emit_signal("popup_shown")

func popup_hided() -> void:
	emit_signal("popup_hided")
