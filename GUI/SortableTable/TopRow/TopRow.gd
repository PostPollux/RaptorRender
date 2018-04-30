tool

extends MarginContainer

var column_names = []
var column_widths = []

var Splitters = []
var ColumnButtons = []
onready var SortableTable = $"../.."
onready var RowContainerFilled = $"../RowScrollContainer/VBoxContainer/RowContainerFilled"
onready var RowContainerEmpty = $"../RowScrollContainer/VBoxContainer/ClipContainerForEmptyRows/RowContainerEmpty"
var dragging_splitter = false
var dragging_splitter_id
var column_used_for_sort = 1
var sort_reversed = false

var mouse_position_x_before_dragging
var min_size_of_column_before_dragging

var ColumnSplitterRes = preload("res://GUI/SortableTable/TopRow/ColumnSplitter.tscn")
var ColumnButtonRes = preload("res://GUI/SortableTable/TopRow/ColumnButton.tscn")

func _ready():
	
	column_names = SortableTable.column_names
	column_widths = SortableTable.column_widths
	column_used_for_sort = SortableTable.sort_column
	
	create_buttons_and_splitters()
	assign_ids_to_splitters()
	connect_signals_of_splitters()
	expand_last_column_if_space_available()
	

#	




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
			RowContainerEmpty.set_column_width(dragging_splitter_id, column_width)
			
		# Left mouse button released	
		else:
			
			# apply the size of the ColumnButton of the TopRow to all the rows of the table
			var column_width = ColumnButtons[dragging_splitter_id - 1].rect_size.x
			RowContainerFilled.set_column_width(dragging_splitter_id, column_width)
			RowContainerEmpty.set_column_width(dragging_splitter_id, column_width)
			
			# stop dragging logic
			dragging_splitter = false


func create_buttons_and_splitters():
	
	# delete existing nodes
	for CurrentNode in $HBoxContainer.get_children():
		CurrentNode.queue_free()
		
	var count = 1

	for column_name in column_names:
		
		var ColumnButton = ColumnButtonRes.instance()
		ColumnButton.column_button_name = column_name
		ColumnButton.id = count
		ColumnButton.rect_min_size.x = column_widths[count -1]
		ColumnButton.connect("column_button_pressed", self, "visually_update_columns_to_show_sort")
		if count == column_used_for_sort:
			ColumnButton.active_sort_column = true
			ColumnButton.sort_reversed = false
			ColumnButton.arrow_down_visible = true
			ColumnButton.arrow_up_visible = false

		ColumnButtons.append(ColumnButton)
		$HBoxContainer.add_child(ColumnButton)

		var Splitter = ColumnSplitterRes.instance()
		Splitter.splitter_id = count
		Splitter.connect("just_clicked", self, "resize_column")
		Splitters.append(Splitter)
		$HBoxContainer.add_child(Splitter)

		count += 1
		
		




func assign_ids_to_splitters():
	
	var count = 1
	
	for Splitter in Splitters:
		Splitter.splitter_id = count
		count += 1
		
		
		
func connect_signals_of_splitters ():
	
	for Splitter in Splitters:
		Splitter.connect("just_clicked", self, "resize_column_by_drag")



func resize_column_by_drag(splitter_id):
	dragging_splitter_id = splitter_id
	mouse_position_x_before_dragging = get_viewport().get_mouse_position().x
	min_size_of_column_before_dragging = ColumnButtons[splitter_id - 1].rect_size.x
	dragging_splitter = true
	
	
func expand_last_column_if_space_available ():
	var LastColumnButton = ColumnButtons[ColumnButtons.size() - 1]
	
	var size = SortableTable.rect_size.x
	
	for i in range(0, ColumnButtons.size() - 1):
		size = size - ColumnButtons[i].rect_min_size.x
		
	if size > column_widths[ColumnButtons.size() - 1]:
		LastColumnButton.rect_min_size.x = size - ColumnButtons.size() * 4 - 12




func visually_update_columns_to_show_sort(column_id):
	column_used_for_sort = column_id
	
	var count = 1
	for ColumnButton in ColumnButtons:
		if ColumnButton.active_sort_column == true:
			RowContainerFilled.highlight_column(column_id)
			RowContainerEmpty.highlight_column(column_id)
		if count != column_id:
			ColumnButton.reset_button()
		count += 1
	