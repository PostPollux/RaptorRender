extends MarginContainer

class_name TryInfoPanel

onready var TryInfoTabContainer = $"TabContainer"

onready var DetailsVisibilityContainer = $"TabContainer/Details/ScrollContainer"

onready var NameLabel = $"TabContainer/Details/ScrollContainer/MarginContainer/VBoxContainer/NameLabel"
onready var ClientLabel = $"TabContainer/Details/ScrollContainer/MarginContainer/VBoxContainer/ClientLabel"
onready var TimeStartedLabel = $"TabContainer/Details/ScrollContainer/MarginContainer/VBoxContainer/TimeStartedLabel"
onready var TimeStoppedLabel = $"TabContainer/Details/ScrollContainer/MarginContainer/VBoxContainer/TimeStoppedLabel"
onready var TimeNeededLabel = $"TabContainer/Details/ScrollContainer/MarginContainer/VBoxContainer/TimeNeededLabel"

onready var LogVisibilityContainer = $"TabContainer/Log/MarginContainer"
onready var LogRichTextLabel : RichTextLabel = $"TabContainer/Log/MarginContainer/Log_RichTextLabel"

var currently_displayed_try_id : int = 0
var currently_displayed_chunk_id :int = 0

var current_try_info_tab : int = 0


func _ready():
	RaptorRender.register_try_info_panel(self)
	ReadLogFileManager.connect("log_read_to_end_of_file", self, "add_text_to_log")
	ReadLogFileManager.connect("no_log_file_found", self, "no_log_file_found")




func reset_to_first_tab():
	TryInfoTabContainer.current_tab = 0


func set_tab(tab_number : int):
	TryInfoTabContainer.current_tab = tab_number


func get_current_tab() -> int:
	return TryInfoTabContainer.current_tab


func set_visibility(visibility : bool):
	DetailsVisibilityContainer.visible = visibility
	LogVisibilityContainer.visible = visibility


func _on_TabContainer_tab_selected(tab):
	
	if tab == 1 and not tab == current_try_info_tab:
		clear_log()
		read_log_file()
		
	current_try_info_tab = tab




############################
#  Functions for Details Tab
############################

func update_try_info_panel(job_id : int, chunk_id : int, try_id : int):
	
	
	NameLabel.text = tr("TRY_DETAIL_2") + " " + String(try_id)
	
	var client_id : int = RaptorRender.rr_data.jobs[job_id].chunks[chunk_id].tries[try_id].client
	ClientLabel.text = tr("TRY_DETAIL_3") + ":   " + RaptorRender.rr_data.clients[client_id].name
	
	var time_started : int = RaptorRender.rr_data.jobs[job_id].chunks[chunk_id].tries[try_id].time_started
	TimeStartedLabel.text = tr("TRY_DETAIL_4") + ":   " + TimeFunctions.time_stamp_to_date_as_string(time_started, 1)
	
	var time_stopped: int = RaptorRender.rr_data.jobs[job_id].chunks[chunk_id].tries[try_id].time_finished
	TimeStoppedLabel.text = tr("TRY_DETAIL_5") + ":   " + TimeFunctions.time_stamp_to_date_as_string(time_started, 1)
	
	var time_needed : int = time_stopped - time_started
	TimeNeededLabel.text = tr("TRY_DETAIL_6") + ":   " + TimeFunctions.seconds_to_string(time_needed, 3)



########################
#  Functions for Log Tab
########################

func clear_log():
	LogRichTextLabel.clear()


func update_current_try_id(try_id : int):
	
	# load log file when either chunk_id or try_id changed
	if currently_displayed_chunk_id != RaptorRender.current_chunk_id_for_job_info_panel or currently_displayed_try_id != try_id:
		
		currently_displayed_try_id = try_id
		currently_displayed_chunk_id = RaptorRender.current_chunk_id_for_job_info_panel
	
		if TryInfoTabContainer.current_tab == 1:
			clear_log()
			read_log_file()
	
	currently_displayed_try_id = try_id
	currently_displayed_chunk_id = RaptorRender.current_chunk_id_for_job_info_panel
	

func read_log_file():
	var selected_job : int = RaptorRender.current_job_id_for_job_info_panel
	var selected_chunk : int = RaptorRender.current_chunk_id_for_job_info_panel
	var selected_try : int = currently_displayed_try_id
	
	ReadLogFileManager.reset_file_pointer_position()
	ReadLogFileManager.stop_read_log_timer()
	ReadLogFileManager.read_log_file(selected_job, selected_chunk, selected_try)
	

func add_text_to_log(text : String):
	LogRichTextLabel.append_bbcode( text )
	

func no_log_file_found():
	LogRichTextLabel.append_bbcode( tr("TRY_LOG_2"))


func _on_Log_RichTextLabel_gui_input(event):
	if event.is_action_pressed("ui_right_mouse_button"):
		RaptorRender.log_context_menu_invoked()
	if Input.is_key_pressed(KEY_CONTROL) and Input.is_key_pressed(KEY_C):
		RaptorRender.NotificationSystem.add_info_notification(tr("MSG_INFO_1"), tr("MSG_INFO_4"), 5) # Selection has been copied to clipboard!
	
