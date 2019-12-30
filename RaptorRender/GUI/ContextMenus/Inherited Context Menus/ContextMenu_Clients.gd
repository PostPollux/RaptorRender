extends PopupMenu

### PRELOAD RESOURCES

### SIGNALS

### ONREADY VARIABLES

### EXPORTED VARIABLES

### VARIABLES
var PoolSubmenu : PopupMenu = PopupMenu.new()



########## FUNCTIONS ##########


func _ready() -> void:
	
	PoolSubmenu.set_name("PoolSubmenu")
	PoolSubmenu.connect("id_pressed", self, "pool_submenu_item_selected")
	
	self.add_item("Enable Client", 0, 0)
	self.add_item("Disable Client Deferred", 1, 0)
	self.add_item("Disable Client Immediately", 2, 0)
	self.add_separator()
	self.add_item("Configure Client", 4, 0)
	self.add_separator()
	self.add_item("Reset Client Error count", 6, 0)
	self.add_separator()
	
	self.add_item("Wake on LAN", 8, 0)
	self.add_item("Shutdown computer", 9, 0)
	self.add_item("Reboot computer", 10, 0)
	self.add_separator()
	self.add_item("Execute command on client", 12, 0)
	self.add_separator()
	self.add_submenu_item("Add to pool", "PoolSubmenu", 14)
	self.add_item("Remove from this pool", 15, 0)
	self.add_separator()
	self.add_item("Remove Client", 17, 0)
	
	# trick to calculate the correct size of the popup, so it doesn't display outside of the window when invoked
	self.visible = true
	self.visible = false
	
	set_item_names()



# override show function to make sure the PoolSubmenu is always up to date if we show the clients context menu
func show() -> void:
	
	PoolSubmenu.clear()
	for pool in RaptorRender.rr_data.pools.keys():
		PoolSubmenu.add_item(RaptorRender.rr_data.pools[pool].name, pool)
	self.add_child(PoolSubmenu)
	
	# don't forget to call the original function of the parent
	.show()



func set_item_names() -> void:
	
	if RaptorRender.ClientsTable.get_selected_ids().size() <= 1:
		self.set_item_text(0, "CLIENT_CONTEXT_MENU_1") # Enable Client
		self.set_item_text(1, "CLIENT_CONTEXT_MENU_2") # Disable Client Deferred
		self.set_item_text(2, "CLIENT_CONTEXT_MENU_3") #Disable Client Immediately
		self.set_item_text(4, "CLIENT_CONTEXT_MENU_4") # Configure Client
		self.set_item_text(6, "CLIENT_CONTEXT_MENU_5") # Reset Client Error Count
		self.set_item_text(8, "CLIENT_CONTEXT_MENU_6") # Wake on LAN
		self.set_item_text(9, "CLIENT_CONTEXT_MENU_7") # Shutdown Computer
		self.set_item_text(10, "CLIENT_CONTEXT_MENU_8") # Reboot Computer
		self.set_item_text(12, "CLIENT_CONTEXT_MENU_9") # Execute command on client
		self.set_item_text(14, "CLIENT_CONTEXT_MENU_20") # Add to Pool
		self.set_item_text(15, "CLIENT_CONTEXT_MENU_21") # Remove from this Pool
		self.set_item_text(17, "CLIENT_CONTEXT_MENU_10") # Remove Client
	else:
		self.set_item_text(0, "CLIENT_CONTEXT_MENU_11") # Enable Clients
		self.set_item_text(1, "CLIENT_CONTEXT_MENU_12") # Disable Clients Deferred
		self.set_item_text(2, "CLIENT_CONTEXT_MENU_13") # Disable Clients Immediately
		self.set_item_text(4, "CLIENT_CONTEXT_MENU_14") # Configure Clients
		self.set_item_text(6, "CLIENT_CONTEXT_MENU_15") # Reset Client Error Counts
		self.set_item_text(8, "CLIENT_CONTEXT_MENU_16") # Wake on LAN
		self.set_item_text(9, "CLIENT_CONTEXT_MENU_17") # Shutdown Computers
		self.set_item_text(10, "CLIENT_CONTEXT_MENU_18") # Reboot Computers
		self.set_item_text(12, "CLIENT_CONTEXT_MENU_19") # Execute command on clients
		self.set_item_text(14, "CLIENT_CONTEXT_MENU_20") # Add to Pool
		self.set_item_text(15, "CLIENT_CONTEXT_MENU_21") # Remove from this Pool
		self.set_item_text(17, "CLIENT_CONTEXT_MENU_22") # Remove Clients



