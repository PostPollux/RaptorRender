extends MarginContainer

onready var ClientInfoTabContainer = $"TabContainer"
onready var StatusIconTexture = $"TabContainer/Details/MarginContainer/VBoxContainer/MainInfo/HBoxContainer/Icon"
onready var NameLabel = $"TabContainer/Details/MarginContainer/VBoxContainer/MainInfo/HBoxContainer/MarginContainer/VBoxContainer/NameLabel"
onready var StatusLabel = $"TabContainer/Details/MarginContainer/VBoxContainer/MainInfo/HBoxContainer/MarginContainer/VBoxContainer/StatusLabel"
onready var UptimeLabel = $"TabContainer/Details/MarginContainer/VBoxContainer/MainInfo/HBoxContainer/MarginContainer/VBoxContainer/UptimeLabel"

onready var CPULabel = $"TabContainer/Details/MarginContainer/VBoxContainer/cpu_specs/HBoxContainer/MarginContainer/VBoxContainer/CPULabel"
onready var RAMLabel = $"TabContainer/Details/MarginContainer/VBoxContainer/memory_specs/HBoxContainer/MarginContainer/VBoxContainer/RAMLabel"
onready var GraphicsLabel = $"TabContainer/Details/MarginContainer/VBoxContainer/graphics_specs/HBoxContainer/MarginContainer/VBoxContainer/GraphicsLabel"
onready var PlatformLabel = $"TabContainer/Details/MarginContainer/VBoxContainer/system_specs/HBoxContainer/MarginContainer/VBoxContainer/PlatformLabel"
onready var IPLabel = $"TabContainer/Details/MarginContainer/VBoxContainer/network_specs/HBoxContainer/MarginContainer/VBoxContainer/IPLabel"
onready var MACLabel = $"TabContainer/Details/MarginContainer/VBoxContainer/network_specs/HBoxContainer/MarginContainer/VBoxContainer/MACLabel"



func _ready():
	RaptorRender.register_client_info_panel(self)
	

func reset_to_first_tab():
	ClientInfoTabContainer.current_tab = 0


func update_client_info_panel(client_id):
	
	var selected_client = RaptorRender.rr_data.clients[client_id]
	
	NameLabel.text = selected_client["name"]
	
	
	var status = selected_client["status"]
	
	
	var icon = ImageTexture.new()
	
	match status:
		"1_rendering": icon.load("res://GUI/icons/client_status/200x100/client_status_rendering_200x100.png")
		"2_available": icon.load("res://GUI/icons/client_status/200x100/client_status_online_200x100.png")
		"3_error":     icon.load("res://GUI/icons/client_status/200x100/client_status_error_200x100.png")
		"4_disabled":  icon.load("res://GUI/icons/client_status/200x100/client_status_disabled_200x100.png")
		"5_offline":   icon.load("res://GUI/icons/client_status/200x100/client_status_offline_200x100.png")
		
	StatusIconTexture.set_texture(icon)
	
	
	
	match status:
		"1_rendering": StatusLabel.text = "Status:  Rendering"
		"2_available": StatusLabel.text = "Status:  Available"
		"3_error":     StatusLabel.text = "Status:  Error"
		"4_disabled":  StatusLabel.text = "Status:  Disabled"
		"5_offline":   StatusLabel.text = "Status:  Offline"
	
	if status != "5_offline":	
		UptimeLabel.text = "Uptime:  " + TimeFunctions.time_elapsed_as_string(selected_client["time_connected"], OS.get_unix_time(), 2)
	else:
		UptimeLabel.text = "Last seen:  not implemented yet" 
	
	
	###############
	#  CPU Section
	###############
	
	var cpu_text = ""
	
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
	
	
	
	
	###################
	#  Memory Section
	###################	
	
	var size_in_gb =  String( float(selected_client["memory"]) / 1024 / 1024 )
	RAMLabel.text = size_in_gb.left(size_in_gb.find(".")+ 3) + " GB"
	
	
	
	
	###################
	#  Graphics Section
	###################
	
	var graphics_text = ""
	for i in range(0, selected_client["graphics"].size()):
		graphics_text += selected_client["graphics"][i] + "\n"
		
	if graphics_text.ends_with("\n"):
		graphics_text = graphics_text.substr(0,graphics_text.length()-1)	
	GraphicsLabel.text = graphics_text
	
	
	
	##################
	# Network Section
	##################
	
	if selected_client["ip_addresses"].size() > 1:
		var text = "IP Addresses: \n"
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
		var text = "MAC Addresses: \n"
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
	