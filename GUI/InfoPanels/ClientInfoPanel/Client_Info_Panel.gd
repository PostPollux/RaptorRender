extends MarginContainer

class_name ClientInfoPanel

# references to nodes in details tab
onready var ClientInfoTabContainer : TabContainer = $"TabContainer"
onready var StatusIconTexture = $"TabContainer/Details/ScrollContainer/MarginContainer/VBoxContainer/MainInfo/HBoxContainer/Icon"
onready var NameLabel : Label = $"TabContainer/Details/ScrollContainer/MarginContainer/VBoxContainer/MainInfo/HBoxContainer/MarginContainer/VBoxContainer/HBoxContainer/NameLabel"
onready var UserLabel : Label = $"TabContainer/Details/ScrollContainer/MarginContainer/VBoxContainer/MainInfo/HBoxContainer/MarginContainer/VBoxContainer/HBoxContainer/UserLabel"
onready var StatusLabel : Label = $"TabContainer/Details/ScrollContainer/MarginContainer/VBoxContainer/MainInfo/HBoxContainer/MarginContainer/VBoxContainer/StatusLabel"
onready var UptimeLabel : Label = $"TabContainer/Details/ScrollContainer/MarginContainer/VBoxContainer/MainInfo/HBoxContainer/MarginContainer/VBoxContainer/UptimeLabel"

onready var CPUHeading : Label = $"TabContainer/Details/ScrollContainer/MarginContainer/VBoxContainer/cpu_specs/HBoxContainer/MarginContainer/VBoxContainer/CPUHeading"
onready var MemoryHeading : Label = $"TabContainer/Details/ScrollContainer/MarginContainer/VBoxContainer/memory_specs/HBoxContainer/MarginContainer/VBoxContainer/MemoryHeading"
onready var GraphicsHeading : Label = $"TabContainer/Details/ScrollContainer/MarginContainer/VBoxContainer/graphics_specs/HBoxContainer/MarginContainer/VBoxContainer/GraphicsHeading"
onready var HardDrivesHeading : Label = $"TabContainer/Details/ScrollContainer/MarginContainer/VBoxContainer/hard_drives_specs/HBoxContainer/MarginContainer/VBoxContainer/HardDrivesHeading"
onready var NetworkHeading : Label = $"TabContainer/Details/ScrollContainer/MarginContainer/VBoxContainer/network_specs/HBoxContainer/MarginContainer/VBoxContainer/NetworkHeading"
onready var SystemHeading : Label = $"TabContainer/Details/ScrollContainer/MarginContainer/VBoxContainer/system_specs/HBoxContainer/MarginContainer/VBoxContainer/SystemHeading"

onready var CPULabel : Label = $"TabContainer/Details/ScrollContainer/MarginContainer/VBoxContainer/cpu_specs/HBoxContainer/MarginContainer/VBoxContainer/CPULabel"
onready var RAMLabel : Label = $"TabContainer/Details/ScrollContainer/MarginContainer/VBoxContainer/memory_specs/HBoxContainer/MarginContainer/VBoxContainer/RAMLabel"
onready var GraphicsLabel : Label = $"TabContainer/Details/ScrollContainer/MarginContainer/VBoxContainer/graphics_specs/HBoxContainer/MarginContainer/VBoxContainer/GraphicsLabel"
onready var PlatformLabel : Label = $"TabContainer/Details/ScrollContainer/MarginContainer/VBoxContainer/system_specs/HBoxContainer/MarginContainer/VBoxContainer/PlatformLabel"
onready var IPLabel : Label = $"TabContainer/Details/ScrollContainer/MarginContainer/VBoxContainer/network_specs/HBoxContainer/MarginContainer/VBoxContainer/IPLabel"
onready var MACLabel : Label = $"TabContainer/Details/ScrollContainer/MarginContainer/VBoxContainer/network_specs/HBoxContainer/MarginContainer/VBoxContainer/MACLabel"

