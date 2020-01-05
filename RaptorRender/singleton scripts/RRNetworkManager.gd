extends Node



const RR_PORT = 44444
const server_ip = "192.168.0.220"
#const server_ip = "127.0.0.1"

const MAX_CLIENTS = 4095 # 4095 is max. If we use 4096 there will be an error and the server can't start

# A machine that is just rendering does not need to know most things going on on the renderfarm. So we can reduce network traffic in just not telling it those information in the first place.
# This variable holds the network id's of all clients that currently have the gui open and thus need the latest information about job statues etc. We sync this array over the whole network.
# Network Id "1" is always the server. We want to be sure that the server receives ALL updates, so we add 1 by default.
puppetsync var management_gui_clients : Array  = [1]

# This will hold the corresponding client_id to each connected peer (network id)
puppetsync var peer_id_client_id_dict : Dictionary

var server_is_also_client : bool = true


#func _process(delta : float) -> void:
#	print (management_gui_clients)


func _ready() -> void:
	
	# signals that every client/server on the network will emit
	get_tree().connect("network_peer_connected", self, "_client_connected")
	get_tree().connect("network_peer_disconnected", self,"_client_disconnected")
	
	# signals that only the connecting client will emit
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")



###### connecting #######

func create_server() -> void:
	
	if get_tree().has_network_peer():
		get_tree().set_network_peer(null) # Remove peer
	
	var host = NetworkedMultiplayerENet.new()
	host.create_server(RR_PORT, MAX_CLIENTS)
	host.set_always_ordered(true)
	get_tree().set_network_peer(host)
	
	# add the server to the clients table and to the id dict, too, if desired
	if server_is_also_client:
		for peer in management_gui_clients:
			rpc_id(peer, "add_client", GetSystemInformation.own_client_id, GetSystemInformation.get_machine_properties())
		
		add_entry_to_id_dict(get_tree().get_network_unique_id(), GetSystemInformation.own_client_id)



func connect_to_server() -> void:
	
	# reset the management_gui_clients and make sure that everything get's at least sended to the server
	management_gui_clients = [1]
	
	if get_tree().has_network_peer():
		get_tree().set_network_peer(null) # Remove peer
		
	var client = NetworkedMultiplayerENet.new()
	client.create_client(server_ip, RR_PORT)
	client.set_always_ordered(true)
	get_tree().set_network_peer(client)
	
	


######## connecting callbacks ##########


# Callback from SceneTree, called when client connects
func _client_connected(id) -> void:
	print("New Client connected (", id, ")")
	
	if get_tree().is_network_server():
		rpc_id(id, "set_rr_data", RaptorRender.rr_data)



# Callback from SceneTree, called when client disconnects. Every connected client/server will receive this signal
func _client_disconnected(id) -> void:
	print("Client disconnected (", id, ")")
	
	
	if get_tree().is_network_server():
		
		# remove the peer id from the "managemen_gui_clients"
		if id != 1:
			management_gui_clients.erase(id)
			rset("management_gui_clients", management_gui_clients)
		
		# set status of corresponding client to offline
		var client_id : int = peer_id_client_id_dict[id]
		for peer in management_gui_clients:
			rpc_id(peer, "update_client_status", client_id, RRStateScheme.client_offline)
		
		# remove the peer id from the ids dict
		peer_id_client_id_dict.erase(id)





# Callback from SceneTree, called when successfully connected to server
func _connected_ok() -> void:
	print ("successfully connected to server!")
	
	# login management gui
	rpc_id(1, "login_management_gui", get_tree().get_network_unique_id())
	
	# add client to the clients dict
	for peer in management_gui_clients:
		rpc_id(peer, "add_client", GetSystemInformation.own_client_id, GetSystemInformation.get_machine_properties())
	
	# add the id to the dict on the server
	rpc_id(1, "add_entry_to_id_dict", get_tree().get_network_unique_id(), GetSystemInformation.own_client_id)



# Callback from SceneTree, called when server disconnect
func _server_disconnected() -> void:
	print("server disconnected")
	#emit_signal("server_disconnected")
	# Try to connect again
	#connect_to_server()



# Callback from SceneTree, called when unabled to connect to server
# For some reason this never gets called. Seems to be a bug
func _connected_fail() -> void:
	print("connecting to server failed...")
	#get_tree().set_network_peer(null) # Remove peer
	#emit_signal("connection_failed")
	# Try to connect again
	connect_to_server()



