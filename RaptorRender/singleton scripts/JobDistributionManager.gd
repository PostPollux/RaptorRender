extends Node

### PRELOAD RESOURCES

### SIGNALS

### ONREADY VARIABLES

### EXPORTED VARIABLES

### VARIABLES
var distribute_job_timer : Timer 
var jobs_active : Array # Array of the job ids that need clients (currently rendering jobs and queued jobs)
var clients_available : Array # Array of the client ids that are free and can accept a job

var dispatching_interval : int = 1
var dispatching_response_timeout : int = 5

# clients will be excluded from a job if they produced 10 errors within that job
var max_error_count_clients : int = 10


# This dictionary will hold all clients to which a job just has been dispatched, but that didn't respond yet.
# So the next time jobs get dispatched those clients will still be blocked. 
# The value of the "client" key is the remaining time in sec till the timeout. If it times out, the entry will be deleted and new jobs will be dispatched to that client.
var blocked_clients : Dictionary

var blocked_chunks : Dictionary




########## FUNCTIONS ##########


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	jobs_active = []
	clients_available = []
	
	# create timer to constantly distribute the work across the connected clients 
	distribute_job_timer = Timer.new()
	distribute_job_timer.name = "Distribute Job Timer"
	distribute_job_timer.wait_time = dispatching_interval
	distribute_job_timer.connect("timeout",self,"distribute_jobs")
	var root_node : Node = get_tree().get_root().get_node("RaptorRenderMainScene")
	if root_node != null:
		root_node.add_child(distribute_job_timer)
	
	
	distribute_job_timer.start()




func distribute_jobs() -> void:
	
	# make sure only the server distributes jobs
	if get_tree().has_network_peer():
		if get_tree().is_network_server():
			
			# handle dispatching response timeouts (clients)
			for client in blocked_clients.keys():
				if blocked_clients[client] > 0:
					blocked_clients[client] = blocked_clients[client] - dispatching_interval
				else:
					blocked_clients.erase(client)
			
			# handle dispatching response timeouts (chunks)
			for job in blocked_chunks.keys():
				for chunk in blocked_chunks[job].keys():
					if blocked_chunks[job][chunk] > 0:
						blocked_chunks[job][chunk] = blocked_chunks[job][chunk] - dispatching_interval
					else:
						blocked_chunks[job].erase(chunk)
						if blocked_chunks.keys().size() == 0:
							blocked_chunks.erase(job)
			
			# update the jobs_active array, so that we know, if there is some work to do
			jobs_active = []
			for job in RaptorRender.rr_data.jobs.keys():
				var job_status = RaptorRender.rr_data.jobs[job].status
				if job_status == RRStateScheme.job_rendering or job_status == RRStateScheme.job_queued:
					jobs_active.append(job)
			
			# Is there some work to do?
			if jobs_active.size() > 0:
				
				# are there resources to wake over lan that can help?
				# to be implemented 
				
				# update the clients_available array
				clients_available = []
				for client in RaptorRender.rr_data.clients.keys():
					if RaptorRender.rr_data.clients[client].status == RRStateScheme.client_available:
						if not blocked_clients.has(client):
							clients_available.append(client)
				
				
				# are there any available clients to distribute the work to?
				if clients_available.size() > 0:
					
					# create a priority sortable jobs array 
					var jobs_active_sort_array : Array = []
					
					for job in jobs_active:
						# New jobs with no rendered chunks will get a priority boost
						if RaptorRender.rr_data.jobs[job].priority_boost == true:
							jobs_active_sort_array.append( [job, 101] )
						else:
							jobs_active_sort_array.append( [job, RaptorRender.rr_data.jobs[job].priority] )
					
					# sort jobs_active_sort_array
					jobs_active_sort_array.sort_custom ( self, "sort_by_priority" )
					
					
					
					# assign a job to each available client
					for client_id in clients_available:
						
						# go through the priority sorted jobs and take the first one that uses a JobType supported by the client
						for job in jobs_active_sort_array:
							
							var job_id : int = job[0]
							
							# check if job can be processed by this client
							
							# check error counts
							var error_count_ok : bool = true
							if RaptorRender.rr_data.jobs[job_id].erroneous_clients.has(client_id):
								if RaptorRender.rr_data.jobs[job_id].erroneous_clients[client_id] >= max_error_count_clients:
									error_count_ok = false
							
							# check pools
							var pools_are_matching : bool = true
							if RaptorRender.rr_data.jobs[job_id].pools.size() > 0:
								pools_are_matching = false
								for pool in RaptorRender.rr_data.jobs[job_id].pools:
									if RaptorRender.rr_data.clients[client_id].pools.has(pool):
										pools_are_matching = true
							
							# check enabled software
							
							if error_count_ok and pools_are_matching and true:
								
								# assign a chunk
								for chunk_id in RaptorRender.rr_data.jobs[job_id].chunks.keys():
									if RaptorRender.rr_data.jobs[job_id].chunks[chunk_id].status == RRStateScheme.chunk_queued:
										
										
								
										# break if this chunk is currently blocked
										var chunk_blocked : bool = false
										if blocked_chunks.has(job_id):
											if blocked_chunks[job_id].has(chunk_id):
												chunk_blocked = true
										
										if not chunk_blocked:
											
											# get peer id of that client
											var peer_id : int = -1
											for peer in RRNetworkManager.peer_id_client_id_dict:
												if RRNetworkManager.peer_id_client_id_dict[peer] == client_id:
													peer_id = peer
											
											# get try id
											var current_tries_count : int = RaptorRender.rr_data.jobs[job_id].chunks[chunk_id].number_of_tries
											var try_id : int = current_tries_count + 1
											
											# start render process on that peer
											if peer_id != -1:
												RRNetworkManager.rpc_id(peer_id, "start_render", job_id, chunk_id, try_id)
											
											# add that client to the blocked list
											blocked_clients[client_id] = dispatching_response_timeout
											
											# add that chunk to the blocked list
											if not blocked_chunks.has(job_id):
												blocked_chunks[job_id] = {}
											blocked_chunks[job_id][chunk_id] = dispatching_response_timeout
											
											# make sure to leave that chunk for loop, so no other chunks get assigned to that client
											break
								
								# make sure to leave the job for loop, so no chunks of other jobs get assigned to the client
								break
							
				
			else:
				
				# check if timeout for shutting down pc is reached
					# automatically shut down pcs
				return

func sort_by_priority(a, b) -> bool:
	return a[1] > b[1]
