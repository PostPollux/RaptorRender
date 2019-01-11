extends VSeparator

signal just_clicked

var splitter_id = 0

func _ready():
	pass


func _on_ColumnSplitter_gui_input(ev):
	if ev.is_action_pressed("ui_left_mouse_button"):
		emit_signal("just_clicked", splitter_id)

