extends MarginContainer

class_name ItemListBox

### PRELOAD RESOURCES
var ItemListBoxItemRes = preload("ItemListBoxItem.tscn")


### SIGNALS
signal item_selected
signal selection_cleared
signal item_name_changed
signal item_doubleclicked


### ONREADY VARIABLES
onready var ItemVBox : VBoxContainer = $"ItemVBox"
onready var BoxBackgroundColorRect : ColorRect = $"BGColorRect"


### EXPORTED VARIABLES
export (bool) var item_names_editable : bool = false
export (bool) var items_dragable : bool = false


### VARIABLES
var SelectedItems : Array = []
var hovered : bool = false

var item_bg_color_normal : Color = RRColorScheme.bg_1
var item_bg_color_selected : Color = RRColorScheme.selected





########## FUNCTIONS ##########

func _ready() -> void:
	for item in ItemVBox.get_children():
		item.name_editable = item_names_editable
		item.dragable = items_dragable


func _process(delta : float) -> void:
	
	if hovered:
		
		if Input.is_action_just_pressed("select_all"):
			
			# check if mouse is really hovering the box. Because in some circumstances the mouse exited event doesn't fire
			if self.get_global_rect().has_point( get_viewport().get_mouse_position() ):
				select_all()
			else:
				hovered = false



func get_all_items() -> Array:
	return ItemVBox.get_children()



func update_colors(bg_color : Color, item_color_normal : Color, item_color_selected : Color) -> void:
	item_bg_color_normal = item_color_normal
	item_bg_color_selected = item_color_selected
	
	BoxBackgroundColorRect.color = bg_color
	
	for Item in get_all_items():
		Item.set_colors(item_color_normal, item_color_selected)




func clear() -> void:
	for Item in get_all_items():
		Item.queue_free()
	SelectedItems.clear()


func clear_immediately() -> void:
	for Item in get_all_items():
		Item.free()
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



func remove_item_by_id (item_id : int) -> void:
	for Item in get_all_items():
		if item_id == Item.item_id:
			SelectedItems.erase(Item)
			Item.queue_free()



func remove_item_by_name (item_name : String) -> void:
	for Item in get_all_items():
		if item_name == Item.item_name:
			SelectedItems.erase(Item)
			Item.queue_free()



func exit_and_apply_name_edit_mode_for_all_items(currently_clicked : Node) -> void:
	
	for Item in get_all_items():
		
		# don't exit on the clicked one itself. Otherwise we could not enter that mode with a double click at all...
		if Item != currently_clicked:
			Item.exit_and_apply_name_edit_mode()



func item_doubleclicked(item_id : int) -> void:
	emit_signal("item_doubleclicked", item_id)



func item_name_changed(Item : ItemListBoxItem) -> void:
	emit_signal("item_name_changed", Item)



func sort_items_by_name() -> void:
	
	var sort_array : Array = []
	
	# create the array to sort
	for Item in self.get_all_items():
	
		sort_array.append([Item, Item.item_name.to_lower()])
	
	# sort the array
	sort_array.sort_custom ( self, "items_custom_sort" )
	
	# update the table by moving the row nodes
	var item_position : int = 0
	
	for item in sort_array:
		ItemVBox.move_child(item[0], item_position)
		item_position += 1



func items_custom_sort(a, b) -> bool:
	return a[1] < b[1]
	




#############
### Selection
#############


func select_item( ClickedItem : Node) -> void:
	
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



func drag_select_item(ClickedItem : ItemListBoxItem) -> void:
	
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




func select_all() -> void:
	
	# select or deselect all pool items depending on wheter all are already selected or not
	if SelectedItems.size() != ItemVBox.get_child_count():
		
		for Item in get_all_items():
			if Item.selected == false:
				Item.select()
				SelectedItems.append(Item)
		
		emit_signal("item_selected", SelectedItems.back().item_id)
		
	else:
		clear_selection()



func clear_selection() -> void:
	
	SelectedItems.clear()
	
	for Item in get_all_items():
		if Item.selected == true:
			Item.deselect()
	
	emit_signal("selection_cleared")




func _on_ItemListBox_mouse_entered() -> void:
	hovered = true


func _on_ItemListBox_mouse_exited() -> void:
	hovered = false
