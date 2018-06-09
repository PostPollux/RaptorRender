extends MarginContainer

onready var ClientInfoTabContainer = $"TabContainer"
onready var StatusIconTexture = $"TabContainer/Details/MarginContainer/VBoxContainer/MainInfo/HBoxContainer/Icon"
onready var NameLabel = $"TabContainer/Details/MarginContainer/VBoxContainer/MainInfo/HBoxContainer/MarginContainer/VBoxContainer/NameLabel"
onready var StatusLabel = $"TabContainer/Details/MarginContainer/VBoxContainer/MainInfo/HBoxContainer/MarginContainer/VBoxContainer/StatusLabel"
onready var UptimeLabel = $"TabContainer/Details/MarginContainer/VBoxContainer/MainInfo/HBoxContainer/MarginContainer/VBoxContainer/UptimeLabel"

onready var CPULabel = $"TabContainer/Details/MarginContainer/VBoxContainer/Specs/HBoxContainer/MarginContainer/VBoxContainer/CPULabel"
onready var RAMLabel = $"TabContainer/Details/MarginContainer/VBoxContainer/Specs/HBoxContainer/MarginContainer/VBoxContainer/RAMLabel"
onready var PlatformLabel = $"TabContainer/Details/MarginContainer/VBoxContainer/Specs/HBoxContainer/MarginContainer/VBoxContainer/PlatformLabel"
onready var IPLabel = $"TabContainer/Details/MarginContainer/VBoxContainer/Specs/HBoxContainer/MarginContainer/VBoxContainer/IPLabel"



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
		
	UptimeLabel.text = "Uptime:  " + selected_client["uptime"]
	
	CPULabel.text = "CPU:  " + selected_client["cpu"]
	RAMLabel.text = "Memory:  " + String(selected_client["memory"]) + " GB"
	PlatformLabel.text = "Platform:  " + selected_client["platform"]
	IPLabel.text = "IP:  " + selected_client["ip"]

