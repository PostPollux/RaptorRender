#////////////////////#
# RowContainerFilled #
#////////////////////#

# A VBoxContainer that holds all the rows that contain data. 
# Basic row handling and the sorting algorithm is part of this script file.



extends VBoxContainer

class_name SortableTableRowContainerFilled


var row_height : int

# Array to hold all current rows. It get's updated when sorting, so it always reflects the current order of rows
var SortableRows : Array = []

# Dictionary that maps row ids to the current position in the sorted table
var id_position_dict : Dictionary = {} 

# Array for selections. It hold's the ids, not the rows themselves
var selected_row_ids : Array = []

# references to other nodes of sortable table
onready var SortableTable : SortableTable = $"../../../.."
onready var TopRow : SortableTableTopRow = $"../../../TopRow"
onready var RowScrollContainer : ScrollContainer = $"../.."
onready var RowContainerEmpty = $"../ClipContainerForEmptyRows/RowContainerEmpty"

# preload Resources
var SortableTableRowRes = preload("res://GUI/SortableTable/SortableTableRow.tscn")

# variables used for selection handling
var row_pos_of_last_middle_mouse_click : int  = 0




func _ready():
	
	row_height = SortableTable.row_height
	
	for SortableRow in SortableRows:
		SortableRow.set_row_height(row_height)



func _process(delta : float) -> void:
	if Input.is_action_just_pressed("select_all"):
		var mouse_pos : Vector2 = get_viewport().get_mouse_position()
		var row_scroll_container_rect : Rect2 = RowScrollContainer.get_global_rect()
		if row_scroll_container_rect.has_point(mouse_pos):
			select_all()









###############
### manage rows
###############


# Update the SortableRows array to reflect the current order of the sorted table
func update_sortable_rows_array():
	SortableRows = self.get_children()


# Update the "id_position_dict". This dictionary is used to quickly look up the position of a row by it's id.
func update_id_position_dict():
	for Row in SortableRows:
		id_position_dict[Row.id] = Row.get_index() + 1


# sets the "row_position" variable of each row, so that it knows which background color (even or odd) to show. 
func update_positions_of_rows():
	var count : int = 1
	for Row in SortableRows:
		Row.set_row_position(count)
		count += 1


# creating a row
func initialize_row(id) -> SortableTableRow:
	
	var Row : SortableTableRow = SortableTableRowRes.instance()
	
	# set variables. (id, amount of cells , row height)
	Row.id = id
	Row.column_count = TopRow.ColumnButtons.size()
	Row.row_height = SortableTable.row_height
	
	# connect signals to enable selecting and invoking a context menu
	Row.connect("row_clicked", self, "select_SortableRows")
	Row.connect("row_clicked_middle", self, "select_SortableRows_middle_mouse")
	Row.connect("row_clicked_rmb", self, "open_context_menu")
	Row.connect("drag_select", self, "drag_select_SortableRows")
	Row.connect("drag_select_middle", self, "drag_select_SortableRows_middle_mouse")
	
	# initialize the array for the sort values with correct amount of empty strings. Important, otherwise it would crash
	for column in TopRow.ColumnButtons:
		Row.sort_values.append("")
	Row.sort_values.append("")
	
	# create the cells
	Row.create_cells()
	if TopRow:
		Row.modulate_cell_color(TopRow.sort_column_primary, Color("18ffffff"))
		
		var count : int = 1
		for ColumnButton in TopRow.ColumnButtons:
			
			# apply the size of the ColumnButtons of the TopRow to the cells
			Row.set_cell_width(count, ColumnButton.rect_min_size.x)
			count += 1
	
	# add the row to the tree and to the array 
	self.add_child(Row)
	SortableRows.append(Row)
	
	# make an entry in the id_position_dict
	id_position_dict[id] = Row.get_index() + 1
	
	return Row



# removing a specific row
func remove_row(id):
	
	# remove from selection
	selected_row_ids.erase(id)
	
	# remove the node
	SortableRows[ id_position_dict[id] - 1 ].free()
	
	# remove the references in the Sortable Rows Array
	SortableRows.remove( id_position_dict[id] - 1  )
	
	# remove the entry in the dict
	id_position_dict.erase( id )
	
	# update the dict to reflect correct positions of the rows
	update_id_position_dict()






##############
### Row Colors
##############


func set_row_color(row : int, color : Color):
	if row >= 1:
		SortableRows[row - 1].set_row_color(color)


func set_row_color_by_string(row : int, color_string : String):
	if row >= 1:
		SortableRows[row - 1].set_row_color_by_string(color_string)


func reset_all_row_colors_to_default():
	for Row in SortableRows:
		Row.set_row_color_by_string("default")


