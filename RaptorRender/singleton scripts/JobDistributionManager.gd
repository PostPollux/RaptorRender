extends Node

### PRELOAD RESOURCES

### SIGNALS

### ONREADY VARIABLES

### EXPORTED VARIABLES

### VARIABLES
var distribute_job_timer : Timer 
var jobs_active : Array # Array of the job ids that need clients (currently rendering jobs and queued jobs)
var clients_available : Array # Array of the client ids that are free and can accept a job





########## FUNCTIONS ##########


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	jobs_active = []
	clients_available = []
	
	CommandLineManager.connect("render_process_exited",self ,"reactivate_client") # TODO - this is just temporarily
	CommandLineManager.connect("render_process_exited_without_software_start",self ,"reactivate_client") # TODO - this is just temporarily
	
	
	# create timer to constantly distribute the work across the connected clients 
	distribute_job_timer = Timer.new()
	distribute_job_timer.name = "Distribute Job Timer"
	distribute_job_timer.wait_time = 1
	distribute_job_timer.connect("timeout",self,"distribute_jobs")
	var root_node : Node = get_tree().get_root().get_node("RaptorRenderMainScene")
	if root_node != null:
		root_node.add_child(distribute_job_timer)
	
	
	distribute_job_timer.start()
	
	
	
	# TODO - this is just temporarily
func reactivate_client() -> void:
	RaptorRender.rr_data.clients[GetSystemInformation.own_client_id].status = RRStateScheme.client_available
	




func distribute_jobs() -> void:
	
	# make sure only the server distributes jobs
	if get_tree().has_network_peer():
		if get_tree().is_network_server():
			
			# update the jobs_active array, so that we know, if there is some work to do
			jobs_active = []
			for job in RaptorRender.rr_data.jobs.keys():
				var job_status = RaptorRender.rr_data.jobs[job].status
				if job_status == RRStateScheme.job_rendering or job_status == RRStateScheme.job_queued:
					jobs_active.append(job)
			
			# Is there some work to do?
			if jobs_active.size() > 0:
				
				# are there resources to wake over lan that can help?
				
				# update the clients_available array
				clients_available = []
				for client in RaptorRender.rr_data.clients.keys():
					if RaptorRender.rr_data.clients[client].status == RRStateScheme.client_available:
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
					for client in clients_available:
						
						# go through the priority sorted jobs and take the first one that uses a JobType supported by the client
						for job in jobs_active_sort_array:
							
							# check if job can be processed by this client
							if true:
								
								# assign a chunk
								for chunk in RaptorRender.rr_data.jobs[job[0]].chunks.keys():
									if RaptorRender.rr_data.jobs[job[0]].chunks[chunk].status == RRStateScheme.chunk_queued:
										
										# add a new try
										var current_tries_count : int = RaptorRender.rr_data.jobs[job[0]].chunks[chunk].number_of_tries
										var new_try_data : Dictionary = {
											"cmd" : "",
											"status" : RRStateScheme.try_rendering,
											"client" : client,
											"time_started" : OS.get_unix_time(),
											"time_stopped" : 0
											}
										
										
										RRNetworkManager.rpc("add_try", job[0], chunk, current_tries_count + 1, new_try_data)
										#RaptorRender.rr_data.jobs[job[0]].chunks[chunk].tries[current_tries_count + 1] = new_try_data
										#RaptorRender.rr_data.jobs[job[0]].chunks[chunk].number_of_tries += 1
										
										# start this chunk on the client
										JobExecutionManager.start_chunk( job[0] , chunk, current_tries_count + 1)
										
										# eliminate priority boost, as now at least one chunk is rendering
										RaptorRender.rr_data.jobs[job[0]].priority_boost = false
										
										# set "current_job" and "last_render_log" information for the client
										RaptorRender.rr_data.clients[client].current_job_id = job[0]
										RaptorRender.rr_data.clients[client].last_render_log = [job[0], chunk, current_tries_count + 1]
										
										
										RaptorRender.rr_data.jobs[job[0]].status = RRStateScheme.job_rendering
										
										RaptorRender.rr_data.jobs[job[0]].chunks[chunk].status = RRStateScheme.chunk_rendering
										
										
										RaptorRender.rr_data.clients[client].status = RRStateScheme.client_rendering
										
										break
								
							
							
				
			else:
				
				# check if timeout for shutting down pc is reached
					# automatically shut down pcs
				return

func sort_by_priority(a, b) -> bool:
	return a[1] > b[1]
