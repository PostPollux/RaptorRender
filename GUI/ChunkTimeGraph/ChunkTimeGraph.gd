extends Control

export (Color) var shortest_rendertime_color = Color ("93d051") 
export (Color) var longest_rendertime_color = Color ("ff0000")

export (bool) var draw_outline = true
export (Color) var outline_color = Color("000000")

export (int) var desired_spacing_inbetween = 5
export (int) var spacing_top = 25
export (int) var spacing_bottom = 5

export (Font) var font

var job_id = ""


signal chunk_hovered


func _ready():
	pass




func _process(delta):
	
	# only refresh when graph is visible
	if self.is_visible_in_tree():
		
		#if job_id != "":
		update()



func _draw():
	
	#if job_id != "":
	draw_ChunkTimeGraph(job_id)




func draw_ChunkTimeGraph(job_id):
	
	var total_width = self.rect_size.x
	var total_height = self.rect_size.y
	
	var bottom = self.rect_size.y - spacing_bottom
	
	var chunk_count = RaptorRender.rr_data.jobs[job_id].chunks.keys().size()
	
	var spacing_inbetween = desired_spacing_inbetween
	
	var bar_width = (total_width - chunk_count * spacing_inbetween) / chunk_count 
	
	var local_mouse_pos = self.get_local_mouse_position()
	
	var rendering_chunk= false
	var finished_chunk = false
	
	# reducue spacing, if bar is smaller than the spacing
	while bar_width < spacing_inbetween:
		spacing_inbetween -= 1
		bar_width = (total_width - chunk_count * spacing_inbetween) / chunk_count 
		 
	
	
	# calculate shortest and longest rendertimes + average
	
	var shortest_rendertime = 0
	var longest_rendertime = 1
	var average_rendertime = 0
	var rendertimes_array = []
	
	for chunk_number in range(1, chunk_count + 1):
		
		var chunk_rendertime = 0
		var finished
		
		var chunk_dict = RaptorRender.rr_data.jobs[job_id].chunks[String(chunk_number)]
		
		if chunk_dict.status == "5_finished": 
			chunk_rendertime =  chunk_dict.time_finished - chunk_dict.time_started
			finished = true
			rendertimes_array.append(chunk_rendertime)
			finished_chunk = true
			
		if chunk_dict.status == "1_rendering":
			chunk_rendertime = OS.get_unix_time() - chunk_dict.time_started
			finished = false
			rendertimes_array.append(chunk_rendertime)
			rendering_chunk = true
			
		if shortest_rendertime == 0:
			shortest_rendertime = chunk_rendertime	
		if chunk_rendertime > longest_rendertime:
			longest_rendertime = chunk_rendertime
		if longest_rendertime == shortest_rendertime:
			longest_rendertime += 1
		if finished and chunk_rendertime < shortest_rendertime:
			shortest_rendertime = chunk_rendertime
	
	for rendertime in rendertimes_array:
		average_rendertime += rendertime
	if rendertimes_array.size() > 0:
		average_rendertime = average_rendertime / rendertimes_array.size()
	
	
	# draw the bars
	for chunk_number in range(0, chunk_count):
		
		var chunk_dict = RaptorRender.rr_data.jobs[job_id].chunks[String(chunk_number + 1)]
		
		var bar_left = chunk_number * (bar_width + spacing_inbetween)
		
		var chunk_rendertime = 0
		
		if chunk_dict.status == "5_finished": 
			chunk_rendertime =  chunk_dict.time_finished - chunk_dict.time_started
			
		if chunk_dict.status == "1_rendering":
			chunk_rendertime = OS.get_unix_time() - chunk_dict.time_started
		
		var bar_height = ( float (chunk_rendertime) / float(longest_rendertime) ) * (total_height - spacing_top - spacing_bottom)
		
		var color_interpolation_factor = float((chunk_rendertime - shortest_rendertime)) / float((longest_rendertime - shortest_rendertime))
		
		var bar_rect = Rect2(Vector2(bar_left, bottom), Vector2(bar_width, -bar_height))
		
		var bar_color = shortest_rendertime_color.linear_interpolate(longest_rendertime_color, color_interpolation_factor)
		
		# highlight bar and emit signal when hovering
		if local_mouse_pos.x > bar_left and local_mouse_pos.x < bar_left + bar_width + spacing_inbetween and local_mouse_pos.y > 0 and local_mouse_pos.y < total_height:
			draw_rect(bar_rect, bar_color.lightened(0.5), true)
			emit_signal("chunk_hovered", chunk_number + 1)
		
		else:
			draw_rect(bar_rect, bar_color, true)
		
		if draw_outline:
			draw_rect(bar_rect, outline_color, false)

	
	
	# draw longest render time line + time indicator
	if rendering_chunk or finished_chunk:
		var longest_time_string = TimeFunctions.seconds_to_string(longest_rendertime, 3)
		var longest_rendertime_line_y = spacing_top 
		
		draw_line(Vector2(0, longest_rendertime_line_y), Vector2(total_width, longest_rendertime_line_y), Color(1,1,1,0.5), 1.0, false)
		draw_rect(Rect2(Vector2(0, longest_rendertime_line_y - 1), Vector2(longest_time_string.length() * 10 + 20, -20)),Color(0,0,0,0.25), true)
		
		draw_string(font, Vector2 (10, longest_rendertime_line_y - 1 - 5 ), longest_time_string, Color(1,1,1,1), - 1)
		
	
	# draw shortest render time line + time indicator
	if finished_chunk and longest_rendertime - shortest_rendertime > 1:
		if shortest_rendertime > 0:
			var shortest_time_string = TimeFunctions.seconds_to_string(shortest_rendertime, 3)
			var shortest_rendertime_line_y = bottom - float (shortest_rendertime) / float(longest_rendertime) * (total_height - spacing_top - spacing_bottom)
			
			draw_line(Vector2(0, shortest_rendertime_line_y), Vector2(total_width, shortest_rendertime_line_y), Color(1,1,1,0.5), 1.0, false)
			draw_rect(Rect2(Vector2(0, shortest_rendertime_line_y + 1), Vector2(shortest_time_string.length() * 10 + 20, 20)),Color(0,0,0,0.25), true)
			
			draw_string(font, Vector2 (10, shortest_rendertime_line_y + 15 ), shortest_time_string, Color(1,1,1,1), - 1)
			
	
	# draw average render time line + time indicator
	if finished_chunk and average_rendertime > 0:
		var average_time_string = TimeFunctions.seconds_to_string(average_rendertime, 3)
		
		var average_rendertime_line_y = bottom -  float (average_rendertime) / float(longest_rendertime) * (total_height - spacing_top - spacing_bottom)
		
		draw_line(Vector2(average_time_string.length() * 10 + 20, average_rendertime_line_y), Vector2(total_width, average_rendertime_line_y), Color(1,1,1,0.5), 1.0, false)
		draw_rect(Rect2(Vector2(0, average_rendertime_line_y - 9), Vector2(average_time_string.length() * 10 + 20, 20)),Color(0,0,0,0.25), true)
		
		draw_string(font, Vector2 (10, average_rendertime_line_y + 6 ), average_time_string, Color(1,1,1,1), - 1)