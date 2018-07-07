extends Node


###### Settings Variables ########

var colorize_table_rows = false


#### preloads ####
var JobProgressBarRes = preload("res://GUI/JobProgressBar/JobProgressBar.tscn")
var JobPriorityControlRes = preload("res://GUI/PriorityControl/PriorityControl.tscn")



var TableJobs
var TableClients

var ContextMenu_Clients
var ContextMenu_Jobs

var ClientInfoPanel
var JobInfoPanel

var rr_data = {}

func _ready():
	
	rr_data = {
		"jobs": {
			"1": {
				"name": "city_build_v5",
				"type": "Blender",
				"priority": 50,
				"creator": "Johannes",
				"time_created": 1528623180,
				"status": "1_rendering",
				"progress": 28,
				"range_start": 230,
				"range_end": 780,
				"note": "eine Notiz",
				"errors": 2,
				"pools": ["AE_Plugins"],
				"scene_directory" : "/home/johannes/Downloads/",
				"output_directory" : "/home/johannes/GodotTest/",
				"render_time" : 345,
				"chunks": {
					"1":{
						"status" : "queued",
						"frames_to_calculate" : [20,21,22,23],
						"client" : "id1",
						"time_started" : "",
						"time_finished" : "",
						"number_of_tries" : 1
					},
					"2":{
						"status" : "queued",
						"frames_to_calculate" : [24,25,26,27],
						"client" : "id1",
						"time_started" : "",
						"time_finished" : "",
						"number_of_tries" : 1
					},
					"3":{
						"status" : "active",
						"frames_to_calculate" : [24,25,26,27],
						"client" : "id1",
						"time_started" : "",
						"time_finished" : "",
						"number_of_tries" : 1
					},
					"4":{
						"status" : "active",
						"frames_to_calculate" : [24,25,26,27],
						"client" : "id1",
						"time_started" : "",
						"time_finished" : "",
						"number_of_tries" : 1
					},
					"5":{
						"status" : "finished",
						"frames_to_calculate" : [24,25,26,27],
						"client" : "id1",
						"time_started" : "",
						"time_finished" : "",
						"number_of_tries" : 1
					},
					"6":{
						"status" : "finished",
						"frames_to_calculate" : [24,25,26,27],
						"client" : "id1",
						"time_started" : "",
						"time_finished" : "",
						"number_of_tries" : 1
					},
					"7":{
						"status" : "finished",
						"frames_to_calculate" : [24,25,26,27],
						"client" : "id1",
						"time_started" : "",
						"time_finished" : "",
						"number_of_tries" : 1
					}
				}
			},
			"7" : {
				"name": "city_build_v6",
				"type": "Blender",
				"priority": 50,
				"creator": "Johannes",
				"time_created": 1528621180,
				"status": "1_rendering",
				"progress": 28,
				"range_start": 1,
				"range_end": 80,
				"note": "",
				"errors": 0,
				"pools": ["AE_Plugins", "third pool"],
				"scene_directory" : "\\home\\johannes\\Downloads\\",
				"output_directory" : "\\home\\johannes\\GodotTest\\",
				"render_time" : 3645,
				"chunks": {
					"1":{
						"status" : "queued",
						"frames_to_calculate" : [20,21,22,23],
						"client" : "id1",
						"time_started" : "",
						"time_finished" : "",
						"number_of_tries" : 1
					},
					"2":{
						"status" : "active",
						"frames_to_calculate" : [24,25,26,27],
						"client" : "id1",
						"time_started" : "",
						"time_finished" : "",
						"number_of_tries" : 1
					},
					"3":{
						"status" : "active",
						"frames_to_calculate" : [24,25,26,27],
						"client" : "id1",
						"time_started" : "",
						"time_finished" : "",
						"number_of_tries" : 1
					},
					"4":{
						"status" : "active",
						"frames_to_calculate" : [24,25,26,27],
						"client" : "id1",
						"time_started" : "",
						"time_finished" : "",
						"number_of_tries" : 1
					},
					"5":{
						"status" : "queued",
						"frames_to_calculate" : [24,25,26,27],
						"client" : "id1",
						"time_started" : "",
						"time_finished" : "",
						"number_of_tries" : 1
					},
					"6":{
						"status" : "queued",
						"frames_to_calculate" : [24,25,26,27],
						"client" : "id1",
						"time_started" : "",
						"time_finished" : "",
						"number_of_tries" : 1
					},
					"7":{
						"status" : "finished",
						"frames_to_calculate" : [24,25,26,27],
						"client" : "id1",
						"time_started" : "",
						"time_finished" : "",
						"number_of_tries" : 1
					}
				}
			},
			"2": {
				"name": "city_unbuild_v02",
				"type": "Blender",
				"priority": 20,
				"creator": "Chris",
				"time_created": 1528613180,
				"status": "2_queued",
				"progress": 0,
				"range_start": 1,
				"range_end": 500,
				"note": "",
				"errors": 0,
				"pools": ["third pool"],
				"scene_directory" : "/home/johannes/Downloads/",
				"output_directory" : "/home/johannes/GodotTest/",
				"render_time" : 45,
				"chunks": {
					"1":{
						"status" : "queued",
						"frames_to_calculate" : [20,21,22,23],
						"client" : "id1",
						"time_started" : "",
						"time_finished" : "",
						"number_of_tries" : 1
					},
					"2":{
						"status" : "queued",
						"frames_to_calculate" : [24,25,26,27],
						"client" : "id1",
						"time_started" : "",
						"time_finished" : "",
						"number_of_tries" : 1
					},
					"3":{
						"status" : "queued",
						"frames_to_calculate" : [24,25,26,27],
						"client" : "id1",
						"time_started" : "",
						"time_finished" : "",
						"number_of_tries" : 1
					},
					"4":{
						"status" : "queued",
						"frames_to_calculate" : [24,25,26,27],
						"client" : "id1",
						"time_started" : "",
						"time_finished" : "",
						"number_of_tries" : 1
					},
					"5":{
						"status" : "queued",
						"frames_to_calculate" : [24,25,26,27],
						"client" : "id1",
						"time_started" : "",
						"time_finished" : "",
						"number_of_tries" : 1
					},
					"6":{
						"status" : "queued",
						"frames_to_calculate" : [24,25,26,27],
						"client" : "id1",
						"time_started" : "",
						"time_finished" : "",
						"number_of_tries" : 1
					},
					"7":{
						"status" : "queued",
						"frames_to_calculate" : [24,25,26,27],
						"client" : "id1",
						"time_started" : "",
						"time_finished" : "",
						"number_of_tries" : 1
					}
				}
			},
			"3": {
				"name": "Champions_League_Final_Shot3",
				"type": "After Effects",
				"priority": 20,
				"creator": "Michael",
				"time_created": 1528523180,
				"status": "4_paused",
				"progress": 34,
				"range_start": 80,
				"range_end": 115,
				"note": "Rabarber",
				"errors": 0,
				"pools": ["another pool"],
				"scene_directory" : "/home/johannes/Downloads/",
				"output_directory" : "/home/johannes/GodotTest/",
				"render_time" : 54445,
				"chunks": {
					"1":{
						"status" : "queued",
						"frames_to_calculate" : [20,21,22,23],
						"client" : "id1",
						"time_started" : "",
						"time_finished" : "",
						"number_of_tries" : 1
					},
					"2":{
						"status" : "queued",
						"frames_to_calculate" : [24,25,26,27],
						"client" : "id1",
						"time_started" : "",
						"time_finished" : "",
						"number_of_tries" : 1
					},
					"3":{
						"status" : "queued",
						"frames_to_calculate" : [24,25,26,27],
						"client" : "id1",
						"time_started" : "",
						"time_finished" : "",
						"number_of_tries" : 1
					},
					"4":{
						"status" : "queued",
						"frames_to_calculate" : [24,25,26,27],
						"client" : "id1",
						"time_started" : "",
						"time_finished" : "",
						"number_of_tries" : 1
					},
					"5":{
						"status" : "finished",
						"frames_to_calculate" : [24,25,26,27],
						"client" : "id1",
						"time_started" : "",
						"time_finished" : "",
						"number_of_tries" : 1
					},
					"6":{
						"status" : "finished",
						"frames_to_calculate" : [24,25,26,27],
						"client" : "id1",
						"time_started" : "",
						"time_finished" : "",
						"number_of_tries" : 1
					},
					"7":{
						"status" : "finished",
						"frames_to_calculate" : [24,25,26,27],
						"client" : "id1",
						"time_started" : "",
						"time_finished" : "",
						"number_of_tries" : 1
					}
				}
			},
			"4": {
				"name": "job 4",
				"type": "Natron",
				"priority": 77,
				"creator": "Max",
				"time_created": 1528620180,
				"status": "5_finished",
				"progress": 100,
				"range_start": 120,
				"range_end": 350,
				"note": "3 Fehler",
				"errors": 0,
				"pools": ["AE_Plugins"],
				"scene_directory" : "/home/johannes/Downloads/",
				"output_directory" : "/home/johannes/GodotTest/",
				"render_time" : 2487,
				"chunks": {
					"1":{
						"status" : "finished",
						"frames_to_calculate" : [20,21,22,23],
						"client" : "id1",
						"time_started" : "",
						"time_finished" : "",
						"number_of_tries" : 1
					},
					"2":{
						"status" : "finished",
						"frames_to_calculate" : [24,25,26,27],
						"client" : "id1",
						"time_started" : "",
						"time_finished" : "",
						"number_of_tries" : 1
					},
					"3":{
						"status" : "finished",
						"frames_to_calculate" : [24,25,26,27],
						"client" : "id1",
						"time_started" : "",
						"time_finished" : "",
						"number_of_tries" : 1
					},
					"4":{
						"status" : "finished",
						"frames_to_calculate" : [24,25,26,27],
						"client" : "id1",
						"time_started" : "",
						"time_finished" : "",
						"number_of_tries" : 1
					},
					"5":{
						"status" : "finished",
						"frames_to_calculate" : [24,25,26,27],
						"client" : "id1",
						"time_started" : "",
						"time_finished" : "",
						"number_of_tries" : 1
					},
					"6":{
						"status" : "finished",
						"frames_to_calculate" : [24,25,26,27],
						"client" : "id1",
						"time_started" : "",
						"time_finished" : "",
						"number_of_tries" : 1
					},
					"7":{
						"status" : "finished",
						"frames_to_calculate" : [24,25,26,27],
						"client" : "id1",
						"time_started" : "",
						"time_finished" : "",
						"number_of_tries" : 1
					}
				}
			},
			"5": {
				"name": "job 5",
				"type": "Nuke",
				"priority": 10,
				"creator": "Nicolaj",
				"time_created": 1528623110,
				"status": "6_cancelled",
				"progress": 57,
				"range_start": 1600,
				"range_end": 2800,
				"note": "",
				"errors": 0,
				"pools": ["another pool"],
				"scene_directory" : "/home/johannes/Downloads/",
				"output_directory" : "/home/johannes/GodotTest/",
				"render_time" : 3433578,
				"chunks": {
					"1":{
						"status" : "queued",
						"frames_to_calculate" : [20,21,22,23],
						"client" : "id1",
						"time_started" : "",
						"time_finished" : "",
						"number_of_tries" : 1
					},
					"2":{
						"status" : "queued",
						"frames_to_calculate" : [24,25,26,27],
						"client" : "id1",
						"time_started" : "",
						"time_finished" : "",
						"number_of_tries" : 1
					},
					"3":{
						"status" : "queued",
						"frames_to_calculate" : [24,25,26,27],
						"client" : "id1",
						"time_started" : "",
						"time_finished" : "",
						"number_of_tries" : 1
					},
					"4":{
						"status" : "finished",
						"frames_to_calculate" : [24,25,26,27],
						"client" : "id1",
						"time_started" : "",
						"time_finished" : "",
						"number_of_tries" : 1
					},
					"5":{
						"status" : "finished",
						"frames_to_calculate" : [24,25,26,27],
						"client" : "id1",
						"time_started" : "",
						"time_finished" : "",
						"number_of_tries" : 1
					},
					"6":{
						"status" : "finished",
						"frames_to_calculate" : [24,25,26,27],
						"client" : "id1",
						"time_started" : "",
						"time_finished" : "",
						"number_of_tries" : 1
					},
					"7":{
						"status" : "finished",
						"frames_to_calculate" : [24,25,26,27],
						"client" : "id1",
						"time_started" : "",
						"time_finished" : "",
						"number_of_tries" : 1
					}
				}
			},
			"6": {
				"name": "job 6",
				"type": "3DS Max",
				"priority": 10,
				"creator": "Nicolaj",
				"time_created": 1525611110,
				"status": "3_error",
				"progress": 0,
				"range_start": 20,
				"range_end": 50,
				"note": "",
				"errors": 11,
				"pools": ["AE_Plugins"],
				"scene_directory" : "/home/johannes/Downloads/",
				"output_directory" : "/home/johannes/GodotTest/",
				"render_time" : 4578,
				"chunks": {
					"1":{
						"status" : "queued",
						"frames_to_calculate" : [20,21,22,23],
						"client" : "id1",
						"time_started" : "",
						"time_finished" : "",
						"number_of_tries" : 1
					},
					"2":{
						"status" : "queued",
						"frames_to_calculate" : [24,25,26,27],
						"client" : "id1",
						"time_started" : "",
						"time_finished" : "",
						"number_of_tries" : 1
					},
					"3":{
						"status" : "queued",
						"frames_to_calculate" : [24,25,26,27],
						"client" : "id1",
						"time_started" : "",
						"time_finished" : "",
						"number_of_tries" : 1
					},
					"5":{
						"status" : "queued",
						"frames_to_calculate" : [24,25,26,27],
						"client" : "id1",
						"time_started" : "",
						"time_finished" : "",
						"number_of_tries" : 1
					},
					"6":{
						"status" : "queued",
						"frames_to_calculate" : [24,25,26,27],
						"client" : "id1",
						"time_started" : "",
						"time_finished" : "",
						"number_of_tries" : 1
					},
					"7":{
						"status" : "queued",
						"frames_to_calculate" : [24,25,26,27],
						"client" : "id1",
						"time_started" : "",
						"time_finished" : "",
						"number_of_tries" : 1
					}
				}
			}
		},
		
		
		
		"clients": {
			"id1": {
				"name": "T-Rex1",
				"mac_addresses": ["80:fa:5b:53:8b:43","f8:63:3f:cf:77:7c"],
				"ip_addresses": ["192.168.1.45","192.133.1.45"],
				"status": "2_available",
				"current_job_id": "",
				"error_count": 0,
				"platform": ["Linux","4.14.48-2"],
				"pools": ["AE_Plugins"],
				"rr_version": 1.2,
				"time_connected": 1528759663,
				"cpu": ["Intel(R) Core(TM) i7-8800 CPU @ 3.00GHz", 1.8, 2, 4, 8],
				"cpu_usage": 5,
				"memory": 32610232,
				"memory_usage": 22,
				"graphics": ["NVidia GTX 970"],
				"software": ["Blender", "Natron", "Nuke"],
				"note": ""
			},
			"id2": {
				"name": "Raptor1",
				"mac_addresses": ["80:fa:5b:53:8b:43","f8:63:3f:cf:77:7c"],
				"ip_addresses": ["192.168.1.22"],
				"status": "4_disabled",
				"current_job_id": "",
				"error_count": 0,
				"platform": ["Windows","7"],
				"pools": ["AE_Plugins", "another pool", "third pool"],
				"rr_version": 0.2,
				"time_connected": 1528759663,
				"cpu": ["Intel(R) Core(TM) i7-9000 CPU @ 2.80GHz", 2.8, 1, 8, 16],
				"cpu_usage": 25,
				"memory": 16305116,
				"memory_usage": 10,
				"graphics": ["Intel Onboard"],
				"software": ["Blender", "Natron"],
				"note": ""
			},
			"id3": {
				"name": "T-Rex2",
				"mac_addresses": ["80:fa:5b:53:8b:43","f8:63:3f:cf:77:7c"],
				"ip_addresses": ["192.168.1.156"],
				"status": "1_rendering",
				"current_job_id": "1",
				"error_count": 0,
				"platform": ["OSX","SnowLeopard"],
				"pools": ["AE_Plugins"],
				"rr_version": 1.2,
				"time_connected": 1528759663,
				"cpu": ["Intel(R) Core(TM) i7-7800 CPU @ 3.80GHz", 3.8, 1, 4, 8],
				"cpu_usage": 55,
				"memory": 65220464,
				"memory_usage": 22,
				"graphics": ["NVidia GTX 970"],
				"software": ["Blender", "Natron", "Nuke"],
				"note": ""
			},
			"id4": {
				"name": "Raptor2",
				"mac_addresses": ["80:fa:5b:53:8b:43","f8:63:3f:cf:77:7c"],
				"ip_addresses": ["192.168.1.87"],
				"status": "5_offline",
				"current_job_id": "",
				"error_count": 0,
				"platform": ["Windows","10"],
				"pools": ["AE_Plugins", "another pool", "third pool"],
				"rr_version": 0.2,
				"time_connected": 1528759663,
				"cpu": ["Intel(R) Core(TM) i7-10550U CPU @ 1.80GHz", 1.8, 1, 8, 16],
				"cpu_usage": 88,
				"memory": 8150060,
				"memory_usage": 11,
				"graphics": ["Intel Onboard"],
				"software": ["Blender", "Natron"],
				"note": ""
			},
			"id5": {
				"name": "T-Rex3",
				"mac_addresses": ["80:fa:5b:53:8b:43","f8:63:3f:cf:77:7c"],
				"ip_addresses": ["192.168.1.15"],
				"status": "3_error",
				"current_job_id": "",
				"error_count": 1,
				"platform": ["Linux","4.14.48-2"],
				"pools": ["AE_Plugins"],
				"rr_version": 1.2,
				"time_connected": 1528759663,
				"cpu": ["Intel(R) Core(TM) i9-8550 CPU @ 2.20GHz", 2.2, 1, 16, 32],
				"cpu_usage": 27,
				"memory": 4075030,
				"memory_usage": 38,
				"graphics": ["NVidia GTX 970"],
				"software": ["Blender", "Natron", "Nuke"],
				"note": ""
			},
			"id6": {
				"name": "Raptor3",
				"mac_addresses": ["10:7b:44:7a:fb:e2","f8:63:3f:cf:77:7c"],
				"ip_addresses": ["192.168.1.22"],
				"status": "5_offline",
				"current_job_id": "",
				"error_count": 0,
				"platform": ["Windows","XP"],
				"pools": ["AE_Plugins", "another pool", "third pool"],
				"rr_version": 0.2,
				"time_connected": 1528759663,
				"cpu": ["Intel(R) Core(TM) i7-6000 CPU @ 4.00GHz", 4.0, 1, 4, 8],
				"cpu_usage": 100,
				"memory": 16305116,
				"memory_usage": 45,
				"graphics": ["Intel Onboard"],
				"software": ["Blender", "Natron"],
				"note": ""
			},
			"id7": {
				"name": "T-Rex4",
				"mac_addresses": ["80:fa:5b:53:8b:43","f8:63:3f:cf:77:7c"],
				"ip_addresses": ["192.168.1.45"],
				"status": "2_available",
				"current_job_id": "",
				"error_count": 0,
				"platform": ["Linux","4.14.48-2"],
				"pools": ["AE_Plugins"],
				"rr_version": 1.2,
				"time_connected": 1528759663,
				"cpu": ["Intel(R) Core(TM) i7-9200CPU @ 3.40GHz", 3.4, 1, 4, 8],
				"cpu_usage": 65,
				"memory": 32610232,
				"memory_usage": 37,
				"graphics": ["NVidia GTX 970"],
				"software": ["Blender", "Natron", "Nuke"],
				"note": ""
			},
			"id8": {
				"name": "Raptor1",
				"mac_addresses": ["80:fa:5b:53:8b:43","f8:63:3f:cf:77:7c"],
				"ip_addresses": ["192.168.1.22"],
				"status": "4_disabled",
				"current_job_id": "",
				"error_count": 0,
				"platform": ["Windows","10"],
				"pools": [],
				"rr_version": 0.2,
				"time_connected": 1528759663,
				"cpu": ["Intel(R) Core(TM) i7-8550 CPU @ 1.80GHz", 1.8, 1, 8, 16],
				"cpu_usage": 10,
				"memory": 16305116,
				"memory_usage": 64,
				"graphics": ["Intel Onboard"],
				"software": ["Blender", "Natron"],
				"note": ""
			},
			"id9": {
				"name": "T-Rex1",
				"mac_addresses": ["80:fa:5b:53:8b:43","f8:63:3f:cf:77:7c"],
				"ip_addresses": ["192.168.1.45"],
				"status": "2_available",
				"current_job_id": "",
				"error_count": 0,
				"platform": ["Linux","4.14.48-2"],
				"pools": ["AE_Plugins"],
				"rr_version": 1.2,
				"time_connected": 1528759663,
				"cpu": ["Intel(R) Core(TM) i7-8550U CPU @ 1.80GHz", 1.8, 1, 4, 8],
				"cpu_usage": 23,
				"memory": 32610232,
				"memory_usage": 22,
				"graphics": ["NVidia GTX 970"],
				"software": ["Blender", "Natron", "Nuke"],
				"note": ""
			},
			"id10": {
				"name": "Raptor1",
				"mac_addresses": ["80:fa:5b:53:8b:43","f8:63:3f:cf:77:7c"],
				"ip_addresses": ["192.168.1.22"],
				"status": "2_available",
				"current_job_id": "",
				"error_count": 0,
				"platform": ["Windows","10"],
				"pools": ["AE_Plugins", "8GB+ VRam"],
				"rr_version": 0.2,
				"time_connected": 1528759663,
				"cpu": ["Intel(R) Core(TM) i7-85 CPU @ 2.20GHz", 2.2, 1, 8, 16],
				"cpu_usage": 75,
				"memory": 16305116,
				"memory_usage": 29,
				"graphics": ["Intel Onboard"],
				"software": ["Blender", "Natron"],
				"note": "my workstation"
			},
			"id11": {
				"name": "T-Rex2",
				"mac_addresses": ["80:fa:5b:53:8b:43","f8:63:3f:cf:77:7c"],
				"ip_addresses": ["192.168.1.156"],
				"status": "1_rendering",
				"current_job_id": "1",
				"error_count": 0,
				"platform": ["OSX","Snow Leopard"],
				"pools": ["AE_Plugins"],
				"rr_version": 1.2,
				"time_connected": 1528759663,
				"cpu": ["Intel(R) Core(TM) i7-8550U CPU @ 3.80GHz", 3.8, 1, 16, 32],
				"cpu_usage": 15,
				"memory": 65220464,
				"memory_usage": 34,
				"graphics": ["NVidia GTX 970"],
				"software": ["Blender", "Natron", "Nuke"],
				"note": "NVidia GTX 970"
			},
			"id12": {
				"name": "Nedry",
				"mac_addresses": ["80:fa:5b:53:8b:43","f8:63:3f:cf:77:7c"],
				"ip_addresses": ["192.168.1.87"],
				"status": "2_available",
				"current_job_id": "",
				"error_count": 0,
				"platform": ["Windows","10"],
				"pools": ["AE_Plugins", "8GB+ VRam", "third pool"],
				"rr_version": 0.2,
				"time_connected": 1528759663,
				"cpu": ["Intel(R) Core(TM) i7-8550U CPU @ 1.80GHz", 1.8, 1, 4, 8],
				"cpu_usage": 78,
				"memory": 16305116,
				"memory_usage": 23,
				"graphics": ["Intel Onboard"],
				"software": ["Blender", "Natron"],
				"note": ""
			},
			"id13": {
				"name": "T-Rex3",
				"mac_addresses": ["80:fa:5b:53:8b:43","f8:63:3f:cf:77:7c"],
				"ip_addresses": ["192.168.1.15"],
				"status": "3_error",
				"current_job_id": "",
				"error_count": 5,
				"platform": ["Linux","4.14.48-2"],
				"pools": ["AE_Plugins", "8GB+ VRam"],
				"rr_version": 1.2,
				"time_connected": 1528759663,
				"cpu": ["Intel(R) Core(TM) i7-6600 CPU @ 3.80GHz", 3.8, 1, 6, 12],
				"cpu_usage": 66,
				"memory": 4075030,
				"memory_usage": 82,
				"graphics": ["NVidia GTX 970"],
				"software": ["Blender", "Natron", "Nuke"],
				"note": ""
			},
			"id15": {
				"name": "Dr.Malcom",
				"mac_addresses": ["80:fa:5b:53:8b:43","f8:63:3f:cf:77:7c"],
				"ip_addresses": ["192.168.1.45"],
				"status": "2_available",
				"current_job_id": "",
				"error_count": 0,
				"platform": ["Linux","4.14.48-2"],
				"pools": ["8GB+ VRam"],
				"rr_version": 1.2,
				"time_connected": 1528759663,
				"cpu": ["Intel(R) Core(TM) i7-1200 CPU @ 3.20GHz", 3.2, 1, 12, 24],
				"cpu_usage": 61,
				"memory": 2030015,
				"memory_usage": 72,
				"graphics": ["NVidia GTX 970"],
				"software": ["Blender", "Natron", "Nuke"],
				"note": "Just a slow computer"
			},
			"id16": {
				"name": "Hammond",
				"mac_addresses": ["80:fa:5b:53:8b:43","f8:63:3f:cf:77:7c"],
				"ip_addresses": ["192.168.1.22"],
				"status": "4_disabled",
				"current_job_id": "",
				"error_count": 0,
				"platform": ["Windows","7"],
				"pools": ["AE_Plugins", "another pool", "third pool"],
				"rr_version": 0.2,
				"time_connected": 1528759663,
				"cpu": ["Intel(R) Core(TM) i7-8550U CPU @ 1.80GHz", 1.8, 1, 4, 8],
				"cpu_usage": 5,
				"memory": 120440928,
				"memory_usage": 25,
				"graphics": ["Intel Onboard"],
				"software": ["Blender", "Natron"],
				"note": "The Monster Machine!"
			}
		}
	}
	
	#test_prints()
	
	
