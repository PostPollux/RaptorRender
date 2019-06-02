extends MarginContainer

onready var ClientInfoTabContainer = $"TabContainer"
onready var StatusIconTexture = $"TabContainer/Details/ScrollContainer/MarginContainer/VBoxContainer/MainInfo/HBoxContainer/Icon"
onready var NameLabel = $"TabContainer/Details/ScrollContainer/MarginContainer/VBoxContainer/MainInfo/HBoxContainer/MarginContainer/VBoxContainer/HBoxContainer/NameLabel"
onready var UserLabel = $"TabContainer/Details/ScrollContainer/MarginContainer/VBoxContainer/MainInfo/HBoxContainer/MarginContainer/VBoxContainer/HBoxContainer/UserLabel"
onready var StatusLabel = $"TabContainer/Details/ScrollContainer/MarginContainer/VBoxContainer/MainInfo/HBoxContainer/MarginContainer/VBoxContainer/StatusLabel"
onready var UptimeLabel = $"TabContainer/Details/ScrollContainer/MarginContainer/VBoxContainer/MainInfo/HBoxContainer/MarginContainer/VBoxContainer/UptimeLabel"

onready var CPULabel = $"TabContainer/Details/ScrollContainer/MarginContainer/VBoxContainer/cpu_specs/HBoxContainer/MarginContainer/VBoxContainer/CPULabel"
onready var RAMLabel = $"TabContainer/Details/ScrollContainer/MarginContainer/VBoxContainer/memory_specs/HBoxContainer/MarginContainer/VBoxContainer/RAMLabel"
onready var GraphicsLabel = $"TabContainer/Details/ScrollContainer/MarginContainer/VBoxContainer/graphics_specs/HBoxContainer/MarginContainer/VBoxContainer/GraphicsLabel"
onready var PlatformLabel = $"TabContainer/Details/ScrollContainer/MarginContainer/VBoxContainer/system_specs/HBoxContainer/MarginContainer/VBoxContainer/PlatformLabel"
onready var IPLabel = $"TabContainer/Details/ScrollContainer/MarginContainer/VBoxContainer/network_specs/HBoxContainer/MarginContainer/VBoxContainer/IPLabel"
onready var MACLabel = $"TabContainer/Details/ScrollContainer/MarginContainer/VBoxContainer/network_specs/HBoxContainer/MarginContainer/VBoxContainer/MACLabel"

onready var CPUUsageBar = $"TabContainer/Details/ScrollContainer/MarginContainer/VBoxContainer/cpu_specs/HBoxContainer/MarginContainer/VBoxContainer/cpu_usage"
onready var MemoryUsageBar = $"TabContainer/Details/ScrollContainer/MarginContainer/VBoxContainer/memory_specs/HBoxContainer/MarginContainer/VBoxContainer/memory_usage"

onready var HardDriveContainer = $"TabContainer/Details/ScrollContainer/MarginContainer/VBoxContainer/hard_drives_specs/HBoxContainer/MarginContainer/VBoxContainer/HardDriveContainer"

# preload Resources
var HardDriveRes = preload("res://GUI/InfoPanels/ClientInfoPanel/hard_drive.tscn")


func _ready():
	RaptorRender.register_client_info_panel(self)
	

func reset_to_first_tab():
	ClientInfoTabContainer.current_tab = 0

func set_tab(tab_number : int ):
	ClientInfoTabContainer.current_tab = tab_number


func update_client_info_panel(client_id : int):
	
	
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
		RRStateScheme.client_rendering : StatusLabel.text = "Status:  Rendering"
		RRStateScheme.client_available : StatusLabel.text = "Status:  Available"
		RRStateScheme.client_error :     StatusLabel.text = "Status:  Error"
		RRStateScheme.client_disabled :  StatusLabel.text = "Status:  Disabled"
		RRStateScheme.client_offline :   StatusLabel.text = "Status:  Offline"
	
	if status != RRStateScheme.client_offline:
		UptimeLabel.text = "Uptime:  " + TimeFunctions.time_elapsed_as_string(selected_client["time_connected"], OS.get_unix_time(), 2)
	else:
		UptimeLabel.text = "Last seen:  not implemented yet" 
	
	
	###############
	#  CPU Section
	###############
	
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
	
	var size_in_gb : String =  String( float(selected_client["memory"]) / 1024 / 1024 )
	RAMLabel.text = size_in_gb.left(size_in_gb.find(".")+ 3) + " GB"
	
	MemoryUsageBar.update_memory_usage_bar()
	
	
	
	######################
	#  Hard Drives Section
	######################
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
	
	var graphics_text : String = ""
	for i in range(0, selected_client["graphics"].size()):
		graphics_text += selected_client["graphics"][i] + "\n"
		
	if graphics_text.ends_with("\n"):
		graphics_text = graphics_text.substr(0,graphics_text.length()-1)	
	GraphicsLabel.text = graphics_text
	
	
	
	##################
	# Network Section
	##################
	
	if selected_client["ip_addresses"].size() > 1:
		var text : String = "IP Addresses: \n"
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
		var text : String = "MAC Addresses: \n"
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
	
	if selected_client["platform"].size() == 2:
		PlatformLabel.text = selected_client["platform"][0] + "  " + selected_client["platform"][1]
	if selected_client["platform"].size() == 3:
		PlatformLabel.text = selected_client["platform"][0] + "  " + selected_client["platform"][1] + "  " + selected_client["platform"][2]
	