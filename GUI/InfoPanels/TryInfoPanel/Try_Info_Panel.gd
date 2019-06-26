extends MarginContainer

class_name TryInfoPanel

onready var TryInfoTabContainer = $"TabContainer"

onready var DetailsVisibilityContainer = $"TabContainer/Details/ScrollContainer"

onready var NameLabel = $"TabContainer/Details/ScrollContainer/MarginContainer/VBoxContainer/NameLabel"
onready var ClientLabel = $"TabContainer/Details/ScrollContainer/MarginContainer/VBoxContainer/ClientLabel"
onready var TimeStartedLabel = $"TabContainer/Details/ScrollContainer/MarginContainer/VBoxContainer/TimeStartedLabel"
onready var TimeStoppedLabel = $"TabContainer/Details/ScrollContainer/MarginContainer/VBoxContainer/TimeStoppedLabel"
onready var TimeNeededLabel = $"TabContainer/Details/ScrollContainer/MarginContainer/VBoxContainer/TimeNeededLabel"

var current_displayed_try_id : int


func _ready():
	RaptorRender.register_try_info_panel(self)


func reset_to_first_tab():
	TryInfoTabContainer.current_tab = 0

func set_tab(tab_number : int):
	TryInfoTabContainer.current_tab = tab_number

func get_current_tab() -> int:
	return TryInfoTabContainer.current_tab


func set_visibility(visibility : bool):
	DetailsVisibilityContainer.visible = visibility

func update_try_info_panel(job_id : int, chunk_id : int, try_id : int):
	
	
	NameLabel.text = tr("TRY_DETAIL_1") + " " + String(try_id)
	
	var client_id : int = RaptorRender.rr_data.jobs[job_id].chunks[chunk_id].tries[try_id].client
	ClientLabel.text = tr("TRY_DETAIL_2") + ":   " + RaptorRender.rr_data.clients[client_id].name
	
	var time_started : int = RaptorRender.rr_data.jobs[job_id].chunks[chunk_id].tries[try_id].time_started
	TimeStartedLabel.text = tr("TRY_DETAIL_3") + ":   " + TimeFunctions.time_stamp_to_date_as_string(time_started, 1)
	
	var time_stopped: int = RaptorRender.rr_data.jobs[job_id].chunks[chunk_id].tries[try_id].time_finished
	TimeStoppedLabel.text = tr("TRY_DETAIL_4") + ":   " + TimeFunctions.time_stamp_to_date_as_string(time_started, 1)
	
	var time_needed : int = time_stopped - time_started
	TimeNeededLabel.text = tr("TRY_DETAIL_5") + ":   " + TimeFunctions.seconds_to_string(time_needed, 3)
	