func register_client_info_panel(InfoPanel):  
	
	ClientInfoPanel = InfoPanel


func register_job_info_panel(InfoPanel):  
	
	JobInfoPanel = InfoPanel


func register_table(SortableTable):  

	var sortable_table_id = SortableTable.table_id  
	
	match sortable_table_id: 
		"jobs":
			TableJobs = SortableTable
			TableJobs.connect("refresh_table_content", self, "refresh_jobs_table")
			TableJobs.connect("something_just_selected", self, "job_selected")
			TableJobs.connect("context_invoked", self, "jobs_context_menu_invoked")
			
		"clients": 
			TableClients = SortableTable 
			TableClients.connect("refresh_table_content", self, "refresh_clients_table")
			TableClients.connect("something_just_selected", self, "client_selected")
			TableClients.connect("context_invoked", self, "client_context_menu_invoked")




func register_context_menu(ContextMenu):  
	
	match ContextMenu.context_menu_id: 
		"clients":
			ContextMenu_Clients = ContextMenu
			
		"jobs":
			ContextMenu_Jobs = ContextMenu
			
			
			
func client_selected(content_id_of_row):
	TableJobs.clear_selection()
	JobInfoPanel.visible = false
	JobInfoPanel.reset_to_first_tab()
	ClientInfoPanel.update_client_info_panel(content_id_of_row)
	ClientInfoPanel.visible = true
	
	
	
	
