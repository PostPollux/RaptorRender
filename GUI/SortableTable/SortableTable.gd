tool

extends ScrollContainer


export (Array, String) var column_names
export (int) var sort_column = 1





var previous_scroll_horizontal = 0



#onready var TopRow = $"VBoxContainer/TopRow"
#onready var RowContainerFilled = $"VBoxContainer/RowScrollContainer/VBoxContainer/RowContainerFilled"
#onready var RowContainerEmpty = $"VBoxContainer/RowScrollContainer/VBoxContainer/ClipContainerForEmptyRows/RowContainerEmpty"



func _ready():
	pass




func _on_SortableTable_gui_input(ev):
			
	if ev.is_action_pressed("ui_mouse_wheel_up_or_down"):
		self.scroll_horizontal = previous_scroll_horizontal




func _on_SortableTable_draw():
	previous_scroll_horizontal = self.scroll_horizontal
