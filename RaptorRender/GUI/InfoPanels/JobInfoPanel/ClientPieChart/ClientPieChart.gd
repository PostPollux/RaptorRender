extends Control


### PRELOAD RESOURCES

### SIGNALS
signal segment_hovered

### ONREADY VARIABLES 
onready var NameLabel : Label = $"NameLabel"
onready var ChunksLabel : Label = $"ChunksLabel"

### EXPORTED VARIABLES
# variables to customize look of the graph
export (float) var filled_percentage : float = 0.3

export (Color) var most_chunks_rendered_color : Color = Color ("5191d0") 
export (Color) var least_chunks_rendered_color : Color = Color ("bd638d")
export (Color) var chunks_not_assigned_color : Color = Color ("bfbfbf")

export (bool) var draw_outline : bool = false
export (Color) var outline_color : Color = Color("000000")
export (Color) var outline_color_highlighted : Color = Color("FFFFFF")
export (int) var outline_thickness : int = 2

export (int) var desired_spacing_between_segments_in_degrees : int  = 2

### VARIABLES
var job_id
var hovered_client_id : int




########## FUNCTIONS ##########



func _process(delta) -> void:
	update()


func set_job_id(job_ID) -> void:
	job_id = job_ID
	update()


func _draw() -> void:
	
	var chunk_count : int = RaptorRender.rr_data.jobs[job_id].chunks.keys().size()
	
	
	var unique_clients : Array = [] # an array of all clients that are participating in the job
	var count_dictionary : Dictionary = {} # a temporary dictionary used to count up the client occurances while iterating over all chunks
	var clients_and_junk_counts : Array = [] # final array that is supposed to hold arrays [0: client_id, 1: chunk_count ]
	
	
	# unique clients ( -1 means no client assigned)
	for chunk in range(1, chunk_count + 1):
		var number_of_tries : int = RaptorRender.rr_data.jobs[job_id].chunks[chunk].number_of_tries
		if number_of_tries == 0:
			if not unique_clients.has( -1 ):
				unique_clients.append( -1)
		else:
			if not unique_clients.has( RaptorRender.rr_data.jobs[job_id].chunks[chunk].tries[number_of_tries].client ):
				unique_clients.append( RaptorRender.rr_data.jobs[job_id].chunks[chunk].tries[number_of_tries].client )
	
	
	# create the count dictionary
	for client in unique_clients:
		count_dictionary[client] = 0
	
	
	# now count how often each client occures
	for chunk in range(1, chunk_count + 1):
		var number_of_tries : int = RaptorRender.rr_data.jobs[job_id].chunks[chunk].number_of_tries
		if number_of_tries > 0:
			count_dictionary[ RaptorRender.rr_data.jobs[job_id].chunks[chunk].tries[number_of_tries].client ] += 1
		else:
			count_dictionary[ -1 ] += 1
	
	# create clients_and_junk_counts array
	for client in unique_clients:
		if client != -1: 
			clients_and_junk_counts.append( [ client, count_dictionary[client] ] )
	
	
	# sort the array 
	clients_and_junk_counts.sort_custom( self, "sort_clients_by_chunk_counts" )
	
	
	# add the unassigned chunks at the end of the array so they are always on the left side
	if unique_clients.has(-1):
		clients_and_junk_counts.append( [ -1, count_dictionary[-1] ] )
	
	
	# limit spacing size to half of smallest segment or shut of spacing if there is only one client
	var spacing_between_segments_in_degrees : float = desired_spacing_between_segments_in_degrees
	
	if desired_spacing_between_segments_in_degrees > 0 and clients_and_junk_counts.size() > 0:
		var smallest_segement_in_degrees : float = 360 * ( float(clients_and_junk_counts[ clients_and_junk_counts.size() - 1][1]) / float(chunk_count) )
		if float(desired_spacing_between_segments_in_degrees) > float(smallest_segement_in_degrees) / float(2) :
			spacing_between_segments_in_degrees = float(smallest_segement_in_degrees) / float(2)
	
	if unique_clients.size() == 1:
		spacing_between_segments_in_degrees = 0
	
	
	# draw the individual segments
	var start_of_segment_in_degrees : float = 0.0  # 12 o'clock
	var client_number : int = 1
	
	for client_and_junk_count in clients_and_junk_counts:
		
		# define position an angles
		var percentage_of_rendered_chunks : float = float(client_and_junk_count[1]) / float(chunk_count)
		var center = Vector2(self.rect_size.x / 2 , self.rect_size.y / 2)
		var radius : float = (min(rect_size.x, rect_size.y) / 2 ) * 0.8
		var angle_from : float = start_of_segment_in_degrees
		var angle_to : float = start_of_segment_in_degrees + 360 * percentage_of_rendered_chunks - spacing_between_segments_in_degrees
		
		
		# define color
		var color : Color
		var color_interpolation_factor = float(client_number) / float(unique_clients.size())
		
		if client_and_junk_count[0] == -1:
			color = chunks_not_assigned_color
		else:
			color = most_chunks_rendered_color.linear_interpolate(least_chunks_rendered_color, color_interpolation_factor)
		
		var number_of_points : int = int (360 * 2 * percentage_of_rendered_chunks + 2)
		
		# calculate degrees between mouse position and the center of the pie chart
		var mouse_pos_relative_to_center : Vector2 = self.get_local_mouse_position() - center
		var raw_angle_mouse_to_center : float = rad2deg( Vector2(0, -1).angle_to(mouse_pos_relative_to_center))
		var angle_mouse_to_center : float = raw_angle_mouse_to_center
		
		if  raw_angle_mouse_to_center < 0:
			angle_mouse_to_center =  180 + (180 - abs(raw_angle_mouse_to_center))
		
		# highlight hoverd segment and fill labels
		var highlight : bool  = false
		var local_mouse_pos : Vector2 = self.get_local_mouse_position()
		if local_mouse_pos.x > 0 and local_mouse_pos.x < self.rect_size.x and local_mouse_pos.y > 0 and local_mouse_pos.y < self.rect_size.y:
			if angle_mouse_to_center > angle_from and angle_mouse_to_center < angle_to:
				highlight = true
				color = color.lightened(0.4)
				radius = (min(rect_size.x, rect_size.y) / 2 ) * 0.83
				
				emit_signal("segment_hovered", client_and_junk_count)
		
		# actually draw the segment
		draw_circle_segment_as_arc(number_of_points, center, radius, angle_from, angle_to, color, filled_percentage)
		if draw_outline:
			if highlight:
				draw_circle_segment_as_arc_outline(number_of_points, center, radius, angle_from, angle_to, outline_color_highlighted, filled_percentage, outline_thickness)
			else:
				draw_circle_segment_as_arc_outline(number_of_points, center, radius, angle_from, angle_to, outline_color, filled_percentage, outline_thickness)
			
		# advance variables
		start_of_segment_in_degrees = angle_to + spacing_between_segments_in_degrees
		client_number += 1


