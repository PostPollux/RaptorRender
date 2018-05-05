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
				"cpu": "Intel I7 16 core @ 3,8GHZ",
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
				"cpu": "Intel I7 8 core @ 4GHZ",
				"memory": 16,
				"memory_used": 2,
				"graphics": "Intel Onboard",
				"software": ["Blender", "Natron"]
			}
		}
	}

#func _process(delta):
#	if TableClients != null:
#		var l= Label.new()
#		l.text = "hallo"
#		TableClients.set_cell_content(1,2,l)
#	pass


func register_table(SortableTable):  

	var sortable_table_id = SortableTable.table_id  
	
	match sortable_table_id: 
		"jobs": TableJobs = SortableTable 
		"clients": TableClients = SortableTable 


func test_prints():
	print (OS.get_name())
	print ('Number of Threads: ' + String(OS.get_processor_count()) )
	print (OS.get_model_name ( ))
	print (OS.get_dynamic_memory_usage ( ))