onready var CPUUsageBar = $"TabContainer/Details/ScrollContainer/MarginContainer/VBoxContainer/cpu_specs/HBoxContainer/MarginContainer/VBoxContainer/cpu_usage"
onready var MemoryUsageBar = $"TabContainer/Details/ScrollContainer/MarginContainer/VBoxContainer/memory_specs/HBoxContainer/MarginContainer/VBoxContainer/memory_usage"

onready var HardDriveContainer = $"TabContainer/Details/ScrollContainer/MarginContainer/VBoxContainer/hard_drives_specs/HBoxContainer/MarginContainer/VBoxContainer/HardDriveContainer"

# references to nodes in current/last render log tab
onready var JobButtonHeading : Label = $"TabContainer/Current Render Log/HBoxContainer/Job/HBoxContainer/JobHeading"
onready var JobButtonValue : Label = $"TabContainer/Current Render Log/HBoxContainer/Job/HBoxContainer/JobValue"
onready var ChunkButtonHeading : Label = $"TabContainer/Current Render Log/HBoxContainer/Chunk/HBoxContainer/ChunkHeading"
onready var ChunkButtonValue : Label = $"TabContainer/Current Render Log/HBoxContainer/Chunk/HBoxContainer/ChunkValue"
onready var TryButtonHeading : Label = $"TabContainer/Current Render Log/HBoxContainer/Try/HBoxContainer/TryHeading"
onready var TryButtonValue : Label = $"TabContainer/Current Render Log/HBoxContainer/Try/HBoxContainer/TryValue"

onready var JobButton : Button = $"TabContainer/Current Render Log/HBoxContainer/Job/JobButton"
onready var ChunkButton : Button = $"TabContainer/Current Render Log/HBoxContainer/Chunk/ChunkButton"
onready var TryButton : Button = $"TabContainer/Current Render Log/HBoxContainer/Try/TryButton"

onready var LogRichTextLabel : RichTextLabel = $"TabContainer/Current Render Log/MarginContainer/LogRichtTextLabel"

# preload Resources
var HardDriveRes = preload("res://GUI/InfoPanels/ClientInfoPanel/hard_drive.tscn")

var log_job_id : int
var log_chunk_id : int
var log_try_id : int 


var currently_selected_client_id : int = 0
var ctrl_plus_c_pressed : bool = false

func _ready():
	RaptorRender.register_client_info_panel(self)
	ReadLogFileManager.connect("log_read_to_end_of_file", self, "add_text_to_log")
	ReadLogFileManager.connect("no_log_file_found", self, "no_log_file_found")
	
	JobButtonHeading.text = "CLIENT_LATEST_LOG_2"
	ChunkButtonHeading.text = "CLIENT_LATEST_LOG_3"
	TryButtonHeading.text = "CLIENT_LATEST_LOG_4"
	
	translate_tabs()
	
	
	# connect timeout signal of the "refresh_interface_timer" to check if there are more recent logs for the client
	RaptorRender.refresh_interface_timer.connect("timeout", self, "check_if_newer_log_available")


func translate_tabs():
	ClientInfoTabContainer.set_tab_title(0 , tr("CLIENT_DETAIL_1") ) # Details
	ClientInfoTabContainer.set_tab_title(1 , tr("CLIENT_LATEST_LOG_1") ) # Latest Log


func reset_to_first_tab():
	ClientInfoTabContainer.current_tab = 0


func set_tab(tab_number : int ):
	ClientInfoTabContainer.current_tab = tab_number


###########################
# Functions for details tab
###########################

