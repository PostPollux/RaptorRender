extends Node


### PRELOAD RESOURCES
var JobProgressBarRes = preload("res://RaptorRender/GUI/SortableTable/specific_sortable_table_cell_elements/JobProgressBar/JobProgressBar.tscn")
var JobPriorityControlRes = preload("res://RaptorRender/GUI/SortableTable/specific_sortable_table_cell_elements/PriorityControl/PriorityControl.tscn")
var CurrentJobLinkRes = preload("res://RaptorRender/GUI/SortableTable/specific_sortable_table_cell_elements/CurrentJobLink/CurrentJobLink.tscn")
var SubmitJobPopupContentRes = preload("res://RaptorRender/GUI/AutoScalingPopup/Content/SubmitJobPopupContent/SubmitJobPopupContent.tscn")
var PoolManagerPopupContentRes = preload("res://RaptorRender/GUI/AutoScalingPopup/Content/PoolManagerPopupContent/PoolManagerPopupContent.tscn")

### SIGNALS

### ONREADY VARIABLES

### EXPORTED VARIABLES

### VARIABLES
var colorize_erroneous_table_rows : bool = true

var currently_updating_pool_cache : bool = false

var NotificationSystem : NotificationSystem

var JobsTable : SortableTable
var ClientsTable : SortableTable
var ChunksTable : SortableTable
var TriesTable : SortableTable

var PoolTabsContainer : TabContainer 

var ContextMenu_Clients : RRContextMenuBase
var ContextMenu_Jobs : RRContextMenuBase
var ContextMenu_Chunks : RRContextMenuBase
var ContextMenu_Log : RRContextMenuBase

var SubmitJobPopup : AutoScalingPopup
var PoolManagerPopup : AutoScalingPopup

var ClientInfoPanel : ClientInfoPanel
var JobInfoPanel : JobInfoPanel
var TryInfoPanel : TryInfoPanel

var rr_data : Dictionary = {}

var current_job_id_for_job_info_panel : int = 0
var current_chunk_id_for_job_info_panel : int = 0
var current_try_id_for_job_info_panel : int = 0

var refresh_interface_timer : Timer 

var clients_pool_filter : int = -1





########## FUNCTIONS ##########


