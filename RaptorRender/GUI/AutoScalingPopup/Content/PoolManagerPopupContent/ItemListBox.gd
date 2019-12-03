extends MarginContainer

class_name ItemListBox

### PRELOAD RESOURCES
var ItemListBoxItemRes = preload("res://RaptorRender/GUI/AutoScalingPopup/Content/PoolManagerPopupContent/ItemListBoxItem.tscn")


### SIGNALS
signal item_selected
signal selection_cleared
signal item_name_changed
signal item_doubleclicked


### ONREADY VARIABLES
onready var ItemVBox : VBoxContainer = $"ItemVBox"


### EXPORTED VARIABLES

### VARIABLES
var SelectedItems : Array = []

var item_names_editable : bool = false
var items_dragable : bool = false
var item_bg_color_normal : Color = Color(0.001, 0, 0, 1)
var item_bg_color_selected : Color = Color(0.001, 0, 0, 1)





########## FUNCTIONS ##########


func _ready() -> void:
	
	if item_bg_color_normal == Color(0.001, 0, 0, 1):
		item_bg_color_normal = RRColorScheme.bg_1
		
	if item_bg_color_selected == Color(0.001, 0, 0, 1):
		item_bg_color_selected = RRColorScheme.selected



func clear() -> void:
	for child in ItemVBox.get_children():
		child.queue_free()
	SelectedItems.clear()


func clear_immediately() -> void:
	for child in ItemVBox.get_children():
		child.free()
	SelectedItems.clear()



func add_item(name : String, item_id : int) -> ItemListBoxItem:
	var NewListBoxItem : ItemListBoxItem = ItemListBoxItemRes.instance()
	
	NewListBoxItem.set_name(name)
	NewListBoxItem.item_id = item_id
	NewListBoxItem.name_editable = item_names_editable
	NewListBoxItem.dragable = items_dragable
	NewListBoxItem.color_normal = item_bg_color_normal
	NewListBoxItem.color_selected = item_bg_color_selected
	
	NewListBoxItem.connect("item_clicked", self, "select_item")
	NewListBoxItem.connect("item_doubleclicked", self, "item_doubleclicked")
	NewListBoxItem.connect("select_all_pressed", self, "select_all")
	NewListBoxItem.connect("drag_select", self, "drag_select_item")
	NewListBoxItem.connect("name_changed", self, "item_name_changed")
	
	ItemVBox.add_child(NewListBoxItem)
	
	return NewListBoxItem



func has_items() -> bool:
	return ItemVBox.get_child_count() > 0


func get_first_item() -> ItemListBoxItem:
	if ItemVBox.get_child_count() > 0:
		return ItemVBox.get_child(0) as ItemListBoxItem
	return null


func get_all_items() -> Array:
	return ItemVBox.get_children()



func remove_item_by_id (item_id : int) -> void:
	for child in ItemVBox.get_children():
		if item_id == child.item_id:
			SelectedItems.erase(child)
			child.queue_free()


func remove_item_by_name (item_name : String) -> void:
	for child in ItemVBox.get_children():
		if item_name == child.item_name:
			SelectedItems.erase(child)
			child.queue_free()


func exit_and_apply_name_edit_mode_for_all_items(currently_clicked : Node) -> void:
	
	for child in ItemVBox.get_children():
		
		# don't exit on the clicked one itself. Otherwise we could not enter that mode with a double click at all...
		if child != currently_clicked:
			child.exit_and_apply_name_edit_mode()


func item_doubleclicked(item_id : int) -> void:
	emit_signal("item_doubleclicked", item_id)


func item_name_changed(item_id : int) -> void:
	emit_signal("item_name_changed", item_id)


#############
### Selection
#############


func select_item( ClickedItem : Node):
	
	exit_and_apply_name_edit_mode_for_all_items(ClickedItem)
	
	if Input.is_key_pressed(KEY_CONTROL):
		
		
		if ClickedItem.selected == true:
			ClickedItem.deselect()
			SelectedItems.erase(ClickedItem)
			if SelectedItems.size() == 0:
				emit_signal("selection_cleared")
			else:
				emit_signal("item_selected", SelectedItems.back().item_id)
		else:
			ClickedItem.select()
			SelectedItems.append(ClickedItem)
			emit_signal("item_selected", ClickedItem.item_id)
		
		
	elif Input.is_key_pressed(KEY_SHIFT):
		
		if SelectedItems.size() > 0:
			var last_selected_position : int = 0
			last_selected_position = SelectedItems.back().get_position_in_parent()
			var position_of_just_clicked_item : int = ClickedItem.get_position_in_parent()
			
			if last_selected_position < position_of_just_clicked_item:
				for i in range(last_selected_position, position_of_just_clicked_item + 1, 1):
					var SelectedItem : ItemListBoxItem = ItemVBox.get_child(i)
					SelectedItem.select()
					if !SelectedItems.has(SelectedItem):
						SelectedItems.append(SelectedItem)
			else:
				for i in range(last_selected_position, position_of_just_clicked_item -1, -1):
					var SelectedItem : ItemListBoxItem = ItemVBox.get_child(i)
					SelectedItem.select()
					if !SelectedItems.has(SelectedItem):
						SelectedItems.append(SelectedItem)
			
			emit_signal("item_selected", SelectedItems.back().item_id)
		
		
	else:
		clear_selection()
		
		ClickedItem.select()
		SelectedItems.append(ClickedItem)
		emit_signal("item_selected", ClickedItem.item_id)



func drag_select_item(ClickedItem : ItemListBoxItem):
	
	if Input.is_key_pressed(KEY_CONTROL):
		ClickedItem.deselect()
		SelectedItems.erase(ClickedItem)
		
		
	elif Input.is_key_pressed(KEY_SHIFT):
		if ClickedItem.selected == false:
			ClickedItem.select()
			SelectedItems.append(ClickedItem)
		
	else:
		clear_selection()
		
		ClickedItem.select()
		SelectedItems.append(ClickedItem)
		emit_signal("item_selected", ClickedItem.item_id)




func select_all():
	
	# select or deselect all pool items depending on wheter all are already selected or not
	if SelectedItems.size() != ItemVBox.get_child_count():
		
		for child in ItemVBox.get_children():
			if child.selected == false:
				child.select()
				SelectedItems.append(child)
		
		emit_signal("item_selected", SelectedItems.back().item_id)
		
	else:
		clear_selection()



func clear_selection():
	
	SelectedItems.clear()
	
	for child in ItemVBox.get_children():
		if child.selected == true:
			child.deselect()
	
	emit_signal("selection_cleared")
