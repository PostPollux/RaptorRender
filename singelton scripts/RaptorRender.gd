extends Node


###### Settings Variables ########

var colorize_table_rows : bool = false


#### preloads ####
var JobProgressBarRes = preload("res://GUI/SortableTable/specific_sortable_table_cell_elements/JobProgressBar/JobProgressBar.tscn")
var JobPriorityControlRes = preload("res://GUI/SortableTable/specific_sortable_table_cell_elements/PriorityControl/PriorityControl.tscn")
var CurrentJobLinkRes = preload("res://GUI/SortableTable/specific_sortable_table_cell_elements/CurrentJobLink/CurrentJobLink.tscn")



var NotificationSystem : NotificationSystem

var JobsTable : SortableTable
var ClientsTable : SortableTable
var ChunksTable : SortableTable

var ContextMenu_Clients
var ContextMenu_Jobs

var ClientInfoPanel
var JobInfoPanel

var rr_data = {}

var current_job_id_for_job_info_panel : int

var update_tables_timer : Timer 

func _ready():
	
	
	# create timer to constantly distribute the work across the connected clients 
	update_tables_timer = Timer.new()
	update_tables_timer.name = "Distribute Job Timer"
	update_tables_timer.wait_time = 1
	update_tables_timer.connect("timeout",self,"update_all_visible_tables")
	var root_node : Node = get_tree().get_root().get_node("RaptorRenderMainScene")
	if root_node != null:
		root_node.add_child(update_tables_timer)
	
	update_tables_timer.start()
	
	rr_data = {
		"jobs": {
			100: {
				"name": "renderfarmtest",
				"type": "Blender",
				"type_version": "default",
				"priority": 50,
				"creator": "Johannes",
				"time_created": 1528623180,
				"status": RRStateScheme.job_queued,
				"progress": 0,
				"range_start": 10,
				"range_end": 25,
				"note": "blender test",
				"errors": 0,
				"pools": [],
				"scene_path" : "/home/johannes/Schreibtisch/renderfarmtest.blend",
				"output_directory" : "/home/johannes/Schreibtisch/renderfarmtest/",
				"render_time" : 0,
				"SpecificJobSettings" : {},
				"chunks": {
					1:{
						"status" : RRStateScheme.chunk_queued,
						"frame_start" : 10,
						"frame_end" : 14,
						"client" : -1,
						"time_started" : 0,
						"time_finished" : 0,
						"number_of_tries" : 0
					},
					2:{
						"status" : RRStateScheme.chunk_queued,
						"frame_start" : 15,
						"frame_end" : 19,
						"client" : -1,
						"time_started" : 0,
						"time_finished" : 0,
						"number_of_tries" : 0
					},
					3:{
						"status" : RRStateScheme.chunk_queued,
						"frame_start" : 20,
						"frame_end" : 24,
						"client" : -1,
						"time_started" : 0,
						"time_finished" : 0,
						"number_of_tries" : 0
					},
					4:{
						"status" : RRStateScheme.chunk_queued,
						"frame_start" : 25,
						"frame_end" : 25,
						"client" : -1,
						"time_started" : 0,
						"time_finished" : 0,
						"number_of_tries" : 0
					}
				}
			},
			101: {
				"name": "natron test",
				"type": "Natron",
				"type_version": "default",
				"priority": 60,
				"creator": "Johannes",
				"time_created": 1528623180,
				"status": RRStateScheme.job_queued,
				"progress": 0,
				"range_start": 10,
				"range_end": 25,
				"note": "blender test",
				"errors": 0,
				"pools": [],
				"scene_path" : "/home/johannes/Schreibtisch/natron_renderfarm_test.ntp",
				"output_directory" : "/home/johannes/Schreibtisch/renderfarmtest/",
				"render_time" : 0,
				"SpecificJobSettings" : {
					"writer_name" : "Write1"
				},
				"chunks": {
					1:{
						"status" : RRStateScheme.chunk_queued,
						"frame_start" : 10,
						"frame_end" : 14,
						"client" : -1,
						"time_started" : 0,
						"time_finished" : 0,
						"number_of_tries" : 0
					},
					2:{
						"status" : RRStateScheme.chunk_queued,
						"frame_start" : 15,
						"frame_end" : 19,
						"client" : -1,
						"time_started" : 0,
						"time_finished" : 0,
						"number_of_tries" : 0
					},
					3:{
						"status" : RRStateScheme.chunk_queued,
						"frame_start" : 20,
						"frame_end" : 24,
						"client" : -1,
						"time_started" : 0,
						"time_finished" : 0,
						"number_of_tries" : 0
					},
					4:{
						"status" : RRStateScheme.chunk_queued,
						"frame_start" : 25,
						"frame_end" : 25,
						"client" : -1,
						"time_started" : 0,
						"time_finished" : 0,
						"number_of_tries" : 0
					}
				}
			},
			1: {
				"name": "city_build_v5",
				"type": "Blender",
				"type_version": "default",
				"priority": 50,
				"creator": "Johannes",
				"time_created": 1528623180,
				"status": RRStateScheme.job_cancelled,
				"progress": 28,
				"range_start": 230,
				"range_end": 780,
				"note": "eine Notiz",
				"errors": 2,
				"pools": ["AE_Plugins"],
				"scene_path" : "/home/johannes/Downlfoads/test.blend",
				"output_directory" : "/home/johannes/GodogtTest/",
				"render_time" : 345,
				"SpecificJobSettings" : {},
				"chunks": {
					1:{
						"status" : RRStateScheme.chunk_queued,
						"frame_start" : 20,
						"frame_end" : 25,
						"client" : -1,
						"time_started" : 0,
						"time_finished" : 0,
						"number_of_tries" : 1
					},
					2:{
						"status" : RRStateScheme.chunk_queued,
						"frame_start" : 20,
						"frame_end" : 25,
						"client" : -1,
						"time_started" : 0,
						"time_finished" : 0,
						"number_of_tries" : 1
					},
					3:{
						"status" : RRStateScheme.chunk_rendering,
						"frame_start" : 20,
						"frame_end" : 25,
						"client" : 2,
						"time_started" : 1535194239,
						"time_finished" : 0,
						"number_of_tries" : 5
					},
					4:{
						"status" : RRStateScheme.chunk_rendering,
						"frame_start" : 20,
						"frame_end" : 25,
						"client" : 7,
						"time_started" : 1535194219,
						"time_finished" : 0,
						"number_of_tries" : 1
					},
					5:{
						"status" : RRStateScheme.chunk_finished,
						"frame_start" : 20,
						"frame_end" : 25,
						"client" : 1,
						"time_started" : 1528523180,
						"time_finished" : 1528523280,
						"number_of_tries" : 2
					},
					6:{
						"status" : RRStateScheme.chunk_finished,
						"frame_start" : 20,
						"frame_end" : 25,
						"client" : 8,
						"time_started" : 1528523180,
						"time_finished" : 1528523230,
						"number_of_tries" : 1
					},
					7:{
						"status" : RRStateScheme.chunk_finished,
						"frame_start" : 20,
						"frame_end" : 25,
						"client" : 1,
						"time_started" : 1528523180,
						"time_finished" : 1528523280,
						"number_of_tries" : 1
					}
				}
			},
			7 : {
				"name": "city_build_v6",
				"type": "Blender",
				"type_version": "default",
				"priority": 50,
				"creator": "Johannes",
				"time_created": 1528621180,
				"status": RRStateScheme.job_cancelled,
				"progress": 28,
				"range_start": 1,
				"range_end": 80,
				"note": "",
				"errors": 0,
				"pools": ["AE_Plugins", "third pool"],
				"scene_path" : "\\home\\johannes\\Downloads\\test.blend",
				"output_directory" : "\\home\\johannes\\GodotTest\\",
				"render_time" : 3645,
				"SpecificJobSettings" : {},
				"chunks": {
					1:{
						"status" : RRStateScheme.chunk_queued,
						"frame_start" : 20,
						"frame_end" : 25,
						"client" : -1,
						"time_started" : 0,
						"time_finished" : 0,
						"number_of_tries" : 1
					},
					2:{
						"status" : RRStateScheme.chunk_rendering,
						"frame_start" : 20,
						"frame_end" : 25,
						"client" : 1,
						"time_started" : 1528523180,
						"time_finished" : 0,
						"number_of_tries" : 1
					},
					3:{
						"status" : RRStateScheme.chunk_rendering,
						"frame_start" : 20,
						"frame_end" : 25,
						"client" : 1,
						"time_started" : 1528523180,
						"time_finished" : 0,
						"number_of_tries" : 1
					},
					4:{
						"status" : RRStateScheme.chunk_rendering,
						"frame_start" : 20,
						"frame_end" : 25,
						"client" : 1,
						"time_started" : 1528523180,
						"time_finished" : 0,
						"number_of_tries" : 1
					},
					5:{
						"status" : RRStateScheme.chunk_queued,
						"frame_start" : 20,
						"frame_end" : 25,
						"client" : -1,
						"time_started" : 0,
						"time_finished" : 0,
						"number_of_tries" : 1
					}
				}
			},
			2: {
				"name": "city_unbuild_v02",
				"type": "Blender",
				"type_version": "default",
				"priority": 20,
				"creator": "Chris",
				"time_created": 1528613180,
				"status": RRStateScheme.job_cancelled,
				"progress": 0,
				"range_start": 1,
				"range_end": 500,
				"note": "",
				"errors": 0,
				"pools": ["third pool"],
				"scene_path" : "/home/johannes/Downloads/test.blend",
				"output_directory" : "/home/johannes/GodotTest/",
				"render_time" : 45,
				"SpecificJobSettings" : {},
				"chunks": {
					1:{
						"status" : RRStateScheme.chunk_queued,
						"frame_start" : 20,
						"frame_end" : 25,
						"client" : -1,
						"time_started" : 0,
						"time_finished" : 0,
						"number_of_tries" : 1
					},
					2:{
						"status" : RRStateScheme.chunk_queued,
						"frame_start" : 20,
						"frame_end" : 25,
						"client" : -1,
						"time_started" : 0,
						"time_finished" : 0,
						"number_of_tries" : 1
					},
					3:{
						"status" : RRStateScheme.chunk_queued,
						"frame_start" : 20,
						"frame_end" : 25,
						"client" : -1,
						"time_started" : 0,
						"time_finished" : 0,
						"number_of_tries" : 1
					},
					4:{
						"status" : RRStateScheme.chunk_queued,
						"frame_start" : 20,
						"frame_end" : 25,
						"client" : -1,
						"time_started" : 0,
						"time_finished" : 0,
						"number_of_tries" : 1
					},
					5:{
						"status" : RRStateScheme.chunk_queued,
						"frame_start" : 20,
						"frame_end" : 25,
						"client" : -1,
						"time_started" : 0,
						"time_finished" : 0,
						"number_of_tries" : 1
					},
					6:{
						"status" : RRStateScheme.chunk_queued,
						"frame_start" : 20,
						"frame_end" : 25,
						"client" : -1,
						"time_started" : 0,
						"time_finished" : 0,
						"number_of_tries" : 1
					},
					7:{
						"status" : RRStateScheme.chunk_queued,
						"frame_start" : 20,
						"frame_end" : 25,
						"client" : -1,
						"time_started" : 0,
						"time_finished" : 0,
						"number_of_tries" : 1
					}
				}
			},
			3: {
				"name": "Champions_League_Final_Shot3",
				"type": "After Effects",
				"type_version": "default",
				"priority": 20,
				"creator": "Michael",
				"time_created": 1528523180,
				"status": RRStateScheme.job_paused,
				"progress": 34,
				"range_start": 80,
				"range_end": 115,
				"note": "Rabarber",
				"errors": 0,
				"pools": ["another pool"],
				"scene_path" : "/home/johannes/Downloads/test.blend",
				"output_directory" : "/home/johannes/GodotTest/",
				"render_time" : 54445,
				"SpecificJobSettings" : {},
				"chunks": {
					1:{
						"status" : RRStateScheme.chunk_queued,
						"frame_start" : 20,
						"frame_end" : 25,
						"client" : -1,
						"time_started" : 0,
						"time_finished" : 0,
						"number_of_tries" : 1
					},
					2:{
						"status" : RRStateScheme.chunk_queued,
						"frame_start" : 20,
						"frame_end" : 25,
						"client" : -1,
						"time_started" : 0,
						"time_finished" : 0,
						"number_of_tries" : 1
					},
					3:{
						"status" : RRStateScheme.chunk_queued,
						"frame_start" : 20,
						"frame_end" : 25,
						"client" : -1,
						"time_started" : 0,
						"time_finished" : 0,
						"number_of_tries" : 1
					},
					4:{
						"status" : RRStateScheme.chunk_queued,
						"frame_start" : 20,
						"frame_end" : 25,
						"client" : -1,
						"time_started" : 0,
						"time_finished" : 0,
						"number_of_tries" : 1
					},
					5:{
						"status" : RRStateScheme.chunk_finished,
						"frame_start" : 20,
						"frame_end" : 25,
						"client" : 1,
						"time_started" : 1528523180,
						"time_finished" : 1528523200,
						"number_of_tries" : 1
					},
					6:{
						"status" : RRStateScheme.chunk_finished,
						"frame_start" : 20,
						"frame_end" : 25,
						"client" : 1,
						"time_started" : 1528523180,
						"time_finished" : 1528523280,
						"number_of_tries" : 1
					},
					7:{
						"status" : RRStateScheme.chunk_finished,
						"frame_start" : 20,
						"frame_end" : 25,
						"client" : 1,
						"time_started" : 1528523180,
						"time_finished" : 1528523380,
						"number_of_tries" : 1
					}
				}
			},
			4: {
				"name": "job 4",
				"type": "Natron",
				"type_version": "default",
				"priority": 77,
				"creator": "Max",
				"time_created": 1528620180,
				"status": RRStateScheme.job_finished,
				"progress": 100,
				"range_start": 120,
				"range_end": 350,
				"note": "3 Fehler",
				"errors": 0,
				"pools": ["AE_Plugins"],
				"scene_path" : "/home/johannes/Downloads/test.blend",
				"output_directory" : "/home/johannes/GodotTest/",
				"render_time" : 2487,
				"SpecificJobSettings" : {},
				"chunks": {
					1:{
						"status" : RRStateScheme.chunk_finished,
						"frame_start" : 20,
						"frame_end" : 25,
						"client" : 1,
						"time_started" : 1528523180,
						"time_finished" : 1528523280,
						"number_of_tries" : 1
					},
					2:{
						"status" : RRStateScheme.chunk_finished,
						"frame_start" : 20,
						"frame_end" : 25,
						"client" : 4,
						"time_started" : 1528523180,
						"time_finished" : 1528523275,
						"number_of_tries" : 1
					},
					3:{
						"status" : RRStateScheme.chunk_finished,
						"frame_start" : 20,
						"frame_end" : 25,
						"client" : 8,
						"time_started" : 1528523180,
						"time_finished" : 1528523299,
						"number_of_tries" : 1
					},
					4:{
						"status" : RRStateScheme.chunk_finished,
						"frame_start" : 20,
						"frame_end" : 25,
						"client" : 1,
						"time_started" : 1528523180,
						"time_finished" : 1528523268,
						"number_of_tries" : 1
					},
					5:{
						"status" : RRStateScheme.chunk_finished,
						"frame_start" : 20,
						"frame_end" : 25,
						"client" : 10,
						"time_started" : 1528523180,
						"time_finished" : 1528523245,
						"number_of_tries" : 1
					},
					6:{
						"status" : RRStateScheme.chunk_finished,
						"frame_start" : 20,
						"frame_end" : 25,
						"client" : 1,
						"time_started" : 1528523180,
						"time_finished" : 1528523222,
						"number_of_tries" : 1
					},
					7:{
						"status" : RRStateScheme.chunk_finished,
						"frame_start" : 20,
						"frame_end" : 25,
						"client" : 7,
						"time_started" : 1528523180,
						"time_finished" : 1528523200,
						"number_of_tries" : 1
					},
					8:{
						"status" : RRStateScheme.chunk_finished,
						"frame_start" : 20,
						"frame_end" : 25,
						"client" : 1,
						"time_started" : 1528523180,
						"time_finished" : 1528523190,
						"number_of_tries" : 1
					},
					9:{
						"status" : RRStateScheme.chunk_finished,
						"frame_start" : 20,
						"frame_end" : 25,
						"client" : 1,
						"time_started" : 1528523180,
						"time_finished" : 1528523285,
						"number_of_tries" : 1
					},
					10:{
						"status" : RRStateScheme.chunk_finished,
						"frame_start" : 20,
						"frame_end" : 25,
						"client" : 1,
						"time_started" : 1528523180,
						"time_finished" : 1528523230,
						"number_of_tries" : 1
					},
					11:{
						"status" : RRStateScheme.chunk_finished,
						"frame_start" : 20,
						"frame_end" : 25,
						"client" : 13,
						"time_started" : 1528523180,
						"time_finished" : 1528523250,
						"number_of_tries" : 1
					},
					12:{
						"status" : RRStateScheme.chunk_finished,
						"frame_start" : 20,
						"frame_end" : 25,
						"client" : 13,
						"time_started" : 1528523180,
						"time_finished" : 1528523270,
						"number_of_tries" : 1
					},
					13:{
						"status" : RRStateScheme.chunk_finished,
						"frame_start" : 20,
						"frame_end" : 25,
						"client" : 15,
						"time_started" : 1528523180,
						"time_finished" : 1528523260,
						"number_of_tries" : 1
					},
					14:{
						"status" : RRStateScheme.chunk_finished,
						"frame_start" : 20,
						"frame_end" : 25,
						"client" : 16,
						"time_started" : 1528523180,
						"time_finished" : 1528523320,
						"number_of_tries" : 1
					},
					15:{
						"status" : RRStateScheme.chunk_finished,
						"frame_start" : 20,
						"frame_end" : 25,
						"client" : 2,
						"time_started" : 1528523180,
						"time_finished" : 1528523290,
						"number_of_tries" : 1
					},
					16:{
						"status" : RRStateScheme.chunk_finished,
						"frame_start" : 20,
						"frame_end" : 25,
						"client" : 2,
						"time_started" : 1528523180,
						"time_finished" : 1528523255,
						"number_of_tries" : 1
					},
					17:{
						"status" : RRStateScheme.chunk_finished,
						"frame_start" : 20,
						"frame_end" : 25,
						"client" : 1,
						"time_started" : 1528523180,
						"time_finished" : 1528523430,
						"number_of_tries" : 1
					},
					18:{
						"status" : RRStateScheme.chunk_finished,
						"frame_start" : 20,
						"frame_end" : 25,
						"client" : 1,
						"time_started" : 1528523180,
						"time_finished" : 1528523190,
						"number_of_tries" : 1
					},
					19:{
						"status" : RRStateScheme.chunk_finished,
						"frame_start" : 20,
						"frame_end" : 25,
						"client" : 1,
						"time_started" : 1528523180,
						"time_finished" : 1528523270,
						"number_of_tries" : 1
					},
					20:{
						"status" : RRStateScheme.chunk_finished,
						"frame_start" : 20,
						"frame_end" : 25,
						"client" : 1,
						"time_started" : 1528523180,
						"time_finished" : 1528523275,
						"number_of_tries" : 1
					},
					21:{
						"status" : RRStateScheme.chunk_finished,
						"frame_start" : 20,
						"frame_end" : 25,
						"client" : 1,
						"time_started" : 1528523180,
						"time_finished" : 1528523220,
						"number_of_tries" : 1
					}
				}
			},
			5: {
				"name": "job 5",
				"type": "Nuke",
				"type_version": "default",
				"priority": 10,
				"creator": "Nicolaj",
				"time_created": 1528623110,
				"status": RRStateScheme.job_cancelled,
				"progress": 57,
				"range_start": 1600,
				"range_end": 2800,
				"note": "",
				"errors": 0,
				"pools": ["another pool"],
				"scene_path" : "/home/johannes/Downloads/test.blend",
				"output_directory" : "/home/johannes/GodotTest/",
				"render_time" : 3433578,
				"SpecificJobSettings" : {},
				"chunks": {
					1:{
						"status" : RRStateScheme.chunk_queued,
						"frame_start" : 20,
						"frame_end" : 25,
						"client" : -1,
						"time_started" : 0,
						"time_finished" : 0,
						"number_of_tries" : 1
					},
					2:{
						"status" : RRStateScheme.chunk_queued,
						"frame_start" : 20,
						"frame_end" : 25,
						"client" : -1,
						"time_started" : 0,
						"time_finished" : 0,
						"number_of_tries" : 1
					},
					3:{
						"status" : RRStateScheme.chunk_queued,
						"frame_start" : 20,
						"frame_end" : 25,
						"client" : -1,
						"time_started" : 0,
						"time_finished" : 0,
						"number_of_tries" : 1
					},
					4:{
						"status" : RRStateScheme.chunk_finished,
						"frame_start" : 20,
						"frame_end" : 25,
						"client" : 1,
						"time_started" : 1528523180,
						"time_finished" : 1528523380,
						"number_of_tries" : 1
					},
					5:{
						"status" : RRStateScheme.chunk_finished,
						"frame_start" : 20,
						"frame_end" : 25,
						"client" : 1,
						"time_started" : 1528523180,
						"time_finished" : 1528523480,
						"number_of_tries" : 1
					},
					6:{
						"status" : RRStateScheme.chunk_finished,
						"frame_start" : 20,
						"frame_end" : 25,
						"client" : 1,
						"time_started" : 1528523180,
						"time_finished" : 1528523620,
						"number_of_tries" : 1
					},
					7:{
						"status" : RRStateScheme.chunk_finished,
						"frame_start" : 20,
						"frame_end" : 25,
						"client" : 1,
						"time_started" : 1528523180,
						"time_finished" : 1528523680,
						"number_of_tries" : 1
					}
				}
			},
			6: {
				"name": "job 6",
				"type": "3DS Max",
				"type_version": "default",
				"priority": 10,
				"creator": "Nicolaj",
				"time_created": 1525611110,
				"status": RRStateScheme.job_error,
				"progress": 0,
				"range_start": 20,
				"range_end": 50,
				"note": "",
				"errors": 11,
				"pools": ["AE_Plugins"],
				"scene_path" : "/home/johannes/Downloads/test.blend",
				"output_directory" : "/home/johannes/GodotTest/",
				"render_time" : 4578,
				"SpecificJobSettings" : {},
				"chunks": {
					1:{
						"status" : RRStateScheme.chunk_queued,
						"frame_start" : 20,
						"frame_end" : 25,
						"client" : -1,
						"time_started" : 0,
						"time_finished" : 0,
						"number_of_tries" : 1
					},
					2:{
						"status" : RRStateScheme.chunk_queued,
						"frame_start" : 20,
						"frame_end" : 25,
						"client" : -1,
						"time_started" : 0,
						"time_finished" : 0,
						"number_of_tries" : 1
					},
					3:{
						"status" : RRStateScheme.chunk_queued,
						"frame_start" : 20,
						"frame_end" : 25,
						"client" : -1,
						"time_started" : 0,
						"time_finished" : 0,
						"number_of_tries" : 1
					},
					4:{
						"status" : RRStateScheme.chunk_queued,
						"frame_start" : 20,
						"frame_end" : 25,
						"client" : -1,
						"time_started" : 0,
						"time_finished" : 0,
						"number_of_tries" : 1
					},
					5:{
						"status" : RRStateScheme.chunk_queued,
						"frame_start" : 20,
						"frame_end" : 25,
						"client" : -1,
						"time_started" : 0,
						"time_finished" : 0,
						"number_of_tries" : 1
					},
					6:{
						"status" : RRStateScheme.chunk_queued,
						"frame_start" : 20,
						"frame_end" : 25,
						"client" : -1,
						"time_started" : 0,
						"time_finished" : 0,
						"number_of_tries" : 1
					}
				}
			}
		},
		
		
		
		"clients": {
			1: {
				"name": "T-Rex1",
				"username": "Johannes",
				"mac_addresses": ["80:fa:5b:53:8b:43","f8:63:3f:cf:77:7c"],
				"ip_addresses": ["192.168.1.45","192.133.1.45"],
				"status": RRStateScheme.client_disabled,
				"current_job_id": -1,
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
				"hard_drives": [{"name": "C:", "label": "System", "size": "256 GB", "percentage_used": 24, "type": 1}, {"name": "E:", "label": "", "size": "1 TB", "percentage_used": 5, "type": 1}, {"name": "D:", "label": "", "size": "2 TB", "percentage_used": 56, "type": 2}, {"name": "Z:", "label": "Daten", "size": "40 TB", "percentage_used": 76, "type": 3} ],
				"software": ["Blender", "Natron", "Nuke"],
				"note": ""
			},
			2: {
				"name": "Raptor1",
				"username": "Michael",
				"mac_addresses": ["80:fa:5b:53:8b:43","f8:63:3f:cf:77:7c"],
				"ip_addresses": ["192.168.1.22"],
				"status": RRStateScheme.client_disabled,
				"current_job_id": -1,
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
				"hard_drives": [{"name": "C:", "label": "System", "size": "256 GB", "percentage_used": 24, "type": 1}, {"name": "E:", "label": "", "size": "1 TB", "percentage_used": 5, "type": 1}, {"name": "D:", "label": "", "size": "2 TB", "percentage_used": 56, "type": 2}, {"name": "Z:", "label": "Daten", "size": "40 TB", "percentage_used": 76, "type": 3} ],
				"software": ["Blender", "Natron"],
				"note": ""
			},
			3: {
				"name": "T-Rex2",
				"username": "Max",
				"mac_addresses": ["80:fa:5b:53:8b:43","f8:63:3f:cf:77:7c"],
				"ip_addresses": ["192.168.1.156"],
				"status": RRStateScheme.client_disabled,
				"current_job_id": 1,
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
				"hard_drives": [{"name": "C:", "label": "System", "size": "256 GB", "percentage_used": 24, "type": 1}, {"name": "E:", "label": "", "size": "1 TB", "percentage_used": 5, "type": 1}, {"name": "D:", "label": "", "size": "2 TB", "percentage_used": 56, "type": 2}, {"name": "Z:", "label": "Daten", "size": "40 TB", "percentage_used": 76, "type": 3} ],
				"software": ["Blender", "Natron", "Nuke"],
				"note": ""
			},
			4: {
				"name": "Raptor2",
				"username": "Chris",
				"mac_addresses": ["80:fa:5b:53:8b:43","f8:63:3f:cf:77:7c"],
				"ip_addresses": ["192.168.1.87"],
				"status": RRStateScheme.client_offline,
				"current_job_id": -1,
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
				"hard_drives": [{"name": "C:", "label": "System", "size": "256 GB", "percentage_used": 24, "type": 1}, {"name": "E:", "label": "", "size": "1 TB", "percentage_used": 5, "type": 1}, {"name": "D:", "label": "", "size": "2 TB", "percentage_used": 56, "type": 2}, {"name": "Z:", "label": "Daten", "size": "40 TB", "percentage_used": 76, "type": 3} ],
				"software": ["Blender", "Natron"],
				"note": ""
			},
			5: {
				"name": "T-Rex3",
				"username": "Angela",
				"mac_addresses": ["80:fa:5b:53:8b:43","f8:63:3f:cf:77:7c"],
				"ip_addresses": ["192.168.1.15"],
				"status": RRStateScheme.client_error,
				"current_job_id": -1,
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
				"hard_drives": [{"name": "C:", "label": "System", "size": "256 GB", "percentage_used": 24, "type": 1}, {"name": "E:", "label": "", "size": "1 TB", "percentage_used": 5, "type": 1}, {"name": "D:", "label": "", "size": "2 TB", "percentage_used": 56, "type": 2}, {"name": "Z:", "label": "Daten", "size": "40 TB", "percentage_used": 76, "type": 3} ],
				"software": ["Blender", "Natron", "Nuke"],
				"note": ""
			},
			6: {
				"name": "Raptor3",
				"username": "Nicolaj",
				"mac_addresses": ["10:7b:44:7a:fb:e2","f8:63:3f:cf:77:7c"],
				"ip_addresses": ["192.168.1.22"],
				"status": RRStateScheme.client_offline,
				"current_job_id": -1,
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
				"hard_drives": [{"name": "C:", "label": "System", "size": "256 GB", "percentage_used": 24, "type": 1}, {"name": "E:", "label": "", "size": "1 TB", "percentage_used": 5, "type": 1}, {"name": "D:", "label": "", "size": "2 TB", "percentage_used": 56, "type": 2}, {"name": "Z:", "label": "Daten", "size": "40 TB", "percentage_used": 76, "type": 3} ],
				"software": ["Blender", "Natron"],
				"note": ""
			},
			7: {
				"name": "T-Rex4",
				"username": "Patrick",
				"mac_addresses": ["80:fa:5b:53:8b:43","f8:63:3f:cf:77:7c"],
				"ip_addresses": ["192.168.1.45"],
				"status": RRStateScheme.client_disabled,
				"current_job_id": -1,
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
				"hard_drives": [{"name": "C:", "label": "System", "size": "256 GB", "percentage_used": 24, "type": 1}, {"name": "E:", "label": "", "size": "1 TB", "percentage_used": 5, "type": 1}, {"name": "D:", "label": "", "size": "2 TB", "percentage_used": 56, "type": 2}, {"name": "Z:", "label": "Daten", "size": "40 TB", "percentage_used": 76, "type": 3} ],
				"software": ["Blender", "Natron", "Nuke"],
				"note": ""
			},
			8: {
				"name": "Raptor1",
				"username": "Florian",
				"mac_addresses": ["80:fa:5b:53:8b:43","f8:63:3f:cf:77:7c"],
				"ip_addresses": ["192.168.1.22"],
				"status": RRStateScheme.client_disabled,
				"current_job_id": -1,
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
				"hard_drives": [{"name": "C:", "label": "System", "size": "256 GB", "percentage_used": 24, "type": 1}, {"name": "E:", "label": "", "size": "1 TB", "percentage_used": 5, "type": 1}, {"name": "D:", "label": "", "size": "2 TB", "percentage_used": 56, "type": 2}, {"name": "Z:", "label": "Daten", "size": "40 TB", "percentage_used": 76, "type": 3} ],
				"software": ["Blender", "Natron"],
				"note": ""
			},
			9: {
				"name": "T-Rex1",
				"username": "Marcel",
				"mac_addresses": ["80:fa:5b:53:8b:43","f8:63:3f:cf:77:7c"],
				"ip_addresses": ["192.168.1.45"],
				"status": RRStateScheme.client_disabled,
				"current_job_id": -1,
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
				"hard_drives": [{"name": "C:", "label": "System", "size": "256 GB", "percentage_used": 24, "type": 1}, {"name": "E:", "label": "", "size": "1 TB", "percentage_used": 5, "type": 1}, {"name": "D:", "label": "", "size": "2 TB", "percentage_used": 56, "type": 2}, {"name": "Z:", "label": "Daten", "size": "40 TB", "percentage_used": 76, "type": 3} ],
				"software": ["Blender", "Natron", "Nuke"],
				"note": ""
			},
			10: {
				"name": "Raptor1",
				"username": "Andreas",
				"mac_addresses": ["80:fa:5b:53:8b:43","f8:63:3f:cf:77:7c"],
				"ip_addresses": ["192.168.1.22"],
				"status": RRStateScheme.client_disabled,
				"current_job_id": -1,
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
				"hard_drives": [{"name": "C:", "label": "System", "size": "256 GB", "percentage_used": 24, "type": 1}, {"name": "E:", "label": "", "size": "1 TB", "percentage_used": 5, "type": 1}, {"name": "D:", "label": "", "size": "2 TB", "percentage_used": 56, "type": 2}, {"name": "Z:", "label": "Daten", "size": "40 TB", "percentage_used": 76, "type": 3} ],
				"software": ["Blender", "Natron"],
				"note": "my workstation"
			},
			11: {
				"name": "T-Rex2",
				"username": "Thomas",
				"mac_addresses": ["80:fa:5b:53:8b:43","f8:63:3f:cf:77:7c"],
				"ip_addresses": ["192.168.1.156"],
				"status": RRStateScheme.client_disabled,
				"current_job_id": 7,
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
				"hard_drives": [{"name": "C:", "label": "System", "size": "256 GB", "percentage_used": 24, "type": 1}, {"name": "E:", "label": "", "size": "1 TB", "percentage_used": 5, "type": 1}, {"name": "D:", "label": "", "size": "2 TB", "percentage_used": 56, "type": 2}, {"name": "Z:", "label": "Daten", "size": "40 TB", "percentage_used": 76, "type": 3} ],
				"software": ["Blender", "Natron", "Nuke"],
				"note": "NVidia GTX 970"
			},
			12: {
				"name": "Nedry",
				"username": "Dennis",
				"mac_addresses": ["80:fa:5b:53:8b:43","f8:63:3f:cf:77:7c"],
				"ip_addresses": ["192.168.1.87"],
				"status": RRStateScheme.client_disabled,
				"current_job_id": -1,
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
				"hard_drives": [{"name": "C:", "label": "System", "size": "256 GB", "percentage_used": 24, "type": 1}, {"name": "E:", "label": "", "size": "1 TB", "percentage_used": 5, "type": 1}, {"name": "D:", "label": "", "size": "2 TB", "percentage_used": 56, "type": 2}, {"name": "Z:", "label": "Daten", "size": "40 TB", "percentage_used": 76, "type": 3} ],
				"software": ["Blender", "Natron"],
				"note": ""
			},
			13: {
				"name": "T-Rex3",
				"username": "Peter",
				"mac_addresses": ["80:fa:5b:53:8b:43","f8:63:3f:cf:77:7c"],
				"ip_addresses": ["192.168.1.15"],
				"status": RRStateScheme.client_error,
				"current_job_id": -1,
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
				"hard_drives": [{"name": "C:", "label": "System", "size": "256 GB", "percentage_used": 24, "type": 1}, {"name": "E:", "label": "", "size": "1 TB", "percentage_used": 5, "type": 1}, {"name": "D:", "label": "", "size": "2 TB", "percentage_used": 56, "type": 2}, {"name": "Z:", "label": "Daten", "size": "40 TB", "percentage_used": 76, "type": 3} ],
				"software": ["Blender", "Natron", "Nuke"],
				"note": ""
			},
			15: {
				"name": "Dr.Malcom",
				"username": "Horst",
				"mac_addresses": ["80:fa:5b:53:8b:43","f8:63:3f:cf:77:7c"],
				"ip_addresses": ["192.168.1.45"],
				"status": RRStateScheme.client_disabled,
				"current_job_id": -1,
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
				"hard_drives": [{"name": "C:", "label": "System", "size": "256 GB", "percentage_used": 24, "type": 1}, {"name": "E:", "label": "", "size": "1 TB", "percentage_used": 5, "type": 1}, {"name": "D:", "label": "", "size": "2 TB", "percentage_used": 56, "type": 2}, {"name": "Z:", "label": "Daten", "size": "40 TB", "percentage_used": 76, "type": 3} ],
				"software": ["Blender", "Natron", "Nuke"],
				"note": "Just a slow computer"
			},
			16: {
				"name": "Hammond",
				"username": "Daniel",
				"mac_addresses": ["80:fa:5b:53:8b:43","f8:63:3f:cf:77:7c"],
				"ip_addresses": ["192.168.1.22"],
				"status": RRStateScheme.client_disabled,
				"current_job_id": -1,
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
				"hard_drives": [{"name": "C:", "label": "System", "size": "256 GB", "percentage_used": 24, "type": 1}, {"name": "E:", "label": "", "size": "1 TB", "percentage_used": 5, "type": 1}, {"name": "D:", "label": "", "size": "2 TB", "percentage_used": 56, "type": 2}, {"name": "Z:", "label": "Daten", "size": "40 TB", "percentage_used": 76, "type": 3} ],
				"software": ["Blender", "Natron"],
				"note": "The Monster Machine!"
			}
		}
	}
	