func _ready():
	
	# create timer to constantly distribute the work across the connected clients 
	refresh_interface_timer = Timer.new()
	refresh_interface_timer.name = "Refresh Interface Timer"
	refresh_interface_timer.wait_time = 1
	refresh_interface_timer.connect("timeout",self,"update_all_visible_tables")
	var root_node : Node = get_tree().get_root().get_node("RaptorRenderMainScene")
	if root_node != null:
		root_node.add_child(refresh_interface_timer)
	
	refresh_interface_timer.start()
	
	rr_data = {
		"jobs": {
			100: {
				"name": "Blender test",
				"type": "Blender",
				"type_version": "default",
				"priority": 50,
				"priority_boost": true,
				"creator": "Johannes",
				"time_created": 1528623180,
				"frame_range": "10-25",
				"frames_total": 16,
				"status": RRStateScheme.job_paused,
				"note": "blender test",
				"errors": 0,
				"pools": [],
				"scene_path" : "/home/johannes/Schreibtisch/renderfarmtest.blend",
				"output_dirs_and_file_name_patterns" : [["/home/johannes/Schreibtisch/renderfarmtest/",["####.png"]]],
				"render_time" : 0,
				"SpecificJobSettings" : {},
				"chunks": {
					1:{
						"status" : RRStateScheme.chunk_queued,
						"frame_start" : 10,
						"frame_end" : 14,
						"number_of_tries" : 0,
						"tries": {
						
						},
						"errors": 0
					},
					2:{
						"status" : RRStateScheme.chunk_queued,
						"frame_start" : 15,
						"frame_end" : 19,
						"number_of_tries" : 0,
						"tries": {
						
						},
						"errors": 0
					},
					3:{
						"status" : RRStateScheme.chunk_queued,
						"frame_start" : 20,
						"frame_end" : 24,
						"number_of_tries" : 0,
						"tries": {
						
						},
						"errors": 0
					},
					4:{
						"status" : RRStateScheme.chunk_queued,
						"frame_start" : 25,
						"frame_end" : 25,
						"number_of_tries" : 0,
						"tries": {
						
						},
						"errors": 0
					}
				}
			},
			101: {
				"name": "natron test",
				"type": "Natron",
				"type_version": "default",
				"priority": 30,
				"priority_boost": true,
				"creator": "Johannes",
				"time_created": 1528623180,
				"frame_range": "10-25",
				"frames_total": 16,
				"status": RRStateScheme.job_paused,
				"note": "blender test",
				"errors": 0,
				"pools": [],
				"scene_path" : "/home/johannes/Schreibtisch/natron_renderfarm_test.ntp",
				"output_dirs_and_file_name_patterns" : [["/home/johannes/Schreibtisch/renderfarmtest/",["natron_test_###.png"]]],
				"render_time" : 0,
				"SpecificJobSettings" : {
					"writer_name" : "true",
					"writer_name__cmd_value" : "-w;;Write1;;"
				},
				"chunks": {
					1:{
						"status" : RRStateScheme.chunk_queued,
						"frame_start" : 10,
						"frame_end" : 14,
						"number_of_tries" : 0,
						"tries": {
						
						},
						"errors": 0
					},
					2:{
						"status" : RRStateScheme.chunk_queued,
						"frame_start" : 15,
						"frame_end" : 19,
						"number_of_tries" : 0,
						"tries": {
						
						},
						"errors": 0
					},
					3:{
						"status" : RRStateScheme.chunk_queued,
						"frame_start" : 20,
						"frame_end" : 24,
						"number_of_tries" : 0,
						"tries": {
						
						},
						"errors": 0
					},
					4:{
						"status" : RRStateScheme.chunk_queued,
						"frame_start" : 25,
						"frame_end" : 25,
						"number_of_tries" : 0,
						"tries": {
						
						},
						"errors": 0
					}
				}
			},
			102: {
				"name": "Nuke test",
				"type": "Nuke",
				"type_version": "default",
				"priority": 60,
				"priority_boost": true,
				"creator": "Johannes",
				"time_created": 1528623180,
				"frame_range": "10-25",
				"frames_total": 16,
				"status": RRStateScheme.job_paused,
				"note": "Nuke test",
				"errors": 0,
				"pools": [],
				"scene_path" : "/home/johannes/Schreibtisch/Nuke_renderfarmtest.nknc",
				"output_dirs_and_file_name_patterns" : [["/home/johannes/Schreibtisch/renderfarmtest/",["nuke_test_####.png"]]],
				"render_time" : 0,
				"SpecificJobSettings" : {
					"non_commercial" : "true",
					"non_commercial__cmd_value" : ";;--nc;;",
					"interactive_licence" : "false",
					"interactive_licence__cmd_value" : ";;i;;",
					"specific_writer" : "false",
					"specific_writer__cmd_value" : "X;;Writer1;;x"
				},
				"chunks": {
					1:{
						"status" : RRStateScheme.chunk_queued,
						"frame_start" : 10,
						"frame_end" : 14,
						"number_of_tries" : 0,
						"tries": {
						
						},
						"errors": 0
					},
					2:{
						"status" : RRStateScheme.chunk_queued,
						"frame_start" : 15,
						"frame_end" : 19,
						"number_of_tries" : 0,
						"tries": {
						
						},
						"errors": 0
					},
					3:{
						"status" : RRStateScheme.chunk_queued,
						"frame_start" : 20,
						"frame_end" : 24,
						"number_of_tries" : 0,
						"tries": {
						
						},
						"errors": 0
					},
					4:{
						"status" : RRStateScheme.chunk_queued,
						"frame_start" : 25,
						"frame_end" : 25,
						"number_of_tries" : 0,
						"tries": {
						
						},
						"errors": 0
					}
				}
			},
			
			4: {
				"name": "job 4",
				"type": "Natron",
				"type_version": "default",
				"priority": 77,
				"priority_boost": false,
				"creator": "Max",
				"time_created": 1528620180,
				"frame_range": "10-110",
				"frames_total": 100,
				"status": RRStateScheme.job_finished,
				"note": "3 Fehler",
				"errors": 0,
				"pools": [1],
				"scene_path" : "/home/johannes/Downloads/test.blend",
				"output_dirs_and_file_name_patterns" : [["/home/johannes/GodotTest/",["####.png"]]],
				"render_time" : 2487,
				"SpecificJobSettings" : {},
				"chunks": {
					1:{
						"status" : RRStateScheme.chunk_finished,
						"frame_start" : 20,
						"frame_end" : 25,
						"number_of_tries" : 1,
						"tries": {
							1:{
								"cmd" : "",
								"status" : RRStateScheme.try_finished,
								"client" : 1,
								"time_started" : 1528523180,
								"time_stopped" : 1528523280
							}
						},
						"errors": 0
					},
					2:{
						"status" : RRStateScheme.chunk_finished,
						"frame_start" : 20,
						"frame_end" : 25,
						"number_of_tries" : 2,
						"tries": {
							1:{
								"cmd" : "",
								"status" : RRStateScheme.try_finished,
								"client" : 4,
								"time_started" : 1528523180,
								"time_stopped" : 1528523275
							},
							2:{
								"cmd" : "",
								"status" : RRStateScheme.try_finished,
								"client" : 13,
								"time_started" : 1528523180,
								"time_stopped" : 1528523275
							}
						},
						"errors": 0
					},
					3:{
						"status" : RRStateScheme.chunk_finished,
						"frame_start" : 20,
						"frame_end" : 25,
						"number_of_tries" : 1,
						"tries": {
							1:{
								"cmd" : "",
								"status" : RRStateScheme.try_finished,
								"client" : 8,
								"time_started" : 1528523180,
								"time_stopped" : 1528523299
							}
						},
						"errors": 0
					},
					4:{
						"status" : RRStateScheme.chunk_finished,
						"frame_start" : 20,
						"frame_end" : 25,
						"number_of_tries" : 1,
						"tries": {
							1:{
								"cmd" : "",
								"status" : RRStateScheme.try_finished,
								"client" : 1,
								"time_started" : 1528523180,
								"time_stopped" : 1528523268
							}
						},
						"errors": 0
					},
					5:{
						"status" : RRStateScheme.chunk_finished,
						"frame_start" : 20,
						"frame_end" : 25,
						"number_of_tries" : 1,
						"tries": {
							1:{
								"cmd" : "",
								"status" : RRStateScheme.try_finished,
								"client" : 10,
								"time_started" : 1528523180,
								"time_stopped" : 1528523245
							}
						},
						"errors": 0
					},
					6:{
						"status" : RRStateScheme.chunk_finished,
						"frame_start" : 20,
						"frame_end" : 25,
						"number_of_tries" : 1,
						"tries": {
							1:{
								"cmd" : "",
								"status" : RRStateScheme.try_finished,
								"client" : 1,
								"time_started" : 1528523180,
								"time_stopped" : 1528523222
							}
						},
						"errors": 0
					},
					7:{
						"status" : RRStateScheme.chunk_finished,
						"frame_start" : 20,
						"frame_end" : 25,
						"number_of_tries" : 1,
						"tries": {
							1:{
								"cmd" : "",
								"status" : RRStateScheme.try_finished,
								"client" : 7,
								"time_started" : 1528523180,
								"time_stopped" : 1528523200
							}
						},
						"errors": 0
					},
					8:{
						"status" : RRStateScheme.chunk_finished,
						"frame_start" : 20,
						"frame_end" : 25,
						"number_of_tries" : 1,
						"tries": {
							1:{
								"cmd" : "",
								"status" : RRStateScheme.try_finished,
								"client" : 1,
								"time_started" : 1528523180,
								"time_stopped" : 1528523190
							}
						},
						"errors": 0
					},
					9:{
						"status" : RRStateScheme.chunk_finished,
						"frame_start" : 20,
						"frame_end" : 25,
						"number_of_tries" : 1,
						"tries": {
							1:{
								"cmd" : "",
								"status" : RRStateScheme.try_finished,
								"client" : 1,
								"time_started" : 1528523180,
								"time_stopped" : 1528523285
							}
						},
						"errors": 0
					},
					10:{
						"status" : RRStateScheme.chunk_finished,
						"frame_start" : 20,
						"frame_end" : 25,
						"number_of_tries" : 1,
						"tries": {
							1:{
								"cmd" : "",
								"status" : RRStateScheme.try_finished,
								"client" : 1,
								"time_started" : 1528523180,
								"time_stopped" : 1528523230
							}
						},
						"errors": 0
					},
					11:{
						"status" : RRStateScheme.chunk_finished,
						"frame_start" : 20,
						"frame_end" : 25,
						"number_of_tries" : 1,
						"tries": {
							1:{
								"cmd" : "",
								"status" : RRStateScheme.try_finished,
								"client" : 13,
								"time_started" : 1528523180,
								"time_stopped" : 1528523250
							}
						},
						"errors": 0
					},
					12:{
						"status" : RRStateScheme.chunk_finished,
						"frame_start" : 20,
						"frame_end" : 25,
						"number_of_tries" : 1,
						"tries": {
							1:{
								"cmd" : "",
								"status" : RRStateScheme.try_finished,
								"client" : 13,
								"time_started" : 1528523180,
								"time_stopped" : 1528523270
							}
						},
						"errors": 0
					},
					13:{
						"status" : RRStateScheme.chunk_finished,
						"frame_start" : 20,
						"frame_end" : 25,
						"number_of_tries" : 1,
						"tries": {
							1:{
								"cmd" : "",
								"status" : RRStateScheme.try_finished,
								"client" : 15,
								"time_started" : 1528523180,
								"time_stopped" : 1528523260
							}
						},
						"errors": 0
					},
					14:{
						"status" : RRStateScheme.chunk_finished,
						"frame_start" : 20,
						"frame_end" : 25,
						"number_of_tries" : 1,
						"tries": {
							1:{
								"cmd" : "",
								"status" : RRStateScheme.try_finished,
								"client" : 16,
								"time_started" : 1528523180,
								"time_stopped" : 1528523320
							}
						},
						"errors": 0
					},
					15:{
						"status" : RRStateScheme.chunk_finished,
						"frame_start" : 20,
						"frame_end" : 25,
						"number_of_tries" : 1,
						"tries": {
							1:{
								"cmd" : "",
								"status" : RRStateScheme.try_finished,
								"client" : 2,
								"time_started" : 1528523180,
								"time_stopped" : 1528523290
							}
						},
						"errors": 0
					},
					16:{
						"status" : RRStateScheme.chunk_finished,
						"frame_start" : 20,
						"frame_end" : 25,
						"number_of_tries" : 1,
						"tries": {
							1:{
								"cmd" : "",
								"status" : RRStateScheme.try_finished,
								"client" : 2,
								"time_started" : 1528523180,
								"time_stopped" : 1528523255
							}
						},
						"errors": 0
					},
					17:{
						"status" : RRStateScheme.chunk_finished,
						"frame_start" : 20,
						"frame_end" : 25,
						"number_of_tries" : 1,
						"tries": {
							1:{
								"cmd" : "",
								"status" : RRStateScheme.try_finished,
								"client" : 1,
								"time_started" : 1528523180,
								"time_stopped" : 1528523430
							}
						},
						"errors": 0
					}
					
				}
			}
			
		},
		
		
		
		"clients": {
			1: {
				"machine_properties": {
					"name": "T-Rex1",
					"username": "Johannes",
					"mac_addresses": ["80:fa:5b:53:8b:43","f8:63:3f:cf:77:7c"],
					"ip_addresses": ["192.168.1.45","192.133.1.45"],
					"platform": ["Linux","4.14.48-2"],
					"cpu": ["Intel(R) Core(TM) i7-8800 CPU @ 3.00GHz", 1.8, 2, 4, 8],
					"cpu_usage": 5,
					"memory": 32610232,
					"memory_usage": 22,
					"graphics": ["NVidia GTX 970"],
					"hard_drives": [{"name": "C:", "label": "System", "size": "256 GB", "percentage_used": 24, "type": 1}, {"name": "E:", "label": "", "size": "1 TB", "percentage_used": 5, "type": 1}, {"name": "D:", "label": "", "size": "2 TB", "percentage_used": 56, "type": 2}, {"name": "Z:", "label": "Daten", "size": "40 TB", "percentage_used": 76, "type": 3} ],
				},
				"status": RRStateScheme.client_disabled,
				"current_job_id": -1,
				"last_render_log": [0,0,0],
				"error_count": 0,
				"pools": [1],
				"rr_version": 1.2,
				"time_connected": 1528759663,
				"software": ["Blender", "Natron", "Nuke"],
				"note": ""
			},
			2: {
				"machine_properties": {
					"name": "Raptor1",
					"username": "Michael",
					"mac_addresses": ["80:fa:5b:53:8b:43","f8:63:3f:cf:77:7c"],
					"ip_addresses": ["192.168.1.22"],
					"platform": ["Windows","7"],
					"cpu": ["Intel(R) Core(TM) i7-9000 CPU @ 2.80GHz", 2.8, 1, 8, 16],
					"cpu_usage": 25,
					"memory": 16305116,
					"memory_usage": 10,
					"graphics": ["Intel Onboard"],
					"hard_drives": [{"name": "C:", "label": "System", "size": "256 GB", "percentage_used": 24, "type": 1}, {"name": "E:", "label": "", "size": "1 TB", "percentage_used": 5, "type": 1}, {"name": "D:", "label": "", "size": "2 TB", "percentage_used": 56, "type": 2}, {"name": "Z:", "label": "Daten", "size": "40 TB", "percentage_used": 76, "type": 3} ],
				},
				"status": RRStateScheme.client_disabled,
				"current_job_id": -1,
				"last_render_log": [0,0,0],
				"error_count": 0,
				"pools": [1, 2, 3],
				"rr_version": 0.2,
				"time_connected": 1528759663,
				"software": ["Blender", "Natron"],
				"note": ""
			},
			3: {
				"machine_properties": {
					"name": "T-Rex2",
					"username": "Max",
					"mac_addresses": ["80:fa:5b:53:8b:43","f8:63:3f:cf:77:7c"],
					"ip_addresses": ["192.168.1.156"],
					"platform": ["OSX","SnowLeopard"],
					"cpu": ["Intel(R) Core(TM) i7-7800 CPU @ 3.80GHz", 3.8, 1, 4, 8],
					"cpu_usage": 55,
					"memory": 65220464,
					"memory_usage": 22,
					"graphics": ["NVidia GTX 970"],
					"hard_drives": [{"name": "C:", "label": "System", "size": "256 GB", "percentage_used": 24, "type": 1}, {"name": "E:", "label": "", "size": "1 TB", "percentage_used": 5, "type": 1}, {"name": "D:", "label": "", "size": "2 TB", "percentage_used": 56, "type": 2}, {"name": "Z:", "label": "Daten", "size": "40 TB", "percentage_used": 76, "type": 3} ],
				},
				"status": RRStateScheme.client_disabled,
				"current_job_id": -1,
				"last_render_log": [0,0,0],
				"error_count": 0,
				"pools": [1],
				"rr_version": 1.2,
				"time_connected": 1528759663,
				"software": ["Blender", "Natron", "Nuke"],
				"note": ""
			},
			4: {
				"machine_properties": {
					"name": "Raptor2",
					"username": "Chris",
					"mac_addresses": ["80:fa:5b:53:8b:43","f8:63:3f:cf:77:7c"],
					"ip_addresses": ["192.168.1.87"],
					"platform": ["Windows","10"],
					"cpu": ["Intel(R) Core(TM) i7-10550U CPU @ 1.80GHz", 1.8, 1, 8, 16],
					"cpu_usage": 88,
					"memory": 8150060,
					"memory_usage": 11,
					"graphics": ["Intel Onboard"],
					"hard_drives": [{"name": "C:", "label": "System", "size": "256 GB", "percentage_used": 24, "type": 1}, {"name": "E:", "label": "", "size": "1 TB", "percentage_used": 5, "type": 1}, {"name": "D:", "label": "", "size": "2 TB", "percentage_used": 56, "type": 2}, {"name": "Z:", "label": "Daten", "size": "40 TB", "percentage_used": 76, "type": 3} ],
				},
				
				"status": RRStateScheme.client_offline,
				"current_job_id": -1,
				"last_render_log": [0,0,0],
				"error_count": 0,
				"pools": [1, 2, 3],
				"rr_version": 0.2,
				"time_connected": 1528759663,
				"software": ["Blender", "Natron"],
				"note": ""
			},
			5: {
				"machine_properties": {
					"name": "T-Rex3",
					"username": "Angela",
					"mac_addresses": ["80:fa:5b:53:8b:43","f8:63:3f:cf:77:7c"],
					"ip_addresses": ["192.168.1.15"],
					"platform": ["Linux","4.14.48-2"],
					"cpu": ["Intel(R) Core(TM) i9-8550 CPU @ 2.20GHz", 2.2, 1, 16, 32],
					"cpu_usage": 27,
					"memory": 4075030,
					"memory_usage": 38,
					"graphics": ["NVidia GTX 970"],
					"hard_drives": [{"name": "C:", "label": "System", "size": "256 GB", "percentage_used": 24, "type": 1}, {"name": "E:", "label": "", "size": "1 TB", "percentage_used": 5, "type": 1}, {"name": "D:", "label": "", "size": "2 TB", "percentage_used": 56, "type": 2}, {"name": "Z:", "label": "Daten", "size": "40 TB", "percentage_used": 76, "type": 3} ],
				},
				"status": RRStateScheme.client_error,
				"current_job_id": -1,
				"last_render_log": [0,0,0],
				"error_count": 1,
				"pools": [1],
				"rr_version": 1.2,
				"time_connected": 1528759663,
				"software": ["Blender", "Natron", "Nuke"],
				"note": ""
			},
			6: {
				"machine_properties": {
					"name": "Raptor3",
					"username": "Nicolaj",
					"mac_addresses": ["10:7b:44:7a:fb:e2","f8:63:3f:cf:77:7c"],
					"ip_addresses": ["192.168.1.22"],
					"platform": ["Windows","XP"],
					"cpu": ["Intel(R) Core(TM) i7-6000 CPU @ 4.00GHz", 4.0, 1, 4, 8],
					"cpu_usage": 100,
					"memory": 16305116,
					"memory_usage": 45,
					"graphics": ["Intel Onboard"],
					"hard_drives": [{"name": "C:", "label": "System", "size": "256 GB", "percentage_used": 24, "type": 1}, {"name": "E:", "label": "", "size": "1 TB", "percentage_used": 5, "type": 1}, {"name": "D:", "label": "", "size": "2 TB", "percentage_used": 56, "type": 2}, {"name": "Z:", "label": "Daten", "size": "40 TB", "percentage_used": 76, "type": 3} ],
				},
				"status": RRStateScheme.client_offline,
				"current_job_id": -1,
				"last_render_log": [0,0,0],
				"error_count": 0,
				"pools": [1, 2, 3],
				"rr_version": 0.2,
				"time_connected": 1528759663,
				"software": ["Blender", "Natron"],
				"note": ""
			},
			7: {
				"machine_properties": {
					"name": "T-Rex4",
					"username": "Patrick",
					"mac_addresses": ["80:fa:5b:53:8b:43","f8:63:3f:cf:77:7c"],
					"ip_addresses": ["192.168.1.45"],
					"platform": ["Linux","4.14.48-2"],
					"cpu": ["Intel(R) Core(TM) i7-9200CPU @ 3.40GHz", 3.4, 1, 4, 8],
					"cpu_usage": 65,
					"memory": 32610232,
					"memory_usage": 37,
					"graphics": ["NVidia GTX 970"],
					"hard_drives": [{"name": "C:", "label": "System", "size": "256 GB", "percentage_used": 24, "type": 1}, {"name": "E:", "label": "", "size": "1 TB", "percentage_used": 5, "type": 1}, {"name": "D:", "label": "", "size": "2 TB", "percentage_used": 56, "type": 2}, {"name": "Z:", "label": "Daten", "size": "40 TB", "percentage_used": 76, "type": 3} ],
				},
				"status": RRStateScheme.client_disabled,
				"current_job_id": -1,
				"last_render_log": [0,0,0],
				"error_count": 0,
				"pools": [1],
				"rr_version": 1.2,
				"time_connected": 1528759663,
				"software": ["Blender", "Natron", "Nuke"],
				"note": ""
			},
			8: {
				"machine_properties": {
					"name": "Raptor1",
					"username": "Florian",
					"mac_addresses": ["80:fa:5b:53:8b:43","f8:63:3f:cf:77:7c"],
					"ip_addresses": ["192.168.1.22"],
					"platform": ["Windows","10"],
					"cpu": ["Intel(R) Core(TM) i7-8550 CPU @ 1.80GHz", 1.8, 1, 8, 16],
					"cpu_usage": 10,
					"memory": 16305116,
					"memory_usage": 64,
					"graphics": ["Intel Onboard"],
					"hard_drives": [{"name": "C:", "label": "System", "size": "256 GB", "percentage_used": 24, "type": 1}, {"name": "E:", "label": "", "size": "1 TB", "percentage_used": 5, "type": 1}, {"name": "D:", "label": "", "size": "2 TB", "percentage_used": 56, "type": 2}, {"name": "Z:", "label": "Daten", "size": "40 TB", "percentage_used": 76, "type": 3} ],
				},
				"status": RRStateScheme.client_disabled,
				"current_job_id": -1,
				"last_render_log": [0,0,0],
				"error_count": 0,
				"pools": [],
				"rr_version": 0.2,
				"time_connected": 1528759663,
				"software": ["Blender", "Natron"],
				"note": ""
			},
			12: {
				"machine_properties": {
					"name": "Nedry",
					"username": "Dennis",
					"mac_addresses": ["80:fa:5b:53:8b:43","f8:63:3f:cf:77:7c"],
					"ip_addresses": ["192.168.1.87"],
					"platform": ["Windows","10"],
					"cpu": ["Intel(R) Core(TM) i7-8550U CPU @ 1.80GHz", 1.8, 1, 4, 8],
					"cpu_usage": 78,
					"memory": 16305116,
					"memory_usage": 23,
					"graphics": ["Intel Onboard"],
					"hard_drives": [{"name": "C:", "label": "System", "size": "256 GB", "percentage_used": 24, "type": 1}, {"name": "E:", "label": "", "size": "1 TB", "percentage_used": 5, "type": 1}, {"name": "D:", "label": "", "size": "2 TB", "percentage_used": 56, "type": 2}, {"name": "Z:", "label": "Daten", "size": "40 TB", "percentage_used": 76, "type": 3} ],
				},
				"status": RRStateScheme.client_disabled,
				"current_job_id": -1,
				"last_render_log": [0,0,0],
				"error_count": 0,
				"pools": [1, 4, 3],
				"rr_version": 0.2,
				"time_connected": 1528759663,
				"software": ["Blender", "Natron"],
				"note": ""
			},
			13: {
				"machine_properties": {
					"name": "T-Rex3",
					"username": "Peter",
					"mac_addresses": ["80:fa:5b:53:8b:43","f8:63:3f:cf:77:7c"],
					"ip_addresses": ["192.168.1.15"],
					"platform": ["Linux","4.14.48-2"],
					"cpu": ["Intel(R) Core(TM) i7-6600 CPU @ 3.80GHz", 3.8, 1, 6, 12],
					"cpu_usage": 66,
					"memory": 4075030,
					"memory_usage": 82,
					"graphics": ["NVidia GTX 970"],
					"hard_drives": [{"name": "C:", "label": "System", "size": "256 GB", "percentage_used": 24, "type": 1}, {"name": "E:", "label": "", "size": "1 TB", "percentage_used": 5, "type": 1}, {"name": "D:", "label": "", "size": "2 TB", "percentage_used": 56, "type": 2}, {"name": "Z:", "label": "Daten", "size": "40 TB", "percentage_used": 76, "type": 3} ],
				},
				"status": RRStateScheme.client_error,
				"current_job_id": -1,
				"last_render_log": [0,0,0],
				"error_count": 5,
				"pools": [1, 4],
				"rr_version": 1.2,
				"time_connected": 1528759663,
				"software": ["Blender", "Natron", "Nuke"],
				"note": ""
			},
			15: {
				"machine_properties": {
					"name": "Dr.Malcom",
					"username": "Horst",
					"mac_addresses": ["80:fa:5b:53:8b:43","f8:63:3f:cf:77:7c"],
					"ip_addresses": ["192.168.1.45"],
					"platform": ["Linux","4.14.48-2"],
					"cpu": ["Intel(R) Core(TM) i7-1200 CPU @ 3.20GHz", 3.2, 1, 12, 24],
					"cpu_usage": 61,
					"memory": 2030015,
					"memory_usage": 72,
					"graphics": ["NVidia GTX 970"],
					"hard_drives": [{"name": "C:", "label": "System", "size": "256 GB", "percentage_used": 24, "type": 1}, {"name": "E:", "label": "", "size": "1 TB", "percentage_used": 5, "type": 1}, {"name": "D:", "label": "", "size": "2 TB", "percentage_used": 56, "type": 2}, {"name": "Z:", "label": "Daten", "size": "40 TB", "percentage_used": 76, "type": 3} ],
				},
				"status": RRStateScheme.client_disabled,
				"current_job_id": -1,
				"last_render_log": [0,0,0],
				"error_count": 0,
				"pools": [4],
				"rr_version": 1.2,
				"time_connected": 1528759663,
				"software": ["Blender", "Natron", "Nuke"],
				"note": "Just a slow computer"
			},
			16: {
				"machine_properties": {
					"name": "Hammond",
					"username": "Daniel",
					"mac_addresses": ["80:fa:5b:53:8b:43","f8:63:3f:cf:77:7c"],
					"ip_addresses": ["192.168.1.22"],
					"platform": ["Windows","7"],
					"cpu": ["Intel(R) Core(TM) i7-8550U CPU @ 1.80GHz", 1.8, 1, 4, 8],
					"cpu_usage": 5,
					"memory": 120440928,
					"memory_usage": 25,
					"graphics": ["Intel Onboard"],
					"hard_drives": [{"name": "C:", "label": "System", "size": "256 GB", "percentage_used": 24, "type": 1}, {"name": "E:", "label": "", "size": "1 TB", "percentage_used": 5, "type": 1}, {"name": "D:", "label": "", "size": "2 TB", "percentage_used": 56, "type": 2}, {"name": "Z:", "label": "Daten", "size": "40 TB", "percentage_used": 76, "type": 3} ],
				},
				"status": RRStateScheme.client_disabled,
				"current_job_id": -1,
				"last_render_log": [0,0,0],
				"error_count": 0,
				"pools": [1, 2, 3],
				"rr_version": 0.2,
				"time_connected": 1528759663,
				"software": ["Blender", "Natron"],
				"note": "The Monster Machine!"
			}
		},
		
		
		
		"pools": {
			1 : {
				"name" : "AE_Plugins",
				"note" : "Red Giant plugins installed!",
				"clients" : [1,2,3,4,5,6,7,12,13,16],
				"jobs" : [4]
			},
			2 : {
				"name" : "another pool",
				"note" : "",
				"clients" : [2,4,6,16],
				"jobs" : []
			},
			3 :  {
				"name" : "third pool",
				"note" : "",
				"clients" : [2,4,6,12,16],
				"jobs" : []
			},
			4 : {
				"name" : "8GB+ VRam",
				"note" : "All Computers in this pool have at least 8gb of vram.",
				"clients" : [12,13,15],
				"jobs" : []
			}
		}
	}
	


