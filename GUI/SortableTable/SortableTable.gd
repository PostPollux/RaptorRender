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


# column names and width arrays
export (Array, String) var column_names = []
export (Array, int) var column_widths = []

# variables needed for sorting
export (int) var sort_column_primary : int = 1
export (int) var sort_column_secondary : int = 2
var sort_column_primary_reversed : bool = false
var sort_column_secondary_reversed : bool = false

# row height
export (int) var row_height : int = 30

# color variables
export (Color) var row_color : Color = Color("3c3c3c")
export (Color) var row_color_selected : Color = Color("956248")
export (Color) var row_color_red : Color = Color("643f3b")
export (Color) var row_color_blue : Color = Color("3b5064")
export (Color) var row_color_green : Color = Color("3b5a3b")
export (Color) var row_color_yellow : Color = Color("585a3b")
export (Color) var row_color_black : Color = Color("1d1d1d")
export (float) var row_brightness_difference : float = 0.05
export (float) var hover_brightness_boost : float = 0.1

# id needed in the registring function of the RaptorRender autoload script
export (String) var table_id : String = "custom id"

# references to child nodes
onready var TopRow : SortableTableTopRow = $"VBox_TopRow_Content/TopRow"
onready var RowScrollContainer : ScrollContainer = $"VBox_TopRow_Content/RowScrollContainer"
onready var RowContainerFilled = $"VBox_TopRow_Content/RowScrollContainer/VBoxContainer/RowContainerFilled"
onready var RowContainerEmpty = $ "VBox_TopRow_Content/RowScrollContainer/VBoxContainer/ClipContainerForEmptyRows/RowContainerEmpty"
onready var AutoScrollTween : Tween = $"AutoScrollTween"

# variables needed for scrolling
var previous_scroll_horizontal : int = 0
var previous_scroll_vertical : int = 0
var shift_ctrl_plus_scroll : bool = false

# signals
signal refresh_table_content
signal something_just_selected
signal selection_cleared
signal context_invoked




func _ready():
	
	register_table()
	
	RowContainerFilled.row_height = row_height
	
	# set up top row
	set_top_row()
	
	# set up empty rows
	RowContainerEmpty.row_height = row_height
	RowContainerEmpty.create_initial_empty_rows()
	
	
	
	
	# connect signals
	TopRow.connect("sort_invoked", self, "sort")
	RowContainerEmpty.connect("selection_cleared", self, "emit_selection_cleared_signal")


func _input(event):
	
	# save the position of the vertical scroll as soon as shift or control is pressed
	if Input.is_action_just_pressed("ui_shift") or Input.is_action_just_pressed("ui_ctrl") :
		previous_scroll_vertical = RowScrollContainer.scroll_vertical
	


################
### manage table
################

func set_top_row():
	TopRow.column_names = column_names
	TopRow.column_widths = column_widths 
	TopRow.sort_column_primary = sort_column_primary
	TopRow.sort_column_secondary = sort_column_secondary
	
	TopRow.generate_top_row()


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


##################
### handle columns
##################

func set_column_width(column : int, width : int):
	RowContainerFilled.set_column_width( column, width)
	RowContainerEmpty.set_column_width( column, width)



###############
### handle rows
###############

func create_row(id):
	
	RowContainerFilled.initialize_row(id)
	RowContainerFilled.update_positions_of_rows()
	
	RowContainerEmpty.remove_empty_row()
	RowContainerEmpty.update_positions_of_empty_rows()


# remove a specific row
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


func scroll_to_row (row_id):
	
	var row_position = RowContainerFilled.id_position_dict[row_id]
	var position_of_row_in_px = row_position * row_height
	
	var scroll_value = position_of_row_in_px - (RowScrollContainer.rect_size.y / 2)

	AutoScrollTween.interpolate_property(RowScrollContainer, "scroll_vertical", RowScrollContainer.scroll_vertical, scroll_value, 0.5,Tween.TRANS_QUART,Tween.EASE_OUT, 0)
	AutoScrollTween.start()



func _on_SortableTable_gui_input(ev):
			
	
	if ev.is_action_pressed("ui_mouse_wheel_up_or_down"):

		if Input.is_key_pressed(KEY_SHIFT) or Input.is_key_pressed(KEY_CONTROL):
			shift_ctrl_plus_scroll = true
			RowScrollContainer.scroll_vertical = previous_scroll_vertical
		else:
			shift_ctrl_plus_scroll = false
			self.scroll_horizontal = previous_scroll_horizontal



func _on_SortableTable_draw():
	
	if !shift_ctrl_plus_scroll and !Input.is_mouse_button_pressed(BUTTON_LEFT):
		self.scroll_horizontal = previous_scroll_horizontal
		
	previous_scroll_horizontal = self.scroll_horizontal
	



################
### Context Menu
################

func emit_ContextMenu_signal():
	emit_signal("context_invoked")