func register_notification_system(NotificationSystemInstance : NotificationSystem):
	NotificationSystem = NotificationSystemInstance



func register_client_info_panel(InfoPanel):  
	
	ClientInfoPanel = InfoPanel



func register_job_info_panel(InfoPanel):  
	
	JobInfoPanel = InfoPanel



func register_table(SortableTableInstance : SortableTable):  

	var sortable_table_id : String = SortableTableInstance.table_id  
	
	match sortable_table_id: 
		"jobs":
			JobsTable = SortableTableInstance
			JobsTable.connect("refresh_table_content", self, "refresh_jobs_table")
			JobsTable.connect("something_just_selected", self, "job_selected")
			JobsTable.connect("selection_cleared", self, "job_selection_cleared")
			JobsTable.connect("context_invoked", self, "jobs_context_menu_invoked")
			
		"chunks":
			ChunksTable = SortableTableInstance
		
		"clients": 
			ClientsTable = SortableTableInstance
			ClientsTable.connect("refresh_table_content", self, "refresh_clients_table")
			ClientsTable.connect("something_just_selected", self, "client_selected")
			ClientsTable.connect("selection_cleared", self, "client_selection_cleared")
			ClientsTable.connect("context_invoked", self, "client_context_menu_invoked")



func register_context_menu(ContextMenu):  
	
	match ContextMenu.context_menu_id: 
		"clients":
			ContextMenu_Clients = ContextMenu
			
		"jobs":
			ContextMenu_Jobs = ContextMenu
			
			
			