func register_notification_system(NotificationSystemInstance : NotificationSystem):
	NotificationSystem = NotificationSystemInstance



func register_client_info_panel(InfoPanel):  
	
	ClientInfoPanel = InfoPanel



func register_job_info_panel(InfoPanel):  
	
	JobInfoPanel = InfoPanel



func register_try_info_panel(InfoPanel):  
	
	TryInfoPanel = InfoPanel



func register_table(SortableTableInstance : SortableTable):  

	var sortable_table_id : String = SortableTableInstance.table_id  
	
	match sortable_table_id: 
		"jobs":
			JobsTable = SortableTableInstance
			JobsTable.connect("refresh_table_content", self, "refresh_jobs_table")
			JobsTable.connect("something_just_selected", self, "job_selected")
			JobsTable.connect("selection_cleared", self, "job_selection_cleared")
			JobsTable.connect("context_invoked", self, "jobs_context_menu_invoked")
			
			# Set column names directly with the translation key. The label will change automatically and finding the position of the column in the refresh function is easier with a non changing nstring (translation key)
			JobsTable.column_names.clear()
			JobsTable.column_names.append("JOB_COLUMN_1") # Status
			JobsTable.column_names.append("JOB_COLUMN_2") # Name
			JobsTable.column_names.append("JOB_COLUMN_3") # Priority
			JobsTable.column_names.append("JOB_COLUMN_4") # Clients
			JobsTable.column_names.append("JOB_COLUMN_5") # Progress
			JobsTable.column_names.append("JOB_COLUMN_6") # Type
			JobsTable.column_names.append("JOB_COLUMN_7") # Creator
			JobsTable.column_names.append("JOB_COLUMN_8") # Time Created
			JobsTable.column_names.append("JOB_COLUMN_9") # Frame Range
			JobsTable.column_names.append("JOB_COLUMN_10") # Errors
			JobsTable.column_names.append("JOB_COLUMN_11") # Pools
			JobsTable.column_names.append("JOB_COLUMN_12") # Note
			
			# Set column widths
			JobsTable.column_widths.clear()
			JobsTable.column_widths.append(60)
			JobsTable.column_widths.append(220)
			JobsTable.column_widths.append(80)
			JobsTable.column_widths.append(70)
			JobsTable.column_widths.append(120)
			JobsTable.column_widths.append(100)
			JobsTable.column_widths.append(90)
			JobsTable.column_widths.append(165)
			JobsTable.column_widths.append(140)
			JobsTable.column_widths.append(70)
			JobsTable.column_widths.append(100)
			JobsTable.column_widths.append(150)
			
			
		"chunks":
			ChunksTable = SortableTableInstance
			ChunksTable.connect("context_invoked", self, "chunks_context_menu_invoked")
			ChunksTable.connect("something_just_selected", self, "chunk_selected")
			ChunksTable.connect("selection_cleared", self, "chunk_selection_cleared")
			
			# Set column names directly with the translation key. The label will change automatically and finding the position of the column in the refresh function is easier with a non changing nstring (translation key)
			ChunksTable.column_names.clear()
			ChunksTable.column_names.append("CHUNK_COLUMN_1") # ID
			ChunksTable.column_names.append("CHUNK_COLUMN_2") # Status
			ChunksTable.column_names.append("CHUNK_COLUMN_3") # Frames
			ChunksTable.column_names.append("CHUNK_COLUMN_4") # Client
			ChunksTable.column_names.append("CHUNK_COLUMN_5") # Rendertime
			ChunksTable.column_names.append("CHUNK_COLUMN_6") # Tries
			ChunksTable.column_names.append("CHUNK_COLUMN_7") # Errors
			ChunksTable.column_names.append("CHUNK_COLUMN_8") # Start
			ChunksTable.column_names.append("CHUNK_COLUMN_9") # Finish
			
			# Set column widths
			ChunksTable.column_widths.clear()
			ChunksTable.column_widths.append(40)
			ChunksTable.column_widths.append(60)
			ChunksTable.column_widths.append(100)
			ChunksTable.column_widths.append(100)
			ChunksTable.column_widths.append(100)
			ChunksTable.column_widths.append(60)
			ChunksTable.column_widths.append(60)
			ChunksTable.column_widths.append(160)
			ChunksTable.column_widths.append(160)
			
		"tries":
			TriesTable = SortableTableInstance
			TriesTable.connect("something_just_selected", self, "try_selected")
			TriesTable.connect("selection_cleared", self, "try_selection_cleared")
			
			# Set column names directly with the translation key. The label will change automatically and finding the position of the column in the refresh function is easier with a non changing nstring (translation key)
			TriesTable.column_names.clear()
			TriesTable.column_names.append("TRY_COLUMN_1") # Try
			
			# Set column widths
			TriesTable.column_widths.clear()
			TriesTable.column_widths.append(71)

		
		"clients": 
			ClientsTable = SortableTableInstance
			ClientsTable.connect("refresh_table_content", self, "refresh_clients_table")
			ClientsTable.connect("something_just_selected", self, "client_selected")
			ClientsTable.connect("selection_cleared", self, "client_selection_cleared")
			ClientsTable.connect("context_invoked", self, "client_context_menu_invoked")
			
			# Set column names directly with the translation key. The label will change automatically and finding the position of the column in the refresh function is easier with a non changing nstring (translation key)
			ClientsTable.column_names.clear()
			ClientsTable.column_names.append("CLIENT_COLUMN_1") # Status
			ClientsTable.column_names.append("CLIENT_COLUMN_2") # Name
			ClientsTable.column_names.append("CLIENT_COLUMN_3") # Username
			ClientsTable.column_names.append("CLIENT_COLUMN_4") # Platform
			ClientsTable.column_names.append("CLIENT_COLUMN_5") # CPU
			ClientsTable.column_names.append("CLIENT_COLUMN_6") # RAM
			ClientsTable.column_names.append("CLIENT_COLUMN_7") # Current Job
			ClientsTable.column_names.append("CLIENT_COLUMN_8") # Errors
			ClientsTable.column_names.append("CLIENT_COLUMN_9") # Pools
			ClientsTable.column_names.append("CLIENT_COLUMN_10") # Note
			ClientsTable.column_names.append("CLIENT_COLUMN_11") # Version
			
			# Set column widths
			ClientsTable.column_widths.clear()
			ClientsTable.column_widths.append(60)
			ClientsTable.column_widths.append(100)
			ClientsTable.column_widths.append(100)
			ClientsTable.column_widths.append(100)
			ClientsTable.column_widths.append(100)
			ClientsTable.column_widths.append(60)
			ClientsTable.column_widths.append(150)
			ClientsTable.column_widths.append(60)
			ClientsTable.column_widths.append(200)
			ClientsTable.column_widths.append(150)
			ClientsTable.column_widths.append(90)
			
			if not is_instance_valid(PoolTabsContainer):
				PoolTabsContainer = ClientsTable.get_parent().get_parent()