# add entry to the peer_id_client_id dictionary
master func add_entry_to_id_dict(peer_id : int, client_id : int) -> void:
	peer_id_client_id_dict[peer_id] = client_id
	rset("peer_id_client_id_dict", peer_id_client_id_dict)


# this will add the given network id to the "management_gui_clients" array on the master. Then the master syncs this variable to all puppets
master func login_management_gui(network_id : int) -> void:
	if not management_gui_clients.has(network_id):
		management_gui_clients.append(network_id)
		rset("management_gui_clients", management_gui_clients)



# this will remove the given network from the "management_gui_clients" array on the master. Then the master syncs this variable to all puppets
master func logout_management_gui(network_id : int) -> void:
	if management_gui_clients.has(network_id):
		management_gui_clients.erase(network_id)
		rset("management_gui_clients", management_gui_clients)




######## Remote Procedures ########

puppet func set_rr_data(data : Dictionary) -> void:
	RaptorRender.rr_data = data


remotesync func add_job(job_id : int, job : Dictionary) -> void:
	RaptorRender.rr_data.jobs[job_id] = job
	
	# add job to assigned pools
	for pool in job.pools:
		if RaptorRender.rr_data.pools.has(pool):
			RaptorRender.rr_data.pools[pool].jobs.append(job_id)



remotesync func remove_jobs(job_ids : Array) -> void:
	
	# save the current JobsTable selection
	var current_selections : Array = RaptorRender.JobsTable.get_selected_ids().duplicate()
	
	for job in job_ids:
		
		# cancel render process if this is the job where the machine is currently working on
		if CommandLineManager.currently_rendering and JobExecutionManager.current_processing_job == job:
			CommandLineManager.kill_current_render_process()
			
			#TODO
			# make client available again
			#RaptorRender.rr_data.clients[client].current_job_id = -1
			#RaptorRender.rr_data.clients[client].status = RRStateScheme.client_available
		
		# hide the JobInfoPanel, if the currently displayed job gets deleted
		if job == RaptorRender.current_job_id_for_job_info_panel:
			RaptorRender.JobInfoPanel.current_displayed_job_id = -1
			RaptorRender.JobInfoPanel.reset_to_first_tab()
			RaptorRender.JobInfoPanel.visible = false
		
		# remove the job from rr_data
		RaptorRender.rr_data.jobs.erase(job)
		for pool in RaptorRender.rr_data.pools:
			RaptorRender.rr_data.pools[pool].jobs.erase(job)
		
		# filter and restore the selection
		current_selections.erase(job)
	
	# clear the table
	RaptorRender.JobsTable.clear_table()
	
	# refresh the table
	RaptorRender.JobsTable.refresh()
	
	# restore the selection
	RaptorRender.JobsTable.set_selected_ids(current_selections)



remotesync func update_job_priority(job_id : int, priority : int) -> void:
	if RaptorRender.rr_data.jobs.has(job_id):
		RaptorRender.rr_data.jobs[job_id].priority = priority



remotesync func update_job_states(job_ids : Array, desired_status : String) -> void:
	for job in job_ids:
		update_job_status(job, desired_status)



