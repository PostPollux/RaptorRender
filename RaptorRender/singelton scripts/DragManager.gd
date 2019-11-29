#/////////////#
# Drag Manager#
#/////////////#

# This script simply fires a "drag_ended" signal, as soon as the mousebutton has been released.

extends Node



### PRELOAD RESOURCES

### SIGNALS
signal drag_ended


### ONREADY VARIABLES

### EXPORTED VARIABLES

### VARIABLES
var currently_dragging : bool = false




########## FUNCTIONS ##########
	
func _input(event):
	
	if currently_dragging:
		if Input.is_action_just_released("ui_left_mouse_button"):
			emit_signal("drag_ended")
			currently_dragging = false