func register_context_menu(ContextMenu):  
	
	match ContextMenu.context_menu_id: 
		"clients":
			ContextMenu_Clients = ContextMenu
			
		"jobs":
			ContextMenu_Jobs = ContextMenu
			
		"chunks":
			ContextMenu_Chunks = ContextMenu
		
		"log":
			ContextMenu_Log = ContextMenu
			

func register_popup(popup):  
	
	match popup.popup_id: 
		"submit_job":
			SubmitJobPopup = popup
			
			var SubmitJobPopupContent = SubmitJobPopupContentRes.instance()
			SubmitJobPopupContent.connect("job_successfully_created", SubmitJobPopup, "hide_popup")
			SubmitJobPopup.set_content(SubmitJobPopupContent )
		
		"poolmanager":
			PoolManagerPopup = popup
			
			var PoolManagerPopupContent = PoolManagerPopupContentRes.instance()
			PoolManagerPopupContent.connect("changes_applied_successfully", PoolManagerPopup, "hide_popup")
			PoolManagerPopup.set_content(PoolManagerPopupContent )




func client_selected(id_of_row : int):
	JobsTable.clear_selection()
	ChunksTable.clear_selection()
	JobInfoPanel.visible = false
	JobInfoPanel.reset_to_first_tab()
	ClientInfoPanel.update_client_info_panel(id_of_row)
	ClientInfoPanel.visible = true


func client_selection_cleared():
	ClientInfoPanel.visible = false


func job_selected(id_of_row : int):
	ClientsTable.clear_selection()
	ChunksTable.clear_selection()
	TriesTable.clear_selection()
	current_job_id_for_job_info_panel = id_of_row
	current_chunk_id_for_job_info_panel = 0
	current_try_id_for_job_info_panel = 0
	ClientInfoPanel.visible = false
	ClientInfoPanel.reset_to_first_tab()
	JobInfoPanel.update_job_info_panel(id_of_row)
	if JobInfoPanel.get_current_tab() == 3: # images
		JobInfoPanel.ImagePreviewPanel.update_thumbnails_by_selecting_job()
	JobInfoPanel.visible = true
	TryInfoPanel.set_visibility(false)
	refresh_chunks_table(id_of_row)
	refresh_tries_table(id_of_row, 0)
	

func job_selection_cleared():
	JobInfoPanel.visible = false


func chunk_selected(id_of_row : int):
	refresh_tries_table(current_job_id_for_job_info_panel, id_of_row)
	TriesTable.clear_selection()
	TriesTable.select_by_id(1)
	
	current_chunk_id_for_job_info_panel = id_of_row
	if rr_data.jobs.has(current_job_id_for_job_info_panel):
		if rr_data.jobs[current_job_id_for_job_info_panel].chunks[current_chunk_id_for_job_info_panel].number_of_tries > 0:
			try_selected(1)
		else:
			current_try_id_for_job_info_panel = 0
			TryInfoPanel.currently_displayed_try_id = 0
			TryInfoPanel.set_visibility(false)

func chunk_selection_cleared():
	current_chunk_id_for_job_info_panel = 0
	current_try_id_for_job_info_panel = 0
	refresh_tries_table(current_job_id_for_job_info_panel, current_chunk_id_for_job_info_panel)
	TryInfoPanel.currently_displayed_try_id = 0
	TryInfoPanel.set_visibility(false)


func try_selected(id_of_row : int):
	current_try_id_for_job_info_panel = id_of_row
	
	TryInfoPanel.set_visibility(true)
	TryInfoPanel.update_try_info_panel(current_job_id_for_job_info_panel, current_chunk_id_for_job_info_panel, id_of_row)
	TryInfoPanel.update_current_try_id(id_of_row)

func try_selection_cleared():
	current_try_id_for_job_info_panel = 0
	TryInfoPanel.currently_displayed_try_id = 0
	TryInfoPanel.set_visibility(false)



func client_context_menu_invoked():
	ContextMenu_Clients.show_at_mouse_position()


func jobs_context_menu_invoked():
	ContextMenu_Jobs.show_at_mouse_position()


func chunks_context_menu_invoked():
	ContextMenu_Chunks.show_at_mouse_position()

func log_context_menu_invoked():
	ContextMenu_Log.show_at_mouse_position()




