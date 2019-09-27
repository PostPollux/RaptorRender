extends CheckBox

### PRELOAD RESOURCES

### SIGNALS

### ONREADY VARIABLES

### EXPORTED VARIABLES

### VARIABLES



########## FUNCTIONS ##########

# is only supposed to work if the parent is an hboxcontainer and the third child is the input field which should be editable or not
func set_editable_state_of_input(active : bool):
	if get_parent().get_children().size() >= 3:
		get_parent().get_child(2).editable = active

