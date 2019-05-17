extends HBoxContainer

var job_id
var LabelPriority
var PlusButton
var MinusButton


func _ready():
	
	LabelPriority = $"Label_priority"
	PlusButton = $"plus"
	MinusButton = $"minus"
	
	LabelPriority.text = String ( RaptorRender.rr_data.jobs[job_id].priority )
	
	disable_if_needed()



func disable_if_needed():
	var status = RaptorRender.rr_data.jobs[job_id].status
	if status == "5_finished" or status == "6_cancelled":
		PlusButton.disabled = true
		MinusButton.disabled = true



func _on_plus_pressed():
	
	if Input.is_key_pressed(KEY_SHIFT) or Input.is_key_pressed(KEY_CONTROL):
		# increase by one
		RaptorRender.rr_data.jobs[job_id].priority = min(RaptorRender.rr_data.jobs[job_id].priority + 1, 100)
		LabelPriority.text = String ( RaptorRender.rr_data.jobs[job_id].priority )
	else:
		# increase by 5
		RaptorRender.rr_data.jobs[job_id].priority = min(RaptorRender.rr_data.jobs[job_id].priority + 5, 100)
		LabelPriority.text = String ( RaptorRender.rr_data.jobs[job_id].priority )
	# RaptorRender.TableJobs.refresh()



func _on_minus_pressed():
	
	if Input.is_key_pressed(KEY_SHIFT) or Input.is_key_pressed(KEY_CONTROL):
		# decrease by one
		RaptorRender.rr_data.jobs[job_id].priority = max(RaptorRender.rr_data.jobs[job_id].priority - 1, 0)
		LabelPriority.text = String ( RaptorRender.rr_data.jobs[job_id].priority )
	else:
		# decrease by 5
		RaptorRender.rr_data.jobs[job_id].priority = max(RaptorRender.rr_data.jobs[job_id].priority - 5, 0)
		LabelPriority.text = String ( RaptorRender.rr_data.jobs[job_id].priority )
	# RaptorRender.TableJobs.refresh()




func _on_plus_mouse_entered():
	
	# mark row as hovered, otherwise the row hover color would disappear, if the mouse is over the button
	self.get_parent().get_parent().get_parent().get_parent().update_row_color_hover()
	
	# modulate button on hover
	if !PlusButton.disabled:
		PlusButton.set_modulate(Color(0.75, 1, 0.75, 1)) # green



func _on_plus_mouse_exited():
	
	# reset row hover color. It's needed, because otherwise if we fast pass the button with the mouse, the row would stay highlighted
	self.get_parent().get_parent().get_parent().get_parent().update_row_color_reset()
	
	# reset button modulation
	PlusButton.set_modulate(Color(1, 1, 1, 1))



func _on_minus_mouse_entered():
	
	# mark row as hovered, otherwise the row hover color would disappear, if the mouse is over the button
	self.get_parent().get_parent().get_parent().get_parent().update_row_color_hover()
	
	# modulate button on hover
	if!MinusButton.disabled:
		MinusButton.set_modulate(Color(1, 0.75, 0.75, 1)) # red



# reset row hover color. It's needed, because otherwise if we fast pass the button with the mouse, the row would stay highlighted
func _on_minus_mouse_exited():
	self.get_parent().get_parent().get_parent().get_parent().update_row_color_reset()
	
	# reset button modulation
	MinusButton.set_modulate(Color(1, 1, 1, 1))