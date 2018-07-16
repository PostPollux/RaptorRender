

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

# signals
signal refresh_table_content
signal something_just_selected
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
	var row = RowContainerFilled.initialize_row(id)
	RowContainerFilled.update_positions_of_rows()
	RowContainerEmpty.update_positions_of_empty_rows()


func set_row_color(row, color):
	RowContainerFilled.set_row_color(row, color)


func set_row_color_by_string(row, color_string):
	RowContainerFilled.set_row_color_by_string(row, color_string)




################
### handle cells
################

# first row and column is 1, not 0
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
	return RowContainerFilled.SortableRows[row - 1].CellsMarginContainerArray[column - 1]




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




#############
### Scrolling
#############

func _on_SortableTable_gui_input(ev):
			
	if ev.is_action_pressed("ui_mouse_wheel_up_or_down"):
		if Input.is_key_pressed(KEY_SHIFT) or Input.is_key_pressed(KEY_CONTROL):
			RowScrollContainer.scroll_vertical = previous_scroll_vertical
		else:
			self.scroll_horizontal = previous_scroll_horizontal


func _on_SortableTable_draw():
	previous_scroll_horizontal = self.scroll_horizontal
	previous_scroll_vertical = RowScrollContainer.scroll_vertical




################
### Context Menu
################

func emit_ContextMenu_signal():
	emit_signal("context_invoked")


