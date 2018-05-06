

extends ScrollContainer


export (Array, String) var column_names
export (Array, int) var column_widths_initial
export (int) var sort_column_primary = 1
export (int) var sort_column_secondary = 2
export (int) var row_height = 30

export (Color) var row_color = Color("3c3c3c")
export (Color) var row_color_selected = Color("956248")
export (float) var row_brightness_difference = 0.05
export (float) var hover_brightness_boost = 0.1

export (String) var table_id = "custom id"

onready var RowScrollContainer = $"VBox_TopRow_Content/RowScrollContainer"
onready var RowContainerFilled = $"VBox_TopRow_Content/RowScrollContainer/VBoxContainer/RowContainerFilled" 


var previous_scroll_horizontal = 0
var previous_scroll_vertical = 0


var sort_column_primary_reversed = false
var sort_column_secondary_reversed = false

signal refresh_table_content




func _ready():
	
	# register to RaptorRender script
	if RaptorRender != null:
		RaptorRender.register_table(self)
	
	create_rows(16)




func _on_SortableTable_gui_input(ev):
			
	if ev.is_action_pressed("ui_mouse_wheel_up_or_down"):
		if !Input.is_key_pressed(KEY_CONTROL):
			self.scroll_horizontal = previous_scroll_horizontal
		else:
			RowScrollContainer.scroll_vertical = previous_scroll_vertical



func create_rows(count): 
	RowContainerFilled.add_rows_and_delete_previous(count) 
	RowContainerFilled.update_ids_of_rows()
 
func set_cell_content(row, column, child): 
	RowContainerFilled.set_cell_content(row, column, child) 




func _on_SortableTable_draw():
	previous_scroll_horizontal = self.scroll_horizontal
	previous_scroll_vertical = RowScrollContainer.scroll_vertical


func refresh():
	emit_signal("refresh_table_content")
