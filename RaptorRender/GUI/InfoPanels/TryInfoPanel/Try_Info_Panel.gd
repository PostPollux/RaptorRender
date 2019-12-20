extends MarginContainer

class_name TryInfoPanel


### PRELOAD RESOURCES

### SIGNALS

### ONREADY VARIABLES 
onready var TryInfoTabContainer : TabContainer = $"TabContainer"

onready var DetailsVisibilityContainer = $"TabContainer/Details/ScrollContainer"

onready var NameLabel : Label= $"TabContainer/Details/ScrollContainer/MarginContainer/VBoxContainer/NameLabel"
onready var StatusLabel : Label = $"TabContainer/Details/ScrollContainer/MarginContainer/VBoxContainer/StatusLabel"
onready var ClientLabel : Label = $"TabContainer/Details/ScrollContainer/MarginContainer/VBoxContainer/ClientLabel"
onready var TimeStartedLabel : Label = $"TabContainer/Details/ScrollContainer/MarginContainer/VBoxContainer/TimeStartedLabel"
onready var TimeStoppedLabel : Label = $"TabContainer/Details/ScrollContainer/MarginContainer/VBoxContainer/TimeStoppedLabel"
onready var TimeNeededLabel : Label = $"TabContainer/Details/ScrollContainer/MarginContainer/VBoxContainer/TimeNeededLabel"
onready var CommandLabel : Label = $"TabContainer/Details/ScrollContainer/MarginContainer/VBoxContainer/CommandLabel"
onready var CommandRichTextLabel : RichTextLabel = $"TabContainer/Details/ScrollContainer/MarginContainer/VBoxContainer/CommandRichTextLabel"

onready var LogVisibilityContainer = $"TabContainer/Log/MarginContainer"
onready var LogRichTextLabel : RichTextLabel = $"TabContainer/Log/MarginContainer/Log_RichTextLabel"

### EXPORTED VARIABLES

### VARIABLES
var currently_displayed_try_id : int = 0
var currently_displayed_chunk_id :int = 0

var ctrl_plus_c_pressed: bool = false




########## FUNCTIONS ##########


func _ready() -> void:
	RaptorRender.register_try_info_panel(self)
	ReadLogFileManager.connect("log_read_to_end_of_file", self, "add_text_to_log")
	ReadLogFileManager.connect("no_log_file_found", self, "no_log_file_found")
	
	translate_tabs()


func translate_tabs() -> void:
	TryInfoTabContainer.set_tab_title(0 , tr("TRY_DETAIL_1") ) # Details
	TryInfoTabContainer.set_tab_title(1 , tr("TRY_LOG_1") ) # Log


func reset_to_first_tab() -> void:
	TryInfoTabContainer.current_tab = 0


func set_tab(tab_number : int) -> void:
	TryInfoTabContainer.current_tab = tab_number


func get_current_tab() -> int:
	return TryInfoTabContainer.current_tab


func set_visibility(visibility : bool) -> void:
	DetailsVisibilityContainer.visible = visibility
	LogVisibilityContainer.visible = visibility


func _on_TabContainer_tab_changed(tab) -> void:
	if tab == 1:
		clear_log()
		read_log_file()
		


############################
#  Functions for Details Tab
############################