func client_selected(id_of_row : int):
	JobsTable.clear_selection()
	ChunksTable.clear_selection()
	JobInfoPanel.visible = false
	JobInfoPanel.reset_to_first_tab()
	ClientInfoPanel.update_client_info_panel(id_of_row)
	ClientInfoPanel.visible = true


func client_selection_cleared():
	ClientInfoPanel.visible = false



func job_selected(id_of_row):
	ClientsTable.clear_selection()
	ChunksTable.clear_selection()
	ClientInfoPanel.visible = false
	ClientInfoPanel.reset_to_first_tab()
	JobInfoPanel.update_job_info_panel(id_of_row)
	JobInfoPanel.visible = true
	refresh_chunks_table(id_of_row)
	current_job_id_for_job_info_panel = id_of_row


func job_selection_cleared():
	JobInfoPanel.visible = false


func client_context_menu_invoked():
	ContextMenu_Clients.show_at_mouse_position()
	

func jobs_context_menu_invoked():
	ContextMenu_Jobs.show_at_mouse_position()




func _input(event):
		
	if Input.is_key_pressed(KEY_R):
		JobsTable.refresh()
		ClientsTable.refresh()
		
	if Input.is_key_pressed(KEY_C):
		if colorize_table_rows:
			colorize_table_rows = false
		else:
			colorize_table_rows = true
		JobsTable.refresh()
		ClientsTable.refresh()
			
	if Input.is_key_pressed(KEY_X):
		rr_data.clients.erase("id4")
		rr_data.clients.erase("id8")
		rr_data.clients.erase("id10")
		ClientsTable.refresh()
		
	if Input.is_key_pressed(KEY_B):
		rr_data.jobs["1"] = {
				"name": "new name",
				"type": "new program",
				"priority": 99,
				"creator": "new",
				"time_created": 623180,
				"status": RRStateScheme.job_queued,
				"progress": 88,
				"range_start": 280,
				"range_end": 880,
				"note": "eine andere Notiz",
				"errors": 10,
				"pools": ["neuer pool","neuer pool2"],
				"scene_directory" : "/home/johannes/Downloads/",
				"output_directory" : "/home/johannes/GodotTest/",
				"render_time" : 345,
				"chunks": {
					"1":{
						"status" : RRStateScheme.chunk_finished,
						"frames" : [20,21,22,23],
						"client" : "id1",
						"time_started" : 1528523180,
						"time_finished" : 1528583180,
						"number_of_tries" : 1
					},
					"2":{
						"status" : RRStateScheme.chunk_finished,
						"frames" : [24,25,26,27],
						"client" : "id1",
						"time_started" : 1528523180,
						"time_finished" : 1528583180,
						"number_of_tries" : 1
					},
					"3":{
						"status" : RRStateScheme.chunk_rendering,
						"frames" : [24,25,26,27],
						"client" : "id1",
						"time_started" : 1528523180,
						"time_finished" : 1528583180,
						"number_of_tries" : 1
					},
					"4":{
						"status" : RRStateScheme.chunk_rendering,
						"frames" : [24,25,26,27],
						"client" : "id1",
						"time_started" : 1528523180,
						"time_finished" : 1528583180,
						"number_of_tries" : 1
					},
					"5":{
						"status" : RRStateScheme.chunk_finished,
						"frames" : [24,25,26,27],
						"client" : "id1",
						"time_started" : 1528523180,
						"time_finished" : 1528583180,
						"number_of_tries" : 1
					},
					"6":{
						"status" : RRStateScheme.chunk_finished,
						"frames" : [24,25,26,27],
						"client" : "id1",
						"time_started" : 1528523180,
						"time_finished" : 1528583180,
						"number_of_tries" : 1
					},
					"7":{
						"status" : RRStateScheme.chunk_finished,
						"frames" : [24,25,26,27],
						"client" : "id1",
						"time_started" : 1528523180,
						"time_finished" : 1528583180,
						"number_of_tries" : 1
					}
				}
			}

		rr_data.clients["id1"] =  {
				"name": "new machine",
				"username": "new user",
				"mac_addresses": ["80:fa:5b:53:8b:43","f8:63:3f:cf:77:7c"],
				"ip_addresses": ["192.168.1.45","192.133.1.45"],
				"status": RRStateScheme.client_disabled,
				"current_job_id": 4,
				"error_count": 12,
				"platform": ["Linux","4.14.48-2"],
				"pools": ["new pool", "new pools"],
				"rr_version": 1.6,
				"time_connected": 1528759663,
				"cpu": ["Intel(R) Core(TM) i7-8800 CPU @ 30.00GHz", 30, 2, 4, 8],
				"cpu_usage": 5,
				"memory": 329610232,
				"memory_usage": 22,
				"graphics": ["NVidia GTX 970"],
				"software": ["Blender", "Natron", "Nuke"],
				"note": "new note"
			}
			
		rr_data.clients["77"] =  {
				"name": "Double Sun Power!",
				"username": "Sun",
				"mac_addresses": ["80:fa:5b:53:8b:43","f8:63:3f:cf:77:7c"],
				"ip_addresses": ["192.168.1.45","192.133.1.45"],
				"status": RRStateScheme.client_disabled,
				"current_job_id": 4,
				"error_count": 12,
				"platform": ["Linux","4.14.48-2"],
				"pools": ["new pool", "new pools"],
				"rr_version": 1.6,
				"time_connected": 1528759663,
				"cpu": ["Intel(R) Core(TM) i7-8800 CPU @ 30.00GHz", 30, 2, 4, 8],
				"cpu_usage": 5,
				"memory": 329610232,
				"memory_usage": 22,
				"graphics": ["NVidia GTX 970"],
				"software": ["Blender", "Natron", "Nuke"],
				"note": "new note"
			}
		
		ClientsTable.refresh()
		JobsTable.refresh()