func update_client_info_panel(client_id : int):
	
	currently_selected_client_id = client_id
	
	# set the id for the cpu usage bar so that it knows which value to get
	CPUUsageBar.client_id = client_id
	MemoryUsageBar.client_id = client_id
	
	
	var selected_client = RaptorRender.rr_data.clients[client_id]
	
	
	#################
	#  Status Section
	#################
	
	
	NameLabel.text = selected_client["name"]
	UserLabel.text = "( " + selected_client["username"] + " )"
	
	
	var status = selected_client["status"]
	
	match status:
		RRStateScheme.client_rendering : StatusIconTexture.set_modulate(RRColorScheme.state_active)
		RRStateScheme.client_available : StatusIconTexture.set_modulate(RRColorScheme.state_finished_or_online)
		RRStateScheme.client_error :     StatusIconTexture.set_modulate(RRColorScheme.state_error)
		RRStateScheme.client_disabled :  StatusIconTexture.set_modulate(RRColorScheme.state_paused)
		RRStateScheme.client_offline :   StatusIconTexture.set_modulate(RRColorScheme.state_offline_or_cancelled)
	
	
	
	
	match status:
		RRStateScheme.client_rendering : StatusLabel.text = tr("CLIENT_DETAIL_2") + ":  " + tr("CLIENT_DETAIL_STATUS_1")
		RRStateScheme.client_available : StatusLabel.text = tr("CLIENT_DETAIL_2") + ":  " + tr("CLIENT_DETAIL_STATUS_2")
		RRStateScheme.client_error :     StatusLabel.text = tr("CLIENT_DETAIL_2") + ":  " + tr("CLIENT_DETAIL_STATUS_3")
		RRStateScheme.client_disabled :  StatusLabel.text = tr("CLIENT_DETAIL_2") + ":  " + tr("CLIENT_DETAIL_STATUS_4")
		RRStateScheme.client_offline :   StatusLabel.text = tr("CLIENT_DETAIL_2") + ":  " + tr("CLIENT_DETAIL_STATUS_5")
	
	if status != RRStateScheme.client_offline:
		UptimeLabel.text = tr("CLIENT_DETAIL_3") + ":  " + TimeFunctions.time_elapsed_as_string(selected_client["time_connected"], OS.get_unix_time(), 2)
	else:
		UptimeLabel.text = tr("CLIENT_DETAIL_4") + ":  not implemented yet" 
	
	
	###############
	#  CPU Section
	###############
	
	CPUHeading.text = "CLIENT_DETAIL_5" # CPU
	
	var cpu_text : String = ""
	
	cpu_text += selected_client["cpu"][0] + "\n"
	
	if selected_client["cpu"][2] < 2:
		cpu_text += String(selected_client["cpu"][2]) + " Socket, "
	else:
		cpu_text += String(selected_client["cpu"][2]) + " Sockets, "
		
	if selected_client["cpu"][3] < 2:
		cpu_text += String(selected_client["cpu"][2] * selected_client["cpu"][3]) + " Core, "
	else:
		cpu_text += String(selected_client["cpu"][2] * selected_client["cpu"][3]) + " Cores, "
		
	if selected_client["cpu"][4] < 2:
		cpu_text += String(selected_client["cpu"][2] * selected_client["cpu"][4]) + " Thread"
	else:
		cpu_text += String(selected_client["cpu"][2] * selected_client["cpu"][4]) + " Threads"
		
	CPULabel.text = cpu_text
	
	CPUUsageBar.update_cpu_usage_bar()
	
	
	
	
	###################
	#  Memory Section
	###################	
	
	MemoryHeading.text = "CLIENT_DETAIL_6" # Memory
	
	var size_in_gb : String =  String( float(selected_client["memory"]) / 1024 / 1024 )
	RAMLabel.text = size_in_gb.left(size_in_gb.find(".")+ 3) + " GB"
	
	MemoryUsageBar.update_memory_usage_bar()
	
	
	
	######################
	#  Hard Drives Section
	######################
	
	HardDrivesHeading.text = "CLIENT_DETAIL_7" # Hard Drives
	
	var old = HardDriveContainer.get_children()
	
	for o in old:
		o.free()
	
	var drive_count = 0
	for drive in selected_client["hard_drives"]:
		
		var HardDrive = HardDriveRes.instance()
		HardDrive.client_id = client_id
		HardDrive.drive_number = drive_count
		
		HardDriveContainer.add_child(HardDrive)
		
		drive_count += 1
	
	
	
	
	
	###################
	#  Graphics Section
	###################
	
	GraphicsHeading.text = "CLIENT_DETAIL_8" # Graphics
	
	var graphics_text : String = ""
	for i in range(0, selected_client["graphics"].size()):
		graphics_text += selected_client["graphics"][i] + "\n"
		
	if graphics_text.ends_with("\n"):
		graphics_text = graphics_text.substr(0,graphics_text.length()-1)	
	GraphicsLabel.text = graphics_text
	
	
	
	##################
	# Network Section
	##################
	
	NetworkHeading.text = "CLIENT_DETAIL_9" # Network
	
	if selected_client["ip_addresses"].size() > 1:
		var text : String = "IP " + tr("CLIENT_DETAIL_11") + ": \n"
		for i in range(0, selected_client["ip_addresses"].size()):
			text += " " + selected_client["ip_addresses"][i].replace(".", " . ") + "\n"
		if text.ends_with("\n"):
			text = text.substr(0,text.length()-1)
		IPLabel.text = text
	elif selected_client["ip_addresses"].size() == 1:
		IPLabel.text = "IP:  " + selected_client["ip_addresses"][0].replace(".", " . ")
	else:
		IPLabel.text = ""
		
		
	if selected_client["mac_addresses"].size() > 1:
		var text : String = "MAC " + tr("CLIENT_DETAIL_11") + ": \n"
		for i in range(0, selected_client["mac_addresses"].size()):
			text += " " + selected_client["mac_addresses"][i].to_upper().replace(":", " : ") + "\n"
		if text.ends_with("\n"):
			text = text.substr(0,text.length()-1)
		MACLabel.text = text
	elif selected_client["mac_addresses"].size() == 1:
		MACLabel.text = "MAC:  " + selected_client["mac_addresses"][0].to_upper().replace(":", " : ")
	else:
		MACLabel.text = ""


	##################
	# System Section
	##################
	
	SystemHeading.text = "CLIENT_DETAIL_10" # System
	
	if selected_client["platform"].size() == 2:
		PlatformLabel.text = selected_client["platform"][0] + "  " + selected_client["platform"][1]
	if selected_client["platform"].size() == 3:
		PlatformLabel.text = selected_client["platform"][0] + "  " + selected_client["platform"][1] + "  " + selected_client["platform"][2]




