extends Node

var TableJobs
var TableClients

var rr_data = {}

func _ready():
	
	rr_data = {
		"jobs": {
			"job1": {
				"id": 1,
				"name": "job 1",
				"priority": 50,
				"creator": "Johannes",
				"time_created": "13.3.2018 - 16:23:44",
				"status": "rendering",
				"progress": 28,
				"range_start": 20,
				"range_end": 50,
				"chunks": {
					"1":{
						"status" : "queued",
						"frames_to_calculate" : [20,21,22,23]
					},
					"2":{
						"status" : "queued",
						"frames_to_calculate" : [24,25,26,27]
					}
				}
			},
			"job2": {
				"id": 2,
				"name": "second_job",
				"priority": 20,
				"creator": "Michael",
				"time_created": "1.3.2018 - 10:43:14",
				"status": "finished",
				"progress": 100,
				"range_start": 2,
				"range_end": 5,
				"chunks": {
					"1":{
						"status" : "finished",
						"frames_to_calculate" : [2,3,4,5]
					}
				}
			}
		},
		
		
		
		"clients": {
			"id1": {
				"name": "T-Rex1",
				"ip": "192.168.1.45",
				"status": "2_waiting",
				"platform": "Linux",
				"pools": ["AE_Plugins"],
				"rr_version": 1.2,
				"uptime": "2h",
				"cpu": "16 x 3,8GHZ",
				"memory": 32,
				"memory_used": 22,
				"graphics": "NVidia GTX 970",
				"software": ["Blender", "Natron", "Nuke"],
				"note": ""
			},
			"id2": {
				"name": "Raptor1",
				"ip": "192.168.1.22",
				"status": "4_disabled",
				"platform": "Windows",
				"pools": ["AE_Plugins", "another pool", "third pool"],
				"rr_version": 0.2,
				"uptime": "1h",
				"cpu": "8 x 4GHZ",
				"memory": 16,
				"memory_used": 2,
				"graphics": "Intel Onboard",
				"software": ["Blender", "Natron"],
				"note": ""
			},
			"id3": {
				"name": "T-Rex2",
				"ip": "192.168.1.156",
				"status": "1_rendering",
				"platform": "MacOS",
				"pools": ["AE_Plugins"],
				"rr_version": 1.2,
				"uptime": "2h",
				"cpu": "16 x 3,8GHZ",
				"memory": 64,
				"memory_used": 22,
				"graphics": "NVidia GTX 970",
				"software": ["Blender", "Natron", "Nuke"],
				"note": ""
			},
			"id4": {
				"name": "Raptor2",
				"ip": "192.168.1.87",
				"status": "5_offline",
				"platform": "Windows",
				"pools": ["AE_Plugins", "another pool", "third pool"],
				"rr_version": 0.2,
				"uptime": "1h",
				"cpu": "8 x 4GHZ",
				"memory": 8,
				"memory_used": 2,
				"graphics": "Intel Onboard",
				"software": ["Blender", "Natron"],
				"note": ""
			},
			"id5": {
				"name": "T-Rex3",
				"ip": "192.168.1.15",
				"status": "3_error",
				"platform": "Linux",
				"pools": ["AE_Plugins"],
				"rr_version": 1.2,
				"uptime": "2h",
				"cpu": "16 x 3,8GHZ",
				"memory": 4,
				"memory_used": 22,
				"graphics": "NVidia GTX 970",
				"software": ["Blender", "Natron", "Nuke"],
				"note": ""
			},
			"id6": {
				"name": "Raptor3",
				"ip": "192.168.1.22",
				"status": "5_offline",
				"platform": "Windows",
				"pools": ["AE_Plugins", "another pool", "third pool"],
				"rr_version": 0.2,
				"uptime": "1h",
				"cpu": "8 x 4GHZ",
				"memory": 16,
				"memory_used": 2,
				"graphics": "Intel Onboard",
				"software": ["Blender", "Natron"],
				"note": ""
			},
			"id7": {
				"name": "T-Rex4",
				"ip": "192.168.1.45",
				"status": "2_waiting",
				"platform": "Linux",
				"pools": ["AE_Plugins"],
				"rr_version": 1.2,
				"uptime": "2h",
				"cpu": "4 x 3,2GHZ",
				"memory": 32,
				"memory_used": 22,
				"graphics": "NVidia GTX 970",
				"software": ["Blender", "Natron", "Nuke"],
				"note": ""
			},
			"id8": {
				"name": "Raptor1",
				"ip": "192.168.1.22",
				"status": "4_disabled",
				"platform": "Windows",
				"pools": [],
				"rr_version": 0.2,
				"uptime": "1h",
				"cpu": "8 x 2,4GHZ",
				"memory": 16,
				"memory_used": 2,
				"graphics": "Intel Onboard",
				"software": ["Blender", "Natron"],
				"note": ""
			},
			"id9": {
				"name": "T-Rex1",
				"ip": "192.168.1.45",
				"status": "2_waiting",
				"platform": "Linux",
				"pools": ["AE_Plugins"],
				"rr_version": 1.2,
				"uptime": "2h",
				"cpu": "16 x 3,8GHZ",
				"memory": 32,
				"memory_used": 22,
				"graphics": "NVidia GTX 970",
				"software": ["Blender", "Natron", "Nuke"],
				"note": ""
			},
			"id10": {
				"name": "Raptor1",
				"ip": "192.168.1.22",
				"status": "2_waiting",
				"platform": "Windows",
				"pools": ["AE_Plugins", "8GB+ VRam"],
				"rr_version": 0.2,
				"uptime": "1h",
				"cpu": "8 x 4GHZ",
				"memory": 16,
				"memory_used": 2,
				"graphics": "Intel Onboard",
				"software": ["Blender", "Natron"],
				"note": "my workstation"
			},
			"id11": {
				"name": "T-Rex2",
				"ip": "192.168.1.156",
				"status": "1_rendering",
				"platform": "MacOS",
				"pools": ["AE_Plugins"],
				"rr_version": 1.2,
				"uptime": "2h",
				"cpu": "16 x 3,8GHZ",
				"memory": 64,
				"memory_used": 22,
				"graphics": "NVidia GTX 970",
				"software": ["Blender", "Natron", "Nuke"],
				"note": "NVidia GTX 970"
			},
			"id12": {
				"name": "Nedry",
				"ip": "192.168.1.87",
				"status": "2_waiting",
				"platform": "Windows",
				"pools": ["AE_Plugins", "8GB+ VRam", "third pool"],
				"rr_version": 0.2,
				"uptime": "100h",
				"cpu": "12 x 4GHZ",
				"memory": 16,
				"memory_used": 2,
				"graphics": "Intel Onboard",
				"software": ["Blender", "Natron"],
				"note": ""
			},
			"id13": {
				"name": "T-Rex3",
				"ip": "192.168.1.15",
				"status": "3_error",
				"platform": "Linux",
				"pools": ["AE_Plugins", "8GB+ VRam"],
				"rr_version": 1.2,
				"uptime": "5h",
				"cpu": "6 x 3,8GHZ",
				"memory": 4,
				"memory_used": 22,
				"graphics": "NVidia GTX 970",
				"software": ["Blender", "Natron", "Nuke"],
				"note": ""
			},
			"id14": {
				"name": "Raptor3",
				"ip": "192.168.1.22",
				"status": "5_offline",
				"platform": "Windows",
				"pools": ["AE_Plugins", "another pool", "third pool"],
				"rr_version": 0.2,
				"uptime": "1h",
				"cpu": "2 x 4GHZ",
				"memory": 16,
				"memory_used": 2,
				"graphics": "Intel Onboard",
				"software": ["Blender", "Natron"],
				"note": ""
			},
			"id15": {
				"name": "Dr.Malcom",
				"ip": "192.168.1.45",
				"status": "2_waiting",
				"platform": "Linux",
				"pools": ["8GB+ VRam"],
				"rr_version": 1.2,
				"uptime": "20h",
				"cpu": "12 x 3,2GHZ",
				"memory": 2,
				"memory_used": 22,
				"graphics": "NVidia GTX 970",
				"software": ["Blender", "Natron", "Nuke"],
				"note": "Just a slow computer"
			},
			"id16": {
				"name": "Hammond",
				"ip": "192.168.1.22",
				"status": "4_disabled",
				"platform": "Windows",
				"pools": ["AE_Plugins", "another pool", "third pool"],
				"rr_version": 0.2,
				"uptime": "11h",
				"cpu": "24 x 2,4GHZ",
				"memory": 128,
				"memory_used": 2,
				"graphics": "Intel Onboard",
				"software": ["Blender", "Natron"],
				"note": "The Monster Machine!"
			}
		}
	}
	
	#test_prints()
	
	