remotesync func update_job_status(job_id : int, desired_status : String) -> void:
	
	if RaptorRender.rr_data.jobs.has(job_id):
		
		var current_status : String = RaptorRender.rr_data.jobs[job_id].status
		
		match desired_status:
			
			# desired state "rendering"
			RRStateScheme.job_rendering:
				if current_status != RRStateScheme.job_cancelled and current_status != RRStateScheme.job_finished:
					RaptorRender.rr_data.jobs[job_id].status = desired_status
			
			
			# desired state "rendering_paused_deferred"
			RRStateScheme.job_rendering_paused_deferred:
				
				if current_status == RRStateScheme.job_rendering: 
					
					RaptorRender.rr_data.jobs[job_id].status = desired_status
					
					# pause queued chunks
					for chunk in RaptorRender.rr_data.jobs[job_id].chunks.keys():
						var chunk_status : String = RaptorRender.rr_data.jobs[job_id].chunks[chunk].status
						if chunk_status == RRStateScheme.chunk_queued:
							RaptorRender.rr_data.jobs[job_id].chunks[chunk].status = RRStateScheme.chunk_paused
					
				if current_status == RRStateScheme.job_queued or current_status == RRStateScheme.job_error:
					RaptorRender.rr_data.jobs[job_id].status = RRStateScheme.job_paused
			
			
			# desired state "queued"
			RRStateScheme.job_queued:
				
				if current_status == RRStateScheme.job_paused:
					
					RaptorRender.rr_data.jobs[job_id].status = desired_status
					
					# queue all paused chunks
					for chunk in RaptorRender.rr_data.jobs[job_id].chunks.keys():
						if RaptorRender.rr_data.jobs[job_id].chunks[chunk].status == RRStateScheme.chunk_paused:
							RaptorRender.rr_data.jobs[job_id].chunks[chunk].status = RRStateScheme.chunk_queued
				
				if current_status == RRStateScheme.job_rendering_paused_deferred:
					RaptorRender.rr_data.jobs[job_id].status = RRStateScheme.job_rendering
			
			# desired state "error"
			RRStateScheme.job_error:  
				RaptorRender.rr_data.jobs[job_id].status = desired_status
			
			
			# desired state "paused"
			RRStateScheme.job_paused:  
				
				if current_status == RRStateScheme.job_rendering or current_status == RRStateScheme.job_rendering_paused_deferred or current_status == RRStateScheme.job_queued or current_status == RRStateScheme.job_error:
					
					# cancel render if needed
					if JobExecutionManager.current_processing_job == job_id and CommandLineManager.currently_rendering:
						CommandLineManager.kill_current_render_process()
					
					# remove current job from clients (the hint in the table)
					for client in RaptorRender.rr_data.clients.keys():
						if RaptorRender.rr_data.clients[client].current_job_id == job_id:
							RaptorRender.rr_data.clients[client].current_job_id = -1
					
					# cancle active chunks
					for chunk in RaptorRender.rr_data.jobs[job_id].chunks.keys():
						var chunk_status : String = RaptorRender.rr_data.jobs[job_id].chunks[chunk].status
						var number_of_tries : int = RaptorRender.rr_data.jobs[job_id].chunks[chunk].number_of_tries
						
						if chunk_status == RRStateScheme.chunk_rendering: 
							RaptorRender.rr_data.jobs[job_id].chunks[chunk].status = RRStateScheme.chunk_paused
							
							# change try status
							RaptorRender.rr_data.jobs[job_id].chunks[chunk].tries[number_of_tries].status = RRStateScheme.try_cancelled
							RaptorRender.rr_data.jobs[job_id].chunks[chunk].tries[number_of_tries].time_stopped = OS.get_unix_time()
						
						if chunk_status == RRStateScheme.chunk_queued:
							RaptorRender.rr_data.jobs[job_id].chunks[chunk].status = RRStateScheme.chunk_paused
							
					# Set Job Status to paused
					RaptorRender.rr_data.jobs[job_id].status = desired_status
			
			
			# desired state "finished"
			RRStateScheme.job_finished:
				RaptorRender.rr_data.jobs[job_id].status = desired_status
			
			
			# desired state "cancelled"
			RRStateScheme.job_cancelled:
				if current_status == RRStateScheme.job_rendering or current_status == RRStateScheme.job_rendering_paused_deferred or current_status == RRStateScheme.job_queued or current_status == RRStateScheme.job_error or current_status == RRStateScheme.job_paused:
					
					# cancel render if needed
					if JobExecutionManager.current_processing_job == job_id:
						CommandLineManager.kill_current_render_process()
					
					# remove current job from clients (the hint in the table)
					for client in RaptorRender.rr_data.clients.keys():
						if RaptorRender.rr_data.clients[client].current_job_id == job_id:
							RaptorRender.rr_data.clients[client].current_job_id = -1
					
					# cancle active chunks
					for chunk in RaptorRender.rr_data.jobs[job_id].chunks.keys():
						var chunk_status : String = RaptorRender.rr_data.jobs[job_id].chunks[chunk].status
						var number_of_tries : int = RaptorRender.rr_data.jobs[job_id].chunks[chunk].number_of_tries
						
						if chunk_status == RRStateScheme.chunk_rendering: 
							RaptorRender.rr_data.jobs[job_id].chunks[chunk].status = RRStateScheme.chunk_cancelled
							
							# change try status
							RaptorRender.rr_data.jobs[job_id].chunks[chunk].tries[number_of_tries].status = RRStateScheme.try_cancelled
							RaptorRender.rr_data.jobs[job_id].chunks[chunk].tries[number_of_tries].time_stopped = OS.get_unix_time()
						
						if chunk_status == RRStateScheme.chunk_queued:
							RaptorRender.rr_data.jobs[job_id].chunks[chunk].status = RRStateScheme.chunk_cancelled
							
					# Set Job Status to paused
					RaptorRender.rr_data.jobs[job_id].status = desired_status



