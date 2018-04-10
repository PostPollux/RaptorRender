tool

extends MarginContainer

export (Array, String) var column_names

var Splitters = []
var ColumnButtons = []
onready var RowContainerFilled = $"../ScrollContainer/VBoxContainer/RowContainerFilled"
var dragging_splitter = false
var dragging_splitter_id

var mouse_position_x_before_dragging
var min_size_of_column_before_dragging

var ColumnSplitterRes = preload("res://GUI/SortableTable/TopRow/ColumnSplitter.tscn")


func _ready():
	
	get_column_buttons_and_splitters()
	assign_ids_to_splitters()
	connect_signals_of_splitters()
	
#	var count = 1
#
#	for column_name in column_names:
#		var ColumnButton = Button.new()
#		ColumnButton.name = column_name
#		ColumnButton.text = column_name
#
#		ColumnButtons.append(ColumnButton)
#		$HBoxContainer.add_child(ColumnButton)
#
#		var Splitter = ColumnSplitterRes.instance()
#		Splitter.splitter_id = count
#		Splitter.connect("just_clicked", self, "resize_column")
#		Splitters.append(Splitter)
#		$HBoxContainer.add_child(Splitter)
#
#		count += 1

func _process(delta):
	
	if dragging_splitter:
		
		# Left mouse button still pressed
		if Input.is_mouse_button_pressed(1):
			
			# resize the ColumnButton of the TopRow
			var mouse_pos_x = get_viewport().get_mouse_position().x
			var calculated_size = min_size_of_column_before_dragging + (mouse_pos_x - mouse_position_x_before_dragging)
			ColumnButtons[dragging_splitter_id - 1].rect_min_size.x = calculated_size
			
			# apply the size of the ColumnButton of the TopRow to all the rows of the table
			var column_width = ColumnButtons[dragging_splitter_id - 1].rect_size.x
			RowContainerFilled.set_column_width(dragging_splitter_id, column_width)
		
		# Left mouse button released	
		else:
			dragging_splitter = false

func get_column_buttons_and_splitters ():
	
	var count = 1
	
	for CurrentNode in $HBoxContainer.get_children():
		
		if count%2 == 0:
			Splitters.append(CurrentNode)
		else:
			ColumnButtons.append(CurrentNode)
			
		
		count += 1


func assign_ids_to_splitters():
	
	var count = 1
	
	for Splitter in Splitters:
		Splitter.splitter_id = count
		count += 1
		
func connect_signals_of_splitters ():
	
	for Splitter in Splitters:
		Splitter.connect("just_clicked", self, "resize_column")


func resize_column(splitter_id):
	dragging_splitter_id = splitter_id
	mouse_position_x_before_dragging = get_viewport().get_mouse_position().x
	min_size_of_column_before_dragging = ColumnButtons[splitter_id - 1].rect_size.x
	dragging_splitter = true
	
	
	
	
	