func enable_disable_items() -> void:
	
	# disable all
	self.set_item_disabled(0, true)  # enable client
	self.set_item_disabled(1, true)  # diable client deffered
	self.set_item_disabled(2, true)  # diable client immediately
	self.set_item_disabled(4, true)  # configure client
	self.set_item_disabled(6, true)  # reset client error count
	self.set_item_disabled(8, true)  # wake on LAN
	self.set_item_disabled(9, true)  # shutdown computer
	self.set_item_disabled(10, true)  # reboot computer
	self.set_item_disabled(12, true)  # execute command
	self.set_item_disabled(14, true)  # add to pool
	self.set_item_disabled(15, true)  # remove from this pool
	self.set_item_disabled(17, true)  # remove client
	
	
	var selected_ids = RaptorRender.ClientsTable.get_selected_ids()
	
	# now enable correct ones
	for selected in selected_ids:
		
		var status =  RaptorRender.rr_data.clients[selected].status
		
		
		if status == RRStateScheme.client_rendering:
			self.set_item_disabled(1, false) # diable client deffered
			self.set_item_disabled(2, false) # diable client immediately
			self.set_item_disabled(4, false) # configure client
			self.set_item_disabled(6, false) # reset client error count
			self.set_item_disabled(9, false) # shutdown computer
			self.set_item_disabled(10, false) # reboot computer
			self.set_item_disabled(12, false) # execute command
		
		if status == RRStateScheme.client_available:
			self.set_item_disabled(2, false) # diable client immediately
			self.set_item_disabled(4, false) # configure client
			self.set_item_disabled(6, false) # reset client error count
			self.set_item_disabled(9, false) # shutdown computer
			self.set_item_disabled(10, false) # reboot computer
			self.set_item_disabled(12, false) # execute command
		
		if status == RRStateScheme.client_error:
			self.set_item_disabled(1, false) # diable client deffered
			self.set_item_disabled(2, false) # diable client immediately
			self.set_item_disabled(6, false) # reset client error count
			self.set_item_disabled(9, false) # shutdown computer
			self.set_item_disabled(10, false) # reboot computer
			self.set_item_disabled(12, false) # execute command
		
		if status == RRStateScheme.client_disabled:
			self.set_item_disabled(0, false) # enable client
			self.set_item_disabled(4, false) # configure client
			self.set_item_disabled(6, false) # reset client error count
			self.set_item_disabled(9, false) # shutdown computer
			self.set_item_disabled(10, false) # reboot computer
			self.set_item_disabled(12, false) # execute command
		
		if status == RRStateScheme.client_offline:
			self.set_item_disabled(4, false) # configure client
			self.set_item_disabled(6, false) # reset client error count
			self.set_item_disabled(8, false) # wake on LAN
			self.set_item_disabled(17, false) # remove client
			
		
		if RaptorRender.clients_pool_filter != -1:
			self.set_item_disabled(15, false)
		
		# always enabled options
		self.set_item_disabled(14, false)  # add to pool