remotesync func update_chunk_states(job_id : int, chunk_ids : Array, desired_status : String) -> void:
	for chunk in chunk_ids:
		update_chunk_status(job_id, chunk, desired_status)



remotesync func update_chunk_status(job_id : int, chunk_id : int, desired_status : String) -> void:
	
	if RaptorRender.rr_data.jobs.has(job_id):
		if RaptorRender.rr_data.jobs[job_id].chunks.has(chunk_id):
			
			var current_status : String = RaptorRender.rr_data.jobs[job_id].chunks[chunk_id].status
			
			match desired_status:
				
				# desired state "rendering"
				RRStateScheme.chunk_rendering:
					
					if current_status != RRStateScheme.chunk_cancelled and current_status != RRStateScheme.chunk_finished:
						RaptorRender.rr_data.jobs[job_id].chunks[chunk_id].status = desired_status
				
				
				# desired state "queued"
				RRStateScheme.chunk_queued:
					
					if current_status == RRStateScheme.chunk_rendering:
						
						var number_of_tries : int = RaptorRender.rr_data.jobs[job_id].chunks[chunk_id].number_of_tries
						
						# cancel render process if necessary
						if JobExecutionManager.current_processing_job == job_id and JobExecutionManager.current_processing_chunk == chunk_id:
							CommandLineManager.kill_current_render_process()
						
						# change try status
						RaptorRender.rr_data.jobs[job_id].chunks[chunk_id].tries[number_of_tries].status = RRStateScheme.try_cancelled
						RaptorRender.rr_data.jobs[job_id].chunks[chunk_id].tries[number_of_tries].time_stopped = OS.get_unix_time()
						
						# change chunk status
						RaptorRender.rr_data.jobs[job_id].chunks[chunk_id].status = desired_status
					
					if current_status == RRStateScheme.chunk_paused or current_status == RRStateScheme.chunk_finished or current_status == RRStateScheme.chunk_error:
						RaptorRender.rr_data.jobs[job_id].chunks[chunk_id].status = desired_status
				
				
				# desired state "error"
				RRStateScheme.chunk_error:  
					RaptorRender.rr_data.jobs[job_id].chunks[chunk_id].status = desired_status
				
				
				# desired state "paused". This is not meant to be used, because we can not pause a single chunk. This will happen automatically if we pause the wohle job.
				RRStateScheme.chunk_paused:  
					pass
				
				
				# desired state "finished"
				RRStateScheme.chunk_finished:
					if current_status != RRStateScheme.chunk_cancelled:
						RaptorRender.rr_data.jobs[job_id].chunks[chunk_id].status = desired_status
				
				
				# desired state "cancelled". This is not meant to be used, because we can not cancel a single chunk. This will happen automatically if we cancel the wohle job.
				RRStateScheme.chunk_cancelled:
					pass



remotesync func mark_chunks_as_finished(job_id : int, chunk_ids : Array) -> void:
	for chunk in chunk_ids:
		mark_chunk_as_finished(job_id, chunk)



remotesync func mark_chunk_as_finished(job_id : int, chunk_id : int) -> void:
	
	if RaptorRender.rr_data.jobs.has(job_id):
		if RaptorRender.rr_data.jobs[job_id].chunks.has(chunk_id):
			
			var current_status : String = RaptorRender.rr_data.jobs[job_id].chunks[chunk_id].status
			
			if current_status == RRStateScheme.chunk_rendering:
				
				var number_of_tries : int = RaptorRender.rr_data.jobs[job_id].chunks[chunk_id].number_of_tries
				
				# cancel render process if necessary
				if JobExecutionManager.current_processing_job == job_id and JobExecutionManager.current_processing_chunk == chunk_id:
					CommandLineManager.kill_current_render_process()
				
				# change try status
				RaptorRender.rr_data.jobs[job_id].chunks[chunk_id].tries[number_of_tries].status = RRStateScheme.try_cancelled
				RaptorRender.rr_data.jobs[job_id].chunks[chunk_id].tries[number_of_tries].time_stopped = OS.get_unix_time()
				
				# change chunk status
				RaptorRender.rr_data.jobs[job_id].chunks[chunk_id].status = RRStateScheme.chunk_finished
			
			if current_status == RRStateScheme.chunk_paused or current_status == RRStateScheme.chunk_error or current_status == RRStateScheme.chunk_queued:
				RaptorRender.rr_data.jobs[job_id].chunks[chunk_id].status = RRStateScheme.chunk_finished