######################################
# Functions for current render log tab
######################################
func update_log_buttons():
	
	if RaptorRender.rr_data.jobs.has(log_job_id):
		JobButtonValue.text = RaptorRender.rr_data.jobs[log_job_id].name
		ChunkButtonValue.text = String(log_chunk_id)
		TryButtonValue.text = String(log_try_id)


func clear_log():
	LogRichTextLabel.clear()


func read_log_file():
	log_job_id = RaptorRender.rr_data.clients[currently_selected_client_id].last_render_log[0]
	log_chunk_id = RaptorRender.rr_data.clients[currently_selected_client_id].last_render_log[1]
	log_try_id = RaptorRender.rr_data.clients[currently_selected_client_id].last_render_log[2]
	
	ReadLogFileManager.reset_file_pointer_position()
	ReadLogFileManager.stop_read_log_timer()
	ReadLogFileManager.read_log_file(log_job_id, log_chunk_id, log_try_id)


func add_text_to_log(text : String):
	LogRichTextLabel.append_bbcode( text )

func no_log_file_found():
	LogRichTextLabel.append_bbcode( tr("TRY_LOG_2"))

func _on_LogRichtTextLabel_gui_input(event):
	if event.is_action_pressed("ui_right_mouse_button"):
		RaptorRender.log_context_menu_invoked()
	if Input.is_key_pressed(KEY_CONTROL) and Input.is_key_pressed(KEY_C):
		if not ctrl_plus_c_pressed:
			ctrl_plus_c_pressed = true
			RaptorRender.NotificationSystem.add_info_notification(tr("MSG_INFO_1"), tr("MSG_INFO_4"), 5) # Selection has been copied to clipboard!
	else:
		ctrl_plus_c_pressed = false


