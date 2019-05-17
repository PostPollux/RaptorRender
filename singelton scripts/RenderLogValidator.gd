#////////////////////#
# RenderLogValidator #
#////////////////////#

# This script handles 
# - executing a commandline render instruction in a separate processes and redirect it's output into a file
# - continuously read and monitor the output file while rendering to detect errors and successes
# - abort rendering by killing the process


extends Node

signal error_detected
signal critical_error_detected
signal success_detected


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	

func validate_log_line(line : String) -> String:
	
	
	if line.begins_with("Saved:"):
		line =  "[color=#" + RRColorScheme.log_success + "]" + line + "[/color]"
		emit_signal("success_detected")
		
	
	elif line.begins_with("Warning:"):
		line = "[color=#" + RRColorScheme.log_warning + "]" + line + "[/color]"
	
	elif line.begins_with("AttributeError:") or line.begins_with("KeyError:") or line.begins_with("TypeError:") or line.begins_with("FileNotFoundError:"):
		line = "[color=#" + RRColorScheme.log_error + "]" + line + "[/color]"
	
	elif line.begins_with("Error:"):
		line = "[color=#" + RRColorScheme.log_critical_error + "]" + line + "[/color]"
		emit_signal("critical_error_detected")
		
	
	return line

