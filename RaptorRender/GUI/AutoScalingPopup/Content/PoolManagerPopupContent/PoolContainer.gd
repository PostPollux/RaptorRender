#///////////////#
# PoolContainer #
#///////////////#

# The PoolContainer is supposed to hold all the PoolItems in its "PoolItemVBox".
# It is handling the selection logic and the creation and deletion of PoolItems.



extends MarginContainer


### PRELOAD RESOURCES
var PoolItemRes = preload("res://RaptorRender/GUI/AutoScalingPopup/Content/PoolManagerPopupContent/PoolItem.tscn")

### SIGNALS
signal pool_selected
signal selection_cleared
signal pool_created
signal pool_deleted


### ONREADY VARIABLES
onready var BgColorRect : ColorRect = $"BgColorRect"
onready var PoolItemVBox : VBoxContainer = $"PoolItemVBox"


### EXPORTED VARIABLES

### VARIABLES
var SelectedPoolItems : Array = []
var pools_dict : Dictionary




########## FUNCTIONS ##########


func _ready() -> void:
	load_existing_pools()



func clear() -> void:
	for child in PoolItemVBox.get_children():
		child.queue_free()


func clear_immediately() -> void:
	for child in PoolItemVBox.get_children():
		child.free()


func load_existing_pools() -> void:
	
	for pool in pools_dict.keys():
		
		var NewPoolItem : PoolItem = PoolItemRes.instance()
		
		NewPoolItem.set_name(pools_dict[pool].name)
		NewPoolItem.pool_id = pool
		
		# connect signals to enable selecting 
		NewPoolItem.connect("pool_item_clicked", self, "select_PoolItem")
		NewPoolItem.connect("select_all_pressed", self, "select_all")
		NewPoolItem.connect("name_changed", self, "pool_name_changed")
		
		PoolItemVBox.add_child(NewPoolItem)




func create_new_pool_item(pool_name : String, select_pool : bool) -> int:
	
	var NewPoolItem : PoolItem = PoolItemRes.instance()
	
	var final_pool_name : String = check_pool_name(pool_name, -1)
	
	var pool_id : int
	
	pool_id = RRFunctions.generate_pool_id(OS.get_unix_time(), final_pool_name)
	
	NewPoolItem.set_name(final_pool_name)
	NewPoolItem.pool_id = pool_id
	
	# connect signals to enable selecting 
	NewPoolItem.connect("pool_item_clicked", self, "select_PoolItem")
	NewPoolItem.connect("select_all_pressed", self, "select_all")
	
	PoolItemVBox.add_child(NewPoolItem)
	
	if select_pool:
		NewPoolItem.select()
		SelectedPoolItems.append(NewPoolItem)
	
	pools_dict[pool_id] = {
				"name" : final_pool_name,
				"note" : "",
				"clients": [],
				"jobs" : []
			}
	
	emit_signal("pool_created", pool_id)
	
	return pool_id


func delete_pools() -> void:
	for DelPoolItem in PoolItemVBox.get_children():
		if DelPoolItem.selected == true:
			SelectedPoolItems.erase(DelPoolItem)
			DelPoolItem.queue_free()
			pools_dict.erase(DelPoolItem.pool_id)
			emit_signal("pool_deleted", DelPoolItem.pool_id)
	
	emit_signal("selection_cleared")



func pool_name_changed(pool_id : int) -> void:
	
	for pool_item in PoolItemVBox.get_children():
		if pool_item.pool_id == pool_id:
			var final_pool_name : String = check_pool_name(pool_item.pool_name, pool_id)
			pool_item.set_name(final_pool_name)
			pools_dict[pool_id].name = final_pool_name



