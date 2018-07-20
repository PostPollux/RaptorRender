#///////////////////#
# RowContainerEmpty #
#///////////////////#

# A VBoxContainer that holds all the rows that do not contain any data. 
# The sortable table is supposed to be scrollable and should look like there are actually rows, 
# even if there is no data displayed. So we need some empty rows with alternating colors.
# As these empty rows shouldn't be recognized as scrollable content we need a simple parent "Container" with clipping enabled.
# At the beginning there are enough empty rows created, so that even if this container fills up the whole screen, everything would be covered with alternating rows.
# As rows are added to the RowContainerFilled empty rows will be deleted to improve performance.



extends VBoxContainer


var row_height
var amount_of_needed_rows_to_fill_up_screen

var EmptyRows = []

# references to other nodes of sortable table
onready var SortableTable = $"../../../../.."
onready var TopRow = $"../../../../TopRow"
onready var RowContainerFilled = $"../../RowContainerFilled"

# preload Resources
var SortableTableRowRes = preload("res://GUI/SortableTable/SortableTableRow.tscn")




func _ready():
	
	row_height = SortableTable.row_height
	
	amount_of_needed_rows_to_fill_up_screen =  int( OS.get_screen_size()[1] / row_height )
	
	# create enough empty rows to fill up the whole screen
	for i in range(1, amount_of_needed_rows_to_fill_up_screen):
		create_empty_row()
	
	update_width_of_RowContainerEmpty()
	
	update_positions_of_empty_rows()
	
	initialize_column_widths()
	
	highlight_column(TopRow.sort_column_primary)





###################
### manage the rows
###################


# create an empty row
func create_empty_row():
	
	if EmptyRows.size() < amount_of_needed_rows_to_fill_up_screen:
		var SortableTableRow = SortableTableRowRes.instance()
		
		SortableTableRow.connect("row_clicked", self, "select_SortableRows")
		SortableTableRow.set_row_height(row_height)
		SortableTableRow.column_count = TopRow.ColumnButtons.size()
		SortableTableRow.create_cells()
		
		self.add_child(SortableTableRow)
		EmptyRows.append(SortableTableRow)



func remove_empty_row():
	if EmptyRows.size() > 1: # make sure one empty row is always available
		
		EmptyRows[0].free()
		EmptyRows.pop_front()



# this function is needed for correct alternating colors
func update_positions_of_empty_rows():
	var filled_row_count = RowContainerFilled.SortableRows.size()
	var count = 1
	for Row in get_children():
		Row.set_row_position(filled_row_count + count)
		count += 1




######################################
### correct width of RowContainerEmpty
######################################


func _on_ClipContainerForEmptyRows_resized():
	update_width_of_RowContainerEmpty()

# this function is needed, as the size flag "fill, expand" doen't work if the parent container is a simple "Container" 
func update_width_of_RowContainerEmpty():
	var width_of_clipcontainer = $"../../ClipContainerForEmptyRows".rect_size.x
	rect_min_size.x = width_of_clipcontainer





##################
### handle columns
##################


func initialize_column_widths():
	
	var column = 1
	
	for ColumnButton in TopRow.ColumnButtons:
		
		# apply the size of the ColumnButtons of the TopRow to the columns of all the rows of the table
		set_column_width(column, ColumnButton.rect_min_size.x)
		
		column += 1



func set_column_width(column, width):
	
	for Row in EmptyRows:
		Row.set_cell_width(column,width)



# function to highlight the primary sort column 
func highlight_column(column):
	if TopRow:
		if column <= TopRow.ColumnButtons.size() and column > 0:
			for i in range(1, TopRow.ColumnButtons.size() + 1) :
				for Row in EmptyRows:
					Row.modulate_cell_color(i,Color("00ffffff"))
			for Row in EmptyRows:
				Row.modulate_cell_color(column,Color("18ffffff"))






#############
### Selection
#############

# empty rows are not selectable, but clicking them can have an effect on the selection of the filled ones
func select_SortableRows(row_position):
	
	var SortableRows = RowContainerFilled.SortableRows
	
	
	if Input.is_key_pressed(KEY_CONTROL):
		pass
		
	elif Input.is_key_pressed(KEY_SHIFT):
		if RowContainerFilled.selected_row_ids.size() > 0:
			
			var previous_selected_row_position = 0
			for Row in SortableRows:
				if Row.id == RowContainerFilled.selected_row_ids[RowContainerFilled.selected_row_ids.size() - 1]:
					previous_selected_row_position = Row.row_position
					
			for i in range(previous_selected_row_position, SortableRows.size() + 1):
				if SortableRows[i-1].selected == false:
					SortableRows[i-1].set_selected(true)
					RowContainerFilled.selected_row_ids.append(SortableRows[i-1].id)
		
	else:
		for Row in SortableRows:
			Row.set_selected(false)
		RowContainerFilled.selected_row_ids.clear()


