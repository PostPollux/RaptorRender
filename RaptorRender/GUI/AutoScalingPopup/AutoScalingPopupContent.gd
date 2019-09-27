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


func cancel_pressed():
	emit_signal("cancel_pressed")

func ok_pressed():
	emit_signal("ok_pressed")

func popup_shown():
	emit_signal("popup_shown")

func popup_hided():
	emit_signal("popup_hided")