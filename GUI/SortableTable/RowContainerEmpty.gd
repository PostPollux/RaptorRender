extends VBoxContainer

var row_height

var SortableTableRowRes = preload("res://GUI/SortableTable/SortableTableRow.tscn")
onready var RowContainerFilled = $"../../RowContainerFilled"
onready var TopRow = $"../../../../TopRow"
onready var SortableTable = $"../../../../.."
var EmptyRows = []

func _ready():
	row_height = SortableTable.row_height
	
	update_width_of_RowContainerEmpty()
	fill_up_available_space_with_empty_rows()
	update_ids_of_empty_rows()
	connect_row_clicked_signals()
	set_amount_of_columns()
	resize_columns()
	highlight_column(TopRow.column_used_for_sort)



func connect_row_clicked_signals():
	for Row in get_children():
		Row.connect("row_clicked", self, "select_SortableRows")
		

func fill_up_available_space_with_empty_rows():
	var screen_size_y = OS.get_screen_size()[1]
	var amount_of_needed_rows = int(screen_size_y/row_height)
	
	for i in range(1, amount_of_needed_rows):
		var SortableTableRow = SortableTableRowRes.instance()
		add_child(SortableTableRow)
		SortableTableRow.set_row_height(row_height)
		EmptyRows.append(SortableTableRow)
		

		
	
func update_ids_of_empty_rows():
	var filled_row_count = RowContainerFilled.SortableRows.size()
	var count = 1
	for Row in get_children():
		Row.set_row_id(filled_row_count + count)
		count += 1


func update_width_of_RowContainerEmpty():
	var width_of_clipcontainer = $"../../ClipContainerForEmptyRows".rect_size.x
	rect_min_size.x = width_of_clipcontainer
	
	
func set_amount_of_columns():
	for Row in EmptyRows:
		Row.cell_count = TopRow.ColumnButtons.size()
		Row.create_cells()
		
		
func resize_columns():
	
	var count = 1
	
	for ColumnButton in TopRow.ColumnButtons:
		
		# apply the size of the ColumnButtons of the TopRow to the collumns of all the rows of the table
		set_column_width(count, ColumnButton.rect_min_size.x)
		
		count += 1
		
		
func set_column_width(column, width):
	
	for Row in EmptyRows:
		Row.set_cell_width(column,width)
		

func highlight_column(column):
	if TopRow:
		if column <= TopRow.ColumnButtons.size() and column > 0:
			for i in range(1, TopRow.ColumnButtons.size() + 1) :
				for Row in EmptyRows:
					Row.modulate_cell_color(i,Color("00ffffff"))
			for Row in EmptyRows:
				Row.modulate_cell_color(column,Color("08ffffff"))


# empty rows are not selectable, but clicking them can have an effect on the selection of the filled ones
func select_SortableRows(row_id):
	
	var SortableRows = RowContainerFilled.SortableRows
	var SortableRowsSelected = RowContainerFilled.SortableRowsSelected
	
	if Input.is_key_pressed(KEY_CONTROL):
		pass
		
		
	elif Input.is_key_pressed(KEY_SHIFT):
		if SortableRowsSelected.size() > 0:
			var previous_selected_row_id = SortableRowsSelected[SortableRowsSelected.size() - 1].get_row_id()
			
			for i in range(previous_selected_row_id, SortableRows.size() + 1):
				if SortableRows[i-1].get_selected() == false:
					SortableRows[i-1].set_selected(true)
					SortableRowsSelected.append(SortableRows[i-1])
		
		
	else:
		for Row in SortableRows:
			Row.set_selected(false)
		SortableRowsSelected.clear()


func _on_ClipContainerForEmptyRows_resized():
	update_width_of_RowContainerEmpty()
	
	
