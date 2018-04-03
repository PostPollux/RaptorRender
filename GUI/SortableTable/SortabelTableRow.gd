tool

extends MarginContainer


export (int) var cellCount = 4 
export (int) var row_id
export (int) var cellHeight = 20 

#row colors
export (Color) var row_color = Color("3c3c3c")
var row_color_even = row_color
var row_color_odd = row_color.lightened(0.05)
export (Color) var row_color_selected = Color("c88969")
var row_color_selected_even = row_color_selected
var row_color_selected_odd = row_color_selected.lightened(0.1)


onready var HBoxForCells = $HBoxContainer
onready var bg = $BackgroundColor

var cellsClipContainerArray
var cellsMarginContainerArray = []

var even = false
var selected = false


signal row_clicked



func _ready():
	
	# determine if row id is even or odd
	if (row_id % 2) == 0:
		even = true
	else:
		even = false
		
	# assign column color
	if selected:
		if even:
			bg.color = row_color_selected_even
			
		else:
			bg.color = row_color_selected_odd
	
	else:
		if even:
			bg.color = row_color_even
			
		else:
			bg.color = row_color_odd
	
	# create cells
	createCells(cellCount)
	



func _process(delta):
	pass





#create the cells
func createCells(c):
	
	var oldCells = HBoxForCells.get_children()
	
	for cell in oldCells:
		cell.queue_free()
	
	for i in range(c):
		
		var cellClipContainer = Container.new()
		cellClipContainer.name = "cell_clip_container_" + String(i+1)
		cellClipContainer.rect_clip_content = true
		cellClipContainer.set_v_size_flags(3) # fill + expand
		cellClipContainer.set_mouse_filter(Control.MOUSE_FILTER_IGNORE)
		
		var cellMarginContainer = MarginContainer.new()
		cellMarginContainer.name = "cell_margin_container"
		cellMarginContainer.set_v_size_flags(3) # fill + expand
		cellMarginContainer.set_mouse_filter(Control.MOUSE_FILTER_IGNORE)
		cellMarginContainer.margin_left = 3
		cellMarginContainer.margin_top = 3
		cellMarginContainer.margin_right = 3
		cellMarginContainer.margin_bottom = 3
		cellMarginContainer.rect_min_size.y = HBoxForCells.rect_size.y - cellMarginContainer.margin_left - cellMarginContainer.margin_right
		
		
		
		cellClipContainer.add_child(cellMarginContainer)
		HBoxForCells.add_child(cellClipContainer)
		
	update()
	
	# update the cells array
	cellsClipContainerArray = HBoxForCells.get_children()
	fill_cellsMarginContainerArray()
	
	set_cellHeight(30)
	





func fill_cellsMarginContainerArray ():
	
	cellsMarginContainerArray.clear()
	
	for cell in cellsClipContainerArray:
		var marginContainer = cell.get_child(0)
		cellsMarginContainerArray.append(marginContainer)	
	

####### Getters for Variables #########		
	
func get_row_id():
	return row_id

func get_selected():
	return selected
	
####### Setters for Variables #########		
	
	
func set_row_color (color):
	row_color = color
	
func set_row_color_selected (color):
	row_color_selected = color
	
func set_selected (sel):
	selected = sel
	
func set_cellCount(count):
	cellCount = count
	update()
	
	
	
####### Modify Cells #########	

func add_cellContent(column, child):
	if column <= cellsMarginContainerArray.size():
		cellsMarginContainerArray[column-1].add_child(child)
	
	
func set_cellWidth(column, width):
	if column <= cellsClipContainerArray.size():
		cellsClipContainerArray[column-1].rect_min_size.x = width
		
		
func set_cellHeight(height):
	for cell in cellsClipContainerArray:
		cell.rect_min_size.y = height
	for cell in cellsMarginContainerArray:
		cell.rect_min_size.y = HBoxForCells.rect_size.y - cell.margin_left - cell.margin_right


func set_color_hover():
	if selected:
		if even:
			bg.color = row_color_selected_even.lightened(0.2)
		else:
			bg.color = row_color_selected_odd.lightened(0.1)
	
	else:
		if even:
			bg.color = row_color_even.lightened(0.15)
		else:
			bg.color = row_color_odd.lightened(0.1)
		

func set_color_select():
	if even:
		bg.color = row_color_selected_even
	else:
		bg.color = row_color_selected_odd
	
	
func set_color_reset():
	if selected: 
		if even:
			bg.color = row_color_selected_even
		else:
			bg.color = row_color_selected_odd
	else:
		if even:
			bg.color = row_color_even
		else:
			bg.color = row_color_odd






#### Signal handling ####

func _on_SortabelTableRow_mouse_entered():
	set_color_hover()


func _on_SortabelTableRow_mouse_exited():
	set_color_reset()
	

func _on_SortabelTableRow_gui_input(ev):
	if ev.is_action_pressed("ui_left_mouse_button"):
		emit_signal("row_clicked", row_id)
		#if !selected:
			#selected = true;
			#set_color_select()
		
