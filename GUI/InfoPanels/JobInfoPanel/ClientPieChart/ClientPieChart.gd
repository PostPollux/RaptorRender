extends Control

var job_id

# variables to customize look of the graph

#export (Color) var not_started_color = Color(0.75,0.75,0.75,1)
export (float) var filled_percentage = 0.3

export (Color) var most_chunks_rendered_color = Color ("5191d0") 
export (Color) var least_chunks_rendered_color = Color ("bd638d")
export (Color) var chunks_not_assigned_color = Color ("bfbfbf")

export (bool) var draw_outline = false
export (Color) var outline_color = Color("000000")
export (Color) var outline_color_highlighted = Color("FFFFFF")
export (int) var outline_thickness = 2


export (int) var desired_spacing_between_segments_in_degrees = 2

onready var NameLabel = $"NameLabel"
onready var ChunksLabel = $"ChunksLabel"

var hovered_client

signal segment_hovered

func _ready():
	pass

func _process(delta):
	update()



func set_job_id(job_ID):
	job_id = job_ID
	update()



func _draw():
	
	
	var chunk_count = RaptorRender.rr_data.jobs[job_id].chunks.keys().size()
	
	
	var unique_clients = []
	var count_dictionary = {}
	var clients_with_counts = []
	
	
	# unique clients
	for chunk in range(1, chunk_count + 1):
		if not unique_clients.has( RaptorRender.rr_data.jobs[job_id].chunks[chunk].client ):
			unique_clients.append( RaptorRender.rr_data.jobs[job_id].chunks[chunk].client )
	
	
	# create the count dictionary
	for client in unique_clients:
		count_dictionary[client] = 0
	
	
	# now count how often each client occures
	for chunk in range(1, chunk_count + 1):
		count_dictionary[ RaptorRender.rr_data.jobs[job_id].chunks[chunk].client ] += 1
	
	
	# create clients_with_counts array
	for client in unique_clients:
		if client != "": 
			clients_with_counts.append( [ client, count_dictionary[client] ] )
	
	
	# sort the array 
	clients_with_counts.sort_custom( self, "sort_clients_by_chunk_counts" )
	
	
	# add the unassigned chunks at the end of the array so they are always on the left side
	if unique_clients.has(""):
		clients_with_counts.append( [ "", count_dictionary[""] ] )
	
	
	# limit spacing size to half of smallest segment or shut of spacing if there is only one client
	var spacing_between_segments_in_degrees = desired_spacing_between_segments_in_degrees
	
	if desired_spacing_between_segments_in_degrees > 0:
		var smallest_segement_in_degrees = 360 * ( float(clients_with_counts[ clients_with_counts.size() - 1][1]) / float(chunk_count) )
		if float(desired_spacing_between_segments_in_degrees) > float(smallest_segement_in_degrees) / float(2) :
			spacing_between_segments_in_degrees = float(smallest_segement_in_degrees) / float(2)
	
	if unique_clients.size() == 1:
		spacing_between_segments_in_degrees = 0
	
	
	# draw the individual segments
	var start_of_segment_in_degrees = 0  # 12 o'clock
	var client_number = 1
	
	for client in clients_with_counts:
		
		# define position an angles
		var percentage_of_rendered_chunks = float(client[1]) / float(chunk_count)
		var center = Vector2(self.rect_size.x / 2 , self.rect_size.y / 2)
		var radius = (min(rect_size.x, rect_size.y) / 2 ) * 0.8
		var angle_from = start_of_segment_in_degrees
		var angle_to = start_of_segment_in_degrees + 360 * percentage_of_rendered_chunks - spacing_between_segments_in_degrees
		
		
		# define color
		var color
		var color_interpolation_factor = float(client_number) / float(unique_clients.size())
		
		if client[0] == "":
			color = chunks_not_assigned_color
		else:
			color = most_chunks_rendered_color.linear_interpolate(least_chunks_rendered_color, color_interpolation_factor)
		
		var quality = 360 * percentage_of_rendered_chunks * 2 + 2
		
		# calculate degrees between mouse position and the center of the pie chart
		var mouse_pos_relative_to_center = self.get_local_mouse_position() - center
		var raw_angle_mouse_to_center = rad2deg( Vector2(0, -1).angle_to(mouse_pos_relative_to_center))
		var angle_mouse_to_center = raw_angle_mouse_to_center
		
		if  raw_angle_mouse_to_center < 0:
			angle_mouse_to_center =  180 + (180 - abs(raw_angle_mouse_to_center))
		
		# highlight hoverd segment and fill labels
		var highlight = false
		var local_mouse_pos = self.get_local_mouse_position()
		if local_mouse_pos.x > 0 and local_mouse_pos.x < self.rect_size.x and local_mouse_pos.y > 0 and local_mouse_pos.y < self.rect_size.y:
			if angle_mouse_to_center > angle_from and angle_mouse_to_center < angle_to:
				highlight = true
				color = color.lightened(0.4)
				radius = (min(rect_size.x, rect_size.y) / 2 ) * 0.83
				
				emit_signal("segment_hovered", client)
		
		# actually draw the segment
		draw_circle_segment_as_arc(quality, center, radius, angle_from, angle_to, color, filled_percentage)
		if draw_outline:
			if highlight:
				draw_circle_segment_as_arc_outline(quality, center, radius, angle_from, angle_to, outline_color_highlighted, filled_percentage, outline_thickness)
			else:
				draw_circle_segment_as_arc_outline(quality, center, radius, angle_from, angle_to, outline_color, filled_percentage, outline_thickness)
			
		# advance variables
		start_of_segment_in_degrees = angle_to + spacing_between_segments_in_degrees
		client_number += 1


