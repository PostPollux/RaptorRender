extends VBoxContainer


onready var SortableRows = get_children()
onready var SortableRowsSelected = []
onready var TopRow = $"../../../TopRow"

func _ready():

	set_amount_of_columns()
	resize_columns()
	update_ids_of_rows()
	
	#create test labels
	
	var l = Label.new()
	l.name = "label"
	l.text = "Ein recht langer Text zum Testen"
	var l2 = Label.new()
	l2.name = "label"
	l2.text = "Ein recht langer Text zum Testen"
	#l.size_flags_vertical = 0
	#l.set_v_size_flags(4)
	
	add_cell_content(1,1,l)
	add_cell_content(1,2,l2)
	
	print (OS.get_name())
	print ('Number of Threads: ' + String(OS.get_processor_count()) )
	print (OS.get_model_name ( ))
	print (OS.get_dynamic_memory_usage ( ))
	
	
	connect_row_clicked_signals()
	
	

func connect_row_clicked_signals():
	for Row in SortableRows:
		Row.connect("row_clicked", self, "select_SortableRows")
		
		
		
func set_amount_of_columns():
	for Row in SortableRows:
		Row.set_cell_count(TopRow.ColumnButtons.size())
		Row.create_cells()
	

func resize_columns():
	
	var count = 1
	
	for ColumnButton in TopRow.ColumnButtons:
		
		# apply the size of the ColumnButtons of the TopRow to the collumns of all the rows of the table
		set_column_width(count, ColumnButton.rect_size.x)
		
		count += 1
		
		
func set_column_width(column, width):
	
	for Row in SortableRows:
		Row.set_cell_width(column,width)
		
		
func add_cell_content(row, column, child):
	if row <= SortableRows.size():
		SortableRows[row-1].add_cell_content(column, child)
	
	

func update_ids_of_rows():
	var count = 1
	for Row in get_children():
		Row.set_row_id(count)
		count += 1
		
		

func select_SortableRows(row_id):
	
	var ClickedRow = SortableRows[row_id - 1]
	
	if Input.is_key_pressed(KEY_CONTROL):
		if ClickedRow.get_selected() == false:
			ClickedRow.set_selected(true)
			SortableRowsSelected.append(ClickedRow)
		else:
			ClickedRow.set_selected(false)
			SortableRowsSelected.erase(ClickedRow)
		
		
	elif Input.is_key_pressed(KEY_SHIFT):
		if SortableRowsSelected.size() > 0:
			var previous_selected_row_id = SortableRowsSelected[SortableRowsSelected.size() - 1].get_row_id()
			
			if row_id > previous_selected_row_id:
				
				for i in range(previous_selected_row_id, row_id + 1):
					if SortableRows[i-1].get_selected() == false:
						SortableRows[i-1].set_selected(true)
						SortableRowsSelected.append(SortableRows[i-1])
			
			if row_id < previous_selected_row_id:
				
				for i in range(row_id, previous_selected_row_id):
					if SortableRows[i-1].get_selected() == false:
						SortableRows[i-1].set_selected(true)
						SortableRowsSelected.append(SortableRows[i-1])
		
	else:
		for Row in SortableRows:
			Row.set_selected(false)
		SortableRowsSelected.clear()
		
		ClickedRow.set_selected(true)
		SortableRowsSelected.append(ClickedRow)
	