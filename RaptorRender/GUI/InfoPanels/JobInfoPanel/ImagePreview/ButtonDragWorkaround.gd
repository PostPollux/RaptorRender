extends Button



# this is just a workaround. If we don't have this and we start to click and drag, mouse_entered and mouse_exited signals won't be executed on other nodes.
# with this added they get executed as expected!
func get_drag_data(_pos) -> String:
	return "workaround"
