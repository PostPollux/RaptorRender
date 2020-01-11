#///////////////#
# SortableTable #
#///////////////#

# SortableTable is a handy new UI Element build from scratch using availiable Godot Control nodes.
# It's basically a table that can display data sets in rows which can be sorted by clicking the column names on the top.
# For sorting it supports primary and secondary sort criteria. To change the sencondary one, just shift + click on the column name.
#
# The content of a cell can be just everything as the "set_cell_content()" function expects a node that will be added as a child to the cell.
# But how to sort a table where the cells could be everything? That's why there is also a "set_cell_sort_value()" function.
# Triggering a sort will compare all the sort values of the cells in the given column.
# For example: The cell could visually show a progressbar. Now to sort this progress column the sort value of the cell should be set to the progress value which is a number and easily sortable. 
# 
# Structure of SortableTable:
# On the top there is a TopRow with all the column names that can be clicked to sort the table.
# Then there is a ScrollContainer holding both, RowContainerFilled and RowContainerEmpty.
# RowContainerFilled contains the rows that actually show a data set, whereas RowContainerEmpty only visually fills up the available space with empty color alternating rows.


extends ScrollContainer

class_name SortableTable


### PRELOAD RESOURCES

### SIGNALS
signal refresh_table_content
signal something_just_selected
signal selection_cleared
signal context_invoked

### ONREADY VARIABLES
onready var TopRow : SortableTableTopRow = $"VBox_TopRow_Content/TopRow"
onready var RowScrollContainer : ScrollContainer = $"VBox_TopRow_Content/RowScrollContainer"
onready var RowContainerFilled = $"VBox_TopRow_Content/RowScrollContainer/VBoxContainer/RowContainerFilled"
onready var RowContainerEmpty = $ "VBox_TopRow_Content/RowScrollContainer/VBoxContainer/ClipContainerForEmptyRows/RowContainerEmpty"
onready var AutoScrollTween : Tween = $"AutoScrollTween"

### EXPORTED VARIABLES

# variables needed for sorting
export (int) var sort_column_primary : int = 1
export (int) var sort_column_secondary : int = 2

# some SortableTable settings
export (bool) var columns_resizable : bool = true

# row height
export (int) var row_height : int = 30

# color variables
export (Color) var row_color : Color = Color("3c3c3c")
export (Color) var row_color_selected : Color = Color("956248")
export (float) var row_brightness_difference : float = 0.05
export (float) var hover_brightness_boost : float = 0.1

# id needed in the registring function of the RaptorRender autoload script
export (String) var table_id : String = "custom id"

### VARIABLES

var sort_column_primary_reversed : bool = false
var sort_column_secondary_reversed : bool = false

# column names and width arrays
var column_names : Array = []
var column_widths : Array = []

# variables needed for scrolling
var previous_scroll_horizontal : int = 0
var previous_scroll_vertical : int = 0
var shift_ctrl_plus_scroll : bool = false




########## FUNCTIONS ##########


func _ready() -> void:
	
	# connect signals
	TopRow.connect("sort_invoked", self, "sort")
	TopRow.connect("column_resized", self, "set_column_width")
	TopRow.connect("column_highlighted", self, "highlight_column")
	TopRow.connect("primary_sort_column_updated", self, "update_primary_sort_column")
	TopRow.connect("secondary_sort_column_updated", self, "update_secondary_sort_column")
	RowContainerEmpty.connect("selection_cleared", self, "emit_selection_cleared_signal")
	
	register_table()
	
	generate_table()
	


func _input(event) -> void:
	
	# save the position of the vertical scroll as soon as shift or control is pressed
	if Input.is_action_just_pressed("ui_shift") or Input.is_action_just_pressed("ui_ctrl") :
		previous_scroll_vertical = RowScrollContainer.scroll_vertical


################
### manage table
################

func set_columns (init_column_names : Array, init_column_widths : Array) -> void:
	
	if init_column_names.size() == 0:
		print ("Error. A Sortable Table needs at least one column.")
	elif init_column_names.size() != init_column_widths.size():
		print ("Error. Numbers of column names and respective column widhts does not match.")
	else:
		column_names = init_column_names.duplicate()
		column_widths = init_column_widths.duplicate()
		
		if is_instance_valid(TopRow):
			generate_table()


func generate_table () -> void:
	
	if column_names.size() != 0:
		
		# set up row heights
		RowContainerFilled.row_height = row_height
		RowContainerEmpty.row_height = row_height
		
		# set top row
		TopRow.column_names = column_names
		TopRow.column_widths = column_widths 
		TopRow.sort_column_primary = sort_column_primary
		TopRow.sort_column_primary_reversed = sort_column_primary_reversed
		TopRow.sort_column_secondary = sort_column_secondary
		TopRow.sort_column_secondary_reversed = sort_column_secondary_reversed
		TopRow.columns_resizable = columns_resizable
		TopRow.generate_top_row()
		
		# add empty rows
		RowContainerEmpty.create_initial_empty_rows()





