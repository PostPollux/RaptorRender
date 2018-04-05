extends VBoxContainer

var row_height = 30

var sortable_table_row = preload("res://GUI/SortableTable/SortableTableRow.tscn")
onready var RowContainerFilled = $"../../RowContainerFilled"

func _ready():
	update_width_of_RowContainerEmpty()
	fill_up_available_space_with_empty_rows()
	update_ids_of_empty_rows()
	connect_row_clicked_signals()



func connect_row_clicked_signals():
	for Row in get_children():
		Row.connect("row_clicked", self, "select_SortableRows")
		

func fill_up_available_space_with_empty_rows():
	var screen_size_y = OS.get_screen_size()[1]
	var amount_of_needed_rows = int(screen_size_y/row_height)
	
	for i in range(1, amount_of_needed_rows):
		var SortableTableRow = sortable_table_row.instance()
		add_child(SortableTableRow)
		SortableTableRow.set_row_height(row_height)
		
	
func update_ids_of_empty_rows():
	var filled_row_count = RowContainerFilled.SortableRows.size()
	var count = 1
	for Row in get_children():
		Row.set_row_id(filled_row_count + count)
		count += 1


func update_width_of_RowContainerEmpty():
	var width_of_clipcontainer = $"../../ClipContainerForEmptyRows".rect_size.x
	rect_min_size.x = width_of_clipcontainer
	
	


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
	
	