func update_all_visible_tables():
	refresh_jobs_table()
	refresh_clients_table()
	
	if JobInfoPanel.get_current_tab() == 0:
		JobInfoPanel.update_job_info_panel(current_job_id_for_job_info_panel)
	elif JobInfoPanel.get_current_tab() == 1:
		refresh_chunks_table(current_job_id_for_job_info_panel)


func refresh_jobs_table():
	
	
	# define the columns of the jobs table ####
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
	
	
	# get all jobs
	var jobs_array = rr_data.jobs.keys()
	
	# display number of jobs in the Tabname
	JobsTable.get_parent().name = "Jobs (" + String ( jobs_array.size() ) + ")"
	
	
	#### Fill Jobs Table ####
	
	var count = 1
	
	for job in jobs_array:

		##############################################
		### update modified cells in row if row exists
		##############################################
		
		if JobsTable.RowContainerFilled.id_position_dict.has(job):
			
			# get reference to the row
			var row_position = JobsTable.RowContainerFilled.id_position_dict[job]
			var row = JobsTable.get_row_by_position( row_position )
			
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
					if colorize_table_rows:
						JobsTable.set_row_color_by_string(row_position, "blue")
						
				elif rr_data.jobs[job].status == RRStateScheme.job_rendering_paused_deferred:
					StatusIcon.set_modulate(RRColorScheme.state_paused_deferred)
						
				elif rr_data.jobs[job].status == RRStateScheme.job_queued:
					StatusIcon.set_modulate(RRColorScheme.state_queued)
					if colorize_table_rows:
						JobsTable.set_row_color_by_string(row_position, "yellow")
						
				elif rr_data.jobs[job].status == RRStateScheme.job_error:
					StatusIcon.set_modulate(RRColorScheme.state_error)
					if colorize_table_rows:
						JobsTable.set_row_color_by_string(row_position, "red")
						
				elif rr_data.jobs[job].status == RRStateScheme.job_paused:
					StatusIcon.set_modulate(RRColorScheme.state_paused)
						
				elif rr_data.jobs[job].status == RRStateScheme.job_finished:
					StatusIcon.set_modulate(RRColorScheme.state_finished_or_online)
					if colorize_table_rows:
						JobsTable.set_row_color_by_string(row_position, "green")
						
				elif rr_data.jobs[job].status == RRStateScheme.job_cancelled:
					StatusIcon.set_modulate(RRColorScheme.state_offline_or_cancelled)
					if colorize_table_rows:
						JobsTable.set_row_color_by_string(row_position, "black")
						cell.get_child(0).set_modulate(Color(0.6, 0.6, 0.6, 1))
						
				
				# update sort_value
				JobsTable.set_cell_sort_value(row_position, status_column,  rr_data.jobs[job].status)
			
			
			
			### Name ###
			
			# only change when value is different
			if (row.sort_values[name_column] != rr_data.jobs[job].name.to_lower()):
				
				# get reference to the cell
				var cell = JobsTable.get_cell( row_position, name_column )
				
				# change the cell value
				cell.get_child(0).text = rr_data.jobs[job].name
				
				# update sort_value
				JobsTable.set_cell_sort_value(row_position, name_column,  rr_data.jobs[job].name.to_lower())
			
			
			
			### Priority ###
			
			# always update because the buttons have to react to changes of the job state, too
			
			
			# get reference to the cell
			var priority_cell = JobsTable.get_cell( row_position, priority_column )
			
			# change the cell value
			priority_cell.get_child(0).disable_if_needed()
			priority_cell.get_child(0).LabelPriority.text = String( rr_data.jobs[job].priority )
			
			# update sort_value
			JobsTable.set_cell_sort_value(row_position, priority_column,  rr_data.jobs[job].priority)
			
			
			
			
			### Active Clients ###
			
			var active_clients = 0
			
			# calculate the numbers of active clients
			if rr_data.jobs[job].status == RRStateScheme.job_rendering or rr_data.jobs[job].status == RRStateScheme.job_paused:
				for client in rr_data.clients.keys():
					if rr_data.clients[client].current_job_id == job:
						active_clients += 1
						
			# only change when value is different
			if (row.sort_values[active_clients_column] != active_clients):
				
				# get reference to the cell
				var cell = JobsTable.get_cell( row_position, active_clients_column )
				
				# change the cell value
				cell.get_child(0).text = String(active_clients)
				
				# update sort_value
				JobsTable.set_cell_sort_value(row_position, active_clients_column, active_clients)
			
			
			
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
			
			# only change when value is different
			if (row.sort_values[type_column] != rr_data.jobs[job].type.to_lower()):
				
				# get reference to the cell
				var cell = JobsTable.get_cell( row_position, type_column )
				
				# change the cell value
				cell.get_child(0).text = rr_data.jobs[job].type
				
				# update sort_value
				JobsTable.set_cell_sort_value(row_position, type_column,  rr_data.jobs[job].type.to_lower())
			
			
			
			### Creator ###
			
			# impossible to change
			
			
			
			### Time Created ###
			
			# impossible to change
			
			
			
			### Frame Range ###
			
			# only change when value is different
			if (row.sort_values[frame_range_column] != rr_data.jobs[job].range_end - rr_data.jobs[job].range_start):
				
				# get reference to the cell
				var cell = JobsTable.get_cell( row_position, frame_range_column )
				
				# change the cell value
				var frames_total = rr_data.jobs[job].range_end - rr_data.jobs[job].range_start
				cell.get_child(0).text = String(frames_total) + "  (" + String(rr_data.jobs[job].range_start) + " - " + String(rr_data.jobs[job].range_end) + ")"
				
				# update sort_value
				JobsTable.set_cell_sort_value(row_position, frame_range_column,  frames_total)
			
			
			
			### Errors ###
			
			# only change when value is different
			if (row.sort_values[errors_column] != rr_data.jobs[job].errors):
				
				# get reference to the cell
				var cell = JobsTable.get_cell( row_position, errors_column )
				
				# change the cell value
				cell.get_child(0).text = String(rr_data.jobs[job].errors)
				
				# update sort_value
				JobsTable.set_cell_sort_value(row_position, errors_column,  rr_data.jobs[job].errors)
				
				if rr_data.jobs[job].errors > 0:
					if colorize_table_rows:
							JobsTable.set_row_color_by_string(row_position, "red")
			
			
			
			### Pools ###
			
			var pools_string = ""
			var pool_count = 1
				
			if rr_data.jobs[job].pools.size() > 0:
				for pool in rr_data.jobs[job].pools:
					pools_string += pool
					if pool_count < rr_data.jobs[job].pools.size():
						pools_string += ", "
					pool_count += 1
						
			# only change when value is different
			if (row.sort_values[pools_column] != pools_string.to_lower()):
				
				# get reference to the cell
				var cell = JobsTable.get_cell( row_position, pools_column )
				
				# change the cell value
				cell.get_child(0).text = pools_string
				
				# update sort_value
				JobsTable.set_cell_sort_value(row_position, pools_column,  pools_string.to_lower())
			
			
			
			### Note ###
			
			# only change when value is different
			if (row.sort_values[note_column] != rr_data.jobs[job].note.to_lower()):
				
				# get reference to the cell
				var cell = JobsTable.get_cell( row_position, note_column )
				
				# change the cell value
				cell.get_child(0).text = rr_data.jobs[job].note
				
				# update sort_value
				JobsTable.set_cell_sort_value(row_position, note_column,  rr_data.jobs[job].note.to_lower())
			
			
			
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
			icon.load("res://GUI/icons/job_status/job_status_58x30.png")
			StatusIcon.set_texture(icon)
			
			
			if rr_data.jobs[job].status == RRStateScheme.job_rendering:
				StatusIcon.set_modulate(RRColorScheme.state_active)
				if colorize_table_rows:
					JobsTable.set_row_color_by_string(count, "blue")
					
			elif rr_data.jobs[job].status == RRStateScheme.job_rendering_paused_deferred:
				StatusIcon.set_modulate(RRColorScheme.state_paused_deferred)
				
			elif rr_data.jobs[job].status == RRStateScheme.job_queued:
				StatusIcon.set_modulate(RRColorScheme.state_queued)
				if colorize_table_rows:
					JobsTable.set_row_color_by_string(count, "yellow")
					
			elif rr_data.jobs[job].status == RRStateScheme.job_error:
				StatusIcon.set_modulate(RRColorScheme.state_error)
				if colorize_table_rows:
					JobsTable.set_row_color_by_string(count, "red")
					
			elif rr_data.jobs[job].status == RRStateScheme.job_paused:
				StatusIcon.set_modulate(RRColorScheme.state_paused)
					
			elif rr_data.jobs[job].status == RRStateScheme.job_finished:
				StatusIcon.set_modulate(RRColorScheme.state_finished_or_online)
				if colorize_table_rows:
					JobsTable.set_row_color_by_string(count, "green")
					
			elif rr_data.jobs[job].status == RRStateScheme.job_cancelled:
				StatusIcon.set_modulate(RRColorScheme.state_offline_or_cancelled)
				if colorize_table_rows:
					JobsTable.set_row_color_by_string(count, "black")
					StatusIcon.set_modulate(Color(0.6, 0.6, 0.6, 1))
					
			
			JobsTable.set_cell_content(count, status_column, StatusIcon)
			
			# update sort_value
			JobsTable.set_cell_sort_value(count, status_column,  rr_data.jobs[job].status)
			
			
			
			### Name ###
			
			var LabelName = Label.new()
			LabelName.text = rr_data.jobs[job].name
			JobsTable.set_cell_content(count, name_column, LabelName)
			
			# update sort_value
			JobsTable.set_cell_sort_value(count, name_column,  rr_data.jobs[job].name.to_lower())
			
			
			
			### Priority ###
			
			var JobPriorityControl = JobPriorityControlRes.instance()
			JobPriorityControl.job_id = job
			JobsTable.set_cell_content(count, priority_column, JobPriorityControl)
			
			# update sort_value
			JobsTable.set_cell_sort_value(count, priority_column,  rr_data.jobs[job].priority)
			
			
			
			### Active Clients ###
			
			var LabelActiveClients = Label.new()
			
			var active_clients = 0
			
			for client in rr_data.clients.keys():
				if rr_data.clients[client].current_job_id == job:
					active_clients += 1
					
			LabelActiveClients.text = String(active_clients)
			JobsTable.set_cell_content(count, active_clients_column, LabelActiveClients)
			
			# update sort_value
			JobsTable.set_cell_sort_value(count, active_clients_column, active_clients)
			
			
			
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
			
			JobsTable.set_cell_content(count, progress_column, JobProgressBar)
			
			# update sort_value
			JobsTable.set_cell_sort_value(count, progress_column, percentage)
			
			
			
			### Type ###
			
			var LabelType = Label.new()
			LabelType.text = rr_data.jobs[job].type
			JobsTable.set_cell_content(count, type_column, LabelType)
			
			# update sort_value
			JobsTable.set_cell_sort_value(count, type_column,  rr_data.jobs[job].type.to_lower())
			
			
			
			### Creator ###
			
			var LabelCreator = Label.new()
			LabelCreator.text = rr_data.jobs[job].creator
			JobsTable.set_cell_content(count, creator_column, LabelCreator)
			
			# update sort_value
			JobsTable.set_cell_sort_value(count, creator_column,  rr_data.jobs[job].creator.to_lower())
			
			
			
			### Time Created ###
			
			var LabelTimeCreated = Label.new()
			LabelTimeCreated.text = TimeFunctions.time_stamp_to_date_as_string( rr_data.jobs[job].time_created, 2)
			JobsTable.set_cell_content(count, time_created_column, LabelTimeCreated)
			
			# update sort_value
			JobsTable.set_cell_sort_value(count, time_created_column,  rr_data.jobs[job].time_created)
			
			
			
			### Frame Range ###
			
			var LabelFrameRange = Label.new()
			var frames_total = rr_data.jobs[job].range_end - rr_data.jobs[job].range_start
			LabelFrameRange.text = String(frames_total) + "  (" + String(rr_data.jobs[job].range_start) + " - " + String(rr_data.jobs[job].range_end) + ")"
			JobsTable.set_cell_content(count, frame_range_column, LabelFrameRange)
			
			# update sort_value
			JobsTable.set_cell_sort_value(count, frame_range_column, frames_total)
			
			
			
			### Errors ###
			
			var LabelErrors = Label.new()
			LabelErrors.text = String(rr_data.jobs[job].errors)
			JobsTable.set_cell_content(count, errors_column, LabelErrors)
			
			# update sort_value
			JobsTable.set_cell_sort_value(count, errors_column,  rr_data.jobs[job].errors)
			
			if rr_data.jobs[job].errors > 0:
				if colorize_table_rows:
						JobsTable.set_row_color_by_string(count, "red")
			
			
			
			### Pools ###
			
			var LabelPools = Label.new()
			var pools_string = ""
			var pool_count = 1
			
			if rr_data.jobs[job].pools.size() > 0:
				for pool in rr_data.jobs[job].pools:
					pools_string += pool
					if pool_count < rr_data.jobs[job].pools.size():
						pools_string += ", "
					pool_count += 1
					
			LabelPools.text = pools_string
			JobsTable.set_cell_content(count, pools_column, LabelPools)
			
			# update sort_value
			JobsTable.set_cell_sort_value(count, pools_column,  pools_string.to_lower())
			
			
			
			### Note ###
			
			var LabelNote = Label.new()
			LabelNote.text = rr_data.jobs[job].note
			JobsTable.set_cell_content(count, note_column, LabelNote)
			
			# update sort_value
			JobsTable.set_cell_sort_value(count, note_column,  rr_data.jobs[job].note.to_lower())
		
		
		count += 1
	
	JobsTable.sort()
	

