extends PopupMenu

func _ready():
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
	self.add_item("Remove Client", 14, 0)
	
	# trick to calculate the correct size of the popup, so it doesn't display outside of the windo when invoked
	self.visible = true
	self.visible = false


func set_item_names():
	
	if RaptorRender.ClientsTable.get_selected_ids().size() <= 1:
		self.set_item_text(0, "Enable Client")
		self.set_item_text(1, "Disable Client Deferred")
		self.set_item_text(2, "Disable Client Immediately")
		self.set_item_text(4, "Configure Client")
		self.set_item_text(6, "Reset Client Error Count")
		self.set_item_text(8, "Wake on LAN")
		self.set_item_text(9, "Shutdown Computer")
		self.set_item_text(10, "Reboot Computer")
		self.set_item_text(12, "Execute command on client")
		self.set_item_text(14, "Remove Client")
	else:
		self.set_item_text(0, "Enable Clients")
		self.set_item_text(1, "Disable Clients Deferred")
		self.set_item_text(2, "Disable Clients Immediately")
		self.set_item_text(4, "Configure Clients")
		self.set_item_text(6, "Reset Client Error Counts")
		self.set_item_text(8, "Wake on LAN")
		self.set_item_text(9, "Shutdown Computers")
		self.set_item_text(10, "Reboot Computers")
		self.set_item_text(12, "Execute command on clients")
		self.set_item_text(14, "Remove Clients")



func enable_disable_items():
	
	self.set_item_disabled(0, true)  # enable client
	self.set_item_disabled(1, true)  # diable client deffered
	self.set_item_disabled(2, true)  # diable client immediately
	self.set_item_disabled(4, true)  # configure client
	self.set_item_disabled(6, true)  # reset client error count
	self.set_item_disabled(8, true)  # wake on LAN
	self.set_item_disabled(9, true)  # shutdown computer
	self.set_item_disabled(10, true)  # reboot computer
	self.set_item_disabled(12, true)  # execute command
	self.set_item_disabled(14, true)  # remove client
	
	
	var selected_ids = RaptorRender.ClientsTable.get_selected_ids()
	
	for selected in selected_ids:
		
		var status =  RaptorRender.rr_data.clients[selected].status
		
		if status == RRStateScheme.client_rendering:
			self.set_item_disabled(1, false) # diable client deffered
			self.set_item_disabled(2, false) # diable client immediately
			self.set_item_disabled(4, false) # configure client
			self.set_item_disabled(6, false) # reset client error count
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
			self.set_item_disabled(14, false) # remove client






func _on_ContextMenu_index_pressed(index):
	match index:
		
		0:  # Enable Client
			
			var selected_ids = RaptorRender.ClientsTable.get_selected_ids()
			
			for selected in selected_ids:
				
				if RaptorRender.rr_data.clients[selected].status == RRStateScheme.client_disabled:
					
					RaptorRender.rr_data.clients[selected].status = RRStateScheme.client_available
			
			RaptorRender.ClientsTable.refresh()
			
			
			
		1:  # Disable Client Deffered
			
			var selected_ids = RaptorRender.ClientsTable.get_selected_ids()
			
			for selected in selected_ids:
				
				var status =  RaptorRender.rr_data.clients[selected].status
				
				if status == RRStateScheme.client_rendering or status == RRStateScheme.client_available or status == RRStateScheme.client_error:
					
					RaptorRender.rr_data.clients[selected].status = RRStateScheme.client_disabled
				
			RaptorRender.ClientsTable.refresh()
			
			
				
		2:  # Disable Client Immediately
			
			var selected_ids = RaptorRender.ClientsTable.get_selected_ids()
			
			for selected in selected_ids:
				
				var status =  RaptorRender.rr_data.clients[selected].status
				
				if status == RRStateScheme.client_rendering or status == RRStateScheme.client_available or status == RRStateScheme.client_error:
					
					RaptorRender.rr_data.clients[selected].status = RRStateScheme.client_disabled
			
			RaptorRender.ClientsTable.refresh()
			
			
			
		3:  # Separator
			pass	
			
			
		
		4:  # Configure Client	
			RaptorRender.NotificationSystem.add_error_notification("Error", "Not implemented yet!", 5)
			
			
			
		
		5:  # Separator
			pass		
			
			
			
		6:  # Reset Client Error count
			
			var selected_ids = RaptorRender.ClientsTable.get_selected_ids()
			
			for selected in selected_ids:
				RaptorRender.rr_data.clients[selected].error_count = 0
			
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
					var pac = Converters.hex_string_to_PoolByteArray(msg)
					
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
				RaptorRender.NotificationSystem.add_info_notification("Info", String(amount_of_computer_tried_to_wake_up) + " machines should wake up soon, if they support WakeOnLan...", 9)
			else:
				RaptorRender.NotificationSystem.add_info_notification("Info", "Your machine should wake up soon, if it supports WakeOnLan...", 9)
			
			
		9:  # Shutdown Client
			RaptorRender.NotificationSystem.add_error_notification("Error", "Not implemented yet!", 5)
			
#			# Linux
#			var arguments = ["-P", "now", "Raptor Render shuts down your System!"]
#			var result = []
#			OS.execute("shutdown", arguments, false, result)

#			# Windows
#			var arguments = ["-s", "-t", "0"]
#			var result = []
#			OS.execute("shutdown", arguments, false, result)
			
			
		10:  # Reboot Client
			RaptorRender.NotificationSystem.add_error_notification("Error", "Not implemented yet!", 5)
			
#			# Linux 
#			var arguments = ["-r", "now", "Raptor Render reboots your System!"]
#			var result = []
#			OS.execute("shutdown", arguments, false, result)
			
#			# Windows
#			var arguments = ["-r", "-t","0"]
#			var result = []
#			OS.execute("shutdown", arguments, false, result)
			
		11:  # Separator
			pass
		
		
		
		12:  # Execute Command
			RaptorRender.NotificationSystem.add_error_notification("Error", "Not implemented yet!", 5)
		
		
		
		13:  # Separator
			pass
			
			
			
		14:  # Remove Client
			
			var selected_ids = str2var( var2str( RaptorRender.ClientsTable.get_selected_ids() ))  # str2var hack needed to make sure it's not just a reference. Because the reference would change as rows get deleted...
			
			for selected in selected_ids:
				
				
				var status =  RaptorRender.rr_data.clients[selected].status
				
				if status == RRStateScheme.client_offline:
					
					# id reset for Client Info Panel of CPU and memory brs. Otherwise it would crash
					RaptorRender.ClientInfoPanel.CPUUsageBar.client_id = ""
					RaptorRender.ClientInfoPanel.MemoryUsageBar.client_id = ""
					
					# remove from database
					RaptorRender.rr_data.clients.erase(selected)
				
				
					# remove the row from the table
					RaptorRender.ClientsTable.remove_row(selected)
				
			# handle the Clients Info Panel
			RaptorRender.ClientsTable.clear_selection()
			RaptorRender.ClientInfoPanel.visible = false
			RaptorRender.ClientInfoPanel.reset_to_first_tab()
				
				
			RaptorRender.ClientsTable.refresh()