# register to RaptorRender script
func register_table() -> void:
	if RaptorRender != null:
		RaptorRender.register_table(self)


func refresh() -> void:
	RowContainerFilled.reset_all_row_colors_to_default()
	emit_signal("refresh_table_content")
	RowContainerFilled.update_selection()



# This function makes sure that a table looks visually the same as another one. It does not copy the content.
# It syncs stuff like column names, column widths, sorting information, selections, scroll states etc.
# Until now only used for table syncing of the different pool tables.
func viusally_sync_with_other_SortableTable(SourceTable : SortableTable) -> void:
	
	column_names = SourceTable.column_names
	column_widths = SourceTable.column_widths
	sort_column_primary = SourceTable.sort_column_primary
	sort_column_primary_reversed = SourceTable.sort_column_primary_reversed
	sort_column_secondary = SourceTable.sort_column_secondary
	sort_column_secondary_reversed = SourceTable.sort_column_secondary_reversed 
	RowContainerFilled.selected_row_ids = SourceTable.RowContainerFilled.selected_row_ids
	
	
	# highlight the correct colors
	highlight_column(sort_column_primary)
	
	# transfer the sort column settings from SortableTable to its TopRow
	TopRow.sort_column_primary = sort_column_primary
	TopRow.sort_column_secondary = sort_column_secondary
	TopRow.sort_column_primary_reversed = sort_column_primary_reversed
	TopRow.sort_column_secondary_reversed = sort_column_secondary_reversed
	
	# make sure the TopRow Buttons have the correct sorting icon and the correct size
	var count : int = 1
	
	for button in TopRow.ColumnButtons:
		
		button.rect_min_size.x = column_widths[count - 1]
		
		
		if count == sort_column_primary:
			button.primary_sort_column = true
			button.sort_column_primary_reversed = sort_column_primary_reversed
			button.show_correct_icon()
		
		elif count == sort_column_secondary:
			button.secondary_sort_column= true
			button.sort_column_secondary_reversed = sort_column_secondary_reversed
			button.show_correct_icon()
		
		else:
			button.reset_button()
		
		count += 1
		
	# make sure the widths of the column are adjusted
	for col in range(1, column_widths.size()): 
		set_column_width(col, column_widths[col - 1])
		
	# update selection
	RowContainerFilled.update_selection()
	
	# update scroll values. Vertical is reset to 0 as there probably will be different data in the table
	previous_scroll_horizontal = SourceTable.scroll_horizontal
	scroll_horizontal = SourceTable.scroll_horizontal
	RowScrollContainer.scroll_vertical = 0
	



func sort() -> void:
	RowContainerFilled.sort_rows()
	RowContainerFilled.update_sortable_rows_array()
	RowContainerFilled.update_id_position_dict()
	RowContainerFilled.update_positions_of_rows()


func update_primary_sort_column(column : int, is_reversed : bool) -> void:
	sort_column_primary = column
	sort_column_primary_reversed = is_reversed


func update_secondary_sort_column(column : int, is_reversed : bool) -> void:
	sort_column_secondary = column
	sort_column_secondary_reversed = is_reversed



##################
### handle columns
##################

func set_column_width(column : int, width : int) -> void:
	RowContainerFilled.set_column_width( column, width)
	RowContainerEmpty.set_column_width( column, width)


func highlight_column(column : int) -> void:
	RowContainerFilled.highlight_column(column)
	RowContainerEmpty.highlight_column(column)



###############
### handle rows
###############

func create_row(id) -> void:
	
	RowContainerFilled.initialize_row(id)
	RowContainerFilled.update_positions_of_rows()
	
	RowContainerEmpty.remove_empty_row()
	RowContainerEmpty.update_positions_of_empty_rows()


# remove a specific row
func remove_row(id) -> void:
	
	RowContainerFilled.remove_row(id)
	RowContainerFilled.update_positions_of_rows()
	
	RowContainerEmpty.create_empty_row()
	RowContainerEmpty.update_positions_of_empty_rows()


func clear_table() -> void:
	for id in RowContainerFilled.id_position_dict.keys():
		remove_row(id)


func set_row_color(row : int, color : Color) -> void:
	RowContainerFilled.set_row_color(row, color)


func mark_erroneous(row : int, erroneous : bool) -> void:
	RowContainerFilled.mark_erroneous(row, erroneous)



################
### handle cells
################

# first row and column is 1, not 0
# content has to be a node that can be added as a child to the cell
func set_cell_content(row : int, column : int, child : Node) -> void: 
	RowContainerFilled.set_cell_content(row, column, child)



# first row and column is 1, not 0
func set_cell_sort_value(row : int, column : int, value) -> void:
	RowContainerFilled.set_cell_sort_value(row, column, value)