func check_pool_name(pool_name : String, exclude_pool_id : int) -> String:
	
	var tmp_pool_name : String = pool_name
	
	var name_valid : bool = false
	
	while name_valid == false:
		
		var name_already_used : bool = false
		
		for pool in pools_dict.keys():
			if pool != exclude_pool_id:
				if tmp_pool_name == pools_dict[pool].name:
					name_already_used = true
		
		if name_already_used == false:
			name_valid = true
			
		# change name
		else:
			
			var pattern : RegEx = RegEx.new()
			pattern.compile("_\\d+\\b") # select underscor + number endings like "_1" or "_42"
			
			var matches : Array = pattern.search_all( tmp_pool_name )
			
			# increment number if already has an underscore with number
			if matches.size() > 0:
				var last_match : RegExMatch = matches[ matches.size() - 1] # get last match
				tmp_pool_name = tmp_pool_name.replace(last_match.get_string(),"")
				tmp_pool_name = tmp_pool_name + "_" + String ( int(last_match.get_string().replace("_","")) + 1 )
			else:
				tmp_pool_name = tmp_pool_name + "_2"
			
			
	return tmp_pool_name




func _on_Create_Button_pressed() -> void:
	clear_selection()
	create_new_pool_item("new pool", true)


func _on_Duplicate_Button_pressed() -> void:
	
	if SelectedPoolItems.size() > 0:
		for SelectedPoolItem in SelectedPoolItems:
			var pool_id_of_new_PoolItem : int = create_new_pool_item(SelectedPoolItem.pool_name, false)
			pools_dict[pool_id_of_new_PoolItem].note = pools_dict[SelectedPoolItem.pool_id].note
			pools_dict[pool_id_of_new_PoolItem].clients = pools_dict[SelectedPoolItem.pool_id].clients
			pools_dict[pool_id_of_new_PoolItem].jobs = pools_dict[SelectedPoolItem.pool_id].jobs


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
			if SelectedPoolItems.size() == 0:
				emit_signal("selection_cleared")
			else:
				emit_signal("pool_selected", SelectedPoolItems.back().pool_id)
		else:
			ClickedPoolItem.select()
			SelectedPoolItems.append(ClickedPoolItem)
			emit_signal("pool_selected", ClickedPoolItem.pool_id)
		
		
	elif Input.is_key_pressed(KEY_SHIFT):
		
		exit_and_apply_name_edit_mode_for_all_items(ClickedPoolItem)
		
		var last_selected_position : int = 0
		last_selected_position = SelectedPoolItems.back().get_position_in_parent()
		var position_of_just_clicked_item : int = ClickedPoolItem.get_position_in_parent()
		
		if last_selected_position < position_of_just_clicked_item:
			for i in range(last_selected_position, position_of_just_clicked_item + 1, 1):
				var SelectedPoolItem : PoolItem = PoolItemVBox.get_child(i)
				SelectedPoolItem.select()
				if !SelectedPoolItems.has(SelectedPoolItem):
					SelectedPoolItems.append(SelectedPoolItem)
		else:
			for i in range(last_selected_position, position_of_just_clicked_item -1, -1):
				var SelectedPoolItem : PoolItem = PoolItemVBox.get_child(i)
				SelectedPoolItem.select()
				if !SelectedPoolItems.has(SelectedPoolItem):
					SelectedPoolItems.append(SelectedPoolItem)
		
		emit_signal("pool_selected", SelectedPoolItems.back().pool_id)
		
		
	else:
		clear_selection()
		exit_and_apply_name_edit_mode_for_all_items(ClickedPoolItem)
		
		ClickedPoolItem.select()
		SelectedPoolItems.append(ClickedPoolItem)
		emit_signal("pool_selected", ClickedPoolItem.pool_id)






func select_all():
	
	# select or deselect all pool items depending on wheter all are already selected or not
	if SelectedPoolItems.size() != PoolItemVBox.get_child_count():
		
		for child in PoolItemVBox.get_children():
			if child.selected == false:
				child.select()
				SelectedPoolItems.append(child)
		
		emit_signal("pool_selected", SelectedPoolItems.back().pool_id)
		
	else:
		clear_selection()



func clear_selection():
	
	SelectedPoolItems.clear()
	
	for child in PoolItemVBox.get_children():
		if child.selected == true:
			child.deselect()
	
	emit_signal("selection_cleared")


func exit_and_apply_name_edit_mode_for_all_items(currently_clicked : Node) -> void:
	
	for child in PoolItemVBox.get_children():
		
		# don't exit on the clicked one itself. Otherwise we could not enter that mode with a double click at all...
		if child != currently_clicked:
			child.exit_and_apply_name_edit_mode()




