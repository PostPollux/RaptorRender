extends Node

var distribute_job_timer : Timer 

var jobs_active : Array # Array of the job ids that need clients (currently rendering jobs and queued jobs)
var clients_available : Array # Array of the client ids that are free and can accept a job

# Called when the node enters the scene tree for the first time.
func _ready():
	
	jobs_active = []
	clients_available = []
	
	CommandLineManager.connect("render_process_exited",self ,"reactivate_client")
	
	
	# create timer to constantly distribute the work across the connected clients 
	distribute_job_timer = Timer.new()
	distribute_job_timer.name = "Distribute Job Timer"
	distribute_job_timer.wait_time = 1
	distribute_job_timer.connect("timeout",self,"distribute_jobs")
	var root_node : Node = get_tree().get_root().get_node("RaptorRenderMainScene")
	if root_node != null:
		root_node.add_child(distribute_job_timer)
	
	
	distribute_job_timer.start()
	
	
	

func reactivate_client():
	RaptorRender.rr_data.clients[GetSystemInformation.unique_client_id].status = "2_available"
	




func distribute_jobs():
	
	# update the jobs_active array, so that we know, if there is some work to do
	jobs_active = []
	for job in RaptorRender.rr_data.jobs.keys():
		var job_status = RaptorRender.rr_data.jobs[job].status
		if job_status == "1_rendering" or job_status == "2_queued":
			jobs_active.append(job)
	
	# Is there some work to do?
	if jobs_active.size() > 0:
		
		# are there resources to wake over lan that can help?
		
		# update the clients_available array
		clients_available = []
		for client in RaptorRender.rr_data.clients.keys():
			if RaptorRender.rr_data.clients[client].status == "2_available":
				clients_available.append(client)
		
		
		# are there any available clients to distribute the work to?
		if clients_available.size() > 0:
			
			# sort active jobs by priority 
			
			# assign a job to each available client
			for client in clients_available:
				
				# go through the priority sorted jobs and take the first one that uses a JobType supported by the client
				for job in jobs_active:
					
					# check if job can be processed by this client
					if true:
						
						# assign a chunk
						for chunk in RaptorRender.rr_data.jobs[job].chunks.keys():
							if RaptorRender.rr_data.jobs[job].chunks[chunk].status == "2_queued":
								
								# start this chunk on the client
								JobExecutionManager.start_junk( job , chunk)
								
								RaptorRender.rr_data.jobs[job].status = "1_rendering"
								
								RaptorRender.rr_data.jobs[job].chunks[chunk].status = "1_rendering"
								RaptorRender.rr_data.jobs[job].chunks[chunk].time_started = OS.get_unix_time()
								RaptorRender.rr_data.jobs[job].chunks[chunk].client = client
								RaptorRender.rr_data.jobs[job].chunks[chunk].number_of_tries += 1
								
								RaptorRender.rr_data.clients[client].status = "1_rendering"
								
								break
						
						break
					
					
		
	else:
		
		# check if timeout for shutting down pc is reached
			# automatically shut down pcs
		return