func update_all_visible_tables():
	#ClientsTable.refresh()
	#JobsTable.refresh()
	refresh_jobs_table()
	refresh_clients_table()
	
	if JobInfoPanel.get_current_tab() == 0: # details
		JobInfoPanel.update_job_info_panel(current_job_id_for_job_info_panel)
	elif JobInfoPanel.get_current_tab() == 1: # chnunks
		refresh_chunks_table(current_job_id_for_job_info_panel)
		refresh_tries_table(current_job_id_for_job_info_panel, current_chunk_id_for_job_info_panel)
		TryInfoPanel.update_try_info_panel(current_job_id_for_job_info_panel, current_chunk_id_for_job_info_panel, current_try_id_for_job_info_panel)


func refresh_jobs_table():
	
	# get all jobs
	var jobs_array = rr_data.jobs.keys()
	
	# display number of jobs in the Tabname
	JobsTable.get_parent().name = "Jobs (" + String ( jobs_array.size() ) + ")"
	
	
	#### Fill Jobs Table ####
	
	var jobs_iterator : int = 1 # will represent the row number
	
	for job in jobs_array:
	
		update_or_create_job_row(job, jobs_iterator)
		jobs_iterator += 1
	
	JobsTable.sort()



func refresh_chunks_table(job_id):
	
	if RaptorRender.rr_data.jobs.has(job_id):
	
		# get all chunks
		var chunks_array = rr_data.jobs[job_id].chunks.keys()
		
		# remove unneded filled rows of the ChunksTable
		if chunks_array.size() < ChunksTable.RowContainerFilled.SortableRows.size():
			
			for remove_id in range(chunks_array.size() + 1, ChunksTable.RowContainerFilled.SortableRows.size() + 1):
				
				ChunksTable.remove_row( remove_id )
		
		
		
		# display number of chunks in the Tabname
		#ChunksTable.get_parent().name = "Chunks (" + String ( chunks_array.size() ) + ")"
		
		
		#### Fill Chunks Table ####
		
		var chunks_iterator = 1 # will represent the row number
		
		for chunk in chunks_array:
			
			update_or_create_chunk_row(chunk, chunks_iterator, job_id)
			chunks_iterator += 1
		
		ChunksTable.sort()



func refresh_tries_table(job_id : int, chunk_id : int):
	
	if rr_data.jobs.has(job_id):
		if rr_data.jobs[job_id].chunks.has(chunk_id):
			
			# get all tries
			var number_of_tries = rr_data.jobs[job_id].chunks[chunk_id].number_of_tries
			
			# remove unneded filled rows of TriesTable
			if number_of_tries < TriesTable.RowContainerFilled.SortableRows.size():
				
				for remove_id in range(number_of_tries + 1, TriesTable.RowContainerFilled.SortableRows.size() + 1):
					
					TriesTable.remove_row( remove_id )
			
			# get all tries
			var tries_array = rr_data.jobs[job_id].chunks[chunk_id].tries.keys()
			
			#### Fill Chunks Table ####
			
			var tries_iterator : int = 1 # will represent the row number
			
			for try in tries_array:
				
				update_or_create_try_row(try, tries_iterator)
				tries_iterator += 1
			
			TriesTable.sort()
			
		
		else:
			TriesTable.clear_selection()
			
			# remove all rows
			if TriesTable.RowContainerFilled.SortableRows.size() > 0:
				for remove_id in range(1, TriesTable.RowContainerFilled.SortableRows.size() + 1):
						TriesTable.remove_row( remove_id )



func refresh_clients_table():
	
	# get all clients
	var clients_array = rr_data.clients.keys()
	
	
	# add number of clients behind the pool names
	if is_instance_valid(ClientsTable):
		var ClientsTabContainer : TabContainer = ClientsTable.get_parent().get_parent()
		
		ClientsTabContainer.get_child(0).name = tr("CLIENT_TAB_1") + " (" + String ( clients_array.size() ) + ")"
		
		for pool in rr_data.pools.keys():
			var num_of_clients_in_pool : int = rr_data.pools[pool].clients.size()
			
			var tabs_pools_dict : Dictionary = ClientsTabContainer.tabs_pools_dict.keys()
			
			for tab in tabs_pools_dict:
				if tabs_pools_dict[tab] == pool:
					if is_instance_valid(ClientsTabContainer.get_child(tab)):
						ClientsTabContainer.get_child(tab).name = rr_data.pools[pool].name +  " (" + String ( num_of_clients_in_pool ) + ")"
		
		
		#### Fill or update Clients Table ####
		
		var client_iterator : int = 1 # will represent the row number
		
		for client in clients_array:
	
			if clients_pool_filter == -1:
				update_or_create_client_row(client, client_iterator)
				client_iterator += 1
				
			else:
				if rr_data.clients[client].pools.has(clients_pool_filter):
					update_or_create_client_row(client, client_iterator)
					client_iterator += 1
		
		ClientsTable.sort()


