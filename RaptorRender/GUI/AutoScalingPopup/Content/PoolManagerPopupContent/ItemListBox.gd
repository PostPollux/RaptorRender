extends MarginContainer

class_name ItemListBox

### PRELOAD RESOURCES
var ListBoxItem_Base_res = preload("res://RaptorRender/GUI/AutoScalingPopup/Content/PoolManagerPopupContent/ListBoxItem_Base.tscn")


### SIGNALS
signal item_selected
signal selection_cleared


### ONREADY VARIABLES
onready var ItemVBox : VBoxContainer = $"ItemVBox"


### EXPORTED VARIABLES

### VARIABLES
var SelectedItems : Array = []





########## FUNCTIONS ##########


func _ready() -> void:
	pass



func clear() -> void:
	for child in ItemVBox.get_children():
		child.queue_free()


func clear_immediately() -> void:
	for child in ItemVBox.get_children():
		child.free()


func add_item(name : String, item_id : int) -> void:
	var NewListBoxItem : ListBoxItem_Base = ListBoxItem_Base_res.instance()
	
	NewListBoxItem.set_name(name)
	NewListBoxItem.item_id = item_id
	
	NewListBoxItem.connect("item_clicked", self, "select_item")
	NewListBoxItem.connect("select_all_pressed", self, "select_all")

	ItemVBox.add_child(NewListBoxItem)


func remove_item_by_id (item_id : int) -> void:
	for child in ItemVBox.get_children():
		if item_id == child.item_id:
			child.queue_free()


func remove_item_by_name (item_name : String) -> void:
	for child in ItemVBox.get_children():
		if item_name == child.item_name:
			child.queue_free()






#############
### Selection
#############


func select_item( ClickedItem : Node):
	
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
					var SelectedItem : ListBoxItem_Base = ItemVBox.get_child(i)
					SelectedItem.select()
					if !SelectedItems.has(SelectedItem):
						SelectedItems.append(SelectedItem)
			else:
				for i in range(last_selected_position, position_of_just_clicked_item -1, -1):
					var SelectedItem : ListBoxItem_Base = ItemVBox.get_child(i)
					SelectedItem.select()
					if !SelectedItems.has(SelectedItem):
						SelectedItems.append(SelectedItem)
			
			emit_signal("item_selected", SelectedItems.back().item_id)
		
		
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
