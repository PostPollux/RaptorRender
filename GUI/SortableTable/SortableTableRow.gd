tool

extends MarginContainer


var cell_count
var row_id

#row colors
var row_color
var row_color_even 
var row_color_odd 
var row_color_selected 
var row_color_selected_even
var row_color_selected_odd

var even_odd_brightness_difference
var hover_brightness_boost

var column_count

onready var HBoxForCells = $HBoxContainer
onready var RowBackgroundColorRect = $BackgroundColor

var SortableTable

var CellsClipContainerArray = []
var CellsMarginContainerArray = []
var CellsColorRectArray = []

var even = false
var selected = false
var row_height


signal row_clicked
signal row_clicked_rmb



func _ready():
	
	get_reference_to_SortableTable()
	
	set_initial_colors()
	
	row_height = SortableTable.row_height
	
	# determine if row id is even or odd
	update_row_even_or_odd()
		
	# assign column color
	if selected:
		if even:
			RowBackgroundColorRect.color = row_color_selected_even
			
		else:
			RowBackgroundColorRect.color = row_color_selected_odd
	
	else:
		if even:
			RowBackgroundColorRect.color = row_color_even
			
		else:
			RowBackgroundColorRect.color = row_color_odd
	
	



func _process(delta):
	pass



func update_row_even_or_odd():
	if row_id:
		if (row_id % 2) == 0:
			even = true
		else:
			even = false


#create the cells
func create_cells():
	
	var OldCells = HBoxForCells.get_children()
	
	for Cell in OldCells:
		Cell.queue_free()
	
	CellsClipContainerArray.clear()
	
	for i in range(cell_count):
		
		var CellClipContainer = Container.new()
		CellClipContainer.name = "cell_clip_container_" + String(i+1)
		CellClipContainer.rect_clip_content = true
		CellClipContainer.set_v_size_flags(3) # fill + expand
		CellClipContainer.set_mouse_filter(Control.MOUSE_FILTER_IGNORE)
		
		var CellColorRect = ColorRect.new()
		CellColorRect.name = "cell_color_rect"
		CellColorRect.set_mouse_filter(Control.MOUSE_FILTER_IGNORE)
		CellColorRect.set_v_size_flags(3) # fill + expand
		CellColorRect.set_h_size_flags(3) # fill + expand
		CellColorRect.rect_min_size.y = row_height
		CellColorRect.set_modulate(Color("00ffffff"))
		
		var CellMarginContainer = MarginContainer.new()
		CellMarginContainer.name = "cell_margin_container"
		CellMarginContainer.set_v_size_flags(3) # fill + expand
		CellMarginContainer.set_mouse_filter(Control.MOUSE_FILTER_IGNORE)
		CellMarginContainer.margin_left = 3
		CellMarginContainer.margin_top = 3
		CellMarginContainer.margin_right = 3
		CellMarginContainer.margin_bottom = 3
		CellMarginContainer.rect_min_size.y = HBoxForCells.rect_size.y - CellMarginContainer.margin_left - CellMarginContainer.margin_right
		
		# add the cell to the HBoxContainer and to the CellsClipContainerArray
		CellClipContainer.add_child(CellColorRect)
		CellClipContainer.add_child(CellMarginContainer)
		HBoxForCells.add_child(CellClipContainer)
		CellsClipContainerArray.append(CellClipContainer)
		
		
		# add a line to separate the individual cells visually
		var VerticalLine = VSeparator.new()
		if i < cell_count - 1:
			HBoxForCells.add_child(VerticalLine)
		
		
	fill_CellArrays()
	
	set_cell_height(row_height)
	
	column_count = CellsClipContainerArray.size()
	


func get_reference_to_SortableTable():
	var ParentNode = get_parent()
	
		
	while ParentNode.name != "VBox_TopRow_Content":
		ParentNode = ParentNode.get_parent()
	
	# go up one level further to finally get the node of the SortableTable
	ParentNode = ParentNode.get_parent()
	
	SortableTable = ParentNode
	

