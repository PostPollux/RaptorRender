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
		JobLinkButton.visible = false
		

func _on_TextureButton_pressed():
	RaptorRender.TableClients.clear_selection()
	RaptorRender.TableJobs.select_by_content_id(job_id)
	RaptorRender.JobInfoPanel.update_job_info_panel(job_id)
	RaptorRender.ClientInfoPanel.visible = false
	RaptorRender.JobInfoPanel.visible = true