func update_or_create_job_row(job : int, jobs_iterator : int) -> void:
	
	# define the columns of the jobs table ####
	var status_column = JobsTable.column_names.find("JOB_COLUMN_1", 0) + 1
	var name_column = JobsTable.column_names.find("JOB_COLUMN_2", 0) + 1
	var priority_column = JobsTable.column_names.find("JOB_COLUMN_3", 0) + 1
	var active_clients_column = JobsTable.column_names.find("JOB_COLUMN_4", 0) + 1
	var progress_column = JobsTable.column_names.find("JOB_COLUMN_5", 0) + 1
	var type_column = JobsTable.column_names.find("JOB_COLUMN_6", 0) + 1
	var creator_column = JobsTable.column_names.find("JOB_COLUMN_7", 0) + 1
	var time_created_column = JobsTable.column_names.find("JOB_COLUMN_8", 0) + 1
	var frame_range_column = JobsTable.column_names.find("JOB_COLUMN_9", 0) + 1
	var errors_column = JobsTable.column_names.find("JOB_COLUMN_10", 0) + 1
	var pools_column = JobsTable.column_names.find("JOB_COLUMN_11", 0) + 1
	var note_column = JobsTable.column_names.find("JOB_COLUMN_12", 0) + 1
	
	
	##############################################
	### update modified cells in row if row exists
	##############################################
	
	if JobsTable.RowContainerFilled.id_position_dict.has(job):
		
		# get reference to the row
		var row_position : int = JobsTable.RowContainerFilled.id_position_dict[job]
		var row : SortableTableRow = JobsTable.get_row_by_position( row_position )
		
		# update all cells that have changed
		
		
		
		### Status Icon ###
		
		# only change when value is different
		if (row.sort_values[status_column] != rr_data.jobs[job].status):
			
			# get reference to the cell
			var cell = JobsTable.get_cell( row_position, status_column )
			
			# change the cell value
			var StatusIcon = cell.get_child(0)
			
			if rr_data.jobs[job].status == RRStateScheme.job_rendering:
				StatusIcon.set_modulate(RRColorScheme.state_active)
					
			elif rr_data.jobs[job].status == RRStateScheme.job_rendering_paused_deferred:
				StatusIcon.set_modulate(RRColorScheme.state_paused_deferred)
					
			elif rr_data.jobs[job].status == RRStateScheme.job_queued:
				StatusIcon.set_modulate(RRColorScheme.state_queued)
					
			elif rr_data.jobs[job].status == RRStateScheme.job_error:
				StatusIcon.set_modulate(RRColorScheme.state_error)
					
			elif rr_data.jobs[job].status == RRStateScheme.job_paused:
				StatusIcon.set_modulate(RRColorScheme.state_paused)
					
			elif rr_data.jobs[job].status == RRStateScheme.job_finished:
				StatusIcon.set_modulate(RRColorScheme.state_finished_or_online)
					
			elif rr_data.jobs[job].status == RRStateScheme.job_cancelled:
				StatusIcon.set_modulate(RRColorScheme.state_offline_or_cancelled)
					
			
			# update sort_value
			JobsTable.set_cell_sort_value(row_position, status_column,  rr_data.jobs[job].status)
		
		
		
		### Name ###
		JobsTable.update_LABEL_cell(row_position, name_column,  rr_data.jobs[job].name)
		
		
		### Priority ###
		
		# always update because the buttons have to react to changes of the job state, too
		
		# get reference to the cell
		var priority_cell = JobsTable.get_cell( row_position, priority_column )
		
		# change the cell value
		var ChildNode : Node = priority_cell.get_child(0)
		if ChildNode is PriorityControl:
			
			ChildNode.disable_if_needed()
			ChildNode.set_text(String( rr_data.jobs[job].priority )) 
			
			# update sort_value
			JobsTable.set_cell_sort_value(row_position, priority_column,  rr_data.jobs[job].priority)
		
		
		
		### Active Clients ###
		var active_clients = 0
		
		# calculate the numbers of active clients
		if rr_data.jobs[job].status == RRStateScheme.job_rendering or rr_data.jobs[job].status == RRStateScheme.job_paused:
			for client in rr_data.clients.keys():
				if rr_data.clients[client].current_job_id == job:
					active_clients += 1
					
		JobsTable.update_LABEL_cell_with_custom_sort(row_position, active_clients_column, String(active_clients), active_clients)
		
		
		### Progress ###
		
		var chunk_counts = JobFunctions.get_chunk_counts_TotalFinishedActive(job)
		var percentage = int( float(chunk_counts[1]) / float(chunk_counts[0]) * 100.0 )
		
		# here we don't check if something changed or not, because it should also update when new chunks are started, even if the percentage is still the same
		# change the cell values
		var JobProgressBar = JobsTable.get_cell( row_position, progress_column ).get_child(0)
		
		if rr_data.jobs[job].status == RRStateScheme.job_paused:
			JobProgressBar.job_status = "paused"
		elif rr_data.jobs[job].status == RRStateScheme.job_cancelled:
			JobProgressBar.job_status = "cancelled"
		else:
			JobProgressBar.job_status = "normal"
			
		JobProgressBar.set_chunks(chunk_counts[0], chunk_counts[1], chunk_counts[2])
		JobProgressBar.show_progress()
		JobProgressBar.match_color_to_status()
		
		# update sort_value
		JobsTable.set_cell_sort_value(row_position, progress_column, percentage)
		
		
		
		### Type ###
		var type_value : String = rr_data.jobs[job].type
		if rr_data.jobs[job].type_version != "default":
			type_value = type_value + " (" + rr_data.jobs[job].type_version + ")"
		
		JobsTable.update_LABEL_cell(row_position, type_column, type_value)
		
		
		### Creator ###
		# impossible to change
		
		
		### Time Created ###
		# impossible to change
		
		
		### Frame Range ###
		JobsTable.update_LABEL_cell(row_position, frame_range_column, String(rr_data.jobs[job].frames_total) + "  (" + rr_data.jobs[job].frame_range + ")")
		
		
		### Errors ###
		var errors : int = rr_data.jobs[job].errors
		
		JobsTable.update_LABEL_cell_with_custom_sort(row_position, errors_column, String(errors), errors)
		
		JobsTable.set_row_color(row_position, RRColorScheme.ST_row_default)
		JobsTable.mark_erroneous(row_position, false)
		if colorize_erroneous_table_rows:
			if rr_data.jobs[job].errors > 0:
				JobsTable.set_row_color(row_position, RRColorScheme.ST_row_error)
				JobsTable.mark_erroneous(row_position, true)
				
		
		
		### Pools ###
		
		var pools_string : String = ""
		var pool_count : int = 1
			
		if rr_data.jobs[job].pools.size() > 0:
			for pool in rr_data.jobs[job].pools:
				pools_string += rr_data.pools[pool].name
				if pool_count < rr_data.jobs[job].pools.size():
					pools_string += ", "
				pool_count += 1
					
		JobsTable.update_LABEL_cell(row_position, pools_column, pools_string)
		
		### Note ###
		JobsTable.update_LABEL_cell(row_position, note_column, rr_data.jobs[job].note)
		
		
		
	##########################################################
	### create the row if row with given id does not exist yet
	##########################################################
	
	else:
		
		JobsTable.create_row(job)
		
		
		### Status Icon ###
		
		var StatusIcon = TextureRect.new()
		StatusIcon.set_expand(true)
		StatusIcon.set_stretch_mode(6) # 6 - keep aspect centered
		StatusIcon.set_v_size_flags(3) # fill + expand
		StatusIcon.set_h_size_flags(3) # fill + expand
		StatusIcon.rect_min_size.x = 54
		
		var icon = ImageTexture.new()
		icon = load("res://RaptorRender/GUI/icons/job_status/job_status_58x30.png")
		StatusIcon.set_texture(icon)
		
		
		if rr_data.jobs[job].status == RRStateScheme.job_rendering:
			StatusIcon.set_modulate(RRColorScheme.state_active)
				
		elif rr_data.jobs[job].status == RRStateScheme.job_rendering_paused_deferred:
			StatusIcon.set_modulate(RRColorScheme.state_paused_deferred)
			
		elif rr_data.jobs[job].status == RRStateScheme.job_queued:
			StatusIcon.set_modulate(RRColorScheme.state_queued)
				
		elif rr_data.jobs[job].status == RRStateScheme.job_error:
			StatusIcon.set_modulate(RRColorScheme.state_error)
				
		elif rr_data.jobs[job].status == RRStateScheme.job_paused:
			StatusIcon.set_modulate(RRColorScheme.state_paused)
				
		elif rr_data.jobs[job].status == RRStateScheme.job_finished:
			StatusIcon.set_modulate(RRColorScheme.state_finished_or_online)
				
		elif rr_data.jobs[job].status == RRStateScheme.job_cancelled:
			StatusIcon.set_modulate(RRColorScheme.state_offline_or_cancelled)
		
		
		JobsTable.set_cell_content(jobs_iterator, status_column, StatusIcon)
		
		# update sort_value
		JobsTable.set_cell_sort_value(jobs_iterator, status_column,  rr_data.jobs[job].status)
		
		
		
		### Name ###
		JobsTable.set_LABEL_cell(jobs_iterator, name_column, rr_data.jobs[job].name)
		
		
		### Priority ###
		
		var JobPriorityControl = JobPriorityControlRes.instance()
		JobPriorityControl.job_id = job
		JobsTable.set_cell_content(jobs_iterator, priority_column, JobPriorityControl)
		
		# update sort_value
		JobsTable.set_cell_sort_value(jobs_iterator, priority_column,  rr_data.jobs[job].priority)
		
		
		
		### Active Clients ###
		var active_clients : int = 0
		
		for client in rr_data.clients.keys():
			if rr_data.clients[client].current_job_id == job:
				active_clients += 1
		
		JobsTable.set_LABEL_cell_with_custom_sort(jobs_iterator, active_clients_column, String(active_clients), active_clients)
		
		
		### Progress ###
		
		var JobProgressBar = JobProgressBarRes.instance()
		JobProgressBar.rect_min_size.x = 120
		
		var chunk_counts = JobFunctions.get_chunk_counts_TotalFinishedActive(job)
		var percentage = int( float(chunk_counts[1]) / float(chunk_counts[0]) * 100.0 )
		
		JobProgressBar.set_chunks(chunk_counts[0], chunk_counts[1], chunk_counts[2])
		JobProgressBar.in_sortable_table = true
		
		if rr_data.jobs[job].status == RRStateScheme.job_paused:
			JobProgressBar.job_status = "paused"
		elif rr_data.jobs[job].status == RRStateScheme.job_cancelled:
			JobProgressBar.job_status = "cancelled"
		else:
			JobProgressBar.job_status = "normal"
		
		JobsTable.set_cell_content(jobs_iterator, progress_column, JobProgressBar)
		
		# update sort_value
		JobsTable.set_cell_sort_value(jobs_iterator, progress_column, percentage)
		
		
		
		### Type ###
		var type : String = rr_data.jobs[job].type
		if rr_data.jobs[job].type_version != "default":
			type = type + " (" + rr_data.jobs[job].type_version + ")"
		
		JobsTable.set_LABEL_cell(jobs_iterator, type_column, type)
		
		
		### Creator ###
		JobsTable.set_LABEL_cell(jobs_iterator, creator_column, rr_data.jobs[job].creator)
		
		
		### Time Created ###
		JobsTable.set_LABEL_cell_with_custom_sort(jobs_iterator, time_created_column, TimeFunctions.time_stamp_to_date_as_string( rr_data.jobs[job].time_created, 2, true), rr_data.jobs[job].time_created)
		
		
		### Frame Range ###
		JobsTable.set_LABEL_cell(jobs_iterator, frame_range_column, String(rr_data.jobs[job].frames_total) + "  (" + rr_data.jobs[job].frame_range + ")" )
		
		
		### Errors ###
		JobsTable.set_LABEL_cell_with_custom_sort(jobs_iterator, errors_column, String(rr_data.jobs[job].errors), rr_data.jobs[job].errors)
		
		JobsTable.set_row_color(jobs_iterator, RRColorScheme.ST_row_default)
		JobsTable.mark_erroneous(jobs_iterator, false)
		if colorize_erroneous_table_rows:
			if rr_data.jobs[job].errors > 0:
				JobsTable.set_row_color(jobs_iterator, RRColorScheme.ST_row_error)
				JobsTable.mark_erroneous(jobs_iterator, true)
		
		
		### Pools ###
		var pools_string = ""
		var pool_count = 1
		
		if rr_data.jobs[job].pools.size() > 0:
			for pool in rr_data.jobs[job].pools:
				pools_string += rr_data.pools[pool].name
				if pool_count < rr_data.jobs[job].pools.size():
					pools_string += ", "
				pool_count += 1
		
		JobsTable.set_LABEL_cell(jobs_iterator, pools_column, pools_string)
		
		
		### Note ###
		JobsTable.set_LABEL_cell(jobs_iterator, note_column,  rr_data.jobs[job].note)


