extends Node



const RR_PORT = 44444
const server_ip = "192.168.0.220"
#const server_ip = "127.0.0.1"

const MAX_CLIENTS = 4095 # 4095 is max. If we use 4096 there will be an error and the server can't start

# A machine that is just rendering does not need to know most things going on on the renderfarm. So we can reduce network traffic in just not telling it those information in the first place.
# This variable holds the network id's of all clients that currently have the gui open and thus need the latest information about job statues etc. We sync this array over the whole network.
# Network Id "1" is always the server. We want to be sure that the server receives ALL updates, so we add 1 by default.
puppetsync var management_gui_clients : Array  = [1]


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

func create_server():
	
	if get_tree().has_network_peer():
		get_tree().set_network_peer(null) # Remove peer
	
	var host = NetworkedMultiplayerENet.new()
	host.create_server(RR_PORT, MAX_CLIENTS)
	host.set_always_ordered(true)
	get_tree().set_network_peer(host)


func connect_to_server():
	
	# make sure
	management_gui_clients = [1]
	
	if get_tree().has_network_peer():
		get_tree().set_network_peer(null) # Remove peer
		
	var client = NetworkedMultiplayerENet.new()
	client.create_client(server_ip, RR_PORT)
	client.set_always_ordered(true)
	get_tree().set_network_peer(client)




######## connecting callbacks ##########


# Callback from SceneTree, called when client connects
func _client_connected(id):
	print("New Client connected (", id, ")")



# Callback from SceneTree, called when client disconnects. Every connected client/server will receive this signal
func _client_disconnected(id):
	print("Client disconnected (", id, ")")
	
	if get_tree().is_network_server():
		if id != 1:
			management_gui_clients.erase(id)
			rset("management_gui_clients", management_gui_clients)
	



# Callback from SceneTree, called when connect to server
func _connected_ok():
	print ("successfully connected to server!")
	
	# login management gui
	rpc_id(1, "login_management_gui", get_tree().get_network_unique_id())


# Callback from SceneTree, called when server disconnect
func _server_disconnected():
	print("server disconnected")
	#players.clear()
	#emit_signal("server_disconnected")
	# Try to connect again
	#connect_to_server()


# Callback from SceneTree, called when unabled to connect to server
func _connected_fail():
	print("connecting to server failed...")
	#get_tree().set_network_peer(null) # Remove peer
	#emit_signal("connection_failed")
	# Try to connect again
	#connect_to_server()


# this will add the given network id to the "management_gui_clients" array on the master. Then the master syncs this variable to all puppets
master func login_management_gui(network_id : int):
	if not management_gui_clients.has(network_id):
		management_gui_clients.append(network_id)
		rset("management_gui_clients", management_gui_clients)



# this will remove the given network from the "management_gui_clients" array on the master. Then the master syncs this variable to all puppets
master func logout_management_gui(network_id : int):
	if management_gui_clients.has(network_id):
		management_gui_clients.erase(network_id)
		rset("management_gui_clients", management_gui_clients)




######## Remote Procedures ########

remotesync func add_job(job_id : int, job : Dictionary):
	RaptorRender.rr_data.jobs[job_id] = job
	
	# add job to assigned pools
	for pool in job.pools:
		if RaptorRender.rr_data.pools.has(pool):
			RaptorRender.rr_data.pools[pool].jobs.append(job_id)


remotesync func remove_job(job_id : int):
	######## not finished yet #########
	# cancel render process if this is the job where the machine is currently working on
	if JobExecutionManager.current_processing_job == job_id:
		CommandLineManager.kill_current_render_process()
		
	RaptorRender.rr_data.jobs.erase(job_id)
	
	# remove the row from the table
	#RaptorRender.JobsTable.remove_row(selected)



remotesync func update_job_priority(job_id : int, priority : int):
	if RaptorRender.rr_data.jobs.has(job_id):
		RaptorRender.rr_data.jobs[job_id].priority = priority



# add a new try
remotesync func add_try(job_id : int, chunk_id : int, try_id : int, try : Dictionary):
	if RaptorRender.rr_data.jobs.has(job_id):
		if RaptorRender.rr_data.jobs[job_id].chunks.has(chunk_id):
			RaptorRender.rr_data.jobs[job_id].chunks[chunk_id].tries[try_id] = try
			RaptorRender.rr_data.jobs[job_id].chunks[chunk_id].number_of_tries += 1
			
			# eliminate priority boost, as now at least one chunk has tried to render
			RaptorRender.rr_data.jobs[job_id].priority_boost = false



