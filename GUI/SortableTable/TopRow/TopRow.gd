tool

extends MarginContainer

var column_names = []
var column_widths_initial = []
var column_widths = []

var Splitters = []
var ColumnButtons = []
onready var SortableTable = $"../.."
onready var RowContainerFilled = $"../RowScrollContainer/VBoxContainer/RowContainerFilled"
onready var RowContainerEmpty = $"../RowScrollContainer/VBoxContainer/ClipContainerForEmptyRows/RowContainerEmpty"
var dragging_splitter = false
var dragging_splitter_id
var sort_column_primary
var sort_column_secondary
var sort_column_primary_reversed = false
var sort_column_secondary_reversed = false

var mouse_position_x_before_dragging
var min_size_of_column_before_dragging

var ColumnSplitterRes = preload("res://GUI/SortableTable/TopRow/ColumnSplitter.tscn")
var ColumnButtonRes = preload("res://GUI/SortableTable/TopRow/ColumnButton.tscn")

func _ready():
	
	column_names = SortableTable.column_names
	column_widths_initial = SortableTable.column_widths_initial
	column_widths = column_widths_initial
	sort_column_primary = SortableTable.sort_column_primary
	sort_column_secondary = SortableTable.sort_column_secondary
	
	create_buttons_and_splitters()
	assign_ids_to_splitters()
	connect_signals_of_splitters()





func _process(delta):
	
	if dragging_splitter:
		
		# Left mouse button still pressed
		if Input.is_mouse_button_pressed(1):
			
			# resize the ColumnButton of the TopRow
			var mouse_pos_x = get_viewport().get_mouse_position().x
			var calculated_size = min_size_of_column_before_dragging + (mouse_pos_x - mouse_position_x_before_dragging)
			if calculated_size < 12:
				calculated_size = 12
			ColumnButtons[dragging_splitter_id - 1].rect_min_size.x = calculated_size
			column_widths[dragging_splitter_id - 1] = calculated_size
			
			# apply the size of the ColumnButton of the TopRow to all the rows of the table
			var column_width = column_widths[dragging_splitter_id - 1]
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
		ColumnButton.rect_min_size.x = column_widths_initial[count -1]
		ColumnButton.connect("column_button_pressed", self, "column_button_pressed")
		if count == sort_column_primary:
			ColumnButton.primary_sort_column = true
			ColumnButton.sort_column_primary_reversed = false
			ColumnButton.primary_down_visible = true
			ColumnButton.primary_up_visible = false
		if count == sort_column_secondary:
			ColumnButton.secondary_sort_column = true
			ColumnButton.sort_column_secondary_reversed = false
			ColumnButton.secondary_down_visible = true
			ColumnButton.secondary_up_visible = false

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
	min_size_of_column_before_dragging = column_widths[splitter_id - 1]
	dragging_splitter = true
	
	
	
	
###### Not Used at the moment #####
func expand_last_column_if_space_available ():

	
	var column_button_count = ColumnButtons.size()
	var LastColumnButton = ColumnButtons[column_button_count - 1]
	
	var available_size = 0
	var size_all_columns = 0

	for i in column_widths:
		size_all_columns += i

	available_size = column_widths[column_button_count - 1] + (SortableTable.rect_size.x - size_all_columns - column_button_count * 3)
	print (available_size)
	
#	var available_size = SortableTable.rect_size.x 
#
#	for i in range(0, column_button_count - 1): 
#		available_size = available_size - ColumnButtons[i].rect_min_size.x - column_button_count * 3


	if available_size > column_widths_initial[column_button_count - 1]:

		# set the size of the last button in the TopRow
		LastColumnButton.rect_min_size.x = available_size - 12
		column_widths[column_button_count - 1] = available_size

		# apply the size of the ColumnButton of the TopRow to all the rows of the table
		var column_width = column_widths[column_button_count - 1]
		if RowContainerFilled.SortableRows:
			RowContainerFilled.set_column_width(column_button_count, column_width)
		if RowContainerEmpty.EmptyRows:
			RowContainerEmpty.set_column_width(column_button_count, column_width)
		
#############



func column_button_pressed(column_id):
	
	# column set to be the primary sort column
	if ColumnButtons[column_id - 1].primary_sort_column:
		sort_column_primary = column_id
		sort_column_primary_reversed = ColumnButtons[column_id - 1].sort_column_primary_reversed
		SortableTable.sort_column_primary = sort_column_primary
		SortableTable.sort_column_primary_reversed = sort_column_primary_reversed
		
		var count = 1
		for ColumnButton in ColumnButtons:

			if count != column_id:
				ColumnButton.primary_sort_column = false
				ColumnButton.sort_column_primary_reversed = false
				
			count += 1
	
	# column set to be the secondary sort column	
	if ColumnButtons[column_id - 1].secondary_sort_column:
		sort_column_secondary = column_id
		sort_column_secondary_reversed = ColumnButtons[column_id - 1].sort_column_secondary_reversed
		SortableTable.sort_column_secondary = sort_column_secondary
		SortableTable.sort_column_secondary_reversed = sort_column_secondary_reversed
	
	var count = 1
	for ColumnButton in ColumnButtons:
		
		# highlight the primary column
		if ColumnButton.primary_sort_column == true:
			RowContainerFilled.highlight_column(sort_column_primary)
			RowContainerEmpty.highlight_column(sort_column_primary)
		
		# show the correct icon	
		if ColumnButton.secondary_sort_column == true:
			ColumnButton.show_correct_icon()
		
		# reset all buttons that are not used anymore for sorting
		if count != sort_column_primary and count != sort_column_secondary:
			ColumnButton.reset_button()
		count += 1
	
	# sort the table
	RowContainerFilled.sort_table(column_id)
	
	# row array updaten
	
	# update the sortable rows array of RowContainerFilled to ensure selection works correct and row backgroundcolor is also correct
	RowContainerFilled.update_sortable_rows_array()
	RowContainerFilled.update_ids_of_rows()



func _on_VBox_TopRow_Content_resized():
	if ColumnButtons.size() > 0:
		#expand_last_column_if_space_available ()
		pass
		
		