func update_or_create_chunk_row(chunk : int, chunks_iterator : int, job_id : int) -> void:

	# define the columns of the jobs table ####
	var number_column = ChunksTable.column_names.find("CHUNK_COLUMN_1", 0) + 1
	var status_column = ChunksTable.column_names.find("CHUNK_COLUMN_2", 0) + 1
	var frames_column = ChunksTable.column_names.find("CHUNK_COLUMN_3", 0) + 1
	var client_column = ChunksTable.column_names.find("CHUNK_COLUMN_4", 0) + 1
	var rendertime_column = ChunksTable.column_names.find("CHUNK_COLUMN_5", 0) + 1
	var tries_column = ChunksTable.column_names.find("CHUNK_COLUMN_6", 0) + 1
	var errors_column = ChunksTable.column_names.find("CHUNK_COLUMN_7", 0) + 1
	var started_column = ChunksTable.column_names.find("CHUNK_COLUMN_8", 0) + 1
	var finished_column = ChunksTable.column_names.find("CHUNK_COLUMN_9", 0) + 1
	
	# number of tries
	var number_of_tries : int = rr_data.jobs[job_id].chunks[chunk].number_of_tries
	
	
	##############################################
	### update modified cells in row if row exists
	##############################################
	
	if ChunksTable.RowContainerFilled.id_position_dict.has(chunk):
		
		
		
		# get reference to the row
		var row_position : int = ChunksTable.RowContainerFilled.id_position_dict[chunk]
		var row : SortableTableRow = ChunksTable.get_row_by_position( row_position )
		
		# update all cells that have changed
		
		
		### Number ###
		ChunksTable.update_LABEL_cell_with_custom_sort(row_position,number_column, String(chunk), chunk)
		
		
		### Status Icon ###
		
		# only change when value is different
		if (row.sort_values[status_column] != rr_data.jobs[job_id].chunks[chunk].status):
			
			# get reference to the cell
			var cell = ChunksTable.get_cell( row_position, status_column )
			
			var StatusIcon = cell.get_child(0)
			
			if rr_data.jobs[job_id].chunks[chunk].status == RRStateScheme.chunk_rendering:
				StatusIcon.set_modulate(RRColorScheme.state_active)
					
			elif rr_data.jobs[job_id].chunks[chunk].status == RRStateScheme.chunk_queued:
				StatusIcon.set_modulate(RRColorScheme.state_queued)
					
			elif rr_data.jobs[job_id].chunks[chunk].status == RRStateScheme.chunk_error:
				StatusIcon.set_modulate(RRColorScheme.state_error)
					
			elif rr_data.jobs[job_id].chunks[chunk].status == RRStateScheme.chunk_paused:
				StatusIcon.set_modulate(RRColorScheme.state_paused)
					
			elif rr_data.jobs[job_id].chunks[chunk].status == RRStateScheme.chunk_finished:
				StatusIcon.set_modulate(RRColorScheme.state_finished_or_online)
					
			elif rr_data.jobs[job_id].chunks[chunk].status == RRStateScheme.chunk_cancelled:
				StatusIcon.set_modulate(RRColorScheme.state_offline_or_cancelled)
					
			
			
			# update sort_value
			ChunksTable.set_cell_sort_value(row_position, status_column,  rr_data.jobs[job_id].chunks[chunk].status)
		
		
		
		### Frames ###
		var first_chunk_frame : int= rr_data.jobs[job_id].chunks[chunk].frame_start
		var last_chunk_frame : int = rr_data.jobs[job_id].chunks[chunk].frame_end
		
		if first_chunk_frame == last_chunk_frame:
			ChunksTable.update_LABEL_cell_with_custom_sort(row_position, frames_column, String(first_chunk_frame), first_chunk_frame)
		else:
			ChunksTable.update_LABEL_cell_with_custom_sort(row_position, frames_column, String(first_chunk_frame) + " - " + String(last_chunk_frame), first_chunk_frame)
		
		
		### Client ###
		if number_of_tries != 0:
			var client_id : int = rr_data.jobs[job_id].chunks[chunk].tries[number_of_tries].client
			if rr_data.clients.has(client_id):
				var client_name : String = rr_data.clients[ client_id ].machine_properties.name
				ChunksTable.update_LABEL_cell(row_position, client_column, client_name)
			else:
				var client_name : String = tr("UNKNOWN")
				ChunksTable.update_LABEL_cell(row_position, client_column, client_name)
		else:
			ChunksTable.update_LABEL_cell(row_position, client_column, "")
		
		
		### Rendertime ###
		var chunk_rendertime : int = 0
		
		if rr_data.jobs[job_id].chunks[chunk].status == RRStateScheme.chunk_finished: 
			if number_of_tries > 0:
				chunk_rendertime = rr_data.jobs[job_id].chunks[chunk].tries[number_of_tries].time_stopped - rr_data.jobs[job_id].chunks[chunk].tries[number_of_tries].time_started
			
		elif rr_data.jobs[job_id].chunks[chunk].status == RRStateScheme.chunk_rendering: 
			chunk_rendertime = OS.get_unix_time() - rr_data.jobs[job_id].chunks[chunk].tries[number_of_tries].time_started
		
		if chunk_rendertime != 0:
			ChunksTable.update_LABEL_cell_with_custom_sort(row_position, rendertime_column, TimeFunctions.seconds_to_string(chunk_rendertime,3), chunk_rendertime)
		else: 
			ChunksTable.update_LABEL_cell_with_custom_sort(row_position, rendertime_column, "-", chunk_rendertime)
		
		
		### Number of tries ###
		ChunksTable.update_LABEL_cell_with_custom_sort(row_position, tries_column,  String(number_of_tries), number_of_tries)
		
		
		### Number of Errors ###
		var errors : int = rr_data.jobs[job_id].chunks[chunk].errors
		ChunksTable.update_LABEL_cell_with_custom_sort(row_position, errors_column, String(errors), errors)
		
		ChunksTable.set_row_color(row_position, RRColorScheme.ST_row_default)
		ChunksTable.mark_erroneous(row_position, false)
		if colorize_erroneous_table_rows:
			if errors > 0:
				ChunksTable.set_row_color(row_position, RRColorScheme.ST_row_error)
				ChunksTable.mark_erroneous(row_position, true)
		
		### Time Started ###
		
		if number_of_tries != 0:
			
			var time_started : int = rr_data.jobs[job_id].chunks[chunk].tries[number_of_tries].time_started
			
			ChunksTable.update_LABEL_cell_with_custom_sort(row_position, started_column, TimeFunctions.time_stamp_to_date_as_string(time_started, 1, true), time_started)
			
		else:
			ChunksTable.update_LABEL_cell_with_custom_sort(row_position, started_column, "-", 0)
		
		
		### Time Finished ###
		
		if number_of_tries != 0:
			
			var time_stopped : int = rr_data.jobs[job_id].chunks[chunk].tries[number_of_tries].time_stopped
			
			if time_stopped != 0:
				ChunksTable.update_LABEL_cell_with_custom_sort(row_position, finished_column, TimeFunctions.time_stamp_to_date_as_string(time_stopped, 1, true), time_stopped)
			else:
				ChunksTable.update_LABEL_cell_with_custom_sort(row_position, finished_column, "-", time_stopped)
				
		else:
			ChunksTable.update_LABEL_cell_with_custom_sort(row_position, finished_column, "-", 0)
		
		
		
	##########################################################
	### create the row if row with given id does not exist yet
	##########################################################
	
	else:
		
		ChunksTable.create_row(chunk)
		
		
		
		### Number ###
		ChunksTable.set_LABEL_cell_with_custom_sort(chunks_iterator, number_column, String(chunk), chunk)
		
		
		### Status Icon ###
		
		var StatusIcon = TextureRect.new()
		StatusIcon.set_expand(true)
		StatusIcon.set_stretch_mode(6) # 6 - keep aspect centered
		StatusIcon.set_v_size_flags(3) # fill + expand
		StatusIcon.set_h_size_flags(3) # fill + expand
		StatusIcon.rect_min_size.x = 54
		
		var icon = ImageTexture.new()
		icon = load("res://RaptorRender/GUI/icons/chunk_status/chunk_status_58x30.png")
		StatusIcon.set_texture(icon)
		
		if rr_data.jobs[job_id].chunks[chunk].status == RRStateScheme.chunk_rendering:
			StatusIcon.set_modulate(RRColorScheme.state_active)
				
		elif rr_data.jobs[job_id].chunks[chunk].status == RRStateScheme.chunk_queued:
			StatusIcon.set_modulate(RRColorScheme.state_queued)
				
		elif rr_data.jobs[job_id].chunks[chunk].status == RRStateScheme.chunk_error:
			StatusIcon.set_modulate(RRColorScheme.state_error)
				
		elif rr_data.jobs[job_id].chunks[chunk].status == RRStateScheme.chunk_paused:
			StatusIcon.set_modulate(RRColorScheme.state_paused)
				
		elif rr_data.jobs[job_id].chunks[chunk].status == RRStateScheme.chunk_finished:
			StatusIcon.set_modulate(RRColorScheme.state_finished_or_online)
				
		elif rr_data.jobs[job_id].chunks[chunk].status == RRStateScheme.chunk_cancelled:
			StatusIcon.set_modulate(RRColorScheme.state_offline_or_cancelled)
				
		
		ChunksTable.set_cell_content(chunks_iterator, status_column, StatusIcon)
		
		# update sort_value
		ChunksTable.set_cell_sort_value(chunks_iterator, status_column,  rr_data.jobs[job_id].chunks[chunk].status)
		
		
		
		
		### Frames ###
		var first_chunk_frame = rr_data.jobs[job_id].chunks[chunk].frame_start
		var last_chunk_frame = rr_data.jobs[job_id].chunks[chunk].frame_end
		
		if first_chunk_frame == last_chunk_frame:
			ChunksTable.set_LABEL_cell_with_custom_sort(chunks_iterator, frames_column, String(first_chunk_frame), first_chunk_frame)
		else:
			ChunksTable.set_LABEL_cell_with_custom_sort(chunks_iterator, frames_column, String(first_chunk_frame) + " - " + String(last_chunk_frame), first_chunk_frame)
		
		
		### Client ###
		var LabelClient = Label.new()
		
		if number_of_tries != 0:
			var client_id : int = rr_data.jobs[job_id].chunks[chunk].tries[number_of_tries].client
			if rr_data.clients.has(client_id):
				var client_name : String = rr_data.clients[client_id].machine_properties.name
				ChunksTable.set_LABEL_cell(chunks_iterator, client_column, client_name)
			else:
				var client_name : String = tr("UNKNOWN")
				ChunksTable.set_LABEL_cell(chunks_iterator, client_column, client_name)
			
		else:
			ChunksTable.set_LABEL_cell(chunks_iterator, client_column, "-")
		
		
		### Rendertime ###
		var chunk_rendertime : int = 0
		
		if rr_data.jobs[job_id].chunks[chunk].status == RRStateScheme.chunk_finished: 
			chunk_rendertime = rr_data.jobs[job_id].chunks[chunk].tries[number_of_tries].time_stopped - rr_data.jobs[job_id].chunks[chunk].tries[number_of_tries].time_started
			
		elif rr_data.jobs[job_id].chunks[chunk].status == RRStateScheme.chunk_rendering: 
			chunk_rendertime = OS.get_unix_time() - rr_data.jobs[job_id].chunks[chunk].tries[number_of_tries].time_started
		
		if chunk_rendertime != 0:
			ChunksTable.set_LABEL_cell_with_custom_sort(chunks_iterator, rendertime_column, TimeFunctions.seconds_to_string(chunk_rendertime, 3), chunk_rendertime)
		else:
			ChunksTable.set_LABEL_cell_with_custom_sort(chunks_iterator, rendertime_column, "-", 0)
		
		
		### Number of tries ###
		ChunksTable.set_LABEL_cell_with_custom_sort(chunks_iterator, tries_column, String(number_of_tries), number_of_tries)
		
		
		### Number of Errors ###
		var errors : int = rr_data.jobs[job_id].chunks[chunk].errors
		ChunksTable.set_LABEL_cell_with_custom_sort(chunks_iterator, errors_column, String(errors), errors) 
		
		ChunksTable.set_row_color(chunks_iterator, RRColorScheme.ST_row_default)
		ChunksTable.mark_erroneous(chunks_iterator, false)
		if colorize_erroneous_table_rows:
			if errors > 0:
				ChunksTable.set_row_color(chunks_iterator, RRColorScheme.ST_row_error)
				ChunksTable.mark_erroneous(chunks_iterator, false)
		
		### Time Started ###
		var time_started : int = 0
		var time_started_str : String = "-"
		
		if number_of_tries != 0:
			time_started = rr_data.jobs[job_id].chunks[chunk].tries[number_of_tries].time_started
			time_started_str = TimeFunctions.time_stamp_to_date_as_string(time_started, 1, true)
		
		ChunksTable.set_LABEL_cell_with_custom_sort(chunks_iterator, started_column, time_started_str, time_started)
		
		
		
		### Time Finished ###
		var time_stopped : int = 0
		var time_stopped_str : String = "-"
		
		if number_of_tries != 0:
			time_stopped = rr_data.jobs[job_id].chunks[chunk].tries[number_of_tries].time_stopped
			if time_stopped != 0:
				time_stopped_str = TimeFunctions.time_stamp_to_date_as_string(time_stopped, 1, true )
		
		ChunksTable.set_LABEL_cell_with_custom_sort(chunks_iterator, finished_column, time_stopped_str, time_stopped)



func update_or_create_try_row(try : int, tries_iterator : int) -> void:

	# define the columns of the jobs table ####
	var try_column = TriesTable.column_names.find("TRY_COLUMN_1", 0) + 1
	
	
	##############################################
	### update modified cells in row if row exists
	##############################################
	
	if TriesTable.RowContainerFilled.id_position_dict.has(try):
		
		
		# get reference to the row
		var row_position : int = TriesTable.RowContainerFilled.id_position_dict[try]
		var row : SortableTableRow = TriesTable.get_row_by_position( row_position )
		
		# update all cells that have changed
		
		
		### Try ###
		TriesTable.update_LABEL_cell_with_custom_sort(row_position, try_column, String(try), try)
		
		
		
	##########################################################
	### create the row if row with given id does not exist yet
	##########################################################
	
	else:
		
		TriesTable.create_row(try)
		
		
		### Try ###
		TriesTable.set_LABEL_cell_with_custom_sort(tries_iterator, try_column, String(try), try)