# update a try with the exact command the rendering client is using
remotesync func update_try_cmd(job_id : int, chunk_id : int, try_id : int, try_cmd : String):
	if RaptorRender.rr_data.jobs.has(job_id):
		if RaptorRender.rr_data.jobs[job_id].chunks.has(chunk_id):
			if RaptorRender.rr_data.jobs[job_id].chunks[chunk_id].tries.has(try_id):
				RaptorRender.rr_data.jobs[job_id].chunks[chunk_id].tries[try_id].cmd = try_cmd



remotesync func chunk_finished_successfully(job_id : int, chunk_id : int, try_id : int, time_finished : int):
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



remotesync func chunk_error(job_id : int, chunk_id : int, try_id : int, time_stopped : int):
	if RaptorRender.rr_data.jobs.has(job_id):
		if RaptorRender.rr_data.jobs[job_id].chunks.has(chunk_id):
			if RaptorRender.rr_data.jobs[job_id].chunks[chunk_id].tries.has(try_id):
				
				RaptorRender.rr_data.jobs[job_id].errors += 1
				RaptorRender.rr_data.jobs[job_id].chunks[chunk_id].errors += 1
				RaptorRender.rr_data.jobs[job_id].chunks[chunk_id].tries[try_id].status = RRStateScheme.try_error
				RaptorRender.rr_data.jobs[job_id].chunks[chunk_id].tries[try_id].time_stopped = time_stopped
				RaptorRender.rr_data.jobs[job_id].chunks[chunk_id].status = RRStateScheme.chunk_queued
				
				var chunk_counts : Array = JobFunctions.get_chunk_counts_TotalFinishedActive(job_id)
					
				# set job status to "queued" if no active chunks are left
				if chunk_counts[2] == 0:
					RaptorRender.rr_data.jobs[job_id].status = RRStateScheme.job_queued




# This will update the hardware statistics like cpu usage etc. for a given client
remotesync func update_client_hw_stats(client_id : int, cpu_usage : int, memory_usage : int, hard_drives : Array):
	if RaptorRender.rr_data.jobs.has(client_id):
		RaptorRender.rr_data.clients[client_id].machine_properties.memory_usage = memory_usage
		RaptorRender.rr_data.clients[client_id].machine_properties.cpu_usage = cpu_usage
		RaptorRender.rr_data.clients[client_id].machine_properties.hard_drives = hard_drives



remotesync func update_pools(pools : Dictionary):
	
	RaptorRender.rr_data.pools = pools
	
	RaptorRender.currently_updating_pool_cache = true
	
	# clear all cached pool arrays
	for job in RaptorRender.rr_data.jobs.keys():
		RaptorRender.rr_data.jobs[job].pools.clear()
	for client in RaptorRender.rr_data.clients.keys():
		RaptorRender.rr_data.clients[client].pools.clear()
	
	# fill the cache again
	for pool in RaptorRender.rr_data.pools.keys():
		for job in RaptorRender.rr_data.pools[pool].jobs:
			RaptorRender.rr_data.jobs[job].pools.append(pool)
		for client in RaptorRender.rr_data.pools[pool].clients:
			RaptorRender.rr_data.clients[client].pools.append(pool)
	
	RaptorRender.currently_updating_pool_cache = false
	
	# update pool-tabs / client-tabs
	var PoolTabsContainer : TabContainer = RaptorRender.PoolTabsContainer
	#PoolTabsContainer.current_tab = 0 # important so it doesn't try to autoupdate a table with data that has already been deleted
	#PoolTabsContainer.previous_active_tab = 0
	PoolTabsContainer.clear_all_pool_tabs_SortableTables()
	PoolTabsContainer.update_tabs()
	
	if PoolTabsContainer.previous_active_tab >= PoolTabsContainer.get_child_count():
		PoolTabsContainer.previous_active_tab = 0
		
	# refresh tables
	RaptorRender.refresh_clients_table()
	RaptorRender.refresh_jobs_table()
	


# new image_directory detected

# reset error counts

# pools

# delete job

# update job status 

# chunk requeuen

# mark chunk as rendering

# add client

# remove client



# Server will call this function to update the status of a job on every client
remote func update_job_status(job_id : int, status : String):
	if RaptorRender.rr_data.jobs.has(job_id):
		RaptorRender.rr_data.jobs[job_id].status = status



# Server will call this function to update the status of a job on every client
remote func update_chunk_status(job_id : int, chunk_id, status : String):
	if RaptorRender.rr_data.jobs.has(job_id):
		RaptorRender.rr_data.jobs[job_id].status = status