# first row and column is 1, not 0
func set_LABEL_cell(row : int, column : int, text : String) -> void:
	var CellLabel = Label.new()
	CellLabel.text = text
	set_cell_content(row, column, CellLabel)
	set_cell_sort_value(row, column, text.to_lower())



# first row and column is 1, not 0
func set_LABEL_cell_with_custom_sort(row : int, column : int, text : String, sort_value) -> void:
	var CellLabel = Label.new()
	CellLabel.text = text
	set_cell_content(row, column, CellLabel)
	set_cell_sort_value(row, column, sort_value)



# first row and column is 1, not 0
func update_LABEL_cell(row : int, column : int, text : String) -> void:
	
	var TableRow : SortableTableRow = get_row_by_position(row)
	
	if ( TableRow.sort_values[column] != text):
		
		# get reference to the cell
		var Cell : Node = get_cell( row, column )
		var CellLabel : Label = Cell.get_child(0)
		
		# change the cell value
		CellLabel.text = text
		
		# update sort_value
		set_cell_sort_value(row, column, text.to_lower())



# first row and column is 1, not 0
func update_LABEL_cell_with_custom_sort(row : int, column : int, text : String, sort_value) -> void:
	
	var TableRow : SortableTableRow = get_row_by_position(row)
	
	if ( TableRow.sort_values[column] != sort_value):
		
		# get reference to the cell
		var Cell : Node = get_cell( row, column )
		var CellLabel : Label = Cell.get_child(0)
		
		# change the cell value
		CellLabel.text = text
		
		# update sort_value
		set_cell_sort_value(row, column, sort_value)



# first row and column is 1, not 0
# this makes sense to use, if the value that goes into the cell is heavy to calculate
func compare_sort_values_to_check_if_cell_needs_update(row : int, column : int, sort_value) -> bool:
	
	var TableRow : SortableTableRow = get_row_by_position(row)
	
	return TableRow.sort_values[column] != sort_value




###############################
### get elements from the table
###############################

# first row is 1, not 0
func get_row_by_position(pos) -> SortableTableRow:
	return RowContainerFilled.SortableRows[pos - 1]



# first row and cell is 1, not 0
func get_cell(row, column) -> Node:
	return RowContainerFilled.SortableRows[row - 1].CellsArray[column - 1]




#############
### Selection
#############

func select_by_id(id) -> void:
	RowContainerFilled.clear_selection()
	RowContainerFilled.add_id_to_selection(id)
	RowContainerFilled.update_selection()
	
	
func clear_selection() -> void:
	RowContainerFilled.clear_selection()
	
	
func get_selected_ids() -> Array:
	return RowContainerFilled.selected_row_ids


func set_selected_ids(selected_ids : Array) -> void:
	RowContainerFilled.selected_row_ids = selected_ids
	RowContainerFilled.update_selection()


func emit_selection_signal(last_selected) -> void:
	emit_signal("something_just_selected", last_selected)


func emit_selection_cleared_signal() -> void:
	emit_signal("selection_cleared")


#############
### Scrolling
#############


func scroll_to_row (row_id) -> void:
	
	var row_position = RowContainerFilled.id_position_dict[row_id]
	var position_of_row_in_px = row_position * row_height
	
	var scroll_value = position_of_row_in_px - (RowScrollContainer.rect_size.y / 2)

	AutoScrollTween.interpolate_property(RowScrollContainer, "scroll_vertical", RowScrollContainer.scroll_vertical, scroll_value, 0.5,Tween.TRANS_QUART,Tween.EASE_OUT, 0)
	AutoScrollTween.start()



func _on_SortableTable_gui_input(event: InputEvent) -> void:
	
	if Input.is_key_pressed(KEY_SHIFT) or Input.is_key_pressed(KEY_CONTROL):
		RowScrollContainer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	else:
		RowScrollContainer.mouse_filter = Control.MOUSE_FILTER_STOP
	
	if event.is_action_pressed("ui_mouse_wheel_up_or_down"):
		
		if Input.is_key_pressed(KEY_SHIFT) or Input.is_key_pressed(KEY_CONTROL):
			shift_ctrl_plus_scroll = true
			RowScrollContainer.scroll_vertical = previous_scroll_vertical
		else:
			shift_ctrl_plus_scroll = false
			self.scroll_horizontal = previous_scroll_horizontal



func _on_RowScrollContainer_gui_input(event: InputEvent) -> void:
	
	if Input.is_key_pressed(KEY_SHIFT) or Input.is_key_pressed(KEY_CONTROL):
		RowScrollContainer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	else:
		RowScrollContainer.mouse_filter = Control.MOUSE_FILTER_STOP
		



func _on_SortableTable_draw() -> void:
	
	if !shift_ctrl_plus_scroll and !Input.is_mouse_button_pressed(BUTTON_LEFT):
		self.scroll_horizontal = previous_scroll_horizontal
		
	previous_scroll_horizontal = self.scroll_horizontal



################
### Context Menu
################

func emit_ContextMenu_signal() -> void:
	emit_signal("context_invoked")




