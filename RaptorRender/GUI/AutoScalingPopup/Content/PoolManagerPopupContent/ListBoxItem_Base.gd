extends MarginContainer

class_name ListBoxItem_Base

### PRELOAD RESOURCES

### SIGNALS
signal item_clicked
signal item_doubleclicked
signal select_all_pressed

### ONREADY VARIABLES
onready var BgColorRect : ColorRect = $"BgColorRect"
onready var NameLabel : Label = $"MarginContainer/Label"

### EXPORTED VARIABLES

### VARIABLES
var item_name : String = ""
var item_id : int
var selected : bool = false
var hovered : bool = false

var color_normal : Color = RRColorScheme.bg_1
var color_selected : Color = RRColorScheme.selected




########## FUNCTIONS ##########


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if item_name != "":
		NameLabel.text = item_name


func _process(delta : float) -> void:
	if hovered:
		if Input.is_action_just_pressed("select_all"):
			emit_signal("select_all_pressed")


func set_name(name : String) -> void:
	item_name = name
	if is_instance_valid(NameLabel):
		NameLabel.text = item_name



func highlight() -> void:
	if selected:
		BgColorRect.color = color_selected.lightened(0.1)
	else:
		BgColorRect.color = color_normal.lightened(0.1)


func remove_highlight() -> void:
	if selected:
		BgColorRect.color = color_selected
	else:
		BgColorRect.color = color_normal




func select() -> void:
	selected = true
	BgColorRect.color = color_selected
	
	var mouse_pos : Vector2 = get_viewport().get_mouse_position()
	if self.get_global_rect().has_point(mouse_pos):
		BgColorRect.color = color_selected.lightened(0.1)



func deselect() -> void:
	selected = false
	BgColorRect.color = color_normal


# this is just a workaround. If we don't have this and we start to click and drag, mouse_entered and mouse_exited signals won't be executed on other nodes.
# with this added they get executed as expected!
func get_drag_data(_pos):
	return "workaround"


func _on_Item_mouse_entered() -> void:
	hovered = true
	highlight()


func _on_Item_mouse_exited() -> void:
	hovered = false
	remove_highlight()


func _on_Item_gui_input(event: InputEvent) -> void:
	
	# signal for doubleclick
	if event is InputEventMouseButton and event.doubleclick:
		emit_signal("item_doubleclicked")
	
	# signal for left clicked
	if event.is_action_pressed("ui_left_mouse_button"):
		emit_signal("item_clicked", self)
