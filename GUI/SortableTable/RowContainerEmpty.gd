extends VBoxContainer

var row_height = 30

var sortable_table_row = preload("res://GUI/SortableTable/SortableTableRow.tscn")


func _ready():
	update_width_of_RowContainerEmpty()
	fill_up_available_space_with_empty_rows()



func fill_up_available_space_with_empty_rows():
	var filled_row_count = $"../../RowContainerFilled".SortableRows.size()
	var height_of_clipcontainer = $"../../ClipContainerForEmptyRows".rect_size.y
	var amount_of_needed_rows = int(height_of_clipcontainer/row_height)
	
	for i in range(1, amount_of_needed_rows + 3):
		var SortableTableRow = sortable_table_row.instance()
		add_child(SortableTableRow)
		SortableTableRow.set_row_id(filled_row_count + i)
		SortableTableRow.set_row_height(row_height)
		
		

func update_width_of_RowContainerEmpty():
	var width_of_clipcontainer = $"../../ClipContainerForEmptyRows".rect_size.x
	rect_min_size.x = width_of_clipcontainer