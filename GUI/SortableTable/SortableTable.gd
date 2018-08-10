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



# column names and width arrays
export (Array, String) var column_names
export (Array, int) var column_widths_initial

# variables needed for sorting
export (int) var sort_column_primary = 1
export (int) var sort_column_secondary = 2
var sort_column_primary_reversed = false
var sort_column_secondary_reversed = false

# row height
export (int) var row_height = 30

# color variables
export (Color) var row_color = Color("3c3c3c")
export (Color) var row_color_selected = Color("956248")
export (Color) var row_color_red = Color("643f3b")
export (Color) var row_color_blue = Color("3b5064")
export (Color) var row_color_green = Color("3b5a3b")
export (Color) var row_color_yellow = Color("585a3b")
export (Color) var row_color_black = Color("1d1d1d")
export (float) var row_brightness_difference = 0.05
export (float) var hover_brightness_boost = 0.1

# id needed in the registring function of the RaptorRender autoload script
export (String) var table_id = "custom id"

# references to child nodes
onready var RowScrollContainer = $"VBox_TopRow_Content/RowScrollContainer"
onready var RowContainerFilled = $"VBox_TopRow_Content/RowScrollContainer/VBoxContainer/RowContainerFilled" 
onready var RowContainerEmpty = $ "VBox_TopRow_Content/RowScrollContainer/VBoxContainer/ClipContainerForEmptyRows/RowContainerEmpty"

# variables needed for scrolling
var previous_scroll_horizontal = 0
var previous_scroll_vertical = 0
var shift_ctrl_plus_scroll = false

# signals
signal refresh_table_content
signal something_just_selected
signal selection_cleared
signal context_invoked




func _ready():
	
	register_table()






################
### manage table
################

# register to RaptorRender script
func register_table():
	if RaptorRender != null:
		RaptorRender.register_table(self)


func refresh():
	RowContainerFilled.reset_all_row_colors_to_default()
	emit_signal("refresh_table_content")
	RowContainerFilled.update_selection()


func sort():
	
	RowContainerFilled.sort_rows()
	RowContainerFilled.update_sortable_rows_array()
	RowContainerFilled.update_id_position_dict()
	RowContainerFilled.update_positions_of_rows()




###############
### handle rows
###############

func create_row(id):
	
	RowContainerFilled.initialize_row(id)
	RowContainerFilled.update_positions_of_rows()
	
	RowContainerEmpty.remove_empty_row()
	RowContainerEmpty.update_positions_of_empty_rows()



func remove_row(id):
	
	RowContainerFilled.remove_row(id)
	RowContainerFilled.update_positions_of_rows()
	
	RowContainerEmpty.create_empty_row()
	RowContainerEmpty.update_positions_of_empty_rows()



func set_row_color(row, color):
	RowContainerFilled.set_row_color(row, color)


func set_row_color_by_string(row, color_string):
	RowContainerFilled.set_row_color_by_string(row, color_string)




################
### handle cells
################

# first row and column is 1, not 0
# content has to be a node that can be added as a child to the cell
func set_cell_content(row, column, child): 
	RowContainerFilled.set_cell_content(row, column, child)


# first row and column is 1, not 0
func set_cell_sort_value(row, column, value):
	RowContainerFilled.set_cell_sort_value(row, column, value)




###############################
### get elements from the table
###############################

# first row is 1, not 0
func get_row_by_position(pos):
	return RowContainerFilled.SortableRows[pos - 1]



# first row and cell is 1, not 0
func get_cell(row, column):
	return RowContainerFilled.SortableRows[row - 1].CellsArray[column - 1]




#############
### Selection
#############

func select_by_id(id):
	RowContainerFilled.clear_selection()
	RowContainerFilled.add_id_to_selection(id)
	RowContainerFilled.update_selection()
	
	
func clear_selection():
	RowContainerFilled.clear_selection()
	
	
func get_selected_ids():
	return RowContainerFilled.selected_row_ids


func emit_selection_signal(last_selected):
	emit_signal("something_just_selected", last_selected)


func emit_selection_cleared_signal():
	emit_signal("selection_cleared")


#############
### Scrolling
#############

func _on_SortableTable_gui_input(ev):
			
	
	if ev.is_action_pressed("ui_mouse_wheel_up_or_down"):

		if Input.is_key_pressed(KEY_SHIFT) or Input.is_key_pressed(KEY_CONTROL):
			shift_ctrl_plus_scroll = true
			RowScrollContainer.scroll_vertical = previous_scroll_vertical
		else:
			shift_ctrl_plus_scroll = false
			self.scroll_horizontal = previous_scroll_horizontal
			print(previous_scroll_horizontal)
			print(self.scroll_horizontal )


func _on_SortableTable_draw():
	if !shift_ctrl_plus_scroll:
		self.scroll_horizontal = previous_scroll_horizontal
	
	previous_scroll_horizontal = self.scroll_horizontal
	previous_scroll_vertical = RowScrollContainer.scroll_vertical




################
### Context Menu
################

func emit_ContextMenu_signal():
	emit_signal("context_invoked")