func sort_clients_by_chunk_counts(a, b) -> bool:
	
	# a custom sort function must return true if the first argument (a) is less than the second (b)
	
	return a[1] > b[1]






func draw_circle_segment(number_of_points : int, center : Vector2, radius : float, angle_from : float, angle_to : float, color : Color) -> void:
	var points_arc : PoolVector2Array = PoolVector2Array()
	points_arc.push_back(center)
	var colors : PoolColorArray = PoolColorArray([color])
	
	for i in range(number_of_points + 1):
		var angle_point : float = deg2rad(angle_from + i * (angle_to - angle_from) / number_of_points - 90)
		points_arc.push_back(center + Vector2(cos(angle_point), sin(angle_point)) * radius)
	draw_polygon(points_arc, colors)



func draw_circle_segment_as_arc(number_of_points : int, center : Vector2, radius : float, angle_from : float, angle_to : float, color : Color, filled_percentage : float) -> void:
	var points_arc = PoolVector2Array()
	var colors = PoolColorArray([color])
	
	for i in range(number_of_points + 1):
		var angle_point : float = deg2rad(angle_from + i * (angle_to - angle_from) / number_of_points - 90)
		points_arc.push_back(center + Vector2(cos(angle_point), sin(angle_point)) * radius)
	
	for i in range(number_of_points + 1):
		var angle_point : float = deg2rad(angle_to + i * (angle_from - angle_to) / number_of_points - 90)
		points_arc.push_back(center + Vector2(cos(angle_point), sin(angle_point)) * (radius - radius * filled_percentage))
	
	draw_polygon(points_arc, colors)



