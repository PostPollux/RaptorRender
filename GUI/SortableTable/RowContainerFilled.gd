extends VBoxContainer


onready var SortableRows = []
onready var SortableRowsSelected = []
onready var TopRow = $"../../../TopRow"
onready var RowScrollContainer = $"../.."
onready var SortableTable = $"../../../.."
onready var RowContainerEmpty = $"../ClipContainerForEmptyRows/RowContainerEmpty"


var SortableTableRowRes = preload("res://GUI/SortableTable/SortableTableRow.tscn")

var row_height



func _ready():
	
	row_height = SortableTable.row_height
	for SortableRow in SortableRows:
		SortableRow.set_row_height(row_height)

	add_rows_and_delete_previous(10)
	add_row()

	update_ids_of_rows()

	


func add_row():
	var Row = initialize_row()
		
	add_child(Row)
	SortableRows.append(Row)



func add_rows_and_delete_previous(count):
	
	if SortableRows.size() > 0:
		for SortableRow in SortableRows:
			SortableRow.queue_free()
			
	for i in range(0, count):
		
		var Row = initialize_row()
		
		add_child(Row)
		SortableRows.append(Row)
		
		
		
func initialize_row():
	var Row = SortableTableRowRes.instance()
		
	Row.connect("row_clicked", self, "select_SortableRows")
	Row.connect("row_clicked_rmb", self, "open_context_menu")
	Row.connect("drag_select", self, "drag_select_SortableRows")
		
	Row.cell_count = TopRow.ColumnButtons.size()
	Row.row_height = SortableTable.row_height
	Row.create_cells()
	if TopRow:
		Row.modulate_cell_color(TopRow.column_used_for_sort,Color("08ffffff"))
		
		var count = 1
		for ColumnButton in TopRow.ColumnButtons:
			# apply the size of the ColumnButtons of the TopRow to the cells
			Row.set_cell_width(count,ColumnButton.rect_min_size.x)
			count += 1
			
	return Row
	
	
		
func _process(delta):
	if Input.is_action_just_pressed("select_all"):
		var mouse_pos = get_viewport().get_mouse_position()
		var row_scroll_container_rect = RowScrollContainer.get_global_rect()
		if row_scroll_container_rect.has_point(mouse_pos):
			select_all()
	
	
	

func resize_columns():
	
	var count = 1
	
	for ColumnButton in TopRow.ColumnButtons:
		
		# apply the size of the ColumnButtons of the TopRow to the columns of all the rows of the table
		set_column_width(count, ColumnButton.rect_min_size.x)
		count += 1
		
		
func set_column_width(column, width):
	
	for Row in SortableRows:
		Row.set_cell_width(column,width)
		
		
func set_cell_content(row, column, child):
	if row <= SortableRows.size():
		SortableRows[row-1].set_cell_content(column, child)
	
	

func update_ids_of_rows():
	var count = 1
	for Row in get_children():
		Row.set_row_id(count)
		count += 1
	
	

func highlight_column(column):
	if TopRow:
		if column <= TopRow.ColumnButtons.size() and column > 0:
			for i in range(1, TopRow.ColumnButtons.size() + 1) :
				for Row in SortableRows:
					Row.modulate_cell_color(i,Color("00ffffff"))
			for Row in SortableRows:
				Row.modulate_cell_color(column,Color("08ffffff"))
		
		

func select_SortableRows(row_id):
	
	var ClickedRow = SortableRows[row_id - 1]
	
	if Input.is_key_pressed(KEY_CONTROL):
		if ClickedRow.selected == true:
			ClickedRow.set_selected(false)
			SortableRowsSelected.erase(ClickedRow)
		
		
	elif Input.is_key_pressed(KEY_SHIFT):
		if SortableRowsSelected.size() > 0:
			var previous_selected_row_id = SortableRowsSelected[SortableRowsSelected.size() - 1].row_id
			
			if row_id > previous_selected_row_id:
				
				for i in range(previous_selected_row_id, row_id + 1):
					if SortableRows[i-1].selected == false:
						SortableRows[i-1].set_selected(true)
						SortableRowsSelected.append(SortableRows[i-1])
			
			if row_id < previous_selected_row_id:
				
				for i in range(row_id, previous_selected_row_id):
					if SortableRows[i-1].selected == false:
						SortableRows[i-1].set_selected(true)
						SortableRowsSelected.append(SortableRows[i-1])
		else:
			ClickedRow.set_selected(true)
			SortableRowsSelected.append(ClickedRow)
		
	else:
		for Row in SortableRows:
			Row.set_selected(false)
		SortableRowsSelected.clear()
		
		ClickedRow.set_selected(true)
		SortableRowsSelected.append(ClickedRow)
		


func drag_select_SortableRows(row_id):
	
	var DragedRow = SortableRows[row_id - 1]
	
	if Input.is_key_pressed(KEY_CONTROL):
		DragedRow.set_selected(false)
		SortableRowsSelected.erase(DragedRow)
		
		
	elif Input.is_key_pressed(KEY_SHIFT):
		if DragedRow.selected == false:
			DragedRow.set_selected(true)
			SortableRowsSelected.append(DragedRow)
		
	else:
		for Row in SortableRows:
			Row.set_selected(false)
		SortableRowsSelected.clear()
		
		DragedRow.set_selected(true)
		SortableRowsSelected.append(DragedRow)
		
		



func select_all():
	
	# select or deselect all rows depending on wheter all are already selected or not
	if SortableRowsSelected.size() != SortableRows.size():
		
		SortableRowsSelected.clear()
		for Row in SortableRows:
			Row.set_selected(true)
			SortableRowsSelected.append(Row)
	else:
		SortableRowsSelected.clear()
		for Row in SortableRows:
			Row.set_selected(false)




func open_context_menu(row_id):
	
	var ClickedRow = SortableRows[row_id - 1]
	
	#if clicked row is not selected, deselect all but this one
	if ClickedRow.selected == false:
		
		for Row in SortableRows:
			Row.set_selected(false)
		SortableRowsSelected.clear()
		
		ClickedRow.set_selected(true)
		SortableRowsSelected.append(ClickedRow)
	
	
	print("some options to select")
	