func register_table(SortableTable):  

	var sortable_table_id = SortableTable.table_id  
	
	match sortable_table_id: 
		"jobs":
			TableJobs = SortableTable
			
		"clients": 
			TableClients = SortableTable 
			TableClients.connect("refresh_table_content", self, "refresh_clients_table")



func _input(event):
	
	if Input.is_key_pressed(KEY_R):
		refresh_clients_table()
		
		
		



func refresh_clients_table():
	
	
	#### define the columns of the clients table ####
	var status_column = 1
	var name_column = 2
	var platform_column = 3
	var cpu_column = 4
	var memory_column = 5
	
	var pools_column = 8
	var note_column = 9
	var rr_version_column = 10
	
	#### get all clients
	var clients_array = rr_data.clients.keys()
	
	
	#### sort clients_array ####
	
#	var sortable_table_id = SortableTable.table_id  
	
#
#	match sortable_table_id: 
#		"jobs": TableJobs = SortableTable 
#		"clients": primary = rr_data.clients[client].memory 
		
	var sortable_clients_array = []
	
	for client in clients_array:
		
		var primary = rr_data.clients[client].platform
		var secondary = rr_data.clients[client].memory
		
		match TableClients.sort_column_primary: 
		
			1: primary = rr_data.clients[client].status
			2: primary = rr_data.clients[client].name
			3: primary = rr_data.clients[client].platform
			4: primary = rr_data.clients[client].cpu
			5: primary = rr_data.clients[client].memory
			8: primary = rr_data.clients[client].pools.size()
			9: primary = rr_data.clients[client].note
			10: primary = rr_data.clients[client].rr_version 
		
		match TableClients.sort_column_secondary: 
		
			1: secondary = rr_data.clients[client].status
			2: secondary = rr_data.clients[client].name
			3: secondary = rr_data.clients[client].platform
			4: secondary = rr_data.clients[client].cpu
			5: secondary = rr_data.clients[client].memory
			8: secondary = rr_data.clients[client].pools.size()
			9: secondary = rr_data.clients[client].note
			10: secondary = rr_data.clients[client].rr_version 
		
		sortable_clients_array.append([client, primary, secondary ])
	
	
	sortable_clients_array.sort_custom ( self, "clients_table_sort" )
	
	
	#### create the correct amount of rows in RowContainerFilled ####
	
	#TableClients.create_rows(clients_array.size())
	#TableClients.
	#update_ids_of_rows()
	
	#### Fill Clients Table ####
	
	var count = 1
	
	for client in sortable_clients_array:


		TableClients.set_row_content_id(count, client[0])

		# Status Icon
		
		var StatusIcon = TextureRect.new()
		StatusIcon.set_expand(true)
		StatusIcon.set_stretch_mode(6) # 6 - keep aspect centered
		StatusIcon.set_v_size_flags(3) # fill + expand
		StatusIcon.set_h_size_flags(3) # fill + expand
		StatusIcon.rect_min_size.x = 54
		
		var icon = ImageTexture.new()
		
		
		if rr_data.clients[client[0]].status == "1_rendering":
			icon.load("res://GUI/icons/client_status/58x30/client_status_rendering_58x30_2.png")
			
		elif rr_data.clients[client[0]].status == "2_waiting":
			icon.load("res://GUI/icons/client_status/58x30/client_status_online_58x30.png")

		elif rr_data.clients[client[0]].status == "3_error":
			icon.load("res://GUI/icons/client_status/58x30/client_status_error_58x30.png")

		elif rr_data.clients[client[0]].status == "4_disabled":
			icon.load("res://GUI/icons/client_status/58x30/client_status_disabled_58x30.png")

		elif rr_data.clients[client[0]].status == "5_offline":
			icon.load("res://GUI/icons/client_status/58x30/client_status_offline_58x30.png")
			StatusIcon.set_modulate(Color("88ffffff"))
		
		StatusIcon.set_texture(icon)
		TableClients.set_cell_content(count, status_column, StatusIcon)


		# Name

		var LabelName = Label.new()
		LabelName.text = rr_data.clients[client[0]].name
		TableClients.set_cell_content(count, name_column, LabelName)
		
		
		# Platform
		
		var LabelPlatform = Label.new()
		LabelPlatform.text = rr_data.clients[client[0]].platform
		TableClients.set_cell_content(count, platform_column, LabelPlatform)

		
		# CPU

		var LabelCPU = Label.new()
		LabelCPU.text = rr_data.clients[client[0]].cpu
		#LabelCPU.set_mouse_filter(Control.MOUSE_FILTER_PASS)
		#LabelCPU.hint_tooltip = rr_data.clients[client[0]].cpu
		TableClients.set_cell_content(count, cpu_column, LabelCPU)
		#var row_of_label = LabelCPU.get_parent().get_parent().get_parent().get_parent()
		#var name_of_signal = "_on_" + LabelCPU.name +"_mouse_entered"
		#row_of_label.connect("mouse_enter", row_of_label, "update_row_color_hover")
		
		
		
		# RAM
		
		var LabelMemory = Label.new()
		LabelMemory.text = String(rr_data.clients[client[0]].memory) + " GB"
		TableClients.set_cell_content(count, memory_column, LabelMemory)
		
		
		# Pools
		
		var LabelPools = Label.new()
		var pools_string = ""
		var pool_count = 1
		
		if rr_data.clients[client[0]].pools.size() > 0:
			for pool in rr_data.clients[client[0]].pools:
				pools_string += pool
				if pool_count < rr_data.clients[client[0]].pools.size():
					pools_string += ", "
				pool_count += 1
				
		LabelPools.text = pools_string
		TableClients.set_cell_content(count, pools_column, LabelPools)
		
		
		# Note
		
		var LabelNote = Label.new()
		LabelNote.text = String(rr_data.clients[client[0]].note) 
		TableClients.set_cell_content(count, note_column, LabelNote)
		
		
		
		
		# Raptor Render Version
		
		var LabelVersion = Label.new()
		LabelVersion.text = String(rr_data.clients[client[0]].rr_version) 
		TableClients.set_cell_content(count, rr_version_column, LabelVersion)
		
		count += 1
		


func clients_table_sort(a,b):
	
	if !TableClients.sort_column_primary_reversed:
		
		if !TableClients.sort_column_secondary_reversed:

			return a[1] < b[1] or (a[1] == b[1] and a[2] < b[2])
		
		else:	
			
			return a[1] < b[1] or (a[1] == b[1] and a[2] > b[2])
			
	else:
		
		if !TableClients.sort_column_secondary_reversed:

			return a[1] > b[1] or (a[1] == b[1] and a[2] < b[2])
		
		else:	
			
			return a[1] > b[1] or (a[1] == b[1] and a[2] > b[2])		
		







func test_prints():
	print (OS.get_name())
	print ('Number of Threads: ' + String(OS.get_processor_count()) )
	print (OS.get_model_name ( ))
	print (OS.get_dynamic_memory_usage ( ))
	
	


	
		
	