# add a new try
remotesync func add_try(job_id : int, chunk_id : int, try_id : int, try : Dictionary) -> void:
	if RaptorRender.rr_data.jobs.has(job_id):
		if RaptorRender.rr_data.jobs[job_id].chunks.has(chunk_id):
			RaptorRender.rr_data.jobs[job_id].chunks[chunk_id].tries[try_id] = try
			RaptorRender.rr_data.jobs[job_id].chunks[chunk_id].number_of_tries += 1
			
			# eliminate priority boost, as now at least one chunk has tried to render
			RaptorRender.rr_data.jobs[job_id].priority_boost = false



# update a try with the exact command the rendering client is using
remotesync func update_try_cmd(job_id : int, chunk_id : int, try_id : int, try_cmd : String) -> void:
	if RaptorRender.rr_data.jobs.has(job_id):
		if RaptorRender.rr_data.jobs[job_id].chunks.has(chunk_id):
			if RaptorRender.rr_data.jobs[job_id].chunks[chunk_id].tries.has(try_id):
				RaptorRender.rr_data.jobs[job_id].chunks[chunk_id].tries[try_id].cmd = try_cmd



remotesync func chunk_finished_successfully(job_id : int, chunk_id : int, try_id : int, time_finished : int) -> void:
	if RaptorRender.rr_data.jobs.has(job_id):
		if RaptorRender.rr_data.jobs[job_id].chunks.has(chunk_id):
			if RaptorRender.rr_data.jobs[job_id].chunks[chunk_id].tries.has(try_id):
				
				RaptorRender.rr_data.jobs[job_id].chunks[chunk_id].status = RRStateScheme.chunk_finished
				RaptorRender.rr_data.jobs[job_id].chunks[chunk_id].tries[try_id].status = RRStateScheme.try_finished
				RaptorRender.rr_data.jobs[job_id].chunks[chunk_id].tries[try_id].time_stopped = time_finished
				var chunk_counts : Array = JobFunctions.get_chunk_counts_TotalFinishedActive(job_id)
				
				# change status only, if there are no active chunks left
				if chunk_counts[2] == 0:
				
					# set job status to "finished" if all chunks are finished
					if chunk_counts[0] == chunk_counts[1]:
						RaptorRender.rr_data.jobs[job_id].status = RRStateScheme.job_finished
					else:
						RaptorRender.rr_data.jobs[job_id].status = RRStateScheme.job_queued
					
				# set job status to "paused" if all active chunks of a "paused deffered" job have finished
				if RaptorRender.rr_data.jobs[job_id].status == RRStateScheme.job_rendering_paused_deferred and chunk_counts[2] == 0:
					RaptorRender.rr_data.jobs[job_id].status = RRStateScheme.job_paused



remotesync func chunk_error(client_id : int, job_id : int, chunk_id : int, try_id : int, time_stopped : int) -> void:
	if RaptorRender.rr_data.jobs.has(job_id):
		if RaptorRender.rr_data.jobs[job_id].chunks.has(chunk_id):
			if RaptorRender.rr_data.jobs[job_id].chunks[chunk_id].tries.has(try_id):
				
				RaptorRender.rr_data.jobs[job_id].errors += 1
				RaptorRender.rr_data.jobs[job_id].chunks[chunk_id].errors += 1
				RaptorRender.rr_data.clients[client_id].error_count += 1
				if RaptorRender.rr_data.jobs[job_id].erroneous_clients.has(client_id):
					RaptorRender.rr_data.jobs[job_id].erroneous_clients[client_id] += 1
				else: 
					RaptorRender.rr_data.jobs[job_id].erroneous_clients[client_id] = 1
				RaptorRender.rr_data.jobs[job_id].chunks[chunk_id].tries[try_id].status = RRStateScheme.try_error
				RaptorRender.rr_data.jobs[job_id].chunks[chunk_id].tries[try_id].time_stopped = time_stopped
				RaptorRender.rr_data.jobs[job_id].chunks[chunk_id].status = RRStateScheme.chunk_queued
				
				var chunk_counts : Array = JobFunctions.get_chunk_counts_TotalFinishedActive(job_id)
				
				# set job status to "queued" if no active chunks are left
				if chunk_counts[2] == 0:
					RaptorRender.rr_data.jobs[job_id].status = RRStateScheme.job_queued




