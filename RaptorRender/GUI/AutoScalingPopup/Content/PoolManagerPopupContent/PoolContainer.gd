extends MarginContainer



### PRELOAD RESOURCES
var PoolItemRes = preload("res://RaptorRender/GUI/AutoScalingPopup/Content/PoolManagerPopupContent/PoolItem.tscn")

### SIGNALS
signal clicked
signal doubleclicked

### ONREADY VARIABLES
onready var BgColorRect : ColorRect = $"BgColorRect"
onready var PoolItemVBoxContainer : VBoxContainer = $"PoolItemVBoxContainer"


### EXPORTED VARIABLES

### VARIABLES
var SelectedPoolItems : Array = []




########## FUNCTIONS ##########


func _ready() -> void:
	load_existing_pools()
	pass 



func clear() -> void:
	for child in PoolItemVBoxContainer.get_children():
		child.queue_free()


func load_existing_pools() -> void:
	
	for pool in RaptorRender.rr_data.pools.keys():
		
		var NewPoolItem : PoolItem = PoolItemRes.instance()	
		
		NewPoolItem.set_name(RaptorRender.rr_data.pools[pool].name)
		
		# connect signals to enable selecting 
		NewPoolItem.connect("pool_item_clicked", self, "select_PoolItem")
		NewPoolItem.connect("select_all_pressed", self, "select_all")
		
		PoolItemVBoxContainer.add_child(NewPoolItem)




func create_new_pool_item() -> void:
	
	var NewPoolItem : PoolItem = PoolItemRes.instance()
	
	var name : String = "new pool"
	
	NewPoolItem.set_name("new pool")
	
	# connect signals to enable selecting 
	NewPoolItem.connect("pool_item_clicked", self, "select_PoolItem")
	NewPoolItem.connect("select_all_pressed", self, "select_all")
	
	PoolItemVBoxContainer.add_child(NewPoolItem)
	
	NewPoolItem.select()
	SelectedPoolItems.append(NewPoolItem)



func delete_pools() -> void:
	for DelPoolItem in PoolItemVBoxContainer.get_children():
		if DelPoolItem.selected == true:
			DelPoolItem.queue_free()



func _on_Create_Button_pressed() -> void:
	clear_selection()
	create_new_pool_item()




func _on_Delete_Button_pressed() -> void:
	delete_pools()



#############
### Selection
#############


func select_PoolItem( ClickedPoolItem : Node):
	
	if Input.is_key_pressed(KEY_CONTROL):
		
		exit_and_apply_name_edit_mode_for_all_items(ClickedPoolItem)
		
		if ClickedPoolItem.selected == true:
			ClickedPoolItem.deselect()
			SelectedPoolItems.erase(ClickedPoolItem)
		else:
			ClickedPoolItem.select()
			SelectedPoolItems.append(ClickedPoolItem)
		
		
	elif Input.is_key_pressed(KEY_SHIFT):
		
		exit_and_apply_name_edit_mode_for_all_items(ClickedPoolItem)
		
		var last_selected_position : int = 0
		last_selected_position = SelectedPoolItems.back().get_position_in_parent()
		var position_of_just_clicked_item : int = ClickedPoolItem.get_position_in_parent()
		
		if last_selected_position < position_of_just_clicked_item:
			for i in range(last_selected_position, position_of_just_clicked_item + 1, 1):
				PoolItemVBoxContainer.get_child(i).select()
		else:
			for i in range(last_selected_position, position_of_just_clicked_item -1, -1):
				PoolItemVBoxContainer.get_child(i).select()
			
		
	else:
		clear_selection()
		exit_and_apply_name_edit_mode_for_all_items(ClickedPoolItem)
		
		ClickedPoolItem.select()
		SelectedPoolItems.append(ClickedPoolItem)






func select_all():
	
	# select or deselect all pool items depending on wheter all are already selected or not
	if SelectedPoolItems.size() != PoolItemVBoxContainer.get_child_count():
		
		for child in PoolItemVBoxContainer.get_children():
			if child.selected == false:
				child.select()
				SelectedPoolItems.append(child)
		
	else:
		clear_selection()



func clear_selection():
	
	SelectedPoolItems.clear()
	
	for child in PoolItemVBoxContainer.get_children():
		if child.selected == true:
			child.deselect()


func exit_and_apply_name_edit_mode_for_all_items(currently_clicked : Node) -> void:
	
	for child in PoolItemVBoxContainer.get_children():
		
		# don't exit on the clicked one itself. Otherwise we could not enter that mode with a double click at all...
		if child != currently_clicked:
			child.exit_and_apply_name_edit_mode()

