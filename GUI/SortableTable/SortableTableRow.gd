#//////////////////#
# SortableTableRow #
#//////////////////#

# The SortableTableRow represents just one row in the table showing one dataset.
# It is a MarginContainer that contains a HBoxContainer with all the cells and separators as children.
# There is no class like SortableTableCell. The cell containers are being created and accessed in this script.
# Content that is supposed to be shown in a cell has to be a child of an element of the "CellsArray" array.
# The actual cell (MarginContainer) is wrapped in an extra container (Container) to be able to clip the content.


extends MarginContainer


var column_count
var row_position # position of the row in the table. First row is 1, not 0.
var id # unique id of the representing content
var sort_values = [] # e.g. sort_values[5-1] holds the value that is used to sort column 5

var even = false
var selected = false
var row_height

var SortableTable

# cell references
var CellsClipContainerArray = [] # used to clip the cell content
var CellsArray = [] # references to the actual cells. For appending childs as content.
var CellsColorRectArray = [] # used for highlighting the primary sort column

# row colors
var row_color
var row_color_even 
var row_color_odd 
var row_color_selected 
var row_color_selected_even
var row_color_selected_odd
var row_color_red
var row_color_blue
var row_color_green
var row_color_yellow
var row_color_black

var even_odd_brightness_difference
var hover_brightness_boost

# references to child nodes
onready var HBoxForCells = $"HBoxContainer"
onready var RowBackgroundColorRect = $"BackgroundColor"


# signals
signal row_clicked
signal row_clicked_rmb
signal drag_select





func _ready():
	
	SortableTable = self.get_parent().SortableTable
	
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





######################
### basic row handling
######################


func set_row_position(pos):
	row_position = pos
	update_row_even_or_odd()
	update_row_color_reset()



func update_row_even_or_odd():
	if row_position:
		if (row_position % 2) == 0:
			even = true
		else:
			even = false



func set_selected (sel):
	selected = sel
	if selected:
		update_row_color_select()
	else:
		update_row_color_reset()



func set_row_height(height):
	row_height = height
	rect_min_size.y = height
	set_cell_height(height)





#################
### cell handling
#################


# create the cells
func create_cells():
	
	
	CellsClipContainerArray.clear()
	
	for i in range(column_count):
		
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
		CellMarginContainer.margin_top = 0
		CellMarginContainer.margin_right = 3
		CellMarginContainer.margin_bottom = 0
		CellMarginContainer.rect_min_size.y = row_height
		
		# add the cell to the HBoxContainer and to the CellsClipContainerArray
		CellClipContainer.add_child(CellColorRect)
		CellClipContainer.add_child(CellMarginContainer)
		var HBoxForCells = $"HBoxContainer"
		HBoxForCells.add_child(CellClipContainer)
		CellsClipContainerArray.append(CellClipContainer)
		
		
		# add a line to separate the individual cells visually
		var VerticalLine = VSeparator.new()
		VerticalLine.set_mouse_filter(Control.MOUSE_FILTER_IGNORE)
		HBoxForCells.add_child(VerticalLine)
		
		
	fill_CellArrays()
	
	set_cell_height(row_height)



# put the cell references into arrays
func fill_CellArrays ():
	
	CellsArray.clear()
	
	for Cell in CellsClipContainerArray:
		var CellColorRect = Cell.get_child(0)
		var CellMarginContainer = Cell.get_child(1)
		CellsColorRectArray.append(CellColorRect)
		CellsArray.append(CellMarginContainer)



# add a child node as content to a cell
func set_cell_content(column, child):
	
	if column <= column_count:
		if CellsArray[column-1].get_child_count() > 0: 
			var childs = CellsArray[column-1].get_children() 
			for child in childs: 
				child.queue_free() 
		CellsArray[column-1].add_child(child)



# the width has to be set manually, as the "fill, expand" flag doesn't work with parent container that is used for clipping
func set_cell_width(column, width):
	if column <= column_count:
		CellsClipContainerArray[column-1].rect_min_size.x = width
		CellsColorRectArray[column-1].rect_min_size.x = width



func set_cell_height(height):
	if HBoxForCells != null:
		for ClipContainer in CellsClipContainerArray:
			ClipContainer.rect_min_size.y = height
		for CellMarginContainer in CellsArray:
			CellMarginContainer.rect_min_size.y = HBoxForCells.rect_size.y - CellMarginContainer.margin_left - CellMarginContainer.margin_right
		for CellColorRect in CellsColorRectArray:
			CellColorRect.rect_size.y = HBoxForCells.rect_size.y







##################
### color handling
##################


func set_initial_colors():
	row_color = SortableTable.row_color
	
	row_color_selected = SortableTable.row_color_selected
	row_color_red = SortableTable.row_color_red
	row_color_blue = SortableTable.row_color_blue
	row_color_green = SortableTable.row_color_green
	row_color_yellow = SortableTable.row_color_yellow
	row_color_black = SortableTable.row_color_black
	
	even_odd_brightness_difference = SortableTable.row_brightness_difference
	hover_brightness_boost = SortableTable.hover_brightness_boost
	
	row_color_even = row_color
	row_color_odd = row_color.lightened(even_odd_brightness_difference)
	row_color_selected_even = row_color_selected
	row_color_selected_odd = row_color_selected.lightened(hover_brightness_boost)



func set_row_color_by_string(color_string):
	
	match color_string: 
		"default": set_row_color(row_color)	
		"red": set_row_color(row_color_red)	
		"green": set_row_color(row_color_green)	
		"blue": set_row_color(row_color_blue)
		"yellow": set_row_color(row_color_yellow)	
		"black": set_row_color(row_color_black)		



func set_row_color(color):
	
	row_color_even = color
	row_color_odd = color.lightened(even_odd_brightness_difference)



func modulate_cell_color(column, color):
	CellsColorRectArray[column-1].set_modulate( color )



# highlight the row when hovering it
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



# highlight the row when it is selected
func update_row_color_select():
	if even:
		RowBackgroundColorRect.color = row_color_selected_even
	else:
		RowBackgroundColorRect.color = row_color_selected_odd



# reset row color to default
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






###################
### signal handling
###################


func _on_SortabelTableRow_mouse_entered():
	update_row_color_hover()
	if Input.is_action_pressed("ui_left_mouse_button"):
		emit_signal("drag_select", row_position)



func _on_SortabelTableRow_mouse_exited():
	update_row_color_reset()



func _on_SortabelTableRow_gui_input(ev):
	if ev.is_action_pressed("ui_left_mouse_button"):
		emit_signal("row_clicked", row_position)
	if ev.is_action_pressed("ui_right_mouse_button"):
		emit_signal("row_clicked_rmb", row_position)

