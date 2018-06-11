extends Node

func get_chunk_counts_TotalFinishedActive(job_id):

	var chunk_keys = RaptorRender.rr_data.jobs[job_id].chunks.keys()
			
	var chunks_total = 0
	var chunks_finished = 0
	var chunks_active = 0
	
	for chunk_key in chunk_keys:
		var chunk_status = RaptorRender.rr_data.jobs[job_id].chunks[chunk_key].status
		match chunk_status:
			"active": chunks_active += 1
			"finished": chunks_finished += 1
		chunks_total += 1

	return [chunks_total, chunks_finished, chunks_active]