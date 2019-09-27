#////////#
# TopRow #
#////////#

# The TopRow shows the names of the columns and provides the functionality to trigger the table to sort.
# It consists of a button for each column and splitters inbetween these buttons. The splitters can be dragged to risize that column. 
# If a button is pressed, the sort criteria of SortableTable gets set and a sort will happen.
# The TopRow is supposed to always be on top, thus it shouldn't be in the scroll container that contains the actual rows of the table.


extends MarginContainer

class_name SortableTableTopRow


### PRELOAD RESOURCES
var ColumnSplitterRes = preload("res://RaptorRender/GUI/SortableTable/TopRow/ColumnSplitter.tscn")
var ColumnButtonRes = preload("res://RaptorRender/GUI/SortableTable/TopRow/ColumnButton.tscn")

### SIGNALS
signal sort_invoked
signal column_resized
signal column_highlighted
signal primary_sort_column_updated
signal secondary_sort_column_updated

### ONREADY VARIABLES

### EXPORTED VARIABLES

### VARIABLES

# variables for defining the buttons and splitters
var Splitters : Array = []
var ColumnButtons : Array = []

var column_names : Array = []
var column_widths : Array = []

# variables for dragging and resizing the columns
var columns_resizable : bool = true
var dragging_splitter : bool = false
var dragging_splitter_id : int
var mouse_position_x_before_dragging : int
var min_size_of_column_before_dragging : int

# variables for sort functionality
var sort_column_primary : int = 1
var sort_column_secondary : int = 2
var sort_column_primary_reversed : bool = false
var sort_column_secondary_reversed : bool = false

var just_initialized : bool = false # variable for workaround





########## FUNCTIONS ##########


func _process(delta):
	
	if dragging_splitter:
		resize_column_by_drag()
	
	# small workaround needed since Godot 3.1 (it will resize the first collumn one time after the first draw the refresh all top buttons which will then show the little arrows)
	if just_initialized:
		ColumnButtons[0].rect_min_size.x = column_widths[0] - 1
		column_widths[0] = column_widths[0] - 1
		just_initialized = false



##########################
### generating the top row
##########################

func generate_top_row():
	
	# delete existing nodes
	for CurrentNode in $HBoxContainer.get_children():
		CurrentNode.queue_free()
	
	var count : int = 1
	
	# create buttons and splitters
	for column_name in column_names:
		
		# column button
		var ColumnButton : SortableTableCollumnButton = ColumnButtonRes.instance()
		ColumnButton.column_button_name = column_name
		ColumnButton.id = count
		ColumnButton.rect_min_size.x = column_widths[count - 1]
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
		
		# splitter
		var Splitter = ColumnSplitterRes.instance()
		Splitter.splitter_id = count
		Splitter.active = columns_resizable
		if columns_resizable:
			Splitter.connect("just_clicked", self, "splitter_just_clicked")
		Splitters.append(Splitter)
		$HBoxContainer.add_child(Splitter)
		
		count += 1
	
	
	# offset first collumn by one pixel (used for the workaround below)
	ColumnButtons[0].rect_min_size.x = column_widths[0] + 1
	column_widths[0] = column_widths[0] + 1
	
	just_initialized = true




########################
### resizing the columns
########################

func splitter_just_clicked(splitter_id):
	dragging_splitter_id = splitter_id
	mouse_position_x_before_dragging = get_viewport().get_mouse_position().x
	min_size_of_column_before_dragging = column_widths[splitter_id - 1]
	dragging_splitter = true


func resize_column_by_drag():
	
	# Left mouse button still pressed
	if Input.is_mouse_button_pressed(1):
		
		# resize the ColumnButton of the TopRow
		var mouse_pos_x : int = get_viewport().get_mouse_position().x
		var calculated_size : int = min_size_of_column_before_dragging + (mouse_pos_x - mouse_position_x_before_dragging)
		if calculated_size < 12:
			calculated_size = 12
		ColumnButtons[dragging_splitter_id - 1].rect_min_size.x = calculated_size
		column_widths[dragging_splitter_id - 1] = calculated_size
		
		# apply the size of the ColumnButton of the TopRow to all the rows of the table
		var column_width : int = column_widths[dragging_splitter_id - 1]
		
		emit_signal("column_resized", dragging_splitter_id, column_width)
	
	
	
	# Left mouse button released
	else:
		
		# apply the size of the ColumnButton of the TopRow to all the rows of the table
		var column_width : int = ColumnButtons[dragging_splitter_id - 1].rect_size.x
		
		emit_signal("column_resized", dragging_splitter_id, column_width)
		
		# stop dragging logic
		dragging_splitter = false




##############################
### Button clicked for sorting
##############################

func column_button_pressed(column_id):
	
	# column set to be the primary sort column
	if ColumnButtons[column_id - 1].primary_sort_column:
		sort_column_primary = column_id
		sort_column_primary_reversed = ColumnButtons[column_id - 1].sort_column_primary_reversed
		emit_signal("primary_sort_column_updated", sort_column_primary, sort_column_primary_reversed)
		
		var count : int = 1
		for ColumnButton in ColumnButtons:
		
			if count != column_id:
				ColumnButton.primary_sort_column = false
				ColumnButton.sort_column_primary_reversed = false
				
			count += 1
	
	# column set to be the secondary sort column
	if ColumnButtons[column_id - 1].secondary_sort_column:
		sort_column_secondary = column_id
		sort_column_secondary_reversed = ColumnButtons[column_id - 1].sort_column_secondary_reversed
		emit_signal("secondary_sort_column_updated", sort_column_secondary, sort_column_secondary_reversed)
		
	var count : int = 1
	for ColumnButton in ColumnButtons:
		
		# highlight the primary column
		if ColumnButton.primary_sort_column == true:
			emit_signal("column_highlighted", sort_column_primary)
		
		# show the correct icon
		if ColumnButton.secondary_sort_column == true:
			ColumnButton.show_correct_icon()
		
		# reset all buttons that are not used anymore for sorting
		if count != sort_column_primary and count != sort_column_secondary:
			ColumnButton.reset_button()
		count += 1
	
	# sort the table
	emit_signal("sort_invoked")