func draw_circle_segment_as_arc_outline(number_of_points : int, center : Vector2, radius : float, angle_from : float, angle_to : float, color : Color, filled_percentage : float, line_thickness : int) -> void:
	var points_arc : PoolVector2Array = PoolVector2Array()
	var colors : PoolColorArray = PoolColorArray([color])
	
	for i in range(number_of_points + 1):
		var angle_point : float = deg2rad(angle_from + i * (angle_to - angle_from) / number_of_points - 90)
		points_arc.push_back(center + Vector2(cos(angle_point), sin(angle_point)) * radius)
	
	for i in range(number_of_points + 1):
		var angle_point : float = deg2rad(angle_to + i * (angle_from - angle_to) / number_of_points - 90)
		points_arc.push_back(center + Vector2(cos(angle_point), sin(angle_point)) * (radius - radius * filled_percentage))
		
	# add first and second point again to close the outline
	points_arc.push_back(points_arc[0]) 
	points_arc.push_back(points_arc[1])
	
	# draw a polyline
	draw_polyline(points_arc, color, line_thickness)
	
	# draw lines separately 
	for index_point in range(number_of_points * 2 + 2):
		draw_line(points_arc[index_point], points_arc[index_point + 1], color, line_thickness)



func draw_circle_arc(number_of_points : int, center : Vector2, radius : float, angle_from : float, angle_to : float, color : Color) -> void:
	var points_arc = PoolVector2Array()
		
	for i in range(number_of_points + 1):
		var angle_point = deg2rad(angle_from + i * (angle_to-angle_from) / number_of_points - 90)
		points_arc.push_back(center + Vector2(cos(angle_point), sin(angle_point)) * radius)
		
	for index_point in range(number_of_points):
		draw_line(points_arc[index_point], points_arc[index_point + 1], color)



func _on_ClientPieChart_segment_hovered(client_and_chunk_count : Array) -> void:
	
	hovered_client_id = client_and_chunk_count[0]
	
	if hovered_client_id == -1:
		NameLabel.text = tr("JOB_CLIENT_PIE_CHART_1") # not assigned
	else:
		if RaptorRender.rr_data.clients.has(hovered_client_id):
			NameLabel.text = RaptorRender.rr_data.clients[ hovered_client_id ].machine_properties.name
		else:
			NameLabel.text = tr("UNKNOWN")
	ChunksLabel.text = tr("JOB_CLIENT_PIE_CHART_2") + ": " + String(client_and_chunk_count[1])



func _on_ClientPieChart_mouse_exited() -> void:
	NameLabel.text = ""
	ChunksLabel.text = ""



# Double click on segment to select the client
func _on_ClientPieChart_gui_input(ev) -> void:
	
	# test for double click
	if  ev.is_pressed() and ev.doubleclick and ev.button_index==1:
		
		# find double clicked client
		var client_id : int = hovered_client_id
		
		# select and autofocus correct client
		RaptorRender.JobsTable.clear_selection()
		RaptorRender.ClientsTable.clear_selection()
		RaptorRender.ClientsTable.select_by_id(client_id)
		RaptorRender.client_selected(client_id)
		RaptorRender.ClientsTable.scroll_to_row(client_id)