remotesync func add_client(client_id : int, machine_properties : Dictionary) -> void:
	
	# just update the machine properties if the client already exists in the client dict
	if RaptorRender.rr_data.clients.has(client_id):
		RaptorRender.rr_data.clients[client_id].machine_properties = machine_properties
	
	# only on the server create the client if it does not exist yet (because the sever knows for sure what a default client should look like)
	if get_tree().is_network_server():
		if not RaptorRender.rr_data.clients.has(client_id):
			
			# create the correct dict
			var new_client : Dictionary
			new_client = RaptorRender.default_client.duplicate()
			new_client.machine_properties = machine_properties
			new_client["time_connected"] = OS.get_unix_time()
			
			# add it to the dict on the server
			RaptorRender.rr_data.clients[client_id] = new_client
			
			# now send it to all connected management guis
			for peer in management_gui_clients:
				if peer != 1:
					rpc_id(peer, "copy_client", client_id, new_client)



# copies a client dictionary to all that don't have that client_id yet
puppet func copy_client(client_id : int, client : Dictionary) -> void:
	if not RaptorRender.rr_data.clients.has(client_id):
		RaptorRender.rr_data.clients[client_id] = client


remotesync func remove_clients(client_ids : Array) -> void:
	
	# save the current ClientsTable selection
	var current_selections : Array = RaptorRender.ClientsTable.get_selected_ids().duplicate()
	
	for client in client_ids:
		
		# we don't need to cancle any render processes, as clients can only be removed if they are not reachable/offline.
		
		# hide the CLientInfoPanel, if the currently displayed clinet gets deleted
		if client == RaptorRender.ClientInfoPanel.currently_selected_client_id:
			RaptorRender.ClientInfoPanel.currently_selected_client_id = -1
			RaptorRender.ClientInfoPanel.reset_to_first_tab()
			RaptorRender.ClientInfoPanel.visible = false
		
		# id reset for Client Info Panel of CPU and memory bars. Otherwise it would crash
		if client == RaptorRender.ClientInfoPanel.CPUUsageBar.client_id or client == RaptorRender.ClientInfoPanel.MemoryUsageBar.client_id:
			RaptorRender.ClientInfoPanel.CPUUsageBar.client_id = -1
			RaptorRender.ClientInfoPanel.MemoryUsageBar.client_id = -1
		
		# remove the job from rr_data
		RaptorRender.rr_data.clients.erase(client)
		for pool in RaptorRender.rr_data.pools:
			RaptorRender.rr_data.pools[pool].clients.erase(client)
		
		# filter and restore the selection
		current_selections.erase(client)
	
	# clear the table
	RaptorRender.ClientsTable.clear_table()
	
	# refresh the table
	RaptorRender.ClientsTable.refresh()
	
	# restore the selection
	RaptorRender.ClientsTable.set_selected_ids(current_selections)



remotesync func update_client_states(client_ids : Array, desired_status : String) -> void:
	for client in client_ids:
		update_client_status(client, desired_status)



