extends VBoxContainer


onready var SortableRows = []
onready var selected_row_content_ids = []
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

	


func add_row():
	var Row = initialize_row()
		
	add_child(Row)
	SortableRows.append(Row)



		

func update_amount_of_rows(count):
	
	if SortableRows.size() == count:
		pass
	
	# add needed rows	
	elif SortableRows.size() < count:
		var rows_to_add = count - SortableRows.size()
		
		for i in range (0, rows_to_add):
			
			var Row = initialize_row()
		
			add_child(Row)
			SortableRows.append(Row)
	
	# remove unneeded rows
	elif SortableRows.size() > count:
		var rows_to_remove = SortableRows.size() - count
		
		# remove from selection
		for i in range (SortableRows.size() - rows_to_remove, SortableRows.size()):
			selected_row_content_ids.erase(SortableRows[i].content_id)
			
		# remove the nodes
		for i in range (SortableRows.size() - rows_to_remove, SortableRows.size()):
			SortableRows[i].free()
			
		# remove the references in the 	Sortable Rows Array
		for i in range (SortableRows.size() - rows_to_remove, SortableRows.size()):
			SortableRows.pop_back()
			
		
		
		
	
func initialize_row():
	var Row = SortableTableRowRes.instance()
		
	Row.connect("row_clicked", self, "select_SortableRows")
	Row.connect("row_clicked_rmb", self, "open_context_menu")
	Row.connect("drag_select", self, "drag_select_SortableRows")
		
	Row.cell_count = TopRow.ColumnButtons.size()
	Row.row_height = SortableTable.row_height
	Row.create_cells()
	if TopRow:
		Row.modulate_cell_color(TopRow.sort_column_primary,Color("18ffffff"))
		
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
	
func set_row_content_id(row, id):
		SortableRows[row-1].content_id = id

func update_ids_of_rows():
	var count = 1
	for Row in SortableRows:
		Row.set_row_id(count)
		count += 1


func update_selection():
	for Row in SortableRows:
		Row.set_selected(false)
		
	for selected_row_content_id in selected_row_content_ids:
		for Row in SortableRows:
			if Row.content_id == selected_row_content_id:
				Row.set_selected(true)
	

func highlight_column(column):
	if TopRow:
		if column <= TopRow.ColumnButtons.size() and column > 0:
			for i in range(1, TopRow.ColumnButtons.size() + 1) :
				for Row in SortableRows:
					Row.modulate_cell_color(i,Color("00ffffff"))
			for Row in SortableRows:
				Row.modulate_cell_color(column,Color("18ffffff"))
		
		

func select_SortableRows(row_id):
	
	var ClickedRow = SortableRows[row_id - 1]
	
	if Input.is_key_pressed(KEY_CONTROL):
		if ClickedRow.selected == true:
			ClickedRow.set_selected(false)
			selected_row_content_ids.erase(ClickedRow.content_id)
		else:
			ClickedRow.set_selected(true)
			selected_row_content_ids.append(ClickedRow.content_id)
		
		
	elif Input.is_key_pressed(KEY_SHIFT):
		if selected_row_content_ids.size() > 0:
			var previous_selected_row_id = 0
			for Row in SortableRows:
				if Row.content_id == selected_row_content_ids[selected_row_content_ids.size() - 1]:
					previous_selected_row_id = Row.row_id
						
			if row_id > previous_selected_row_id:
				
				for i in range(previous_selected_row_id, row_id + 1):
					if SortableRows[i-1].selected == false:
						SortableRows[i-1].set_selected(true)
						selected_row_content_ids.append(SortableRows[i-1].content_id)
			
			if row_id < previous_selected_row_id:
				
				for i in range(row_id, previous_selected_row_id):
					if SortableRows[i-1].selected == false:
						SortableRows[i-1].set_selected(true)
						selected_row_content_ids.append(SortableRows[i-1].content_id)
		else:
			ClickedRow.set_selected(true)
			selected_row_content_ids.append(ClickedRow.content_id)
		
	else:
		for Row in SortableRows:
			Row.set_selected(false)
		selected_row_content_ids.clear()
		
		ClickedRow.set_selected(true)
		selected_row_content_ids.append(ClickedRow.content_id)
		


func drag_select_SortableRows(row_id):
	
	var DragedRow = SortableRows[row_id - 1]
	
	if Input.is_key_pressed(KEY_CONTROL):
		DragedRow.set_selected(false)
		selected_row_content_ids.erase(DragedRow)
		
		
	elif Input.is_key_pressed(KEY_SHIFT):
		if DragedRow.selected == false:
			DragedRow.set_selected(true)
			selected_row_content_ids.append(DragedRow.content_id)
		
	else:
		for Row in SortableRows:
			Row.set_selected(false)
		selected_row_content_ids.clear()
		
		DragedRow.set_selected(true)
		selected_row_content_ids.append(DragedRow.content_id)
		
		



func select_all():
	
	# select or deselect all rows depending on wheter all are already selected or not
	if selected_row_content_ids.size() != SortableRows.size():
		
		selected_row_content_ids.clear()
		for Row in SortableRows:
			Row.set_selected(true)
			selected_row_content_ids.append(Row.content_id)
	else:
		selected_row_content_ids.clear()
		for Row in SortableRows:
			Row.set_selected(false)




func open_context_menu(row_id):
	
	var ClickedRow = SortableRows[row_id - 1]
	
	#if clicked row is not selected, deselect all but this one
	if ClickedRow.selected == false:
		
		for Row in SortableRows:
			Row.set_selected(false)
		selected_row_content_ids.clear()
		
		ClickedRow.set_selected(true)
		selected_row_content_ids.append(ClickedRow)
	
	
	print("some options to select")
	