func highlight_column(column : int):
	if TopRow:
		if column <= TopRow.ColumnButtons.size() and column > 0:
			for i in range(1, TopRow.ColumnButtons.size() + 1) :
				for Row in SortableRows:
					Row.modulate_cell_color(i, Color("00ffffff"))
			for Row in SortableRows:
				Row.modulate_cell_color(column, Color("18ffffff"))





##############
### Sort Rows
##############


func sort_rows():
	
	var primary : int = SortableTable.sort_column_primary
	var secondary : int = SortableTable.sort_column_secondary
	
	var sort_array : Array = []
	
	# create the array to sort
	for Row in SortableRows:
	
		sort_array.append([Row, Row.sort_values[primary], Row.sort_values[secondary], Row.id ] )
	
	# sort the array
	sort_array.sort_custom ( self, "raptor_render_custom_sort" )
	
	# update the table by moving the row nodes
	var position : int = 0
	
	for row in sort_array:
		self.move_child(row[0], position)
		position += 1



func raptor_render_custom_sort(a,b):
	
	# a custom sort function must return true if the first argument (a) is less than the second (b)
	# to ensure that the rows are not jumping when refreshing and both, primary and secondary values are the same, it also uses the id to sort
	
	var primary_reversed : bool = SortableTable.sort_column_primary_reversed
	var secondary_reversed : bool = SortableTable.sort_column_secondary_reversed
	
	if !primary_reversed:
		
		if !secondary_reversed:
		
		#    case 1: primary different     case 2: primary identical,           case 3: primary and secondary identical
		#                                  but secondary different              -> check for id because this is distinct   
		#                 v                            v                                            v                    
		#
			return   a[1] < b[1]   or   (a[1] == b[1] and a[2] < b[2])   or   (a[1] == b[1] and a[2] == b[2] and a[3] < b[3])
		
		else:
			
			return   a[1] < b[1]   or   (a[1] == b[1] and a[2] > b[2])   or   (a[1] == b[1] and a[2] == b[2] and a[3] < b[3])
			
	else:
		
		if !secondary_reversed:

			return   a[1] > b[1]   or   (a[1] == b[1] and a[2] < b[2])   or   (a[1] == b[1] and a[2] == b[2] and a[3] < b[3])
		
		else:
			
			return   a[1] > b[1]   or   (a[1] == b[1] and a[2] > b[2])   or   (a[1] == b[1] and a[2] == b[2] and a[3] < b[3])






################
### manage cells
################


# first row and column is 1, not 0
func set_cell_content(row : int, column : int, child : Node):
	if row <= SortableRows.size():
		SortableRows[row - 1].set_cell_content(column, child)


# first row and column is 1, not 0
func set_cell_sort_value(row : int, column : int, value):
	if row <= SortableRows.size():
		SortableRows[row - 1].sort_values[column] = value






#############
### Selection
#############


func select_SortableRows(row_position : int):
	
	var ClickedRow : SortableTableRow = SortableRows[row_position - 1]
	
	if Input.is_key_pressed(KEY_CONTROL):
		if ClickedRow.selected == true:
			ClickedRow.set_selected(false)
			selected_row_ids.erase(ClickedRow.id)
		else:
			ClickedRow.set_selected(true)
			selected_row_ids.append(ClickedRow.id)
		
		
	elif Input.is_key_pressed(KEY_SHIFT):
		
		if selected_row_ids.size() > 0:
			
			var previous_selected_row_position : int = 0
			
			for Row in SortableRows:
				if Row.id == selected_row_ids[selected_row_ids.size() - 1]:
					previous_selected_row_position = Row.row_position
						
			if row_position > previous_selected_row_position:
				
				for i in range(previous_selected_row_position, row_position + 1):
					if SortableRows[i-1].selected == false:
						SortableRows[i-1].set_selected(true)
						selected_row_ids.append(SortableRows[i-1].id)
			
			if row_position < previous_selected_row_position:
				
				for i in range(row_position, previous_selected_row_position):
					if SortableRows[i-1].selected == false:
						SortableRows[i-1].set_selected(true)
						selected_row_ids.append(SortableRows[i-1].id)
		else:
			ClickedRow.set_selected(true)
			selected_row_ids.append(ClickedRow.id)
		
	else:
		for Row in SortableRows:
			Row.set_selected(false)
		selected_row_ids.clear()
		
		ClickedRow.set_selected(true)
		selected_row_ids.append(ClickedRow.id)
	
	# emit correct signal
	if selected_row_ids.size() > 0:
		SortableTable.emit_selection_signal( selected_row_ids[selected_row_ids.size() - 1] )
	else:
		SortableTable.emit_selection_cleared_signal()