func job_selected(content_id_of_row):
	TableClients.clear_selection()
	ClientInfoPanel.visible = false
	ClientInfoPanel.reset_to_first_tab()
	JobInfoPanel.update_job_info_panel(content_id_of_row)
	JobInfoPanel.visible = true
	


func client_context_menu_invoked():
	ContextMenu_Clients.show_at_mouse_position()
	

func jobs_context_menu_invoked():
	ContextMenu_Jobs.show_at_mouse_position()




func _input(event):
		
	if Input.is_key_pressed(KEY_R):
		TableJobs.refresh()
		TableClients.refresh()
	if Input.is_key_pressed(KEY_C):
		if colorize_table_rows:
			colorize_table_rows = false
		else:
			colorize_table_rows = true
		TableJobs.refresh()
		TableClients.refresh()
			
	if Input.is_key_pressed(KEY_X):
		rr_data.clients.erase("id4")
		rr_data.clients.erase("id8")
		rr_data.clients.erase("id10")
		TableClients.refresh()
	if Input.is_key_pressed(KEY_B):
		rr_data.clients["id20"] = {
				"name": "Hammond",
				"ip": "192.168.1.22",
				"status": "3_error",
				"current_job_id": "",
				"error_count": 0,
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
		
		TableClients.refresh()



func refresh_jobs_table():
	
	
	#### define the columns of the jobs table ####
	var status_column = 1
	var name_column = 2
	var priority_column = 3
	var active_clients_column = 4
	var progress_column = 5
	var type_column = 6
	var creator_column = 7
	var time_created_column = 8
	var frame_range_column = 9
	var errors_column = 10
	var pools_column = 11
	var note_column = 12
	
	
	#### get all jobs
	var jobs_array = rr_data.jobs.keys()
	
	
	
	#### sort jobs_array ####
	
		
	var sortable_jobs_array = []
	
	for job in jobs_array:
		
		## calculate the active clients for ordering
		var active_clients = 0
				
		for client in rr_data.clients.keys():
			if rr_data.clients[client].current_job_id == job:
				active_clients += 1
		
		## calculate the progress for ordering		
		var chunk_keys = rr_data.jobs[job].chunks.keys()
		
		var chunks_total = 0
		var chunks_finished = 0
		var job_progress = 0.0
		
		for chunk_key in chunk_keys:
			var chunk_status = rr_data.jobs[job].chunks[chunk_key].status
			match chunk_status:
				"finished": chunks_finished += 1
			chunks_total += 1
		
		job_progress = float(chunks_finished) / float(chunks_total) * 100.0
		
		
		
		
		var primary = ""
		var secondary = ""
		
		match TableJobs.sort_column_primary: 
		
			1: primary = rr_data.jobs[job].status
			2: primary = rr_data.jobs[job].name
			3: primary = rr_data.jobs[job].priority
			4: primary = active_clients
			5: primary = job_progress
			6: primary = rr_data.jobs[job].type
			7: primary = rr_data.jobs[job].creator
			8: primary = rr_data.jobs[job].time_created
			9: primary = rr_data.jobs[job].range_end - rr_data.jobs[job].range_start
			10: primary = rr_data.jobs[job].errors
			11: 
				if rr_data.jobs[job].pools.size() > 0:
					var pools_string = ""
					for pool in rr_data.jobs[job].pools:
						pools_string += pool + ", "
					primary = pools_string
				else: primary = ""
			12: primary = rr_data.jobs[job].note

			
		
		match TableJobs.sort_column_secondary: 
		
			1: secondary = rr_data.jobs[job].status
			2: secondary = rr_data.jobs[job].name
			3: secondary = rr_data.jobs[job].priority
			4: secondary = active_clients
			5: secondary = job_progress
			6: secondary = rr_data.jobs[job].type
			7: secondary = rr_data.jobs[job].creator
			8: secondary = rr_data.jobs[job].time_created
			9: secondary = rr_data.jobs[job].range_end - rr_data.jobs[job].range_start
			10: secondary = rr_data.jobs[job].errors
			11: 
				if rr_data.jobs[job].pools.size() > 0:
					var pools_string = ""
					for pool in rr_data.jobs[job].pools:
						pools_string += pool + ", "
					secondary = pools_string
				else: secondary = ""
			12: secondary = rr_data.jobs[job].note
			 
		
		sortable_jobs_array.append([job, primary, secondary ])
	
	
	sortable_jobs_array.sort_custom ( self, "jobs_table_sort" )
	
	
	#### create the correct amount of rows in RowContainerFilled ####
	
	TableJobs.update_amount_of_rows(jobs_array.size())
	
	
	#### Fill Jobs Table ####
	
	var count = 1
	
	for job in sortable_jobs_array:


		TableJobs.set_row_content_id(count, job[0])

		# Status Icon
		
		var StatusIcon = TextureRect.new()
		StatusIcon.set_expand(true)
		StatusIcon.set_stretch_mode(6) # 6 - keep aspect centered
		StatusIcon.set_v_size_flags(3) # fill + expand
		StatusIcon.set_h_size_flags(3) # fill + expand
		StatusIcon.rect_min_size.x = 54
		
		var icon = ImageTexture.new()
		
		
		if rr_data.jobs[job[0]].status == "1_rendering":
			icon.load("res://GUI/icons/job_status/58x30/job_status_rendering_58x30.png")
			if colorize_table_rows:
				TableJobs.set_row_color_by_string(count, "blue")
				
		elif rr_data.jobs[job[0]].status == "2_queued":
			icon.load("res://GUI/icons/job_status/58x30/job_status_queued_58x30.png")
			if colorize_table_rows:
				TableJobs.set_row_color_by_string(count, "yellow")
				
		elif rr_data.jobs[job[0]].status == "3_error":
			icon.load("res://GUI/icons/job_status/58x30/job_status_error_58x30.png")
			if colorize_table_rows:
				TableJobs.set_row_color_by_string(count, "red")
				
		elif rr_data.jobs[job[0]].status == "4_paused":
			icon.load("res://GUI/icons/job_status/58x30/job_status_paused_58x30.png")
				
		elif rr_data.jobs[job[0]].status == "5_finished":
			icon.load("res://GUI/icons/job_status/58x30/job_status_finished_58x30.png")
			if colorize_table_rows:
				TableJobs.set_row_color_by_string(count, "green")
				
		elif rr_data.jobs[job[0]].status == "6_cancelled":
			icon.load("res://GUI/icons/job_status/58x30/job_status_cancelled_58x30.png")
			if colorize_table_rows:
				TableJobs.set_row_color_by_string(count, "black")
				StatusIcon.set_modulate(Color(0.6, 0.6, 0.6, 1))
				
		StatusIcon.set_texture(icon)
		TableJobs.set_cell_content(count, status_column, StatusIcon)


		# Name

		var LabelName = Label.new()
		LabelName.text = rr_data.jobs[job[0]].name
		TableJobs.set_cell_content(count, name_column, LabelName)
		
		
		# Priority
		
#		var LabelPriority = Label.new()
#		LabelPriority.text = String(rr_data.jobs[job[0]].priority)
#		TableJobs.set_cell_content(count, priority_column, LabelPriority)
		
		var JobPriorityControl = JobPriorityControlRes.instance()
		JobPriorityControl.job_id = job[0]
		TableJobs.set_cell_content(count, priority_column, JobPriorityControl)
		
		# Active Clients
		
		var LabelActiveClients = Label.new()
		
		var active_clients = 0
				
		for client in rr_data.clients.keys():
			if rr_data.clients[client].current_job_id == job[0]:
				active_clients += 1
				
		LabelActiveClients.text = String(active_clients)
		TableJobs.set_cell_content(count, active_clients_column, LabelActiveClients)


		# Progress
		
		var JobProgressBar = JobProgressBarRes.instance()
		JobProgressBar.rect_min_size.x = 120
		
		var chunk_counts = JobFunctions.get_chunk_counts_TotalFinishedActive(job[0])
			
		JobProgressBar.set_chunks(chunk_counts[0], chunk_counts[1], chunk_counts[2])
		JobProgressBar.in_sortable_table = true
		
		if rr_data.jobs[job[0]].status == "4_paused":
			JobProgressBar.job_status = "paused"
		if rr_data.jobs[job[0]].status == "6_cancelled":
			JobProgressBar.job_status = "cancelled"
		TableJobs.set_cell_content(count, progress_column, JobProgressBar)
		
		
		# Type
		
		var LabelType = Label.new()
		LabelType.text = rr_data.jobs[job[0]].type
		TableJobs.set_cell_content(count, type_column, LabelType)
		
		
		# Creator
		
		var LabelCreator = Label.new()
		LabelCreator.text = rr_data.jobs[job[0]].creator
		TableJobs.set_cell_content(count, creator_column, LabelCreator)
		
		
		# Time Created
		
		var LabelTimeCreated = Label.new()
		LabelTimeCreated.text = TimeFunctions.time_stamp_to_date_as_string( rr_data.jobs[job[0]].time_created, 2)
		TableJobs.set_cell_content(count, time_created_column, LabelTimeCreated)

		
		# Frame Range
		
		var LabelFrameRange = Label.new()
		var frames_total = rr_data.jobs[job[0]].range_end - rr_data.jobs[job[0]].range_start
		LabelFrameRange.text = String(frames_total) + "  (" + String(rr_data.jobs[job[0]].range_start) + " - " + String(rr_data.jobs[job[0]].range_end) + ")"
		TableJobs.set_cell_content(count, frame_range_column, LabelFrameRange)
		
		
		# Errors
		
		var LabelErrors = Label.new()
		var job_error_count = rr_data.jobs[job[0]].errors
		LabelErrors.text = String(job_error_count)
		TableJobs.set_cell_content(count, errors_column, LabelErrors)
		
		if job_error_count > 0:
			if colorize_table_rows:
					TableJobs.set_row_color_by_string(count, "red")
		
		
		# Pools
		
		var LabelPools = Label.new()
		var pools_string = ""
		var pool_count = 1
		
		if rr_data.jobs[job[0]].pools.size() > 0:
			for pool in rr_data.jobs[job[0]].pools:
				pools_string += pool
				if pool_count < rr_data.jobs[job[0]].pools.size():
					pools_string += ", "
				pool_count += 1
				
		LabelPools.text = pools_string
		TableJobs.set_cell_content(count, pools_column, LabelPools)
		
		
		# Note
		
		var LabelNote = Label.new()
		LabelNote.text = rr_data.jobs[job[0]].note
		TableJobs.set_cell_content(count, note_column, LabelNote)
		
		
		
		count += 1
		
		
		
		
func refresh_clients_table():
	
	
	#### define the columns of the clients table ####
	var status_column = 1
	var name_column = 2
	var platform_column = 3
	var cpu_column = 4
	var memory_column = 5
	var current_job_column = 6
	var error_count_column = 7
	var pools_column = 8
	var note_column = 9
	var rr_version_column = 10
	
	#### get all clients
	var clients_array = rr_data.clients.keys()
	
	
	
	#### sort clients_array ####
	
		
	var sortable_clients_array = []
	
	for client in clients_array:
		
		var primary = ""
		var secondary  = ""
		
		match TableClients.sort_column_primary: 
		
			1: primary = rr_data.clients[client].status
			2: primary = rr_data.clients[client].name
			3: primary = rr_data.clients[client].platform[0]
			4: primary = rr_data.clients[client].cpu[1] * float(rr_data.clients[client].cpu[2]) * float(rr_data.clients[client].cpu[3])
			5: primary = rr_data.clients[client].memory
			6: 
				if rr_data.clients[client].current_job_id != "":
					primary = rr_data.jobs[ rr_data.clients[client].current_job_id ].name
				else:
					primary = ""
			7: primary = rr_data.clients[client].error_count
			8: 
				if rr_data.clients[client].pools.size() > 0:
					var pools_string = ""
					for pool in rr_data.clients[client].pools:
						pools_string += pool + ", "
					primary = pools_string
				else: primary = ""
			9: primary = rr_data.clients[client].note
			10: primary = rr_data.clients[client].rr_version 
		
		match TableClients.sort_column_secondary: 
		
			1: secondary = rr_data.clients[client].status
			2: secondary = rr_data.clients[client].name
			3: secondary = rr_data.clients[client].platform[0]
			4: secondary = rr_data.clients[client].cpu[1] * float(rr_data.clients[client].cpu[2]) * float(rr_data.clients[client].cpu[3])
			5: secondary = rr_data.clients[client].memory
			6: 
				if rr_data.clients[client].current_job_id != "":
					secondary = rr_data.jobs[ rr_data.clients[client].current_job_id ].name
				else:
					secondary = ""
			7: secondary = rr_data.clients[client].error_count
			8: 
				if rr_data.clients[client].pools.size() > 0:
					var pools_string = ""
					for pool in rr_data.clients[client].pools:
						pools_string += pool + ", "
					secondary = pools_string
				else: secondary = ""
			9: secondary = rr_data.clients[client].note
			10: secondary = rr_data.clients[client].rr_version 
		
		sortable_clients_array.append([client, primary, secondary ])
	
	
	sortable_clients_array.sort_custom ( self, "clients_table_sort" )
	
	
	#### create the correct amount of rows in RowContainerFilled ####
	
	TableClients.update_amount_of_rows(clients_array.size())
	
	
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
			if colorize_table_rows:
				TableClients.set_row_color_by_string(count, "blue")
			
		elif rr_data.clients[client[0]].status == "2_available":
			icon.load("res://GUI/icons/client_status/58x30/client_status_online_58x30.png")
			if colorize_table_rows:
				TableClients.set_row_color_by_string(count, "green")
			
		elif rr_data.clients[client[0]].status == "3_error":
			icon.load("res://GUI/icons/client_status/58x30/client_status_error_58x30.png")

		elif rr_data.clients[client[0]].status == "4_disabled":
			icon.load("res://GUI/icons/client_status/58x30/client_status_disabled_58x30.png")

		elif rr_data.clients[client[0]].status == "5_offline":
			icon.load("res://GUI/icons/client_status/58x30/client_status_offline_58x30.png")
			if colorize_table_rows:
				TableClients.set_row_color_by_string(count, "black")
				StatusIcon.set_modulate(Color(0.6, 0.6, 0.6, 1))
			
		StatusIcon.set_texture(icon)
		TableClients.set_cell_content(count, status_column, StatusIcon)


		# Name

		var LabelName = Label.new()
		LabelName.text = rr_data.clients[client[0]].name
		TableClients.set_cell_content(count, name_column, LabelName)
		
		
		# Platform
		
		var LabelPlatform = Label.new()
		LabelPlatform.text = rr_data.clients[client[0]].platform[0]
		TableClients.set_cell_content(count, platform_column, LabelPlatform)

		
		# CPU

		var LabelCPU = Label.new()
		LabelCPU.text = String(rr_data.clients[client[0]].cpu[1] * rr_data.clients[client[0]].cpu[2] * rr_data.clients[client[0]].cpu[3]) + " GHZ"
		#LabelCPU.set_mouse_filter(Control.MOUSE_FILTER_PASS)
		#LabelCPU.hint_tooltip = rr_data.clients[client[0]].cpu
		TableClients.set_cell_content(count, cpu_column, LabelCPU)
		#var row_of_label = LabelCPU.get_parent().get_parent().get_parent().get_parent()
		#var name_of_signal = "_on_" + LabelCPU.name +"_mouse_entered"
		#row_of_label.connect("mouse_enter", row_of_label, "update_row_color_hover")
		
		
		
		# RAM
		
		var LabelMemory = Label.new()
		LabelMemory.text = String( round(float(rr_data.clients[client[0]].memory) / 1024 / 1024 ))+ " GB"
		TableClients.set_cell_content(count, memory_column, LabelMemory)
		
		
		
		# Current Job
		
		var LabelCurrentJob = Label.new()
		var current_job_id = rr_data.clients[client[0]].current_job_id
		
		if current_job_id != "":
			LabelCurrentJob.text = rr_data.jobs[current_job_id].name
		else:
			LabelCurrentJob.text = ""
			
		TableClients.set_cell_content(count, current_job_column, LabelCurrentJob)
		
		
		# Errors
		
		var LabelErrorCount = Label.new()
		var clients_error_count = rr_data.clients[client[0]].error_count
		LabelErrorCount.text = String(clients_error_count)
		TableClients.set_cell_content(count, error_count_column, LabelErrorCount)
		if clients_error_count > 0:
			if colorize_table_rows:
				TableClients.set_row_color_by_string(count, "red")
			
		
		#Color("9f4c48")
		
		
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
		

func jobs_table_sort(a,b):
	
	if !TableJobs.sort_column_primary_reversed:
		
		if !TableJobs.sort_column_secondary_reversed:

			return a[1] < b[1] or (a[1] == b[1] and a[2] < b[2])
		
		else:	
			
			return a[1] < b[1] or (a[1] == b[1] and a[2] > b[2])
			
	else:
		
		if !TableJobs.sort_column_secondary_reversed:

			return a[1] > b[1] or (a[1] == b[1] and a[2] < b[2])
		
		else:	
			
			return a[1] > b[1] or (a[1] == b[1] and a[2] > b[2])





func test_prints():
	print (OS.get_name())
	print ('Number of Threads: ' + String(OS.get_processor_count()) )
	print (OS.get_model_name ( ))
	print (OS.get_dynamic_memory_usage ( ))
	
	


	
		
	