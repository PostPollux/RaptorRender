extends ScrollContainer

var previous_scroll_horizontal = 0

func _ready():
	pass




func _on_SortableTable_gui_input(ev):
			
	if ev.is_action_pressed("ui_mouse_wheel_up_or_down"):
		self.scroll_horizontal = previous_scroll_horizontal




func _on_SortableTable_draw():
	previous_scroll_horizontal = self.scroll_horizontal