func refresh_chunks_table(job_id):
	
	
	# define the columns of the jobs table ####
	var number_column = 1
	var status_column = 2
	var frames_column = 3
	var client_column = 4
	var rendertime_column = 5
	var tries_column = 6
	var started_column = 7
	var finished_column = 8
	
	
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
		
		var count = 1
		
		for chunk in chunks_array:
	
			##############################################
			### update modified cells in row if row exists
			##############################################
			
			if ChunksTable.RowContainerFilled.id_position_dict.has(chunk):
				
				# get reference to the row
				var row_position = ChunksTable.RowContainerFilled.id_position_dict[chunk]
				var row = ChunksTable.get_row_by_position( row_position )
				
				# update all cells that have changed
	
	
	
	
				### Number ###
				
				# only change when value is different
				if (row.sort_values[number_column] != chunk):
				
					# get reference to the cell
					var cell = ChunksTable.get_cell( row_position, number_column )
					
					# change the cell value
					cell.get_child(0).text = chunk
					
					# update sort_value
					ChunksTable.set_cell_sort_value(row_position, number_column, chunk)
	
	
	
	
	
				### Status Icon ###
				
				# only change when value is different
				if (row.sort_values[status_column] != rr_data.jobs[job_id].chunks[chunk].status):
					
					# get reference to the cell
					var cell = ChunksTable.get_cell( row_position, status_column )
					
					var StatusIcon = cell.get_child(0)
					
					if rr_data.jobs[job_id].chunks[chunk].status == RRStateScheme.chunk_rendering:
						StatusIcon.set_modulate(RRColorScheme.state_active)
						if colorize_table_rows:
							ChunksTable.set_row_color_by_string(row_position, "blue")
							
					elif rr_data.jobs[job_id].chunks[chunk].status == RRStateScheme.chunk_queued:
						StatusIcon.set_modulate(RRColorScheme.state_queued)
						if colorize_table_rows:
							ChunksTable.set_row_color_by_string(row_position, "yellow")
							
					elif rr_data.jobs[job_id].chunks[chunk].status == RRStateScheme.chunk_error:
						StatusIcon.set_modulate(RRColorScheme.state_error)
						if colorize_table_rows:
							ChunksTable.set_row_color_by_string(row_position, "red")
							
					elif rr_data.jobs[job_id].chunks[chunk].status == RRStateScheme.chunk_paused:
						StatusIcon.set_modulate(RRColorScheme.state_paused)
							
					elif rr_data.jobs[job_id].chunks[chunk].status == RRStateScheme.chunk_finished:
						StatusIcon.set_modulate(RRColorScheme.state_finished_or_online)
						if colorize_table_rows:
							ChunksTable.set_row_color_by_string(row_position, "green")
							
					elif rr_data.jobs[job_id].chunks[chunk].status == RRStateScheme.chunk_cancelled:
						StatusIcon.set_modulate(RRColorScheme.state_offline_or_cancelled)
						if colorize_table_rows:
							ChunksTable.set_row_color_by_string(row_position, "black")
							cell.get_child(0).set_modulate(Color(0.6, 0.6, 0.6, 1))
							
					
					
					# update sort_value
					ChunksTable.set_cell_sort_value(row_position, status_column,  rr_data.jobs[job_id].chunks[chunk].status)
				
	
	
	
	
				### Frames ###
				
				# only change when value is different
				if (row.sort_values[frames_column] != rr_data.jobs[job_id].chunks[chunk].frame_start ):
				
					# get reference to the cell
					var cell = ChunksTable.get_cell( row_position, frames_column )
					
					var first_chunk_frame = rr_data.jobs[job_id].chunks[chunk].frame_start
					var last_chunk_frame = rr_data.jobs[job_id].chunks[chunk].frame_end
					
					# change the cell value
					if first_chunk_frame == last_chunk_frame:
						cell.get_child(0).text = String(first_chunk_frame)
					else:
						cell.get_child(0).text = String(first_chunk_frame) + " - " + String(last_chunk_frame)
					
					# update sort_value
					ChunksTable.set_cell_sort_value(row_position, frames_column, first_chunk_frame)
	
	
	
	
	
				### Client ###
				
				if rr_data.jobs[job_id].chunks[chunk].client == -1:
					
					# only change when value is different
					if (row.sort_values[client_column] != "-" ):
					
						# get reference to the cell
						var cell = ChunksTable.get_cell( row_position, client_column )
						
						# change the cell value
						cell.get_child(0).text = "-"
						
						# update sort_value
						ChunksTable.set_cell_sort_value(row_position, client_column, "-")
				
				
				else:
					
					# only change when value is different
					if (row.sort_values[client_column] != rr_data.clients[ rr_data.jobs[job_id].chunks[chunk].client ].name ):
					
						# get reference to the cell
						var cell = ChunksTable.get_cell( row_position, client_column )
						
						# change the cell value
						cell.get_child(0).text = rr_data.clients[ rr_data.jobs[job_id].chunks[chunk].client ].name
						
						# update sort_value
						ChunksTable.set_cell_sort_value(row_position, client_column, rr_data.clients[ rr_data.jobs[job_id].chunks[chunk].client ].name)
		
	
	
	
				### Rendertime ###
				
				var chunk_rendertime = 0
				
				if rr_data.jobs[job_id].chunks[chunk].status == RRStateScheme.chunk_finished: 
					chunk_rendertime = rr_data.jobs[job_id].chunks[chunk].time_finished - rr_data.jobs[job_id].chunks[chunk].time_started
					
				elif rr_data.jobs[job_id].chunks[chunk].status == RRStateScheme.chunk_rendering: 
					chunk_rendertime = OS.get_unix_time() - rr_data.jobs[job_id].chunks[chunk].time_started
				
				# only change when value is different
				if (row.sort_values[rendertime_column] != chunk_rendertime ):
				
					# get reference to the cell
					var cell = ChunksTable.get_cell( row_position, rendertime_column )
					
					# change the cell value
					if chunk_rendertime != 0:
						cell.get_child(0).text = TimeFunctions.seconds_to_string(chunk_rendertime,3)
					else:
						cell.get_child(0).text = "-"
						
					# update sort_value
					ChunksTable.set_cell_sort_value(row_position, rendertime_column, chunk_rendertime)
	
	
	
	
	
				### Number of tries ###
				
				# only change when value is different
				if (row.sort_values[tries_column] != rr_data.jobs[job_id].chunks[chunk].number_of_tries):
					
					# get reference to the cell
					var cell = ChunksTable.get_cell( row_position, tries_column )
					
					# change the cell value
					cell.get_child(0).text = String(rr_data.jobs[job_id].chunks[chunk].number_of_tries)
					
					# update sort_value
					ChunksTable.set_cell_sort_value(row_position, tries_column,  rr_data.jobs[job_id].chunks[chunk].number_of_tries)
	
	
	
	
				### Time Started ###
			
				# only change when value is different
				if (row.sort_values[finished_column] != rr_data.jobs[job_id].chunks[chunk].time_started):
				
					# get reference to the cell
					var cell = ChunksTable.get_cell( row_position, started_column )
					
					# change the cell value
					var time_started = rr_data.jobs[job_id].chunks[chunk].time_started
					
					if time_started != 0:
						cell.get_child(0).text = TimeFunctions.time_stamp_to_date_as_string(time_started, 1)
					else:
						cell.get_child(0).text = "-"
						
					# update sort_value
					ChunksTable.set_cell_sort_value(row_position, started_column,  time_started)
	
	
	
	
				### Time Finished ###
				
				# only change when value is different
				if (row.sort_values[finished_column] != rr_data.jobs[job_id].chunks[chunk].time_finished):
				
					# get reference to the cell
					var cell = ChunksTable.get_cell( row_position, finished_column )
					
					# change the cell value
					var time_finished = rr_data.jobs[job_id].chunks[chunk].time_finished
					
					if time_finished != 0:
						cell.get_child(0).text = TimeFunctions.time_stamp_to_date_as_string(time_finished, 1)
					else:
						cell.get_child(0).text = "-"
						
					# update sort_value
					ChunksTable.set_cell_sort_value(row_position, finished_column, time_finished)
	
	
	
				
			##########################################################
			### create the row if row with given id does not exist yet
			##########################################################
			
			else:
				
				ChunksTable.create_row(chunk)
	
	
	
				### Number ###
				
				var LabelNumber = Label.new()
				LabelNumber.text = String(chunk)
				ChunksTable.set_cell_content(count, number_column, LabelNumber)
				
				# update sort_value
				ChunksTable.set_cell_sort_value(count, number_column,  chunk)
	
	
				
				### Status Icon ###
				
				var StatusIcon = TextureRect.new()
				StatusIcon.set_expand(true)
				StatusIcon.set_stretch_mode(6) # 6 - keep aspect centered
				StatusIcon.set_v_size_flags(3) # fill + expand
				StatusIcon.set_h_size_flags(3) # fill + expand
				StatusIcon.rect_min_size.x = 54
				
				var icon = ImageTexture.new()
				icon.load("res://GUI/icons/chunk_status/chunk_status_58x30.png")
				StatusIcon.set_texture(icon)
				
				if rr_data.jobs[job_id].chunks[chunk].status == RRStateScheme.chunk_rendering:
					StatusIcon.set_modulate(RRColorScheme.state_active)
					if colorize_table_rows:
						ChunksTable.set_row_color_by_string(count, "blue")
						
				elif rr_data.jobs[job_id].chunks[chunk].status == RRStateScheme.chunk_queued:
					StatusIcon.set_modulate(RRColorScheme.state_queued)
					if colorize_table_rows:
						ChunksTable.set_row_color_by_string(count, "yellow")
						
				elif rr_data.jobs[job_id].chunks[chunk].status == RRStateScheme.chunk_error:
					StatusIcon.set_modulate(RRColorScheme.state_error)
					if colorize_table_rows:
						ChunksTable.set_row_color_by_string(count, "red")
						
				elif rr_data.jobs[job_id].chunks[chunk].status == RRStateScheme.chunk_paused:
					StatusIcon.set_modulate(RRColorScheme.state_paused)
						
				elif rr_data.jobs[job_id].chunks[chunk].status == RRStateScheme.chunk_finished:
					StatusIcon.set_modulate(RRColorScheme.state_finished_or_online)
					if colorize_table_rows:
						ChunksTable.set_row_color_by_string(count, "green")
						
				elif rr_data.jobs[job_id].chunks[chunk].status == RRStateScheme.chunk_cancelled:
					StatusIcon.set_modulate(RRColorScheme.state_offline_or_cancelled)
					if colorize_table_rows:
						ChunksTable.set_row_color_by_string(count, "black")
						StatusIcon.set_modulate(Color(0.6, 0.6, 0.6, 1))
						
				
				ChunksTable.set_cell_content(count, status_column, StatusIcon)
				
				# update sort_value
				ChunksTable.set_cell_sort_value(count, status_column,  rr_data.jobs[job_id].chunks[chunk].status)
				
				
	
	
	
	
				### Frames ###
				
				var LabelFrames = Label.new()
				var first_chunk_frame = rr_data.jobs[job_id].chunks[chunk].frame_start
				var last_chunk_frame = rr_data.jobs[job_id].chunks[chunk].frame_end
				
				if first_chunk_frame == last_chunk_frame:
					LabelFrames.text = String(first_chunk_frame)
				else:
					LabelFrames.text = String(first_chunk_frame) + " - " + String(last_chunk_frame)
				
				ChunksTable.set_cell_content(count, frames_column, LabelFrames)
				
				# update sort_value
				ChunksTable.set_cell_sort_value(count, frames_column,  first_chunk_frame)
	
	
	
	
	
				### Client ###
	
				var LabelClient = Label.new()
				
				if rr_data.jobs[job_id].chunks[chunk].client == -1:
					LabelClient.text = "-"
					ChunksTable.set_cell_content(count, client_column, LabelClient)
					
					# update sort_value
					ChunksTable.set_cell_sort_value(count, client_column,  "-")
				else:
					LabelClient.text = rr_data.clients[ rr_data.jobs[job_id].chunks[chunk].client ].name
					ChunksTable.set_cell_content(count, client_column, LabelClient)
				
					# update sort_value
					ChunksTable.set_cell_sort_value(count, client_column,  rr_data.clients[ rr_data.jobs[job_id].chunks[chunk].client ].name)
	
	
	
				### Rendertime ###
				
				var LabelRendertime = Label.new()
				var chunk_rendertime = 0
				
				if rr_data.jobs[job_id].chunks[chunk].status == RRStateScheme.chunk_finished: 
					chunk_rendertime = rr_data.jobs[job_id].chunks[chunk].time_finished - rr_data.jobs[job_id].chunks[chunk].time_started
					LabelRendertime.text = TimeFunctions.seconds_to_string(chunk_rendertime, 3)
					
				elif rr_data.jobs[job_id].chunks[chunk].status == RRStateScheme.chunk_rendering: 
					chunk_rendertime = OS.get_unix_time() - rr_data.jobs[job_id].chunks[chunk].time_started
					LabelRendertime.text = TimeFunctions.seconds_to_string(chunk_rendertime, 3)
				else:
					LabelRendertime.text = "-"
					
				ChunksTable.set_cell_content(count, rendertime_column, LabelRendertime)
				
				# update sort_value
				ChunksTable.set_cell_sort_value(count, rendertime_column,  chunk_rendertime)
	
	
	
	
	
				### Number of tries ###
				
				var LabelNumberOfTries = Label.new()
				LabelNumberOfTries.text = String(rr_data.jobs[job_id].chunks[chunk].number_of_tries)
				ChunksTable.set_cell_content(count, tries_column, LabelNumberOfTries)
				
				# update sort_value
				ChunksTable.set_cell_sort_value(count, tries_column,  rr_data.jobs[job_id].chunks[chunk].number_of_tries)
	
	
	
	
				### Time Started ###
				
				var LabelTimeStarted = Label.new()
				
				var time_started = rr_data.jobs[job_id].chunks[chunk].time_started
				
				if time_started != 0:
					LabelTimeStarted.text = TimeFunctions.time_stamp_to_date_as_string(time_started, 1 )
				else:
					LabelTimeStarted.text = "-"
				ChunksTable.set_cell_content(count, started_column, LabelTimeStarted)
				
				# update sort_value
				ChunksTable.set_cell_sort_value(count, started_column, time_started)
	
	
	
	
				### Time Finished ###
				
				var LabelTimeFinished = Label.new()
				
				var time_finished = rr_data.jobs[job_id].chunks[chunk].time_finished
				
				if time_finished != 0:
					LabelTimeFinished.text = TimeFunctions.time_stamp_to_date_as_string(time_finished, 1 )
				else:
					LabelTimeFinished.text = "-"
				ChunksTable.set_cell_content(count, finished_column, LabelTimeFinished)
				
				# update sort_value
				ChunksTable.set_cell_sort_value(count, finished_column, time_finished)
			
			
			
			count += 1
		
		ChunksTable.sort()