func select_SortableRows_middle_mouse(row_position : int):
	
	var ClickedRow : SortableTableRow = SortableRows[row_position - 1]
	
	if row_pos_of_last_middle_mouse_click == 0:
		row_pos_of_last_middle_mouse_click = ClickedRow.row_position
		
	if Input.is_key_pressed(KEY_SHIFT):
		
		if selected_row_ids.size() > 0:
			
			if row_position > row_pos_of_last_middle_mouse_click:
				
				for i in range(row_pos_of_last_middle_mouse_click, row_position + 1):
					if SortableRows[i-1].selected == true:
						SortableRows[i-1].set_selected(false)
						selected_row_ids.erase(SortableRows[i-1].id)
			
			if row_position < row_pos_of_last_middle_mouse_click:
				
				for i in range(row_position , row_pos_of_last_middle_mouse_click + 1):
					if SortableRows[i-1].selected == true:
						SortableRows[i-1].set_selected(false)
						selected_row_ids.erase(SortableRows[i-1].id)
		else:
			ClickedRow.set_selected(false)
			selected_row_ids.erase(ClickedRow.id)
		
	else:
		ClickedRow.set_selected(false)
		selected_row_ids.erase(ClickedRow.id)
	
	row_pos_of_last_middle_mouse_click = ClickedRow.row_position
	
	# emit correct signal
	if selected_row_ids.size() > 0:
		SortableTable.emit_selection_signal( selected_row_ids[selected_row_ids.size() - 1] )
	else:
		SortableTable.emit_selection_cleared_signal()




func drag_select_SortableRows(row_position : int):
	
	var DragedRow : SortableTableRow = SortableRows[row_position - 1]
	
	if Input.is_key_pressed(KEY_CONTROL):
		DragedRow.set_selected(false)
		selected_row_ids.erase(DragedRow)
		
		
	elif Input.is_key_pressed(KEY_SHIFT):
		if DragedRow.selected == false:
			DragedRow.set_selected(true)
			selected_row_ids.append(DragedRow.id)
		
	else:
		for Row in SortableRows:
			Row.set_selected(false)
		selected_row_ids.clear()
		
		DragedRow.set_selected(true)
		selected_row_ids.append(DragedRow.id)
	
	if selected_row_ids.size() > 0:
		SortableTable.emit_selection_signal( selected_row_ids[selected_row_ids.size() - 1])



func drag_select_SortableRows_middle_mouse(row_position : int):
	
	var DragedRow : SortableTableRow  = SortableRows[row_position - 1]
	
	DragedRow.set_selected(false)
	selected_row_ids.erase(DragedRow)
	
	if selected_row_ids.size() > 0:
		SortableTable.emit_selection_signal( selected_row_ids[selected_row_ids.size() - 1])




func select_all():
	
	# select or deselect all rows depending on wheter all are already selected or not
	if selected_row_ids.size() != SortableRows.size():
		
		selected_row_ids.clear()
		for Row in SortableRows:
			Row.set_selected(true)
			selected_row_ids.append(Row.id)
			
		SortableTable.emit_selection_signal( selected_row_ids[selected_row_ids.size() - 1 ] )
		
		
	else:
		selected_row_ids.clear()
		
		for Row in SortableRows:
			Row.set_selected(false)
		
		SortableTable.emit_selection_cleared_signal()


func update_selection():
	for Row in SortableRows:
		Row.set_selected(false)
		
	for selected_row_id in selected_row_ids:
		for Row in SortableRows:
			if Row.id == selected_row_id:
				Row.set_selected(true)



func clear_selection():
	
	selected_row_ids.clear()
	
	for Row in SortableRows:
		Row.set_selected(false)



func add_id_to_selection(id):
	selected_row_ids.append(id)






##################
### resize columns
##################


func resize_columns():
	
	var count : int = 1
	
	for ColumnButton in TopRow.ColumnButtons:
		
		# apply the size of the ColumnButtons of the TopRow to the columns of all the rows of the table
		set_column_width(count, ColumnButton.rect_min_size.x)
		count += 1



func set_column_width(column : int, width : int):
	
	for Row in SortableRows:
		Row.set_cell_width(column,width)






#######################
### invoke Context menu
#######################


func open_context_menu(row_position):
	
	var ClickedRow : SortableTableRow = SortableRows[row_position - 1]
	
	# handle selection. If clicked row is not selected, deselect all but this one
	if ClickedRow.selected == false:
		
		for Row in SortableRows:
			Row.set_selected(false)
		selected_row_ids.clear()
		
		ClickedRow.set_selected(true)
		selected_row_ids.append(ClickedRow.id)
	
	# emit signals
	if selected_row_ids.size() > 0:
		SortableTable.emit_selection_signal( selected_row_ids[selected_row_ids.size() - 1 ] )
		SortableTable.emit_ContextMenu_signal()
	