remotesync func update_client_status(client_id : int, desired_status : String) -> void:
	
	if RaptorRender.rr_data.clients.has(client_id):
		
		var current_status : String = RaptorRender.rr_data.clients[client_id].status
		
		match desired_status:
			
			# desired state "rendering"
			RRStateScheme.client_rendering:
				RaptorRender.rr_data.clients[client_id].status = desired_status
			
			
			# desired state "error"
			RRStateScheme.client_error:
				RaptorRender.rr_data.clients[client_id].status = desired_status
			
			
			# desired state "available"
			RRStateScheme.client_available:
				
				if current_status == RRStateScheme.client_disabled:
					RaptorRender.rr_data.clients[client_id].status = desired_status
				
				if current_status == RRStateScheme.client_rendering or current_status == RRStateScheme.client_rendering_disabled_deferred:
					if client_id == GetSystemInformation.own_client_id:
						if CommandLineManager.currently_rendering:
							CommandLineManager.kill_current_render_process()
					
					RaptorRender.rr_data.clients[client_id].status = desired_status
			
			
			# desired state "rendering_disabled_deffered"
			RRStateScheme.client_rendering_disabled_deferred:  
				
				if current_status == RRStateScheme.client_rendering: 
					RaptorRender.rr_data.clients[client_id].status = desired_status
				
				if current_status == RRStateScheme.client_available or current_status == RRStateScheme.client_error:
					RaptorRender.rr_data.clients[client_id].status = RRStateScheme.client_disabled
			
			
			# desired state "disabled"
			RRStateScheme.client_disabled:  
				
				if current_status == RRStateScheme.client_rendering or current_status == RRStateScheme.client_available or current_status == RRStateScheme.client_error:
					
					# cancel render process if required
					if client_id == GetSystemInformation.own_client_id:
						if RaptorRender.rr_data.clients[client_id].status == RRStateScheme.client_rendering:
							CommandLineManager.kill_current_render_process()
					
					RaptorRender.rr_data.clients[client_id].status = desired_status
			
			
			# desired state "offline"
			RRStateScheme.client_offline:
				RaptorRender.rr_data.clients[client_id].status = desired_status



# This will update the hardware statistics like cpu usage etc. for a given client
remotesync func update_client_hw_stats(client_id : int, cpu_usage : int, memory_usage : int, hard_drives : Array) -> void:
	
	if RaptorRender.rr_data.clients.has(client_id):
		RaptorRender.rr_data.clients[client_id].machine_properties.memory_usage = memory_usage
		RaptorRender.rr_data.clients[client_id].machine_properties.cpu_usage = cpu_usage
		RaptorRender.rr_data.clients[client_id].machine_properties.hard_drives = hard_drives



# This will update the hardware statistics like cpu usage etc. for a given client
remotesync func update_client_current_job(client_id : int, job_id : int, chunk_id : int, try_id : int) -> void:
	
	if RaptorRender.rr_data.clients.has(client_id):
		RaptorRender.rr_data.clients[client_id].current_job_id = job_id
		RaptorRender.rr_data.clients[client_id].last_render_log = [job_id, chunk_id, try_id]



remotesync func update_pools(pools : Dictionary) -> void:
	
	RaptorRender.rr_data.pools = pools
	
	# reset current pool filter if the pool does not exist anymore
	if not RaptorRender.rr_data.pools.has(RaptorRender.clients_pool_filter):
		RaptorRender.clients_pool_filter = -1
	
	RaptorRender.update_pool_cache()
	
	# update pool-tabs / client-tabs
	var PoolTabsContainer : TabContainer = RaptorRender.PoolTabsContainer
	PoolTabsContainer.clear_all_pool_tabs_SortableTables()
	PoolTabsContainer.update_tabs()
	
	# this currently destroys the selection and the tab is not correct, too, if we delete a tab before
	
	# refresh tables
	RaptorRender.refresh_clients_table()
	RaptorRender.refresh_jobs_table()
	
	# handle the Clients Info Panel
	RaptorRender.ClientInfoPanel.currently_selected_client_id = -1
	RaptorRender.ClientInfoPanel.visible = false
	RaptorRender.ClientInfoPanel.reset_to_first_tab()