func refresh_clients_table():
	
	
	# define the columns of the clients table ####
	var status_column = 1
	var name_column = 2
	var username_column = 3
	var platform_column = 4
	var cpu_column = 5
	var memory_column = 6
	var current_job_column = 7
	var error_count_column = 8
	var pools_column = 9
	var note_column = 10
	var rr_version_column = 11
	
	# get all clients
	var clients_array = rr_data.clients.keys()
	
	# display number of clients in the Tabname
	ClientsTable.get_parent().name = "Clients (" + String ( clients_array.size() ) + ")"
	
	
	#### Fill Clients Table ####
	
	var count = 1
	
	for client in clients_array:

		##############################################
		### update modified cells in row if row exists
		##############################################
		
		if ClientsTable.RowContainerFilled.id_position_dict.has(client):
			
			# get reference to the row
			var row_position = ClientsTable.RowContainerFilled.id_position_dict[client]
			var row = ClientsTable.get_row_by_position( row_position )
			
			
			# update all cells that have changed
			
			
			### Status Icon ###
			
			# only change when value is different
			if (row.sort_values[status_column] != rr_data.clients[client].status):
				
				# get reference to the cell
				var cell = ClientsTable.get_cell( row_position, status_column )
				
				var StatusIcon = cell.get_child(0)
				
				if rr_data.clients[client].status == RRStateScheme.client_rendering:
					StatusIcon.set_modulate(RRColorScheme.state_active)
					if colorize_table_rows:
						ClientsTable.set_row_color_by_string(row_position, "blue")
					
				elif rr_data.clients[client].status == RRStateScheme.client_available:
					StatusIcon.set_modulate(RRColorScheme.state_finished_or_online)
					if colorize_table_rows:
						ClientsTable.set_row_color_by_string(row_position, "green")
					
				elif rr_data.clients[client].status == RRStateScheme.client_error:
					StatusIcon.set_modulate(RRColorScheme.state_error)
		
				elif rr_data.clients[client].status == RRStateScheme.client_disabled:
					StatusIcon.set_modulate(RRColorScheme.state_paused)
		
				elif rr_data.clients[client].status == RRStateScheme.client_offline:
					StatusIcon.set_modulate(RRColorScheme.state_offline_or_cancelled)
					if colorize_table_rows:
						ClientsTable.set_row_color_by_string(row_position, "black")
						cell.get_child(0).set_modulate(Color(0.6, 0.6, 0.6, 1))
				
				
				# update sort_value
				ClientsTable.set_cell_sort_value(row_position, status_column,  rr_data.clients[client].status)
			
			
			
			### Name ###
			
			# only change when value is different
			if (row.sort_values[name_column] != rr_data.clients[client].name.to_lower()):
				
				# get reference to the cell
				var cell = ClientsTable.get_cell( row_position, name_column )
				
				# change the cell value
				cell.get_child(0).text = rr_data.clients[client].name
				
				# update sort_value
				ClientsTable.set_cell_sort_value(row_position, name_column,  rr_data.clients[client].name.to_lower())
			
			
			
			### Username ###
			
			# only change when value is different
			if (row.sort_values[username_column] != rr_data.clients[client].username.to_lower()):
				
				# get reference to the cell
				var cell = ClientsTable.get_cell( row_position, username_column )
				
				# change the cell value
				cell.get_child(0).text = rr_data.clients[client].username
				
				# update sort_value
				ClientsTable.set_cell_sort_value(row_position, username_column,  rr_data.clients[client].username.to_lower())
			
			
			
			### Platform ###
			
			# only change when value is different
			if (row.sort_values[platform_column] != rr_data.clients[client].platform[0]):
				
				# get reference to the cell
				var cell = ClientsTable.get_cell( row_position, platform_column )
				
				# change the cell value
				cell.get_child(0).text = rr_data.clients[client].platform[0]
				
				# update sort_value
				ClientsTable.set_cell_sort_value(row_position, platform_column,  rr_data.clients[client].platform[0])
			
			
			
			### CPU ###
			
			# only change when value is different
			if (row.sort_values[cpu_column] != rr_data.clients[client].cpu[1] * rr_data.clients[client].cpu[2] * rr_data.clients[client].cpu[3]):
				
				# get reference to the cell
				var cell = ClientsTable.get_cell( row_position, cpu_column )
				
				# change the cell value
				var ghz = rr_data.clients[client].cpu[1] * rr_data.clients[client].cpu[2] * rr_data.clients[client].cpu[3]
				cell.get_child(0).text =  String( ghz ) + " GHZ"
				
				# update sort_value
				ClientsTable.set_cell_sort_value(row_position, cpu_column,  ghz)
			
			
			
			### RAM ###
			
			# only change when value is different
			if (row.sort_values[memory_column] != rr_data.clients[client].memory):
				
				# get reference to the cell
				var cell = ClientsTable.get_cell( row_position, memory_column )
				
				# change the cell value
				cell.get_child(0).text = String( round(float(rr_data.clients[client].memory) / 1024 / 1024 ))+ " GB"
				
				# update sort_value
				ClientsTable.set_cell_sort_value(row_position, memory_column,  rr_data.clients[client].memory)
			
			
			
			### Current Job ###
			
			# only change when value is different
			if (row.sort_values[current_job_column] != rr_data.clients[client].current_job_id):
				
				# get reference to the cell
				var cell = ClientsTable.get_cell( row_position, current_job_column )
				
				# change the cell value
				var job_id = rr_data.clients[client].current_job_id
				cell.get_child(0).job_id = job_id
				
				if job_id == "":
					cell.get_child(0).CurrentJobLabel.text = ""
				else:
					cell.get_child(0).CurrentJobLabel.text = rr_data.jobs[job_id].name
				cell.get_child(0).set_correct_visibility_of_link_button()
				
				# update sort_value
				ClientsTable.set_cell_sort_value(row_position, current_job_column,  rr_data.clients[client].current_job_id)
			
			
			
			### Errors ###
			
			# only change when value is different
			if (row.sort_values[error_count_column] != rr_data.clients[client].error_count):
				
				# get reference to the cell
				var cell = ClientsTable.get_cell( row_position, error_count_column )
				
				# change the cell value
				var clients_error_count = rr_data.clients[client].error_count
				cell.get_child(0).text = String ( clients_error_count )
				
				# update sort_value
				ClientsTable.set_cell_sort_value( row_position, error_count_column,  clients_error_count )
				
				if clients_error_count > 0:
					if colorize_table_rows:
						ClientsTable.set_row_color_by_string(row_position, "red")
			
			
			
			### Pools ###
			
			var pools_string = ""
			var pool_count = 1
			
			if rr_data.clients[client].pools.size() > 0:
				for pool in rr_data.clients[client].pools:
					pools_string += pool
					if pool_count < rr_data.clients[client].pools.size():
						pools_string += ", "
					pool_count += 1
					
			# only change when value is different
			if (row.sort_values[pools_column] != pools_string):
				
				# get reference to the cell
				var cell = ClientsTable.get_cell( row_position, pools_column )
				
				# change the cell value
				cell.get_child(0).text = pools_string
				
				# update sort_value
				ClientsTable.set_cell_sort_value(row_position, pools_column, pools_string)
			
			
			
			### Note ###
			
			# only change when value is different
			if (row.sort_values[note_column] != rr_data.clients[client].note):
				
				# get reference to the cell
				var cell = ClientsTable.get_cell( row_position, note_column )
				
				# change the cell value
				cell.get_child(0).text = String(rr_data.clients[client].note) 
				
				# update sort_value
				ClientsTable.set_cell_sort_value(row_position, note_column,  rr_data.clients[client].note)
			
			
			
			### Raptor Render Version ###
			
			
			# only change when value is different
			if (row.sort_values[rr_version_column] != rr_data.clients[client].rr_version):
				
				# get reference to the cell
				var cell = ClientsTable.get_cell( row_position, rr_version_column )
				
				# change the cell value
				cell.get_child(0).text = String(rr_data.clients[client].rr_version) 
				
				# update sort_value
				ClientsTable.set_cell_sort_value(count, rr_version_column,  rr_data.clients[client].rr_version)
		
		
		
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
			icon.load("res://GUI/icons/client_status/client_status_58x30.png")
			StatusIcon.set_texture(icon)
			
			if rr_data.clients[client].status == RRStateScheme.client_rendering:
				StatusIcon.set_modulate(RRColorScheme.state_active)
				if colorize_table_rows:
					ClientsTable.set_row_color_by_string(count, "blue")
				
			elif rr_data.clients[client].status == RRStateScheme.client_available:
				StatusIcon.set_modulate(RRColorScheme.state_finished_or_online)
				if colorize_table_rows:
					ClientsTable.set_row_color_by_string(count, "green")
				
			elif rr_data.clients[client].status == RRStateScheme.client_error:
				StatusIcon.set_modulate(RRColorScheme.state_error)
	
			elif rr_data.clients[client].status == RRStateScheme.client_disabled:
				StatusIcon.set_modulate(RRColorScheme.state_paused)
	
			elif rr_data.clients[client].status == RRStateScheme.client_offline:
				StatusIcon.set_modulate(RRColorScheme.state_offline_or_cancelled)
				if colorize_table_rows:
					ClientsTable.set_row_color_by_string(count, "black")
					StatusIcon.set_modulate(Color(0.6, 0.6, 0.6, 1))
				
			StatusIcon.set_texture(icon)
			ClientsTable.set_cell_content(count, status_column, StatusIcon)
			
			# update sort_value
			ClientsTable.set_cell_sort_value(count, status_column,  rr_data.clients[client].status)
			
			
			
			### Name ###
	
			var LabelName = Label.new()
			LabelName.text = rr_data.clients[client].name
			ClientsTable.set_cell_content(count, name_column, LabelName)
			
			# update sort_value
			ClientsTable.set_cell_sort_value(count, name_column,  rr_data.clients[client].name.to_lower())
			
			
			
			### Username ###
			
			var LabelUserName = Label.new()
			LabelUserName.text = rr_data.clients[client].username
			ClientsTable.set_cell_content(count, username_column, LabelUserName)
			
			# update sort_value
			ClientsTable.set_cell_sort_value(count, username_column,  rr_data.clients[client].username.to_lower())
			
			
			
			### Platform ###
			
			var LabelPlatform = Label.new()
			LabelPlatform.text = rr_data.clients[client].platform[0]
			ClientsTable.set_cell_content(count, platform_column, LabelPlatform)
			
			# update sort_value
			ClientsTable.set_cell_sort_value(count, platform_column,  rr_data.clients[client].platform[0])
			
			
			
			### CPU ###
			
			var LabelCPU = Label.new()
			var ghz = rr_data.clients[client].cpu[1] * rr_data.clients[client].cpu[2] * rr_data.clients[client].cpu[3]
			LabelCPU.text =  String( ghz ) + " GHZ"
			ClientsTable.set_cell_content(count, cpu_column, LabelCPU)
			
			# update sort_value
			ClientsTable.set_cell_sort_value(count, cpu_column,  ghz)
			
			
			
			### RAM ###
			
			var LabelMemory = Label.new()
			LabelMemory.text = String( round(float(rr_data.clients[client].memory) / 1024 / 1024 ))+ " GB"
			ClientsTable.set_cell_content(count, memory_column, LabelMemory)
			
			# update sort_value
			ClientsTable.set_cell_sort_value(count, memory_column,  rr_data.clients[client].memory)
			
			
			
			### Current Job ###
			
			var CurrentJobLink = CurrentJobLinkRes.instance()
			
			CurrentJobLink.job_id = rr_data.clients[client].current_job_id
			
			ClientsTable.set_cell_content(count, current_job_column, CurrentJobLink)
			
			# update sort_value
			ClientsTable.set_cell_sort_value(count, current_job_column,  rr_data.clients[client].current_job_id)
			
			
			
			### Errors ###
			
			var LabelErrorCount = Label.new()
			var clients_error_count = rr_data.clients[client].error_count
			LabelErrorCount.text = String(clients_error_count)
			ClientsTable.set_cell_content(count, error_count_column, LabelErrorCount)
			
			# update sort_value
			ClientsTable.set_cell_sort_value(count, error_count_column,  rr_data.clients[client].error_count)
			
			if clients_error_count > 0:
				if colorize_table_rows:
					ClientsTable.set_row_color_by_string(count, "red")
			
			
			
			### Pools ###
			
			var LabelPools = Label.new()
			var pools_string = ""
			var pool_count = 1
			
			if rr_data.clients[client].pools.size() > 0:
				for pool in rr_data.clients[client].pools:
					pools_string += pool
					if pool_count < rr_data.clients[client].pools.size():
						pools_string += ", "
					pool_count += 1
					
			LabelPools.text = pools_string
			ClientsTable.set_cell_content(count, pools_column, LabelPools)
			
			# update sort_value
			ClientsTable.set_cell_sort_value(count, pools_column, pools_string)
			
			
			
			### Note ###
			
			var LabelNote = Label.new()
			LabelNote.text = String(rr_data.clients[client].note) 
			ClientsTable.set_cell_content(count, note_column, LabelNote)
			
			# update sort_value
			ClientsTable.set_cell_sort_value(count, note_column,  rr_data.clients[client].note)
			
			
			
			### Raptor Render Version ###
			
			var LabelVersion = Label.new()
			LabelVersion.text = String(rr_data.clients[client].rr_version) 
			ClientsTable.set_cell_content(count, rr_version_column, LabelVersion)
			
			# update sort_value
			ClientsTable.set_cell_sort_value(count, rr_version_column,  rr_data.clients[client].rr_version)
		
		
		count += 1
	
	ClientsTable.sort()




