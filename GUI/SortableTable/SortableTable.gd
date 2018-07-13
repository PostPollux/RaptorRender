

extends ScrollContainer


export (Array, String) var column_names
export (Array, int) var column_widths_initial
export (int) var sort_column_primary = 1
export (int) var sort_column_secondary = 2
export (int) var row_height = 30

export (Color) var row_color = Color("3c3c3c")
export (Color) var row_color_selected = Color("956248")
export (Color) var row_color_red = Color("643f3b")
export (Color) var row_color_blue = Color("3b5064")
export (Color) var row_color_green = Color("3b5a3b")
export (Color) var row_color_yellow = Color("585a3b")
export (Color) var row_color_black = Color("1d1d1d")


export (float) var row_brightness_difference = 0.05
export (float) var hover_brightness_boost = 0.1

export (String) var table_id = "custom id"

onready var RowScrollContainer = $"VBox_TopRow_Content/RowScrollContainer"
onready var RowContainerFilled = $"VBox_TopRow_Content/RowScrollContainer/VBoxContainer/RowContainerFilled" 
onready var RowContainerEmpty = $ "VBox_TopRow_Content/RowScrollContainer/VBoxContainer/ClipContainerForEmptyRows/RowContainerEmpty"

var previous_scroll_horizontal = 0
var previous_scroll_vertical = 0


var sort_column_primary_reversed = false
var sort_column_secondary_reversed = false

signal refresh_table_content
signal something_just_selected
signal context_invoked




func _ready():
	
	# register to RaptorRender script
	if RaptorRender != null:
		RaptorRender.register_table(self)
	




func _on_SortableTable_gui_input(ev):
			
	if ev.is_action_pressed("ui_mouse_wheel_up_or_down"):
		if Input.is_key_pressed(KEY_SHIFT) or Input.is_key_pressed(KEY_CONTROL):
			RowScrollContainer.scroll_vertical = previous_scroll_vertical
		else:
			self.scroll_horizontal = previous_scroll_horizontal


	
	
func update_amount_of_rows(count): 
	
	RowContainerFilled.update_amount_of_rows(count) 
	RowContainerFilled.update_ids_of_rows()
	RowContainerEmpty.update_ids_of_empty_rows()
	
	
func set_cell_content(row, column, child): 
	RowContainerFilled.set_cell_content(row, column, child)
	
func set_cell_sort_value(row, column, value):
	RowContainerFilled.set_cell_sort_value(row, column, value)
	
	
func set_row_color(row, color):
	RowContainerFilled.set_row_color(row, color)
	
func set_row_color_by_string(row, color_string):
	RowContainerFilled.set_row_color_by_string(row, color_string)
	

func set_row_content_id(row, id): 
	RowContainerFilled.set_row_content_id(row, id) 


func clear_selection():
	RowContainerFilled.clear_selection()
	
	
func select_by_content_id(content_id):
	RowContainerFilled.clear_selection()
	RowContainerFilled.add_content_id_to_selection(content_id)
	RowContainerFilled.update_selection()

func emit_selection_signal(last_selected):
	emit_signal("something_just_selected", last_selected)
	
func emit_ContextMenu_signal():
	emit_signal("context_invoked")
	
func get_selected_content_ids():
	return RowContainerFilled.selected_row_content_ids
	

func refresh():
	RowContainerFilled.reset_all_row_colors_to_default()
	emit_signal("refresh_table_content")
	RowContainerFilled.update_selection()
	
	

func _on_SortableTable_draw():
	previous_scroll_horizontal = self.scroll_horizontal
	previous_scroll_vertical = RowScrollContainer.scroll_vertical