# this is meant to only be executed on the client that renders that job, not the whole network.
remotesync func start_render(job_id : int, chunk_id : int, try_id : int ) -> void:
	
	# add a new try
	var new_try_data : Dictionary = {
		"cmd" : "",
		"status" : RRStateScheme.try_rendering,
		"client" : GetSystemInformation.own_client_id,
		"time_started" : OS.get_unix_time(),
		"time_stopped" : 0
		}
	
	# add the try
	for peer in management_gui_clients:
		rpc_id(peer,"add_try", job_id, chunk_id, try_id, new_try_data)
	
	# start this chunk on the client
	JobExecutionManager.start_chunk( job_id, chunk_id, try_id)
	
	# set "current_job" and "last_render_log" information for the client
	for peer in RRNetworkManager.management_gui_clients:
		RRNetworkManager.rpc_id(peer, "update_client_current_job", GetSystemInformation.own_client_id, job_id, chunk_id, try_id)
	
	# set job state to rendering
	for peer in RRNetworkManager.management_gui_clients:
		RRNetworkManager.rpc_id(peer, "update_job_status", job_id, RRStateScheme.job_rendering)
	
	# set chunk state to rendering
	for peer in RRNetworkManager.management_gui_clients:
		RRNetworkManager.rpc_id(peer, "update_chunk_status", job_id, chunk_id, RRStateScheme.chunk_rendering)
		
	# set client state to rendering
	for peer in RRNetworkManager.management_gui_clients:
		RRNetworkManager.rpc_id(peer, "update_client_status", GetSystemInformation.own_client_id, RRStateScheme.client_rendering)
	
	# wait one second
	yield(get_tree().create_timer(1.0), "timeout")
	
	# let the server know that the dispatched job has been accepted
	rpc_id(1, "dispatch_response", GetSystemInformation.own_client_id, job_id, chunk_id)



# this removes the clients / chunks from the blocked list in the distribution manager
master func dispatch_response(client_id : int, job_id : int, chunk_id : int) -> void:
	JobDistributionManager.blocked_clients.erase(client_id)
	
	if JobDistributionManager.blocked_chunks.has(job_id):
		JobDistributionManager.blocked_chunks[job_id].erase(chunk_id)
		if JobDistributionManager.blocked_chunks[job_id].keys().size() == 0:
			JobDistributionManager.blocked_chunks.erase(job_id)



remotesync func reset_client_errors(client_id : int) -> void:
	
	# remove error counts from the client itself
	RaptorRender.rr_data.clients[client_id].error_count = 0
	
	# remove the errors caused by this client from all jobs
	for job in RaptorRender.rr_data.jobs.keys():
		if RaptorRender.rr_data.jobs[job].erroneous_clients.has(client_id):
			var errors_from_that_client : int = RaptorRender.rr_data.jobs[job].erroneous_clients[client_id]
			RaptorRender.rr_data.jobs[job].erroneous_clients.erase(client_id)
			RaptorRender.rr_data.jobs[job].errors -= errors_from_that_client



remotesync func reset_job_errors(job_id : int) -> void:
	
	# remove error counts from the job itself
	RaptorRender.rr_data.jobs[job_id].errors = 0
	
	# remove errors from all chunks
	for chunk in RaptorRender.rr_data.jobs[job_id].chunks.keys():
		RaptorRender.rr_data.jobs[job_id].chunks[chunk].errors = 0
	
	# remove the errors from clients that came from this job
	for client in RaptorRender.rr_data.jobs[job_id].erroneous_clients.keys():
		RaptorRender.rr_data.clients[client].error_count -= RaptorRender.rr_data.jobs[job_id].erroneous_clients[client]
		RaptorRender.rr_data.jobs[job_id].erroneous_clients.erase(client)




puppet func shutdown () -> void:
	
	match OS.get_name():
		
		# Linux
		"X11" : 
			
			var arguments = ["-P", "now", "Raptor Render shuts down your System!"]
			var result = []
			OS.execute("shutdown", arguments, false, result)
		
		
		# Windows
		"Windows" :
			
			var arguments = ["-s", "-t", "0"]
			var result = []
			OS.execute("shutdown", arguments, false, result)



puppet func reboot () -> void:
	
	match OS.get_name():
		
		# Linux
		"X11" : 
			
			var arguments = ["-r", "now", "Raptor Render reboots your System!"]
			var result = []
			OS.execute("shutdown", arguments, false, result)
		
		
		# Windows
		"Windows" :
			
			var arguments = ["-r", "-t","0"]
			var result = []
			OS.execute("shutdown", arguments, false, result)



remote func execute_command (command : String) -> void:
	
	match OS.get_name():
		
		# Linux
		"X11" : 
			print ("hello")
			var output : Array = []
			var arguments : Array = ["-c", command]
			OS.execute("bash", arguments, false, output)
		
		
		# Windows
		"Windows" :
			
			var output : Array = []
			var arguments : Array = ['/C', command]
			OS.execute('CMD.exe', arguments, false, output)



# new image_directory detected


