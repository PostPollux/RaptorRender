extends VBoxContainer


### PRELOAD RESOURCES

### SIGNALS

### ONREADY VARIABLES
onready var cmdLineEdit : LineEdit = $"MarginContainer/VBoxContainer/LineEdit"

### EXPORTED VARIABLES

### VARIABLES
var popup_base : AutoScalingPopup
var clients : Array





########## FUNCTIONS ##########


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	popup_base = get_parent().popup_base
	get_parent().connect("ok_pressed", self, "action_confirmed")
	
	cmdLineEdit.grab_focus()



func set_clients(selected_clients : Array) -> void:
	clients = selected_clients


func action_confirmed() -> void:
	
	var command : String = cmdLineEdit.text
	
	for client in clients:
		for peer in RRNetworkManager.peer_id_client_id_dict:
			if RRNetworkManager.peer_id_client_id_dict[peer] == client:
				if peer != get_tree().get_network_unique_id():
					RRNetworkManager.rpc_id(peer, "execute_command", command)
				else:
					RRNetworkManager.execute_command(command)
					
	if clients.size() > 1:
		RaptorRender.NotificationSystem.add_info_notification(tr("MSG_INFO_1"), tr("MSG_INFO_12").replace("{command}", command).replace("{number}", String(clients.size())), 8) # The command "{command}" has been executed on {number} computers.
	elif clients.size() == 1:
		RaptorRender.NotificationSystem.add_info_notification(tr("MSG_INFO_1"), tr("MSG_INFO_11").replace("{command}", command).replace("{client_name}", RaptorRender.rr_data.clients[clients[0]].machine_properties.name), 8) # The command "{command}" has been executed on {client_name}.
	
	# close the popup
	popup_base.hide_popup()