func sort_clients_by_chunk_counts(a,b):
	
	# a custom sort function must return true if the first argument (a) is less than the second (b)
	
	return a[1] > b[1]












func draw_circle_segment(quality, center, radius, angle_from, angle_to, color):
	var nb_points = quality
	var points_arc = PoolVector2Array()
	points_arc.push_back(center)
	var colors = PoolColorArray([color])

	for i in range(nb_points+1):
		var angle_point = deg2rad(angle_from + i * (angle_to - angle_from) / nb_points - 90)
		points_arc.push_back(center + Vector2(cos(angle_point), sin(angle_point)) * radius)
	draw_polygon(points_arc, colors)



func draw_circle_segment_as_arc(quality, center, radius, angle_from, angle_to, color, filled_percentage):
	var nb_points = quality
	var points_arc = PoolVector2Array()
	var colors = PoolColorArray([color])

	for i in range(nb_points+1):
		var angle_point = deg2rad(angle_from + i * (angle_to - angle_from) / nb_points - 90)
		points_arc.push_back(center + Vector2(cos(angle_point), sin(angle_point)) * radius)
	
	for i in range(nb_points+1):
		var angle_point = deg2rad(angle_to + i * (angle_from - angle_to) / nb_points - 90)
		points_arc.push_back(center + Vector2(cos(angle_point), sin(angle_point)) * (radius - radius * filled_percentage))
	
	draw_polygon(points_arc, colors)



func draw_circle_segment_as_arc_outline(quality, center, radius, angle_from, angle_to, color, filled_percentage, line_thickness):
	var nb_points = quality
	var points_arc = PoolVector2Array()
	var colors = PoolColorArray([color])

	for i in range(nb_points+1):
		var angle_point = deg2rad(angle_from + i * (angle_to - angle_from) / nb_points - 90)
		points_arc.push_back(center + Vector2(cos(angle_point), sin(angle_point)) * radius)
	
	for i in range(nb_points+1):
		var angle_point = deg2rad(angle_to + i * (angle_from - angle_to) / nb_points - 90)
		points_arc.push_back(center + Vector2(cos(angle_point), sin(angle_point)) * (radius - radius * filled_percentage))
		
	# add first and second point again to close the outline
	points_arc.push_back(points_arc[0]) 
	points_arc.push_back(points_arc[1])
	
	# draw a polyline
	draw_polyline(points_arc, color, line_thickness)
	
	# draw lines separately 
	for index_point in range(nb_points * 2 + 2):
		draw_line(points_arc[index_point], points_arc[index_point + 1], color, line_thickness)



func draw_circle_arc(quality, center, radius, angle_from, angle_to, color):
	var nb_points = quality
	var points_arc = PoolVector2Array()

	for i in range(nb_points+1):
		var angle_point = deg2rad(angle_from + i * (angle_to-angle_from) / nb_points - 90)
		points_arc.push_back(center + Vector2(cos(angle_point), sin(angle_point)) * radius)

	for index_point in range(nb_points):
		draw_line(points_arc[index_point], points_arc[index_point + 1], color)


func _on_ClientPieChart_segment_hovered(client_with_chunk_count):
	
	hovered_client = client_with_chunk_count[0]
	
	if client_with_chunk_count[0] == "":
		NameLabel.text = "not assigned"
	else:
		NameLabel.text = RaptorRender.rr_data.clients[ client_with_chunk_count[0] ].name
	ChunksLabel.text = "Chunks: " + String(client_with_chunk_count[1])


func _on_ClientPieChart_mouse_exited():
	NameLabel.text = ""
	ChunksLabel.text = ""


# Double click on segment to select the client
func _on_ClientPieChart_gui_input(ev):
	
	# test for double click
	if  ev.is_pressed() and ev.doubleclick and ev.button_index==1:
		
		# find double clicked client
		var client = hovered_client
		
		# select and autofocus correct client
		RaptorRender.JobsTable.clear_selection()
		RaptorRender.ClientsTable.clear_selection()
		RaptorRender.ClientsTable.select_by_id(client)
		RaptorRender.client_selected(client)
		RaptorRender.ClientsTable.scroll_to_row(client)