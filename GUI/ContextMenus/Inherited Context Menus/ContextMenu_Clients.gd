tool

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
	
	self.add_item("Wake over LAN", 8, 0)
	self.add_item("Shutdown computer", 9, 0)
	self.add_item("Reboot computer", 10, 0)
	self.add_separator()
	self.add_item("Execute command on client", 12, 0)
	self.add_separator()
	self.add_item("Remove Client", 14, 0)
	
	# trick to calculate the correct size of the popup, so it doesn't display outside of the windo when invoked
	self.visible = true
	self.visible = false




func enable_disable_items():
	
	self.set_item_disabled(0, true)  # Enable Client
	self.set_item_disabled(1, true)  # Diable Client Deffered
	self.set_item_disabled(2, true)  # Diable Client Immediately
	self.set_item_disabled(4, true)  # Configure Client
	self.set_item_disabled(6, true)  # Error Count
	self.set_item_disabled(8, true)  # Wake over LAN
	self.set_item_disabled(9, true)  # Shutdwon Computer
	self.set_item_disabled(10, true)  # Reboot Computer
	self.set_item_disabled(12, true)  # Execute Command
	self.set_item_disabled(14, true)  # Remove Client
	
	
	var selected_ids = RaptorRender.TableClients.get_selected_content_ids()
	
	for selected in selected_ids:
		
		var status =  RaptorRender.rr_data.clients[selected].status
		
		# Enable Client		
		if status == "4_disabled":
			self.set_item_disabled(0, false)
		
		# Disable Client	
		if status == "1_rendering" or status == "2_available" or status == "3_error":
			self.set_item_disabled(1, false)
			self.set_item_disabled(2, false)
			
		# Configure Client	
		if status != "5_offline":
			self.set_item_disabled(4, false)
			
		# Error Count	
		if status != "5_offline":
			self.set_item_disabled(6, false)
		
		# Wake over LAN
		if status == "5_offline":
			self.set_item_disabled(8, false)
			
		# Shutdown Computer
		if status == "4_disabled" or status == "2_available" or status == "3_error":
			self.set_item_disabled(9, false)
		
		# Reboot Computer
		if status == "4_disabled" or status == "2_available" or status == "3_error":
			self.set_item_disabled(10, false)
			
		# Execute Command
		if status != "5_offline":
			self.set_item_disabled(12, false)
		
		# Remove Client
		if status == "5_offline":
			self.set_item_disabled(14, false)
	





func _on_ContextMenu_index_pressed(index):
	match index:
		
		0:  # Enable Client
			
			var selected_ids = RaptorRender.TableClients.get_selected_content_ids()
			
			for selected in selected_ids:
				
				if RaptorRender.rr_data.clients[selected].status == "4_disabled":
					
					RaptorRender.rr_data.clients[selected].status = "2_available"
			
			RaptorRender.TableClients.refresh()
			
			
			
		1:  # Disable Client Deffered
			
			var selected_ids = RaptorRender.TableClients.get_selected_content_ids()
			
			for selected in selected_ids:
				
				var status =  RaptorRender.rr_data.clients[selected].status
				
				if status == "1_rendering" or status == "2_available" or status == "3_error":
					
					RaptorRender.rr_data.clients[selected].status = "4_disabled"
				
			RaptorRender.TableClients.refresh()
			
			
				
		2:  # Disable Client Immediately
			
			var selected_ids = RaptorRender.TableClients.get_selected_content_ids()
			
			for selected in selected_ids:
				
				var status =  RaptorRender.rr_data.clients[selected].status
				
				if status == "1_rendering" or status == "2_available" or status == "3_error":
					
					RaptorRender.rr_data.clients[selected].status = "4_disabled"
			
			RaptorRender.TableClients.refresh()
			
			
			
		3:  # Separator
			pass	
			
			
		
		4:  # Configure Client	
			print ( "Configure Client - not implemented yet")
			
			
		
		5:  # Separator
			pass		
			
			
			
		6:  # Reset Client Error count
			
			var selected_ids = RaptorRender.TableClients.get_selected_content_ids()
			
			for selected in selected_ids:
				RaptorRender.rr_data.clients[selected].error_count = 0
			
			RaptorRender.TableClients.refresh()
		
		
		
		7:  # Separator
			pass	
			
			
			
		8:  # Wake over LAN
			print ( "Wake over Lan - not implemented yet")
			
			
			
		9:  # Shutdown Client
			print ( "Shutdown client - not implemented yet")
			
			
			
		10:  # Reboot Client
			print ( "Reboot Client - not implemented yet")
			
			
			
		11:  # Separator
			pass
		
		
		
		12:  # Execute Command
			print ( "Execute Command - not implemented yet")
		
		
		
		13:  # Separator
			pass
			
			
			
		14:  # Remove Client
			
			var selected_ids = RaptorRender.TableClients.get_selected_content_ids()
			
			for selected in selected_ids:
				
				var status =  RaptorRender.rr_data.clients[selected].status
				
				if status == "5_offline":
					
					RaptorRender.rr_data.clients.erase(selected)
			
			RaptorRender.TableClients.refresh()





	

