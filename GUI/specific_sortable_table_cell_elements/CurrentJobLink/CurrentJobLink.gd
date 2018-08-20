extends HBoxContainer

var job_id
var JobLinkButton
var CurrentJobLabel

func _ready():
	JobLinkButton = $"TextureButton"
	CurrentJobLabel = $"CurrentJobLabel"
	
	if job_id != "":
		CurrentJobLabel.text = String( RaptorRender.rr_data.jobs[job_id].name )
	else:
		CurrentJobLabel.text = ""
		
	set_correct_visibility_of_link_button()



func set_correct_visibility_of_link_button():
	
	if job_id == "":
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
	

