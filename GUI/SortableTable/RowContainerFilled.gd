extends VBoxContainer


onready var SortableRows = get_children()
onready var SortableRowsSelected = []
onready var TopRow = $"../../../TopRow"
onready var RowScrollContainer = $"../.."
onready var SortableTable = $"../../../.."

var row_height

func _ready():
	
	row_height = SortableTable.row_height
	for SortableRow in SortableRows:
		SortableRow.set_row_height(row_height)

	set_amount_of_columns()
	update_ids_of_rows()
	highlight_column(TopRow.column_used_for_sort)
	resize_columns()
	
	#create test labels
	
	var l = Label.new()
	l.name = "label"
	l.text = "Ein recht langer Text zum Testen"
	var l2 = Label.new()
	l2.name = "label"
	l2.text = "Ein recht langer Text zum Testen"

	
	add_cell_content(1,1,l)
	add_cell_content(1,2,l2)

	
	connect_row_signals()



func _process(delta):
	if Input.is_action_just_pressed("select_all"):
		var mouse_pos = get_viewport().get_mouse_position()
		var row_scroll_container_rect = RowScrollContainer.get_global_rect()
		if row_scroll_container_rect.has_point(mouse_pos):
			select_all()
	
	

func connect_row_signals():
	for Row in SortableRows:
		Row.connect("row_clicked", self, "select_SortableRows")
		Row.connect("row_clicked_rmb", self, "open_context_menu")
		
		
		
func set_amount_of_columns():
	for Row in SortableRows:
		Row.set_cell_count(TopRow.ColumnButtons.size())
		Row.create_cells()
	

func resize_columns():
	
	var count = 1
	
	for ColumnButton in TopRow.ColumnButtons:
		
		# apply the size of the ColumnButtons of the TopRow to the collumns of all the rows of the table
		set_column_width(count, ColumnButton.rect_min_size.x)
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
			ClickedRow.set_selected(true)
			SortableRowsSelected.append(ClickedRow)
		
	else:
		for Row in SortableRows:
			Row.set_selected(false)
		SortableRowsSelected.clear()
		
		ClickedRow.set_selected(true)
		SortableRowsSelected.append(ClickedRow)
		
		
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
	if ClickedRow.get_selected() == false:
		
		for Row in SortableRows:
			Row.set_selected(false)
		SortableRowsSelected.clear()
		
		ClickedRow.set_selected(true)
		SortableRowsSelected.append(ClickedRow)
	
	
	print("some options to select")
	