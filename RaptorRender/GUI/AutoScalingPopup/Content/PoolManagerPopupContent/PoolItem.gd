extends MarginContainer

class_name PoolItem


### PRELOAD RESOURCES

### SIGNALS
signal pool_item_clicked
signal pool_item_doubleclicked
signal select_all_pressed

### ONREADY VARIABLES
onready var BgColorRect : ColorRect = $"BgColorRect"
onready var NameLabel : Label = $"Label"
onready var NameLineEdit : LineEdit = $"NameEdit"

### EXPORTED VARIABLES

### VARIABLES
var pool_name : String = ""
var selected : bool = false
var hovered : bool = false




########## FUNCTIONS ##########


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	NameLabel.text = pool_name
	#BgColorRect.color = RRColorScheme.bg_2


func _process(delta : float) -> void:
	if hovered:
		if Input.is_action_just_pressed("select_all"):
			emit_signal("select_all_pressed")


func set_name(name : String) -> void:
	pool_name = name


func get_drag_data(_pos):
	
	# generate a position corrected clone of self
	var drag_preview : Control = Control.new()
	var drag_clone : Node = self.duplicate()
	drag_clone.pool_name = self.pool_name
	drag_clone.rect_position = -self.get_local_mouse_position()
	drag_preview.add_child(drag_clone)
	set_drag_preview(drag_preview)
	
	# hide the source node
	self.visible = false
	
	# Return color as drag data
	return Color(1,1,1,1)


func can_drop_data(_pos, data):
	if _pos.x >=100:
		NameLabel.text = "yeah, drop me!"
	else:
		NameLabel.text = "holla die waldfee"
	return typeof(data) == TYPE_COLOR



#func drop_data(_pos, data):
#	pass
	#color = data


func highlight() -> void:
	if selected:
		BgColorRect.color = RRColorScheme.selected.lightened(0.1)
	else:
		BgColorRect.color = RRColorScheme.bg_2.lightened(0.1)


func remove_highlight() -> void:
	if selected:
		BgColorRect.color = RRColorScheme.selected
	else:
		BgColorRect.color = RRColorScheme.bg_2


func apply_name() -> void:
	pool_name = NameLineEdit.text
	NameLabel.text = pool_name
	NameLineEdit.visible = false


func enter_name_edit_mode() -> void:
	NameLineEdit.visible = true
	NameLineEdit.text = pool_name
	NameLineEdit.select_all()
	NameLineEdit.caret_blink = true
	NameLineEdit.caret_position = NameLineEdit.text.length()
	NameLineEdit.grab_focus()


func exit_and_apply_name_edit_mode() -> void:
	if NameLineEdit.visible:
		apply_name()


func select() -> void:
	selected = true
	BgColorRect.color = RRColorScheme.selected
	
	var mouse_pos : Vector2 = get_viewport().get_mouse_position()
	if self.get_global_rect().has_point(mouse_pos):
		BgColorRect.color = RRColorScheme.selected.lightened(0.1)



func deselect() -> void:
	selected = false
	BgColorRect.color = RRColorScheme.bg_2



func _on_PoolItem_gui_input(event: InputEvent) -> void:
	
	# make name editable on doubleclick
	if event is InputEventMouseButton and event.doubleclick:
		enter_name_edit_mode()
		emit_signal("pool_item_doubleclicked")
	
	# just left clicked
	if event.is_action_pressed("ui_left_mouse_button"):
		emit_signal("pool_item_clicked", self)





func _on_NameEdit_focus_exited() -> void:
	apply_name()



func _on_NameEdit_text_entered(new_text: String) -> void:
	apply_name()



func _on_PoolItem_mouse_entered() -> void:
	hovered = true
	highlight()



func _on_PoolItem_mouse_exited() -> void:
	hovered = false
	remove_highlight()

