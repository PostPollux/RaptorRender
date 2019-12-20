extends HBoxContainer

class_name PriorityControl

### PRELOAD RESOURCES

### SIGNALS

### ONREADY VARIABLES
onready var PriorityLabel : Label = $"Label_priority"
onready var PlusButton : TextureButton = $"PlusButton"
onready var MinusButton : TextureButton = $"MinusButton"
### EXPORTED VARIABLES

### VARIABLES
var job_id : int




########## FUNCTIONS ##########


func _ready() -> void:
	
	PriorityLabel.text = String ( RaptorRender.rr_data.jobs[job_id].priority )
	
	disable_if_needed()



func set_text(priority : String) -> void:
	if is_instance_valid(PriorityLabel):
		PriorityLabel.text = priority


func disable_if_needed() -> void:
	var status = RaptorRender.rr_data.jobs[job_id].status
	if status == RRStateScheme.job_finished or status == RRStateScheme.job_cancelled:
		PlusButton.disabled = true
		MinusButton.disabled = true



func _on_plus_pressed() -> void:
	
	if Input.is_key_pressed(KEY_SHIFT) or Input.is_key_pressed(KEY_CONTROL):
		# increase by one
		RRNetworkManager.rpc("update_job_priority", job_id, min(RaptorRender.rr_data.jobs[job_id].priority + 1, 100) )
		set_text( String ( RaptorRender.rr_data.jobs[job_id].priority ) )
	else:
		# increase by 5
		RRNetworkManager.rpc("update_job_priority", job_id, min(RaptorRender.rr_data.jobs[job_id].priority + 5, 100) )
		set_text( String ( RaptorRender.rr_data.jobs[job_id].priority ) )



func _on_minus_pressed() -> void:
	
	if Input.is_key_pressed(KEY_SHIFT) or Input.is_key_pressed(KEY_CONTROL):
		# decrease by one
		RRNetworkManager.rpc("update_job_priority", job_id, max(RaptorRender.rr_data.jobs[job_id].priority - 1, 0) )
		set_text( String ( RaptorRender.rr_data.jobs[job_id].priority ) )
	else:
		# decrease by 5
		RRNetworkManager.rpc("update_job_priority", job_id, max(RaptorRender.rr_data.jobs[job_id].priority - 5, 0) )
		set_text( String ( RaptorRender.rr_data.jobs[job_id].priority ) )





func _on_plus_mouse_entered() -> void:
	
	# mark row as hovered, otherwise the row hover color would disappear, if the mouse is over the button
	self.get_parent().get_parent().get_parent().get_parent().update_row_color()
	
	# modulate button on hover
	if !PlusButton.disabled:
		PlusButton.set_modulate(Color(0.75, 1, 0.75, 1)) # green



func _on_plus_mouse_exited() -> void:
	
	# reset row hover color. It's needed, because otherwise if we fast pass the button with the mouse, the row would stay highlighted
	self.get_parent().get_parent().get_parent().get_parent().update_row_color()
	
	# reset button modulation
	PlusButton.set_modulate(Color(1, 1, 1, 1))



func _on_minus_mouse_entered() -> void:
	
	# mark row as hovered, otherwise the row hover color would disappear, if the mouse is over the button
	self.get_parent().get_parent().get_parent().get_parent().update_row_color()
	
	# modulate button on hover
	if!MinusButton.disabled:
		MinusButton.set_modulate(Color(1, 0.75, 0.75, 1)) # red



# reset row hover color. It's needed, because otherwise if we fast pass the button with the mouse, the row would stay highlighted
func _on_minus_mouse_exited() -> void:
	self.get_parent().get_parent().get_parent().get_parent().update_row_color()
	
	# reset button modulation
	MinusButton.set_modulate(Color(1, 1, 1, 1))
