#///////////////////#
# ChunkTimeBarGraph #
#///////////////////#

# The BarGraph is just one control node that uses custom draw function to draw the graph.
# It shows the rendertime of each chunk of a given job.


extends Control

### PRELOAD RESOURCES

### SIGNALS
signal chunk_hovered

### ONREADY VARIABLES 

### EXPORTED VARIABLES
# variables to customize look of the graph
export (bool) var draw_outline = false
export (Color) var outline_color = Color("000000")

export (int) var desired_spacing_inbetween = 5
export (int) var spacing_top = 25
export (int) var spacing_bottom = 5

export (Font) var font

### VARIABLES
var shortest_rendertime_color : Color = RRColorScheme.chunk_time_graph_shortest
var longest_rendertime_color : Color = RRColorScheme.chunk_time_graph_longest
var not_started_color : Color = RRColorScheme.chunk_time_graph_not_started

var accumulate_tries : bool = false
var job_id : int = 0




########## FUNCTIONS ##########


func _process(delta):
	
	# only refresh when graph is visible
	if self.is_visible_in_tree():
		
		update() # triggers the "_draw" func



func _draw():
	
	draw_ChunkTimeGraph(job_id) # remember: all custom draw functions have to be called from the draw func




func draw_ChunkTimeGraph(job_id : int):
	
	# define variables
	
	var total_width : float = self.rect_size.x
	var total_height : float = self.rect_size.y
	
	var bottom : float = self.rect_size.y - spacing_bottom
	
	var chunk_count : int = RaptorRender.rr_data.jobs[job_id].chunks.keys().size()
	
	var spacing_inbetween : int = desired_spacing_inbetween
	
	var bar_width : float  = (total_width - chunk_count * spacing_inbetween) / chunk_count 
	
	var local_mouse_pos : Vector2 = self.get_local_mouse_position()
	
	var at_least_one_rendering_chunk : bool = false
	var at_least_one_finished_chunk : bool = false
	
	
	# reducue spacing, if bar is smaller than the spacing
	
	while bar_width < spacing_inbetween:
		spacing_inbetween -= 1
		bar_width = (total_width - chunk_count * spacing_inbetween) / chunk_count 
		 
	
	
	# calculate shortest and longest rendertimes + average (we need those in order to draw the bars in another loop)
	
	var shortest_rendertime : int = 0
	var longest_rendertime : int = 0
	var average_rendertime : int = 0
	var rendertimes : Array = []
	
	for chunk_number in range(1, chunk_count + 1):
		
		
		var chunk_rendertime : int = 0
		var finished : bool
		
		var chunk_dict : Dictionary = RaptorRender.rr_data.jobs[job_id].chunks[chunk_number]
		
		var number_of_tries : int = chunk_dict.number_of_tries
		
		if chunk_dict.status == RRStateScheme.chunk_finished: 
		
			if number_of_tries > 0:
				if accumulate_tries:
					for try in range(1, number_of_tries + 1):
						chunk_rendertime +=  chunk_dict.tries[try].time_stopped - chunk_dict.tries[try].time_started
				else:
					chunk_rendertime =  chunk_dict.tries[number_of_tries].time_stopped - chunk_dict.tries[number_of_tries].time_started
			else:
				chunk_rendertime = 1
				
			finished = true
			rendertimes.append(chunk_rendertime)
			at_least_one_finished_chunk = true
			
		if chunk_dict.status == RRStateScheme.chunk_rendering:
			if accumulate_tries:
				for try in range(1, number_of_tries + 1):
					if chunk_dict.tries[try].status == RRStateScheme.try_rendering:
						chunk_rendertime +=  OS.get_unix_time() - chunk_dict.tries[try].time_started
					else:
						chunk_rendertime +=  chunk_dict.tries[try].time_stopped - chunk_dict.tries[try].time_started
			else:
				chunk_rendertime = OS.get_unix_time() - chunk_dict.tries[number_of_tries].time_started
			
			finished = false
			rendertimes.append(chunk_rendertime)
			at_least_one_rendering_chunk = true
			
		if shortest_rendertime == 0:
			shortest_rendertime = chunk_rendertime	
		if chunk_rendertime > longest_rendertime:
			longest_rendertime = chunk_rendertime
		if finished and chunk_rendertime < shortest_rendertime:
			shortest_rendertime = chunk_rendertime
	
	for rendertime in rendertimes:
		average_rendertime += rendertime
	if rendertimes.size() > 0:
		average_rendertime = average_rendertime / rendertimes.size()
	
	
	# draw the bars
	
	for chunk_number in range(0, chunk_count):
		
		var chunk_dict : Dictionary = RaptorRender.rr_data.jobs[job_id].chunks[chunk_number + 1]
		
		var number_of_tries : int = chunk_dict.number_of_tries
		
		var bar_left : float = chunk_number * (bar_width + spacing_inbetween)
		
		var chunk_rendertime : int = 0
		
		if chunk_dict.status == RRStateScheme.chunk_finished: 
			if number_of_tries > 0:
				if accumulate_tries:
					for try in range(1, number_of_tries + 1):
						chunk_rendertime +=  chunk_dict.tries[try].time_stopped - chunk_dict.tries[try].time_started
				else:
					chunk_rendertime =  chunk_dict.tries[number_of_tries].time_stopped - chunk_dict.tries[number_of_tries].time_started
			else:
				chunk_rendertime = 1
			
			
		if chunk_dict.status == RRStateScheme.chunk_rendering:
			
			if number_of_tries > 0:
				if accumulate_tries:
					for try in range(1, number_of_tries + 1):
						if chunk_dict.tries[try].status == RRStateScheme.try_rendering:
							chunk_rendertime +=  OS.get_unix_time() - chunk_dict.tries[try].time_started
						else:
							chunk_rendertime +=  chunk_dict.tries[try].time_stopped - chunk_dict.tries[try].time_started
				else:
					chunk_rendertime = OS.get_unix_time() - chunk_dict.tries[number_of_tries].time_started
				
		var bar_height : float = 0
		var color_interpolation_factor : float = 0
		
		if longest_rendertime != 0:
			bar_height = ( float (chunk_rendertime) / float(longest_rendertime) ) * (total_height - spacing_top - spacing_bottom)
		else:
			bar_height = ( float (chunk_rendertime) / 1 ) * (total_height - spacing_top - spacing_bottom)
		
		
		if longest_rendertime != shortest_rendertime:
			color_interpolation_factor = float((chunk_rendertime - shortest_rendertime)) / float((longest_rendertime - shortest_rendertime))
		else:
			color_interpolation_factor = float((chunk_rendertime - shortest_rendertime)) / 1
		
		var bar_rect : Rect2
		var bar_color : Color
		
		if bar_height != 0:
			bar_rect = Rect2(Vector2(bar_left, bottom), Vector2(bar_width, -bar_height))
			bar_color = shortest_rendertime_color.linear_interpolate(longest_rendertime_color, color_interpolation_factor)
		else:
			bar_rect = Rect2(Vector2(bar_left, bottom), Vector2(bar_width, -2))
			bar_color = not_started_color
		
		
		# highlight bar and emit signal when hovering
		if local_mouse_pos.x > bar_left and local_mouse_pos.x < bar_left + bar_width + spacing_inbetween and local_mouse_pos.y > 0 and local_mouse_pos.y < total_height:
			draw_rect(bar_rect, bar_color.lightened(0.5), true)
			emit_signal("chunk_hovered", chunk_number + 1)
		
		else:
			draw_rect(bar_rect, bar_color, true)
		
		if draw_outline:
			draw_rect(bar_rect, outline_color, false)
			

	
	
	# draw longest render time line + time indicator
	if at_least_one_rendering_chunk or at_least_one_finished_chunk:
		var longest_time_string : String = TimeFunctions.seconds_to_string(longest_rendertime, 3)
		var longest_rendertime_line_y : float = spacing_top 
		
		draw_line(Vector2(0, longest_rendertime_line_y), Vector2(total_width, longest_rendertime_line_y), Color(1,1,1,0.5), 1.0, false)
		draw_rect(Rect2(Vector2(0, longest_rendertime_line_y - 1), Vector2(longest_time_string.length() * 10 + 20, -20)),Color(0,0,0,0.25), true)
		
		draw_string(font, Vector2 (10, longest_rendertime_line_y - 1 - 5 ), longest_time_string, Color(1,1,1,1), - 1)
	
	
	
	# draw average render time line + time indicator
	if at_least_one_finished_chunk and average_rendertime > 0:
		var average_time_string : String = TimeFunctions.seconds_to_string(average_rendertime, 3)
		
		var average_rendertime_line_y : float = bottom -  float (average_rendertime) / float(longest_rendertime) * (total_height - spacing_top - spacing_bottom)
		
		draw_line(Vector2(average_time_string.length() * 10 + 20, average_rendertime_line_y), Vector2(total_width, average_rendertime_line_y), Color(1,1,1,0.5), 1.0, false)
		draw_rect(Rect2(Vector2(0, average_rendertime_line_y - 9), Vector2(average_time_string.length() * 10 + 20, 20)),Color(0,0,0,0.25), true)
		
		draw_string(font, Vector2 (10, average_rendertime_line_y + 6 ), average_time_string, Color(1,1,1,1), - 1)
	
	
	# draw shortest render time line + time indicator
	if at_least_one_finished_chunk and longest_rendertime - shortest_rendertime > 1:
		if shortest_rendertime > 0:
			var shortest_time_string : String = TimeFunctions.seconds_to_string(shortest_rendertime, 3)
			var shortest_rendertime_line_y : float = bottom - float (shortest_rendertime) / float(longest_rendertime) * (total_height - spacing_top - spacing_bottom)
			
			draw_line(Vector2(0, shortest_rendertime_line_y), Vector2(total_width, shortest_rendertime_line_y), Color(1,1,1,0.5), 1.0, false)
			
			# draw time indicator on the bottom of the line. Only draw it on top if there is not enough space on the bottom
			if bottom - shortest_rendertime_line_y > 25:
				draw_rect(Rect2(Vector2(0, shortest_rendertime_line_y + 1), Vector2(shortest_time_string.length() * 10 + 20, 20)),Color(0,0,0,0.25), true)
				draw_string(font, Vector2 (10, shortest_rendertime_line_y + 16 ), shortest_time_string, Color(1,1,1,1), - 1)
			else:
				draw_rect(Rect2(Vector2(0, shortest_rendertime_line_y - 1), Vector2(shortest_time_string.length() * 10 + 20, -20)),Color(0,0,0,0.25), true)
				draw_string(font, Vector2 (10, shortest_rendertime_line_y - 1 - 5), shortest_time_string, Color(1,1,1,1), - 1)
	
	



# Double click on a bar to select the chunk in the Chunk List
func _on_BarGraph_gui_input(ev):
	
	# test for double click
	if  ev.is_pressed() and ev.doubleclick and ev.button_index==1:
        
		# find double clicked chunk
		var chunk : int = self.get_parent().get_parent().hovered_chunk
		
		# switch tab
		RaptorRender.JobInfoPanel.set_tab(1)
		
		# select and autofocus correct chunk
		RaptorRender.ChunksTable.clear_selection()
		RaptorRender.ChunksTable.select_by_id(chunk)
		RaptorRender.ChunksTable.scroll_to_row(chunk)
		RaptorRender.chunk_selected(chunk)
		
		# select first try
		if RaptorRender.rr_data.jobs[job_id].chunks[chunk].number_of_tries > 0:
			RaptorRender.TriesTable.clear_selection()
			RaptorRender.TriesTable.select_by_id(1)
			RaptorRender.try_selected(1)



