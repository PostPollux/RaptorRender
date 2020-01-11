extends MarginContainer

class_name ItemListBoxItem

### PRELOAD RESOURCES

### SIGNALS
signal item_clicked
signal item_doubleclicked
signal select_all_pressed
signal drag_select
signal name_changed

### ONREADY VARIABLES
onready var BgColorRect : ColorRect = $"BgColorRect"
onready var NameLabel : Label = $"MarginContainer/Label"
onready var NameLineEdit : LineEdit = $"MarginContainer/NameEdit"

### EXPORTED VARIABLES

### VARIABLES
var item_name : String = ""
var item_id : int
var selected : bool = false
var hovered : bool = false

var color_normal : Color = RRColorScheme.bg_1
var color_selected : Color = RRColorScheme.selected

var dragable : bool = false
var name_editable : bool = false




########## FUNCTIONS ##########


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	BgColorRect.color = color_normal
	
	if item_name == "":
		item_name = name
	
	NameLabel.text = item_name
	
	DragManager.connect("drag_ended", self, "drag_just_ended")


func _process(delta : float) -> void:
	if hovered:
		if Input.is_action_just_pressed("select_all"):
			emit_signal("select_all_pressed")


# ony used for drag and drop
func override_color(color : Color) -> void:
	BgColorRect.color = color


func set_colors(bg_color_normal : Color, bg_color_selected : Color) -> void:
	color_normal = bg_color_normal
	color_selected = bg_color_selected
	BgColorRect.color = color_normal


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


func get_drag_data(_pos):
	
	if dragable:
		DragManager.currently_dragging = true
		
		# generate a position corrected clone of self
		var drag_preview : Control = Control.new()
		var drag_clone : ItemListBoxItem = self.duplicate()
		drag_clone.item_name = self.item_name
		drag_clone.rect_position = -self.get_local_mouse_position()
		drag_preview.add_child(drag_clone)
		set_drag_preview(drag_preview)
		drag_clone.override_color(RRColorScheme.selected)
		
		# hide the source node
		self.modulate = Color(1, 1, 1, 0.3)
		
		# Return self as drag data
		return self
	
	# Still return something. This is just a workaround. If we don't have this and we start to click and drag, mouse_entered and mouse_exited signals won't be executed on other nodes.
	# with this added they get executed as expected!
	else:
		return "workaround"



func can_drop_data(_pos, data):
	return typeof(data) == TYPE_OBJECT



func drop_data(_pos, data) -> void:
	if dragable:
		var desired_position : int = self.get_position_in_parent()
		self.get_parent().move_child(data, desired_position)
		data.modulate = Color(1, 1, 1, 1)


func drag_just_ended() -> void:
	if dragable:
		self.modulate = Color(1, 1, 1, 1)



func apply_name() -> void:
	if name_editable:
		NameLineEdit.visible = false
		if NameLineEdit.text != "" and item_name != NameLineEdit.text:
			item_name = NameLineEdit.text
			NameLabel.text = item_name
			emit_signal("name_changed", self)


func enter_name_edit_mode() -> void:
	if name_editable:
		NameLineEdit.visible = true
		NameLineEdit.text = item_name
		NameLineEdit.select_all()
		NameLineEdit.caret_blink = true
		NameLineEdit.caret_position = NameLineEdit.text.length()
		NameLineEdit.grab_focus()


func exit_and_apply_name_edit_mode() -> void:
	if name_editable:
		if NameLineEdit.visible:
			apply_name()




func _on_Item_mouse_entered() -> void:
	hovered = true
	highlight()
	if dragable == false:
		if Input.is_action_pressed("ui_left_mouse_button"):
			emit_signal("drag_select", self)


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



func _on_NameEdit_text_entered(new_text: String) -> void:
	apply_name()


func _on_NameEdit_focus_exited() -> void:
	apply_name()


func _on_Item_item_doubleclicked() -> void:
	if name_editable:
		enter_name_edit_mode()
