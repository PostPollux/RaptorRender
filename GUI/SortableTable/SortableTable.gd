tool

extends ScrollContainer


export (Array, String) var column_names
export (int) var sort_column = 1

onready var RowScrollContainer = $"VBoxContainer/RowScrollContainer"



var previous_scroll_horizontal = 0
var previous_scroll_vertical = 0



#onready var TopRow = $"VBoxContainer/TopRow"
#onready var RowContainerFilled = $"VBoxContainer/RowScrollContainer/VBoxContainer/RowContainerFilled"
#onready var RowContainerEmpty = $"VBoxContainer/RowScrollContainer/VBoxContainer/ClipContainerForEmptyRows/RowContainerEmpty"



func _ready():
	pass




func _on_SortableTable_gui_input(ev):
			
	if ev.is_action_pressed("ui_mouse_wheel_up_or_down"):
		if !Input.is_key_pressed(KEY_CONTROL):
			self.scroll_horizontal = previous_scroll_horizontal
		else:
			RowScrollContainer.scroll_vertical = previous_scroll_vertical




func _on_SortableTable_draw():
	previous_scroll_horizontal = self.scroll_horizontal
	previous_scroll_vertical = RowScrollContainer.scroll_vertical
