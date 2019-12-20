extends VSeparator

### PRELOAD RESOURCES

### SIGNALS
signal just_clicked

### ONREADY VARIABLES

### EXPORTED VARIABLES

### VARIABLES
var splitter_id : int = 0
var active : bool = true




########## FUNCTIONS ##########


func _ready() -> void:
	if active:
		mouse_default_cursor_shape = Control.CURSOR_HSPLIT
	else:
		mouse_default_cursor_shape = Control.CURSOR_ARROW


func _on_ColumnSplitter_gui_input(ev) -> void:
	if ev.is_action_pressed("ui_left_mouse_button"):
		emit_signal("just_clicked", splitter_id)