func _on_ContextMenu_index_pressed(index) -> void:
	match index:
		
		0:  # Enable Client
			
			var selected_ids = RaptorRender.ClientsTable.get_selected_ids()
			
			for peer in RRNetworkManager.management_gui_clients:
				RRNetworkManager.rpc_id(peer, "update_client_states", selected_ids, RRStateScheme.client_available)
			
			RaptorRender.ClientsTable.refresh()
			
			
			
		1:  # Disable Client Deffered
			
			var selected_ids = RaptorRender.ClientsTable.get_selected_ids()
			
			for peer in RRNetworkManager.management_gui_clients:
				RRNetworkManager.rpc_id(peer, "update_client_states", selected_ids, RRStateScheme.client_rendering_disabled_deferred)
				
			RaptorRender.ClientsTable.refresh()
			
			
			
		2:  # Disable Client Immediately
			
			var selected_ids = RaptorRender.ClientsTable.get_selected_ids()
			
			for peer in RRNetworkManager.management_gui_clients:
				RRNetworkManager.rpc_id(peer, "update_client_states", selected_ids, RRStateScheme.client_disabled)
			
			RaptorRender.ClientsTable.refresh()
			
			
			
		3:  # Separator
			pass	
			
			
		
		4:  # Configure Client	
			RaptorRender.NotificationSystem.add_error_notification(tr("MSG_ERROR_1"), tr("MSG_ERROR_2"), 5) # Not implemented yet
			
			
			
		
		5:  # Separator
			pass
			
			
			
		6:  # Reset Client Error count
			
			var selected_ids = RaptorRender.ClientsTable.get_selected_ids()
			
			for selected in selected_ids:
				for peer in RRNetworkManager.management_gui_clients:
					RRNetworkManager.rpc_id(peer, "reset_client_errors", selected)
			
			RaptorRender.ClientsTable.refresh()
			
			
			
		7:  # Separator
			pass
			
			
			
		8:  # Wake on LAN
			
			# magic packet hat a total of 102 bytes
			# first six bytes are all 255 in hex so "FF" -> FF FF FF FF FF FF
			# next 96 bytes are 16 repetitions of the destination Mac adress (which are also 6 bytes in hex each)
			
			var amount_of_computer_tried_to_wake_up = 0
			var mac_addresses = []
			
			# fill the mac_addresses array with all the mac addresssess that are supposed to recieve a WOL package
			var selected_ids = RaptorRender.ClientsTable.get_selected_ids()
			
			for selected in selected_ids:
				if RaptorRender.rr_data.clients[selected].status == RRStateScheme.client_offline:
					amount_of_computer_tried_to_wake_up  += 1
					var mac_addresses_of_selected = RaptorRender.rr_data.clients[selected].mac_addresses
					for mac_address_of_selected in mac_addresses_of_selected:
						mac_address_of_selected = mac_address_of_selected.replace(":","")  # remove ":"
						mac_addresses.append(mac_address_of_selected)
			
			
			# create an UDP Socket
			var socketUDP = PacketPeerUDP.new()
			
			var port = 9
			var ip 
			
			for ip_addr in GetSystemInformation.ip_addresses:
				
				var ip_bytes = ip_addr.split(".", false, 0)
			
				# send WOL packets for each mac address
				for mac in mac_addresses:
					
					# create the message to send via udp. ( ffffffffffff + 16 x Mac Address ) 
					var msg = "ffffffffffff"
					for i in range (0,16):
						msg = msg + mac
					
					# convert it to PoolByteArray
					var pac = RRFunctions.hex_string_to_PoolByteArray(msg)
					
					# send all packages twice, because udp packages could get lost
					for i in range(0, 2):
						
						# send packets with different broadcast patterns
						
						ip = "255.255.255.255"
						socketUDP.set_dest_address(ip, port)
						socketUDP.put_packet(pac)
						
						ip = ip_bytes[0] + ".255.255.255"
						socketUDP.set_dest_address(ip, port)
						socketUDP.put_packet(pac)
						
						ip = ip_bytes[0] + "." + ip_bytes[1] + ".255.255"
						socketUDP.set_dest_address(ip, port)
						socketUDP.put_packet(pac)
						
						ip = ip_bytes[0] + "." + ip_bytes[1] + "." + ip_bytes[2] + ".255"
						socketUDP.set_dest_address(ip, port)
						socketUDP.put_packet(pac)
			
			
			# close UDP Socket
			socketUDP.close()
			
			if amount_of_computer_tried_to_wake_up > 1:
				RaptorRender.NotificationSystem.add_info_notification(tr("MSG_INFO_1"), String(amount_of_computer_tried_to_wake_up) + " " +  tr("MSG_INFO_3"), 9) # x machines should wake up soon, if they supports WakeOnLan…
			else:
				RaptorRender.NotificationSystem.add_info_notification(tr("MSG_INFO_1"), tr("MSG_INFO_2"), 9) # Your machine should wake up soon, if it supports WakeOnLan!
			
			
			
		9:  # Shutdown Client
			
			var selected_ids : Array = RaptorRender.ClientsTable.get_selected_ids()
			var final_selected_ids : Array = []
			
			for selected in selected_ids:
				if RaptorRender.rr_data.clients[selected].status != RRStateScheme.client_offline:
					final_selected_ids.append(selected)
			
			var selected_id_size : int = final_selected_ids.size()
			
			for selected in final_selected_ids:
				
				for peer in RRNetworkManager.peer_id_client_id_dict:
					if RRNetworkManager.peer_id_client_id_dict[peer] == selected:
						if peer != 1:
							RRNetworkManager.rpc_id(peer, "shutdown")
						else:
							selected_id_size -= 1
							RaptorRender.NotificationSystem.add_error_notification(tr("MSG_ERROR_1"), tr("MSG_INFO_7"), 8) # For safety reasons the server can't be shut down this way.
						break
			
			if selected_id_size > 1:
				RaptorRender.NotificationSystem.add_info_notification(tr("MSG_INFO_1"), String(selected_id_size) + " " + tr("MSG_INFO_6"), 8) # x machines will shut down in a few seconds...
			elif selected_id_size == 1:
				RaptorRender.NotificationSystem.add_info_notification(tr("MSG_INFO_1"), tr("MSG_INFO_5").replace("{client_name}", RaptorRender.rr_data.clients[final_selected_ids[0]].machine_properties.name), 8) # {client_name} will shut down in a few seconds...
			
			
			
		10:  # Reboot Client
			var selected_ids : Array = RaptorRender.ClientsTable.get_selected_ids()
			var final_selected_ids : Array = []
			
			for selected in selected_ids:
				if RaptorRender.rr_data.clients[selected].status != RRStateScheme.client_offline:
					final_selected_ids.append(selected)
			
			var selected_id_size : int = final_selected_ids.size()
			
			for selected in final_selected_ids:
				
				for peer in RRNetworkManager.peer_id_client_id_dict:
					if RRNetworkManager.peer_id_client_id_dict[peer] == selected:
						if peer != 1:
							RRNetworkManager.rpc_id(peer, "reboot")
						else:
							selected_id_size -= 1
							RaptorRender.NotificationSystem.add_error_notification(tr("MSG_ERROR_1"), tr("MSG_INFO_10"), 8) # For safety reasons the server can't be rebooted this way.
						break
			
			if selected_id_size > 1:
				RaptorRender.NotificationSystem.add_info_notification(tr("MSG_INFO_1"), String(selected_id_size) + " " + tr("MSG_INFO_9"), 8) # x machines will reboot in a few seconds...
			elif selected_id_size == 1:
				RaptorRender.NotificationSystem.add_info_notification(tr("MSG_INFO_1"), tr("MSG_INFO_8").replace("{client_name}", RaptorRender.rr_data.clients[final_selected_ids[0]].machine_properties.name), 8) # {client_name} will reboot in a few seconds...
			
			
			
		11:  # Separator
			pass
		
		
		
		12:  # Execute Command
			var selected_ids : Array = RaptorRender.ClientsTable.get_selected_ids()
			var final_selected_ids : Array = []
			
			var command : String = "brave"
			
			for selected in selected_ids:
				if RaptorRender.rr_data.clients[selected].status != RRStateScheme.client_offline:
					final_selected_ids.append(selected)
			
			var selected_id_size : int = final_selected_ids.size()
			
			for selected in final_selected_ids:
				for peer in RRNetworkManager.peer_id_client_id_dict:
					if RRNetworkManager.peer_id_client_id_dict[peer] == selected:
						RRNetworkManager.rpc_id(peer, "execute_command", command)
				
			if selected_id_size > 1:
				RaptorRender.NotificationSystem.add_info_notification(tr("MSG_INFO_1"), String(selected_id_size) + " " + tr("MSG_INFO_12").replace("{command}", command).replace("{number}", String(selected_id_size)), 8) # The command "{command}" has been executed on {number} computers.
			elif selected_id_size == 1:
				RaptorRender.NotificationSystem.add_info_notification(tr("MSG_INFO_1"), tr("MSG_INFO_11").replace("{command}", command).replace("{client_name}", RaptorRender.rr_data.clients[final_selected_ids[0]].machine_properties.name), 8) # The command "{command}" has been executed on {client_name}.
		
		
		13:  # Separator
			pass
		
		
		
		14:  # Add to Pool
			# spawns a submenu
			pass 
		
		
		15:  # Remove from this Pool
			
			var selected_ids = RaptorRender.ClientsTable.get_selected_ids().duplicate()  # duplicate needed because the reference would change as rows get deleted...
			
			for selected in selected_ids:
				RaptorRender.rr_data.pools[RaptorRender.clients_pool_filter].clients.erase(selected)
			
			for peer in RRNetworkManager.management_gui_clients:
				RRNetworkManager.rpc_id(peer, "update_pools", RaptorRender.rr_data.pools)
		
		
		16:  # Separator
			pass
		
		
		17:  # Remove Client
			
			var selected_ids : Array = RaptorRender.ClientsTable.get_selected_ids().duplicate()  # duplicate needed because the reference would change as rows get deleted...
			var final_selected_ids : Array
			for selected in selected_ids:
				
				var status =  RaptorRender.rr_data.clients[selected].status
				
				if status == RRStateScheme.client_offline:
					final_selected_ids.append(selected)
			
			for peer in RRNetworkManager.management_gui_clients:
				RRNetworkManager.rpc_id(peer, "remove_clients", final_selected_ids)



func pool_submenu_item_selected(pool_id : int) -> void:
	
	var selected_ids = RaptorRender.ClientsTable.get_selected_ids()
		
	for selected in selected_ids:
		if not RaptorRender.rr_data.pools[pool_id].clients.has(selected):
			RaptorRender.rr_data.pools[pool_id].clients.append(selected)
	
	for peer in RRNetworkManager.management_gui_clients:
		RRNetworkManager.rpc_id(peer, "update_pools", RaptorRender.rr_data.pools)