func update_try_info_panel(job_id : int, chunk_id : int, try_id : int) -> void:
	
	if job_id != 0 and chunk_id != 0 and try_id != 0:
	
		NameLabel.text = tr("TRY_DETAIL_2") + " " + String(try_id)
		
		var status : String = RaptorRender.rr_data.jobs[job_id].chunks[chunk_id].tries[try_id].status
		match status:
			RRStateScheme.try_rendering : StatusLabel.text = tr("TRY_DETAIL_3") + ":   " + tr("TRY_DETAIL_STATUS_1")
			RRStateScheme.try_error : StatusLabel.text = tr("TRY_DETAIL_3") + ":   " + tr("TRY_DETAIL_STATUS_2")
			RRStateScheme.try_finished : StatusLabel.text = tr("TRY_DETAIL_3") + ":   " + tr("TRY_DETAIL_STATUS_3")
			RRStateScheme.try_cancelled : StatusLabel.text = tr("TRY_DETAIL_3") + ":   " + tr("TRY_DETAIL_STATUS_4")
			RRStateScheme.try_marked_as_finished : StatusLabel.text = tr("TRY_DETAIL_3") + ":   " + tr("TRY_DETAIL_STATUS_5")
		
		var client_id : int = RaptorRender.rr_data.jobs[job_id].chunks[chunk_id].tries[try_id].client
		if RaptorRender.rr_data.clients.has(client_id):
			ClientLabel.text = tr("TRY_DETAIL_4") + ":   " + RaptorRender.rr_data.clients[client_id].machine_properties.name
		else:
			ClientLabel.text = tr("TRY_DETAIL_4") + ":   " + tr("UNKNOWN")
			
		var time_started : int = RaptorRender.rr_data.jobs[job_id].chunks[chunk_id].tries[try_id].time_started
		TimeStartedLabel.text = tr("TRY_DETAIL_5") + ":   " + TimeFunctions.time_stamp_to_date_as_string(time_started, 1, true)
		
		var time_stopped: int = RaptorRender.rr_data.jobs[job_id].chunks[chunk_id].tries[try_id].time_stopped
		TimeStoppedLabel.text = tr("TRY_DETAIL_6") + ":   " + TimeFunctions.time_stamp_to_date_as_string(time_stopped, 1, true)
		
		# calculate time needed
		if time_stopped == 0:
			time_stopped = OS.get_unix_time()
			
		var time_needed : int = time_stopped - time_started
		TimeNeededLabel.text = tr("TRY_DETAIL_7") + ":   " + TimeFunctions.seconds_to_string(time_needed, 3)
		
		CommandLabel.text = tr("TRY_DETAIL_8") + ":   "
		
		CommandRichTextLabel.hint_tooltip = tr("TRY_DETAIL_TOOLTIP_1")
		
		# only update CommandRichTextLabel if the text changes. Otherwise we would constantly loose our selection
		if CommandRichTextLabel.text != RaptorRender.rr_data.jobs[job_id].chunks[chunk_id].tries[try_id].cmd:
			CommandRichTextLabel.text =  RaptorRender.rr_data.jobs[job_id].chunks[chunk_id].tries[try_id].cmd

########################
#  Functions for Log Tab
########################

func clear_log() -> void:
	LogRichTextLabel.clear()


func update_current_try_id(try_id : int) -> void:
	
	# load log file when either chunk_id or try_id changed
	if currently_displayed_chunk_id != RaptorRender.current_chunk_id_for_job_info_panel or currently_displayed_try_id != try_id:
		
		currently_displayed_try_id = try_id
		currently_displayed_chunk_id = RaptorRender.current_chunk_id_for_job_info_panel
	
		if TryInfoTabContainer.current_tab == 1:
			clear_log()
			read_log_file()
	
	currently_displayed_try_id = try_id
	currently_displayed_chunk_id = RaptorRender.current_chunk_id_for_job_info_panel



func read_log_file() -> void:
	var selected_job : int = RaptorRender.current_job_id_for_job_info_panel
	var selected_chunk : int = RaptorRender.current_chunk_id_for_job_info_panel
	var selected_try : int = currently_displayed_try_id
	
	if selected_job != 0 and selected_chunk != 0 and selected_try != 0:
		LogRichTextLabel.append_bbcode( tr("TRY_DETAIL_8") + ":\n" + RaptorRender.rr_data.jobs[selected_job].chunks[selected_chunk].tries[selected_try].cmd + "\n\n\n")
	
	ReadLogFileManager.reset_file_pointer_position()
	ReadLogFileManager.stop_read_log_timer()
	ReadLogFileManager.read_log_file(selected_job, selected_chunk, selected_try)


func add_text_to_log(text : String) -> void:
	LogRichTextLabel.append_bbcode( text )


func no_log_file_found() -> void:
	LogRichTextLabel.clear()
	LogRichTextLabel.append_bbcode( tr("TRY_LOG_2"))


func _on_Log_RichTextLabel_gui_input(event) -> void:
	if event.is_action_pressed("ui_right_mouse_button"):
		RaptorRender.log_context_menu_invoked()
	if Input.is_key_pressed(KEY_CONTROL) and Input.is_key_pressed(KEY_C):
		if not ctrl_plus_c_pressed:
			ctrl_plus_c_pressed = true
			RaptorRender.NotificationSystem.add_info_notification(tr("MSG_INFO_1"), tr("MSG_INFO_4"), 5) # Selection has been copied to clipboard!
	else:
		ctrl_plus_c_pressed = false



func _on_CommandRichTextLabel_gui_input(event) -> void:
	if Input.is_key_pressed(KEY_CONTROL) and Input.is_key_pressed(KEY_C):
		if not ctrl_plus_c_pressed:
			ctrl_plus_c_pressed = true
			RaptorRender.NotificationSystem.add_info_notification(tr("MSG_INFO_1"), tr("MSG_INFO_4"), 5) # Selection has been copied to clipboard!
	else:
		ctrl_plus_c_pressed = false


func _on_CommandRichTextLabel_resized() -> void:
	CommandRichTextLabel.rect_min_size.y = CommandRichTextLabel.get_content_height()
