#//////////////////#
# SortableTableRow #
#//////////////////#

# The SortableTableRow represents just one row in the table showing one dataset.
# It is a MarginContainer that contains a HBoxContainer with all the cells and separators as children.
# There is no class like SortableTableCell. The cell containers are being created and accessed in this script.
# Content that is supposed to be shown in a cell has to be a child of an element of the "CellsArray" array.
# The actual cell (MarginContainer) is wrapped in an extra container (Container) to be able to clip the content.


extends MarginContainer

class_name SortableTableRow


### PRELOAD RESOURCES

### SIGNALS
signal row_clicked
signal row_clicked_rmb
signal drag_select
signal select_all_pressed

### ONREADY VARIABLES
onready var HBoxForCells : HBoxContainer = $"HBoxContainer"
onready var RowBackgroundColorRect : ColorRect = $"BackgroundColor"

### EXPORTED VARIABLES

### VARIABLES
var column_count : int
var row_position : int # position of the row in the table. First row is 1, not 0.
var id : int # unique id of the representing content
var sort_values : Array = [] # e.g. sort_values[5-1] holds the value that is used to sort column 5

var even : bool = false
var selected : bool = false
var hovered : bool = false
var row_height : int = 30

# cell references
var CellsClipContainerArray : Array  = [] # used to clip the cell content
var CellsArray : Array = [] # references to the actual cells. For appending childs as content.
var CellsColorRectArray : Array = [] # used for highlighting the primary sort column

# row colors
var row_color : Color = Color("3c3c3c")
var row_color_selected : Color = Color("956248")
var row_color_red : Color = Color("643f3b")
var row_color_blue : Color = Color("3b5064")
var row_color_green : Color = Color("3b5a3b")
var row_color_yellow : Color = Color("585a3b")
var row_color_black : Color = Color("1d1d1d")

var even_odd_brightness_difference : float = 0.05
var hover_brightness_boost : float = 0.1

var row_color_even : Color
var row_color_odd : Color
var row_color_selected_even : Color
var row_color_selected_odd : Color




########## FUNCTIONS ##########


func _ready():
	set_additional_colors()
	update_row_even_or_odd()
	update_row_color()


func _process(delta : float) -> void:
	if hovered:
		if Input.is_action_just_pressed("select_all"):
			emit_signal("select_all_pressed")



######################
### basic row handling
######################


func set_row_position(pos : int):
	row_position = pos
	update_row_even_or_odd()
	update_row_color()



func update_row_even_or_odd():
	if row_position:
		if (row_position % 2) == 0:
			even = true
		else:
			even = false



func set_selected (sel : bool):
	selected = sel
	if selected:
		update_row_color_select()
	else:
		update_row_color()



func set_row_height(height : int):
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
		
		var CellClipContainer : Container = Container.new()
		CellClipContainer.name = "cell_clip_container_" + String(i+1)
		CellClipContainer.rect_clip_content = true
		CellClipContainer.set_v_size_flags(3) # fill + expand
		CellClipContainer.set_mouse_filter(Control.MOUSE_FILTER_IGNORE)
		
		var CellColorRect : ColorRect = ColorRect.new()
		CellColorRect.name = "cell_color_rect"
		CellColorRect.set_mouse_filter(Control.MOUSE_FILTER_IGNORE)
		CellColorRect.set_v_size_flags(3) # fill + expand
		CellColorRect.set_h_size_flags(3) # fill + expand
		CellColorRect.rect_min_size.y = row_height
		CellColorRect.set_modulate(Color("00ffffff"))
		
		var CellMarginContainer : MarginContainer = MarginContainer.new()
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
		var HBoxForCells : HBoxContainer = $"HBoxContainer"
		HBoxForCells.add_child(CellClipContainer)
		CellsClipContainerArray.append(CellClipContainer)
		
		
		# add a line to separate the individual cells visually
		var VerticalLine : VSeparator = VSeparator.new()
		VerticalLine.set_mouse_filter(Control.MOUSE_FILTER_IGNORE)
		HBoxForCells.add_child(VerticalLine)
		
		
	fill_CellArrays()
	
	set_cell_height(row_height)



# put the cell references into arrays
func fill_CellArrays ():
	
	CellsArray.clear()
	
	for Cell in CellsClipContainerArray:
		var CellColorRect : ColorRect = Cell.get_child(0)
		var CellMarginContainer : MarginContainer = Cell.get_child(1)
		CellsColorRectArray.append(CellColorRect)
		CellsArray.append(CellMarginContainer)



# add a child node as content to a cell
func set_cell_content(column : int, child : Node):
	
	if column <= column_count:
		if CellsArray[column-1].get_child_count() > 0: 
			var childs : Array = CellsArray[column-1].get_children() 
			for child in childs: 
				child.queue_free() 
		CellsArray[column-1].add_child(child)



# the width has to be set manually, as the "fill, expand" flag doesn't work with parent container that is used for clipping
func set_cell_width(column : int, width : int):
	if column <= column_count:
		CellsClipContainerArray[column-1].rect_min_size.x = width
		CellsColorRectArray[column-1].rect_min_size.x = width



func set_cell_height(height : int):
	
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


func set_additional_colors():
	
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



func set_row_color(color : Color):
	
	row_color_even = color
	row_color_odd = color.lightened(even_odd_brightness_difference)



func modulate_cell_color(column : int, color : Color):
	CellsColorRectArray[column - 1].set_modulate( color )



# highlight the row when it is selected
func update_row_color_select():
	if even:
		RowBackgroundColorRect.color = row_color_selected_even
	else:
		RowBackgroundColorRect.color = row_color_selected_odd



# reset row color to default
func update_row_color():
	if selected: 
	
		if hovered:
			
			if even:
				RowBackgroundColorRect.color = row_color_selected_even.lightened(hover_brightness_boost * 2)
			else:
				RowBackgroundColorRect.color = row_color_selected_odd.lightened(hover_brightness_boost)
		else:
			if even:
				RowBackgroundColorRect.color = row_color_selected_even
			else:
				RowBackgroundColorRect.color = row_color_selected_odd
			
	else:
		if hovered:
			
			if even:
				RowBackgroundColorRect.color = row_color_even.lightened(hover_brightness_boost * 1.5)
			else:
				RowBackgroundColorRect.color = row_color_odd.lightened(hover_brightness_boost)
		else:
			if even:
				RowBackgroundColorRect.color = row_color_even
			else:
				RowBackgroundColorRect.color = row_color_odd




###################
### signal handling
###################


func _on_SortabelTableRow_mouse_entered():
	hovered = true
	update_row_color()
	if Input.is_action_pressed("ui_left_mouse_button"):
		emit_signal("drag_select", row_position)



func _on_SortabelTableRow_mouse_exited():
	hovered = false
	update_row_color()



func _on_SortabelTableRow_gui_input(ev : InputEvent):
	if ev.is_action_pressed("ui_left_mouse_button"):
		emit_signal("row_clicked", row_position)
	if ev.is_action_pressed("ui_right_mouse_button"):
		emit_signal("row_clicked_rmb", row_position)


# this is just a workaround. If we don't have this and we start to click and drag, mouse_entered and mouse_exited signals won't be executed on other nodes.
# with this added they get executed as expected!
func get_drag_data(_pos):
	return "workaround"
