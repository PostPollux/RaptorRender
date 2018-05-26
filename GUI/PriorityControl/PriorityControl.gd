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
	
	var status = RaptorRender.rr_data.jobs[job_id].status
	if status == "5_finished" or status == "6_cancelled":
		PlusButton.disabled = true
		MinusButton.disabled = true


func _on_plus_pressed():
	
	if Input.is_key_pressed(KEY_SHIFT) or Input.is_key_pressed(KEY_CONTROL):
		# increase by one
		RaptorRender.rr_data.jobs[job_id].priority = min(RaptorRender.rr_data.jobs[job_id].priority + 1, 100)
		
	else:
		# increase by 5
		RaptorRender.rr_data.jobs[job_id].priority = min(RaptorRender.rr_data.jobs[job_id].priority + 5, 100)
		
	RaptorRender.TableJobs.refresh()

func _on_minus_pressed():
	
	if Input.is_key_pressed(KEY_SHIFT) or Input.is_key_pressed(KEY_CONTROL):
		# decrease by one
		RaptorRender.rr_data.jobs[job_id].priority = max(RaptorRender.rr_data.jobs[job_id].priority - 1, 0)
		
	else:
		# decrease by 5
		RaptorRender.rr_data.jobs[job_id].priority = max(RaptorRender.rr_data.jobs[job_id].priority - 5, 0)
	
	RaptorRender.TableJobs.refresh()