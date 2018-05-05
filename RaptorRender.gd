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
			"T-Rex1": {
				"name": "T-Rex1",
				"ip": "192.168.1.45",
				"status": "Enabled",
				"platform": "Linux",
				"pools": ["AE_Plugins"],
				"rr_version": 1.2,
				"uptime": "2h",
				"cpu": "16 x 3,8GHZ",
				"memory": 32,
				"memory_used": 22,
				"graphics": "NVidia GTX 970",
				"software": ["Blender", "Natron", "Nuke"]
			},
			"Raptor1": {
				"name": "Raptor1",
				"ip": "192.168.1.22",
				"status": "Disabled",
				"platform": "Windows",
				"pools": ["AE_Plugins", "another pool", "third pool"],
				"rr_version": 0.2,
				"uptime": "1h",
				"cpu": "8 x 4GHZ",
				"memory": 16,
				"memory_used": 2,
				"graphics": "Intel Onboard",
				"software": ["Blender", "Natron"]
			},
			"T-Rex2": {
				"name": "T-Rex2",
				"ip": "192.168.1.156",
				"status": "Rendering",
				"platform": "MacOS",
				"pools": ["AE_Plugins"],
				"rr_version": 1.2,
				"uptime": "2h",
				"cpu": "16 x 3,8GHZ",
				"memory": 64,
				"memory_used": 22,
				"graphics": "NVidia GTX 970",
				"software": ["Blender", "Natron", "Nuke"]
			},
			"Raptor2": {
				"name": "Raptor2",
				"ip": "192.168.1.87",
				"status": "Offline",
				"platform": "Windows",
				"pools": ["AE_Plugins", "another pool", "third pool"],
				"rr_version": 0.2,
				"uptime": "1h",
				"cpu": "8 x 4GHZ",
				"memory": 8,
				"memory_used": 2,
				"graphics": "Intel Onboard",
				"software": ["Blender", "Natron"]
			},
			"T-Rex3": {
				"name": "T-Rex3",
				"ip": "192.168.1.15",
				"status": "Enabled",
				"platform": "Linux",
				"pools": ["AE_Plugins"],
				"rr_version": 1.2,
				"uptime": "2h",
				"cpu": "16 x 3,8GHZ",
				"memory": 4,
				"memory_used": 22,
				"graphics": "NVidia GTX 970",
				"software": ["Blender", "Natron", "Nuke"]
			},
			"Raptor3": {
				"name": "Raptor3",
				"ip": "192.168.1.22",
				"status": "Offline",
				"platform": "Windows",
				"pools": ["AE_Plugins", "another pool", "third pool"],
				"rr_version": 0.2,
				"uptime": "1h",
				"cpu": "8 x 4GHZ",
				"memory": 16,
				"memory_used": 2,
				"graphics": "Intel Onboard",
				"software": ["Blender", "Natron"]
			},
			"T-Rex4": {
				"name": "T-Rex4",
				"ip": "192.168.1.45",
				"status": "Enabled",
				"platform": "Linux",
				"pools": ["AE_Plugins"],
				"rr_version": 1.2,
				"uptime": "2h",
				"cpu": "4 x 3,2GHZ",
				"memory": 32,
				"memory_used": 22,
				"graphics": "NVidia GTX 970",
				"software": ["Blender", "Natron", "Nuke"]
			},
			"Raptor4": {
				"name": "Raptor1",
				"ip": "192.168.1.22",
				"status": "Disabled",
				"platform": "Windows",
				"pools": ["AE_Plugins", "another pool", "third pool"],
				"rr_version": 0.2,
				"uptime": "1h",
				"cpu": "8 x 2,4GHZ",
				"memory": 16,
				"memory_used": 2,
				"graphics": "Intel Onboard",
				"software": ["Blender", "Natron"]
			}
		}
	}
	
	#test_prints()
	
	



func register_table(SortableTable):  

	var sortable_table_id = SortableTable.table_id  
	
	match sortable_table_id: 
		"jobs": TableJobs = SortableTable 
		"clients": TableClients = SortableTable 




func _input(event):
	
	if Input.is_key_pressed(KEY_R):
		

		#### Fill Clients Table ####
		
		var clients_array = rr_data.clients.keys()
		
		var status_column = 1
		var name_column = 2
		var platform_column = 3
		var cpu_column = 4
		var memory_column = 5
		
		var count = 1
		
		for client in clients_array:
			print (rr_data.clients[client].name)

			
			var LabelStatus = Label.new()
			LabelStatus.text = rr_data.clients[client].status
			TableClients.set_cell_content(count,status_column,LabelStatus)


			var LabelName = Label.new()
			LabelName.text = rr_data.clients[client].name
			TableClients.set_cell_content(count,name_column,LabelName)
			
			
			var LabelPlatform = Label.new()
			LabelPlatform.text = rr_data.clients[client].platform
			TableClients.set_cell_content(count,platform_column,LabelPlatform)


			var LabelCPU = Label.new()
			LabelCPU.text = rr_data.clients[client].cpu
			LabelCPU.set_mouse_filter(Control.MOUSE_FILTER_PASS)
			LabelCPU.hint_tooltip = rr_data.clients[client].cpu
			TableClients.set_cell_content(count,cpu_column,LabelCPU)
			
			
			var LabelMemory = Label.new()
			LabelMemory.text = String(rr_data.clients[client].memory) + " GB"
			TableClients.set_cell_content(count,memory_column,LabelMemory)
			
			count += 1
		
		

func test_prints():
	print (OS.get_name())
	print ('Number of Threads: ' + String(OS.get_processor_count()) )
	print (OS.get_model_name ( ))
	print (OS.get_dynamic_memory_usage ( ))
	
	
	
	
	
	