func update_or_create_client_row(client : int, client_iterator : int) -> void:
	
	
	# define the columns of the clients table ####
	var status_column = ClientsTable.column_names.find("CLIENT_COLUMN_1", 0) + 1
	var name_column = ClientsTable.column_names.find("CLIENT_COLUMN_2", 0) + 1
	var username_column = ClientsTable.column_names.find("CLIENT_COLUMN_3", 0) + 1
	var platform_column = ClientsTable.column_names.find("CLIENT_COLUMN_4", 0) + 1
	var cpu_column = ClientsTable.column_names.find("CLIENT_COLUMN_5", 0) + 1
	var memory_column = ClientsTable.column_names.find("CLIENT_COLUMN_6", 0) + 1
	var current_job_column = ClientsTable.column_names.find("CLIENT_COLUMN_7", 0) + 1
	var error_count_column = ClientsTable.column_names.find("CLIENT_COLUMN_8", 0) + 1
	var pools_column = ClientsTable.column_names.find("CLIENT_COLUMN_9", 0) + 1
	var note_column = ClientsTable.column_names.find("CLIENT_COLUMN_10", 0) + 1
	var rr_version_column = ClientsTable.column_names.find("CLIENT_COLUMN_11", 0) + 1
	
	
	##############################################
	### update modified cells in row if row exists
	##############################################
	
	if ClientsTable.RowContainerFilled.id_position_dict.has(client):
		
		# get reference to the row
		var row_position : int = ClientsTable.RowContainerFilled.id_position_dict[client]
		var row : SortableTableRow = ClientsTable.get_row_by_position( row_position )
		
		
		# update all cells that have changed
		
		
		### Status Icon ###
		
		# only change when value is different
		if (row.sort_values[status_column] != rr_data.clients[client].status):
			
			# get reference to the cell
			var cell = ClientsTable.get_cell( row_position, status_column )
			
			var StatusIcon = cell.get_child(0)
			
			if rr_data.clients[client].status == RRStateScheme.client_rendering:
				StatusIcon.set_modulate(RRColorScheme.state_active)
				
			elif rr_data.clients[client].status == RRStateScheme.client_available:
				StatusIcon.set_modulate(RRColorScheme.state_finished_or_online)
				
			elif rr_data.clients[client].status == RRStateScheme.client_error:
				StatusIcon.set_modulate(RRColorScheme.state_error)
			
			elif rr_data.clients[client].status == RRStateScheme.client_disabled:
				StatusIcon.set_modulate(RRColorScheme.state_paused)
			
			elif rr_data.clients[client].status == RRStateScheme.client_offline:
				StatusIcon.set_modulate(RRColorScheme.state_offline_or_cancelled)
			
			
			# update sort_value
			ClientsTable.set_cell_sort_value(row_position, status_column,  rr_data.clients[client].status)
		
		
		
		### Name ###
		ClientsTable.update_LABEL_cell(row_position, name_column, rr_data.clients[client].machine_properties.name)
		
		
		### Username ###
		ClientsTable.update_LABEL_cell(row_position, username_column, rr_data.clients[client].machine_properties.username)
		
		
		### Platform ###
		ClientsTable.update_LABEL_cell(row_position, platform_column,  rr_data.clients[client].machine_properties.platform[0])
		
		
		### CPU ###
		var cpu_array : Array = rr_data.clients[client].machine_properties.cpu
		var ghz : float = cpu_array[1] * cpu_array[2] * cpu_array[3]
		ClientsTable.update_LABEL_cell_with_custom_sort(row_position, cpu_column, String( ghz ) + " GHZ", ghz)
		
		
		### RAM ###
		ClientsTable.update_LABEL_cell_with_custom_sort(row_position, memory_column, String( round(float(rr_data.clients[client].machine_properties.memory) / 1024 / 1024 ))+ " GB", rr_data.clients[client].machine_properties.memory)
		
		
		### Current Job ###
		
		# only change when value is different
		if (row.sort_values[current_job_column] != rr_data.clients[client].current_job_id):
			
			# get reference to the cell
			var cell = ClientsTable.get_cell( row_position, current_job_column )
			
			# change the cell value
			var job_id = rr_data.clients[client].current_job_id
			cell.get_child(0).job_id = job_id
			
			if job_id == -1:
				cell.get_child(0).CurrentJobLabel.text = ""
			else:
				cell.get_child(0).CurrentJobLabel.text = rr_data.jobs[job_id].name
			cell.get_child(0).set_correct_visibility_of_link_button()
			
			# update sort_value
			ClientsTable.set_cell_sort_value(row_position, current_job_column,  rr_data.clients[client].current_job_id)
		
		
		
		### Errors ###
		var errors : int = rr_data.clients[client].error_count
		ClientsTable.update_LABEL_cell_with_custom_sort(row_position, error_count_column, String (errors), errors)
		
		ClientsTable.set_row_color(row_position, RRColorScheme.ST_row_default)
		ClientsTable.mark_erroneous(row_position, false)
		if colorize_erroneous_table_rows:
			if errors > 0:
				ClientsTable.set_row_color(row_position, RRColorScheme.ST_row_error)
				ClientsTable.mark_erroneous(row_position, true)
		
		
		### Pools ###
		
		var pools_string : String = ""
		var pool_count : int = 1

		if rr_data.clients[client].pools.size() > 0:
			for pool in rr_data.clients[client].pools:
				if rr_data.pools.has(pool):
					pools_string += rr_data.pools[pool].name
					if pool_count < rr_data.clients[client].pools.size():
						pools_string += ", "
					pool_count += 1

		ClientsTable.update_LABEL_cell(row_position, pools_column, pools_string)

		
		### Note ###
		ClientsTable.update_LABEL_cell(row_position, note_column,  rr_data.clients[client].note)
		
		
		### Raptor Render Version ###
		ClientsTable.update_LABEL_cell_with_custom_sort(row_position, rr_version_column, String(rr_data.clients[client].rr_version), rr_data.clients[client].rr_version)
	
	
	
	##########################################################
	### create the row if row with given id does not exist yet
	##########################################################
	
	else:
		ClientsTable.create_row(client)
		
		
		### Status Icon ###
		
		var StatusIcon = TextureRect.new()
		StatusIcon.set_expand(true)
		StatusIcon.set_stretch_mode(6) # 6 - keep aspect centered
		StatusIcon.set_v_size_flags(3) # fill + expand
		StatusIcon.set_h_size_flags(3) # fill + expand
		StatusIcon.rect_min_size.x = 54
		
		var icon = ImageTexture.new()
		icon = load("res://RaptorRender/GUI/icons/client_status/client_status_58x30.png")
		StatusIcon.set_texture(icon)
		
		if rr_data.clients[client].status == RRStateScheme.client_rendering:
			StatusIcon.set_modulate(RRColorScheme.state_active)
			
		elif rr_data.clients[client].status == RRStateScheme.client_available:
			StatusIcon.set_modulate(RRColorScheme.state_finished_or_online)
			
		elif rr_data.clients[client].status == RRStateScheme.client_error:
			StatusIcon.set_modulate(RRColorScheme.state_error)
		
		elif rr_data.clients[client].status == RRStateScheme.client_disabled:
			StatusIcon.set_modulate(RRColorScheme.state_paused)
		
		elif rr_data.clients[client].status == RRStateScheme.client_offline:
			StatusIcon.set_modulate(RRColorScheme.state_offline_or_cancelled)
			
		StatusIcon.set_texture(icon)
		ClientsTable.set_cell_content(client_iterator, status_column, StatusIcon)
		
		# update sort_value
		ClientsTable.set_cell_sort_value(client_iterator, status_column,  rr_data.clients[client].status)
		
		
		### Name ###
		ClientsTable.set_LABEL_cell(client_iterator, name_column, rr_data.clients[client].machine_properties.name)
		
		
		### Username ###
		ClientsTable.set_LABEL_cell(client_iterator, username_column, rr_data.clients[client].machine_properties.username)
		
		
		### Platform ###
		ClientsTable.set_LABEL_cell(client_iterator, platform_column, rr_data.clients[client].machine_properties.platform[0])
		
		
		### CPU ###
		var cpu_array : Array = rr_data.clients[client].machine_properties.cpu
		var ghz : float = cpu_array[1] * cpu_array[2] * cpu_array[3]
		ClientsTable.set_LABEL_cell_with_custom_sort(client_iterator, cpu_column, String( ghz ) + " GHZ", ghz)
		
		
		### RAM ###
		var ram : String  = String( round(float(rr_data.clients[client].machine_properties.memory) / 1024 / 1024 ))+ " GB"
		ClientsTable.set_LABEL_cell_with_custom_sort(client_iterator, memory_column, ram, rr_data.clients[client].machine_properties.memory)
		
		
		### Current Job ###
		
		var CurrentJobLink = CurrentJobLinkRes.instance()
		
		CurrentJobLink.job_id = rr_data.clients[client].current_job_id
		
		ClientsTable.set_cell_content(client_iterator, current_job_column, CurrentJobLink)
		
		# update sort_value
		ClientsTable.set_cell_sort_value(client_iterator, current_job_column,  rr_data.clients[client].current_job_id)
		
		
		
		### Errors ###
		
		ClientsTable.set_LABEL_cell_with_custom_sort(client_iterator, error_count_column, String(rr_data.clients[client].error_count), rr_data.clients[client].error_count )
		
		
		ClientsTable.set_row_color(client_iterator, RRColorScheme.ST_row_default)
		ClientsTable.mark_erroneous(client_iterator, false)
		if colorize_erroneous_table_rows:
			if rr_data.clients[client].error_count > 0:
				ClientsTable.set_row_color(client_iterator, RRColorScheme.ST_row_error)
				ClientsTable.mark_erroneous(client_iterator, true)
		
		
		
		### Pools ###
		var pools_string = ""
		var pool_count = 1

		if rr_data.clients[client].pools.size() > 0:
			for pool in rr_data.clients[client].pools:
				if rr_data.pools.has(pool):
					pools_string += rr_data.pools[pool].name
					if pool_count < rr_data.clients[client].pools.size():
						pools_string += ", "
					pool_count += 1

		ClientsTable.set_LABEL_cell(client_iterator, pools_column, pools_string)

		
		### Note ###
		ClientsTable.set_LABEL_cell(client_iterator, note_column, rr_data.clients[client].note)
		
		
		### Raptor Render Version ###
		ClientsTable.set_LABEL_cell_with_custom_sort(client_iterator, rr_version_column, String(rr_data.clients[client].rr_version), rr_data.clients[client].rr_version)


