extends Control

export (Color) var shortest_rendertime_color = Color ("93d051") 
export (Color) var longest_rendertime_color = Color ("ff0000")

export (bool) var draw_outline = true
export (Color) var outline_color = Color("000000")

export (int) var spacing_inbetween = 5
export (int) var spacing_top = 20

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	print (OS.get_unix_time())
	pass


func _draw():
	
	draw_ChunkTimeGraph("4")




func draw_ChunkTimeGraph(job_id):
	
	var total_width = self.margin_right - self.margin_left
	var total_height = self.margin_bottom - self.margin_top
	var bottom = self.margin_bottom
	
	var chunk_count = RaptorRender.rr_data.jobs[job_id].chunks.keys().size()
	
	var bar_width = (total_width - chunk_count * spacing_inbetween) / chunk_count 
	
	# reducue spacing, if bar is smaller than the spacing
	while bar_width < spacing_inbetween:
		spacing_inbetween -= 1
		bar_width = (total_width - chunk_count * spacing_inbetween) / chunk_count 
		 
	
	
	# calculate shortest and longest rendertimes
	
	var shortest_rendertime = 0
	var longest_rendertime = 0
	
	
	for chunk_number in range(1, chunk_count + 1):
		
		var chunk_rendertime = 0
		var finished
		
		var chunk_dict = RaptorRender.rr_data.jobs[job_id].chunks[String(chunk_number)]
		
		if chunk_dict.status == "5_finished": 
			chunk_rendertime =  chunk_dict.time_finished - chunk_dict.time_started
			finished = true
		if chunk_dict.status == "1_rendering":
			chunk_rendertime = OS.get_unix_time() - chunk_dict.time_started
			finished = false
		
		if shortest_rendertime == 0:
			shortest_rendertime = chunk_rendertime	
		if chunk_rendertime > longest_rendertime:
			longest_rendertime = chunk_rendertime
		if finished and chunk_rendertime < shortest_rendertime:
			shortest_rendertime = chunk_rendertime
		
	
	# draw the bars
	for chunk_number in range(0, chunk_count):
		
		var chunk_dict = RaptorRender.rr_data.jobs[job_id].chunks[String(chunk_number + 1)]
		
		var bar_left = chunk_number * (bar_width + spacing_inbetween)
		
		var chunk_rendertime = 0
		
		if chunk_dict.status == "5_finished": 
			chunk_rendertime =  chunk_dict.time_finished - chunk_dict.time_started
			
		if chunk_dict.status == "1_rendering":
			chunk_rendertime = OS.get_unix_time() - chunk_dict.time_started
		
		var bar_height = ( float (chunk_rendertime) / float(longest_rendertime) ) * (total_height - spacing_top)
		
		var color_interpolation_factor = float((chunk_rendertime - shortest_rendertime)) / float((longest_rendertime - shortest_rendertime))
		
		draw_rect(Rect2(Vector2(bar_left, bottom), Vector2(bar_width, -bar_height)), shortest_rendertime_color.linear_interpolate(longest_rendertime_color, color_interpolation_factor), true)
		if draw_outline:
			draw_rect(Rect2(Vector2(bar_left, bottom), Vector2(bar_width, -bar_height)), outline_color, false)





func _process(delta):
	update()
#	pass
