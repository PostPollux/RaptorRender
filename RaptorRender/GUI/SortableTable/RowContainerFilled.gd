#////////////////////#
# RowContainerFilled #
#////////////////////#

# A VBoxContainer that holds all the rows that contain data. 
# Basic row handling and the sorting algorithm is part of this script file.



extends VBoxContainer

class_name SortableTableRowContainerFilled


### PRELOAD RESOURCES
var SortableTableRowRes = preload("SortableTableRow.tscn")

### SIGNALS

### ONREADY VARIABLES
onready var SortableTable = $"../../../.." as SortableTable
onready var TopRow = $"../../../TopRow" as SortableTableTopRow
onready var RowScrollContainer = $"../.." as ScrollContainer
onready var RowContainerEmpty = $"../ClipContainerForEmptyRows/RowContainerEmpty"

### EXPORTED VARIABLES

### VARIABLES
var row_height : int = 30

# Array to hold all current rows. It get's updated when sorting, so it always reflects the current order of rows
var SortableRows : Array = []

# Dictionary that maps row ids to the current position in the sorted table
var id_position_dict : Dictionary = {} 

# Array for selections. It hold's the ids, not the rows themselves
var selected_row_ids : Array = []

# row colors
var row_color : Color = RRColorScheme.ST_row_default
var row_color_selected : Color = RRColorScheme.selected

var even_odd_brightness_difference : float = 0.05
var hover_brightness_boost : float = 0.1





########## FUNCTIONS ##########


func _ready() -> void:
	row_height = SortableTable.row_height


###############
### manage rows
###############


# Update the SortableRows array to reflect the current order of the sorted table
func update_sortable_rows_array() -> void:
	SortableRows = self.get_children()


# Update the "id_position_dict". This dictionary is used to quickly look up the position of a row by it's id.
func update_id_position_dict() -> void:
	for Row in SortableRows:
		id_position_dict[Row.id] = Row.get_index() + 1


# sets the "row_position" variable of each row, so that it knows which background color (even or odd) to show. 
func update_positions_of_rows() -> void:
	var iterator : int = 1
	for Row in SortableRows:
		Row.set_row_position(iterator)
		iterator += 1


# creating a row
func initialize_row(id) -> SortableTableRow:
	
	var Row : SortableTableRow = SortableTableRowRes.instance()
	
	# set color variables of SortableTableRow
	Row.row_color = row_color
	Row.row_color_selected = row_color_selected 
	Row.even_odd_brightness_difference = even_odd_brightness_difference
	Row.hover_brightness_boost = hover_brightness_boost
	Row.set_additional_colors()
	
	# set variables. (id, amount of cells , row height)
	Row.id = id
	Row.column_count = TopRow.ColumnButtons.size()
	Row.set_row_height(row_height)
	
	# connect signals to enable selecting and invoking a context menu
	Row.connect("row_clicked", self, "select_SortableRows")
	Row.connect("row_clicked_rmb", self, "open_context_menu")
	Row.connect("drag_selected", self, "drag_select_SortableRows")
	Row.connect("select_all_pressed", self, "select_all")
	
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
func remove_row(id) -> void:
	
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


func set_row_color(row : int, color : Color) -> void:
	if row >= 1:
		SortableRows[row - 1].set_row_color(color)


# first row and column is 1, not 0
func mark_erroneous(row : int, erroneous : bool) -> void:
	if row >= 1 and row < SortableRows.size():
		SortableRows[row - 1].mark_erroneous(erroneous)



func reset_all_row_colors_to_default() -> void:
	for Row in SortableRows:
		Row.set_row_color(RRColorScheme.ST_row_default)



func highlight_column(column : int) -> void:
	
	# reset the color of each cell in each row
	for Row in SortableRows:
		for i in range(1, Row.column_count + 1) :
			Row.modulate_cell_color(i,Color("00ffffff"))
	
	# highlight the correct cell in each row
	for Row in SortableRows:
		Row.modulate_cell_color(column,Color("18ffffff"))





##############
### Sort Rows
##############


func sort_rows() -> void:
	
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



func raptor_render_custom_sort(a, b) -> bool:
	
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
func set_cell_content(row : int, column : int, child : Node) -> void:
	if row <= SortableRows.size():
		SortableRows[row - 1].set_cell_content(column, child)


# first row and column is 1, not 0
func set_cell_sort_value(row : int, column : int, value) -> void:
	if row <= SortableRows.size():
		SortableRows[row - 1].sort_values[column] = value






#############
### Selection
#############


func select_SortableRows(row_position : int) -> void:
	
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




func drag_select_SortableRows(row_position : int) -> void:
	
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





func select_all() -> void:
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


func update_selection() -> void:
	for Row in SortableRows:
		Row.set_selected(false)
		
	for selected_row_id in selected_row_ids:
		for Row in SortableRows:
			if Row.id == selected_row_id:
				Row.set_selected(true)



func clear_selection() -> void:
	
	selected_row_ids.clear()
	
	for Row in SortableRows:
		Row.set_selected(false)



func add_id_to_selection(id) -> void:
	selected_row_ids.append(id)






##################
### resize columns
##################


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
	