func set_initial_colors():
	row_color = SortableTable.row_color
	row_color_selected = SortableTable.row_color_selected
	even_odd_brightness_difference = SortableTable.row_brightness_difference
	hover_brightness_boost = SortableTable.hover_brightness_boost
	
	row_color_even = row_color
	row_color_odd = row_color.lightened(even_odd_brightness_difference)
	row_color_selected_even = row_color_selected
	row_color_selected_odd = row_color_selected.lightened(hover_brightness_boost)
	
	

func fill_CellArrays ():
	
	CellsMarginContainerArray.clear()
	
	for Cell in CellsClipContainerArray:
		var CellColorRect = Cell.get_child(0)
		var CellMarginContainer = Cell.get_child(1)
		CellsColorRectArray.append(CellColorRect)	
		CellsMarginContainerArray.append(CellMarginContainer)	
	

####### Getters for Variables #########		
	
func get_row_id():
	return row_id

func get_selected():
	return selected
	
####### Setters for Variables #########		
	
func set_row_id(id):
	row_id = id
	update_row_even_or_odd()
	update_row_color_reset()
	
func set_row_color (color):
	row_color = color
	
func set_row_color_selected (color):
	row_color_selected = color
	
func set_selected (sel):
	selected = sel
	if selected:
		update_row_color_select()
	else:
		update_row_color_reset()
	
func set_cell_count(count):
	cell_count = count
	update()
	
	
	
####### Modify Cells #########	

func add_cell_content(column, child):
	if column <= column_count:
		CellsMarginContainerArray[column-1].add_child(child)
	
	
func set_cell_width(column, width):
	if column <= column_count:
		CellsClipContainerArray[column-1].rect_min_size.x = width
		CellsColorRectArray[column-1].rect_min_size.x = width
		
		

func set_row_height(height):
	row_height = height
	rect_min_size.y = height
	set_cell_height(height)
	

func set_cell_height(height):
	if column_count:
		for ClipContainer in CellsClipContainerArray:
			ClipContainer.rect_min_size.y = height
		for CellMarginContainer in CellsMarginContainerArray:
			CellMarginContainer.rect_min_size.y = HBoxForCells.rect_size.y - CellMarginContainer.margin_left - CellMarginContainer.margin_right
		for CellColorRect in CellsColorRectArray:
			CellColorRect.rect_size.y = HBoxForCells.rect_size.y
			
func modulate_cell_color(column, color):
	CellsColorRectArray[column-1].set_modulate( color )
	
	
func update_row_color_hover():
	if selected:
		if even:
			RowBackgroundColorRect.color = row_color_selected_even.lightened(hover_brightness_boost * 2)
		else:
			RowBackgroundColorRect.color = row_color_selected_odd.lightened(hover_brightness_boost)
	
	else:
		if even:
			RowBackgroundColorRect.color = row_color_even.lightened(hover_brightness_boost * 1.5)
		else:
			RowBackgroundColorRect.color = row_color_odd.lightened(hover_brightness_boost)
		

func update_row_color_select():
	if even:
		RowBackgroundColorRect.color = row_color_selected_even
	else:
		RowBackgroundColorRect.color = row_color_selected_odd
	
	
func update_row_color_reset():
	if selected: 
		if even:
			RowBackgroundColorRect.color = row_color_selected_even
		else:
			RowBackgroundColorRect.color = row_color_selected_odd
	else:
		if even:
			RowBackgroundColorRect.color = row_color_even
		else:
			RowBackgroundColorRect.color = row_color_odd






#### Signal handling ####

func _on_SortabelTableRow_mouse_entered():
	update_row_color_hover()


func _on_SortabelTableRow_mouse_exited():
	update_row_color_reset()
	

func _on_SortabelTableRow_gui_input(ev):
	if ev.is_action_pressed("ui_left_mouse_button"):
		emit_signal("row_clicked", row_id)
	if ev.is_action_pressed("ui_right_mouse_button"):
		emit_signal("row_clicked_rmb", row_id)
		
