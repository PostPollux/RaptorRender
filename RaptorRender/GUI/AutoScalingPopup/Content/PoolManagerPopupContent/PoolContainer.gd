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

func _process(delta : float) -> void:
	if self.visible:
		if Input.is_action_just_pressed("select_all"):
			var mouse_pos : Vector2 = get_viewport().get_mouse_position()
			var PoolItemVBoxContainer_rect : Rect2 = PoolItemVBoxContainer.get_global_rect()
			if PoolItemVBoxContainer_rect.has_point(mouse_pos):
				select_all()



func clear() -> void:
	for child in PoolItemVBoxContainer.get_children():
		child.queue_free()


func load_existing_pools() -> void:
	
	for pool in RaptorRender.rr_data.pools.keys():
		
		var NewPoolItem : PoolItem = PoolItemRes.instance()	
		
		NewPoolItem.set_name(RaptorRender.rr_data.pools[pool].name)
		
		# connect signals to enable selecting 
		NewPoolItem.connect("pool_item_clicked", self, "select_PoolItem")
		
		PoolItemVBoxContainer.add_child(NewPoolItem)




func create_new_pool_item() -> void:
	
	var NewPoolItem : PoolItem = PoolItemRes.instance()
	
	var name : String = "new pool"
	
	NewPoolItem.set_name("new pool")
	
	# connect signals to enable selecting 
	NewPoolItem.connect("pool_item_clicked", self, "select_PoolItem")
	
	PoolItemVBoxContainer.add_child(NewPoolItem)


func delete_pools() -> void:
	for DelPoolItem in PoolItemVBoxContainer.get_children():
		if DelPoolItem.selected == true:
			DelPoolItem.queue_free()



func _on_Create_Button_pressed() -> void:
	create_new_pool_item()




func _on_Delete_Button_pressed() -> void:
	delete_pools()



#############
### Selection
#############


func select_PoolItem( ClickedPoolItem : Node):
	
	if Input.is_key_pressed(KEY_CONTROL):
		if ClickedPoolItem.selected == true:
			ClickedPoolItem.deselect()
			SelectedPoolItems.erase(ClickedPoolItem)
		else:
			ClickedPoolItem.select()
			SelectedPoolItems.append(ClickedPoolItem)

		
		
#	elif Input.is_key_pressed(KEY_SHIFT):
#
#		if selected_row_ids.size() > 0:
#
#			var previous_selected_row_position : int = 0
#
#			for Row in SortableRows:
#				if Row.id == selected_row_ids[selected_row_ids.size() - 1]:
#					previous_selected_row_position = Row.row_position
#
#			if row_position > previous_selected_row_position:
#
#				for i in range(previous_selected_row_position, row_position + 1):
#					if SortableRows[i-1].selected == false:
#						SortableRows[i-1].set_selected(true)
#						selected_row_ids.append(SortableRows[i-1].id)
#
#			if row_position < previous_selected_row_position:
#
#				for i in range(row_position, previous_selected_row_position):
#					if SortableRows[i-1].selected == false:
#						SortableRows[i-1].set_selected(true)
#						selected_row_ids.append(SortableRows[i-1].id)
#		else:
#			ClickedRow.set_selected(true)
#			selected_row_ids.append(ClickedRow.id)
#
#	else:
#		for Row in SortableRows:
#			Row.set_selected(false)
#		selected_row_ids.clear()
#
#		ClickedRow.set_selected(true)
#		selected_row_ids.append(ClickedRow.id)
#
#	# emit correct signal
#	if selected_row_ids.size() > 0:
#		SortableTable.emit_selection_signal( selected_row_ids[selected_row_ids.size() - 1] )
#	else:
#		SortableTable.emit_selection_cleared_signal()




#func drag_select_SortableRows(row_position : int):
#
#	var DragedRow : SortableTableRow = SortableRows[row_position - 1]
#
#	if Input.is_key_pressed(KEY_CONTROL):
#		DragedRow.set_selected(false)
#		selected_row_ids.erase(DragedRow)
#
#
#	elif Input.is_key_pressed(KEY_SHIFT):
#		if DragedRow.selected == false:
#			DragedRow.set_selected(true)
#			selected_row_ids.append(DragedRow.id)
#
#	else:
#		for Row in SortableRows:
#			Row.set_selected(false)
#		selected_row_ids.clear()
#
#		DragedRow.set_selected(true)
#		selected_row_ids.append(DragedRow.id)
#
#	if selected_row_ids.size() > 0:
#		SortableTable.emit_selection_signal( selected_row_ids[selected_row_ids.size() - 1])





func select_all():
	
	# select or deselect all pool items depending on wheter all are already selected or not
	if SelectedPoolItems.size() != PoolItemVBoxContainer.get_child_count():
		
		for child in PoolItemVBoxContainer.get_children():
			if child.selected == false:
				child.select()
				SelectedPoolItems.append(child)
		
	else:
		clear_selection()


#
#func update_selection():
#	for Row in SortableRows:
#		Row.set_selected(false)
#
#	for selected_row_id in selected_row_ids:
#		for Row in SortableRows:
#			if Row.id == selected_row_id:
#				Row.set_selected(true)



func clear_selection():
	
	SelectedPoolItems.clear()
	
	for child in PoolItemVBoxContainer.get_children():
		if child.selected == true:
			child.deselect()

