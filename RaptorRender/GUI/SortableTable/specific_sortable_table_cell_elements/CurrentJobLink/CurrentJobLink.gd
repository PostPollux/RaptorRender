extends HBoxContainer


### PRELOAD RESOURCES

### SIGNALS

### ONREADY VARIABLES
onready var JobLinkButton : TextureButton = $"TextureButton"
onready var CurrentJobLabel : Label = $"CurrentJobLabel"

### EXPORTED VARIABLES

### VARIABLES
var job_id : int






########## FUNCTIONS ##########


func _ready():
	
	if job_id != -1:
		CurrentJobLabel.text = String( RaptorRender.rr_data.jobs[job_id].name )
	else:
		CurrentJobLabel.text = ""
		
	set_correct_visibility_of_link_button()



func set_correct_visibility_of_link_button():
	
	if job_id == -1:
		JobLinkButton.visible = false
	else:
		JobLinkButton.visible = true



func _on_TextureButton_pressed():
	RaptorRender.ClientsTable.clear_selection()
	RaptorRender.JobsTable.select_by_id(job_id)
	RaptorRender.JobInfoPanel.update_job_info_panel(job_id)
	RaptorRender.ClientInfoPanel.visible = false
	RaptorRender.JobInfoPanel.visible = true
	
	# scroll table to correct position
	RaptorRender.JobsTable.scroll_to_row(job_id)
	








func _on_TextureButton_mouse_entered():
	
	# mark row as hovered, otherwise the row hover color would disappear, if the mouse is over the button
	self.get_parent().get_parent().get_parent().get_parent().update_row_color()
	
	# modulate button on hover
	if !JobLinkButton.disabled:
		JobLinkButton.set_modulate(Color(1, 0.75, 0.5, 1)) # orange


func _on_TextureButton_mouse_exited():
	
	# reset row hover color. It's needed, because otherwise if we fast pass the button with the mouse, the row would stay highlighted
	self.get_parent().get_parent().get_parent().get_parent().update_row_color()
	
	# reset button modulation
	JobLinkButton.set_modulate(Color(1, 1, 1, 1))
