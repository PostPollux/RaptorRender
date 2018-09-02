extends Control

var job_id

func _ready():
	pass

func _process(delta):
	pass







func _draw():
	var center = Vector2(self.rect_size.x / 2 , self.rect_size.y / 2)
	var radius = (min(rect_size.x, rect_size.y) / 2 ) * 0.8
	var angle_from = 0
	var angle_to = 180
	var color = Color(1.0, 0.0, 0.0)
	
	draw_circle_segment_as_arc(32, center, radius, angle_from, angle_to, color, 0.3)
	draw_circle_segment_as_arc_outline(32, center, radius, angle_from, angle_to, Color(0,0,0,1), 0.3, 5)












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