func _on_TabContainer_tab_changed(tab):
	if tab == 1:
		clear_log()
		read_log_file()
		update_log_buttons()


func check_if_newer_log_available():
	
	if currently_selected_client_id != 0:
		var fetched_job_id : int = RaptorRender.rr_data.clients[currently_selected_client_id].last_render_log[0]
		var fetched_chunk_id : int = RaptorRender.rr_data.clients[currently_selected_client_id].last_render_log[1]
		var fetched_try_id : int = RaptorRender.rr_data.clients[currently_selected_client_id].last_render_log[2]
		
		if fetched_job_id != log_job_id or fetched_chunk_id != log_chunk_id or fetched_try_id != log_try_id:
			clear_log()
			read_log_file()
			update_log_buttons()


func _on_JobButton_pressed():
	# select job in jobs table, switch info panel to JobInfoPanel
	RaptorRender.ClientsTable.clear_selection()
	RaptorRender.current_job_id_for_job_info_panel = log_job_id
	RaptorRender.JobsTable.select_by_id(log_job_id)
	RaptorRender.JobInfoPanel.update_job_info_panel(log_job_id)
	RaptorRender.JobsTable.scroll_to_row(log_job_id)
	RaptorRender.ClientInfoPanel.visible = false
	RaptorRender.JobInfoPanel.visible = true

# chunk button pressed
func _on_ChunkButton_pressed():
	
	# select job in jobs table, switch info panel to JobInfoPanel
	RaptorRender.ClientsTable.clear_selection()
	RaptorRender.current_job_id_for_job_info_panel = log_job_id
	RaptorRender.JobsTable.select_by_id(log_job_id)
	RaptorRender.JobInfoPanel.update_job_info_panel(log_job_id)
	RaptorRender.JobsTable.scroll_to_row(log_job_id)
	RaptorRender.ClientInfoPanel.visible = false
	RaptorRender.JobInfoPanel.visible = true
	
	# select and autofocus correct chunk
	RaptorRender.current_chunk_id_for_job_info_panel = log_chunk_id
	RaptorRender.JobInfoPanel.set_tab(1)
	RaptorRender.refresh_chunks_table(log_job_id)
	RaptorRender.ChunksTable.clear_selection()
	RaptorRender.ChunksTable.select_by_id(log_chunk_id)
	RaptorRender.chunk_selected(log_chunk_id)
	RaptorRender.ChunksTable.scroll_to_row(log_chunk_id)


func _on_TryButton_pressed():
	# select job in jobs table, switch info panel to JobInfoPanel
	RaptorRender.ClientsTable.clear_selection()
	RaptorRender.current_job_id_for_job_info_panel = log_job_id
	RaptorRender.JobsTable.select_by_id(log_job_id)
	RaptorRender.JobInfoPanel.update_job_info_panel(log_job_id)
	RaptorRender.JobsTable.scroll_to_row(log_job_id)
	RaptorRender.ClientInfoPanel.visible = false
	RaptorRender.JobInfoPanel.visible = true
	
	# select and autofocus correct chunk
	RaptorRender.current_chunk_id_for_job_info_panel = log_chunk_id
	RaptorRender.JobInfoPanel.set_tab(1) # Chunks
	RaptorRender.TryInfoPanel.set_tab(0) # Details
	RaptorRender.refresh_chunks_table(log_job_id)
	RaptorRender.ChunksTable.clear_selection()
	RaptorRender.ChunksTable.select_by_id(log_chunk_id)
	RaptorRender.chunk_selected(log_chunk_id)
	RaptorRender.ChunksTable.scroll_to_row(log_chunk_id)
	
	# select and autofocus correct try
	RaptorRender.TriesTable.clear_selection()
	RaptorRender.TriesTable.select_by_id(log_try_id)
	RaptorRender.try_selected(log_try_id)
	RaptorRender.refresh_tries_table(log_job_id, log_chunk_id)
	RaptorRender.TriesTable.scroll_to_row(log_try_id)
	