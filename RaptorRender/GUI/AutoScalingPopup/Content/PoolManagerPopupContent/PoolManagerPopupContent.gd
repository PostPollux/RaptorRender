#/////////////////////////#
# PoolManagerPopupContent #
#/////////////////////////#

# Copies the current pool dictionary. This way one can make changes that don't apply immediately. If we hit cancel nothing has changed.
# Changes only apply if we hit apply/ok.


extends HBoxContainer



### PRELOAD RESOURCES

### SIGNALS
signal changes_applied_successfully

### ONREADY VARIABLES
onready var PoolNoteTextEdit : TextEdit = $"PoolSection/MarginContainer/VBoxContainer/PoolNote"
onready var PoolItemListBox : ItemListBox = $"PoolSection/MarginContainer/VBoxContainer/ScrollContainer/Pool_ItemListBox"
onready var ClientsInPool_ItemListBox : ItemListBox = $"ClientsSection/VBoxContainer/HBoxContainer/VBoxContainer/ScrollContainer/ClientsInPool_ItemListBox"
onready var ClientsAvailable_ItemListBox : ItemListBox = $"ClientsSection/VBoxContainer/HBoxContainer/VBoxContainer2/ScrollContainer/ClientsAvailable_ItemListBox"
onready var TransferClientsButton : Button = $"ClientsSection/VBoxContainer/HBoxContainer/VBoxContainer3/CenterContainer/TransferClientsButton"
onready var CreatePoolButton : Button = $"PoolSection/MarginContainer/VBoxContainer/ButtonsContainer/Create Button"
onready var DuplicatePoolButton : Button = $"PoolSection/MarginContainer/VBoxContainer/ButtonsContainer/Duplicate Button"
onready var DeletePoolButton : Button = $"PoolSection/MarginContainer/VBoxContainer/ButtonsContainer/Delete Button"

onready var PoolListHeading : Label = $"PoolSection/MarginContainer/VBoxContainer/Heading"
onready var NoteHeading : Label = $"PoolSection/MarginContainer/VBoxContainer/Note Heading"
onready var ClientsListLeftHeading : Label = $"ClientsSection/VBoxContainer/HBoxContainer/VBoxContainer/Heading"
onready var ClientsListRightHeading : Label = $"ClientsSection/VBoxContainer/HBoxContainer/VBoxContainer2/Heading"

### EXPORTED VARIABLES

### VARIABLES
var pools_dict : Dictionary = {}
var currently_displayed_pool : int





########## FUNCTIONS ##########

func _ready() -> void:
	get_parent().connect("popup_shown", self, "pool_manager_just_opened")
	get_parent().connect("ok_pressed", self, "apply_changes")
	PoolItemListBox.connect("item_selected", self, "pool_selected")
	PoolItemListBox.connect("selection_cleared", self, "pool_selection_cleared")
	PoolItemListBox.connect("item_name_changed", self, "pool_name_changed")
	
	handle_localization()
	

func handle_localization():
	
	# set labels
	PoolListHeading.text = "POPUP_POOLMANAGER_2" # Pools
	CreatePoolButton.text = "POPUP_POOLMANAGER_3" # create
	DuplicatePoolButton.text = "POPUP_POOLMANAGER_4" # duplicate
	DeletePoolButton.text = "POPUP_POOLMANAGER_5" # delete
	NoteHeading.text = "POPUP_POOLMANAGER_6" # Note
	ClientsListLeftHeading.text = "POPUP_POOLMANAGER_7" # Clients in pool
	ClientsListRightHeading.text = "POPUP_POOLMANAGER_8" # Clients available for pool



func pool_manager_just_opened() -> void:

	PoolItemListBox.item_names_editable = true
	PoolItemListBox.items_dragable = true
	
	PoolItemListBox.update_colors(RRColorScheme.bg_2, RRColorScheme.bg_2, RRColorScheme.selected)
	
	# make a local copy of the current pools dict, so changes don't do anything until we hit apply.
	pools_dict = str2var( var2str(RaptorRender.rr_data.pools) ) # conversion is needed to copy the dict. Otherwise you only get a reference
	
	# clear the pools container and generate the pool items again
	PoolItemListBox.clear_immediately()
	load_existing_pools()
	
	# clear selection and select the first one in the list
	currently_displayed_pool = -1
	PoolItemListBox.clear_selection()
	
	# select first pool item
	if PoolItemListBox.has_items():
		PoolItemListBox.select_item( PoolItemListBox.get_first_item() )



func load_existing_pools() -> void:
	
	for pool in pools_dict.keys():
		PoolItemListBox.add_item(pools_dict[pool].name, pool)



func apply_changes() -> void:
	
	# make sure we create a dictionary where the ids of the pools resemble the child position of the pool items.
	# We need this as dictionaries are ordered by the key, NOT by the sequence the values were put in.
	var pools_dict_with_new_ids_in_correct_order : Dictionary
	
	var pool_iterator : int = 1
	for item in PoolItemListBox.get_all_items():
		pools_dict_with_new_ids_in_correct_order[pool_iterator] = str2var( var2str(pools_dict[item.item_id]) )
		pool_iterator += 1
	
	# override the rr_data pool dict with the local one
	for client in RRNetworkManager.management_gui_clients:
		RRNetworkManager.rpc_id(client, "update_pools", str2var( var2str(pools_dict_with_new_ids_in_correct_order) ))
	
	emit_signal("changes_applied_successfully")




func create_new_pool(pool_name : String, select_pool : bool) -> int:
	
	var final_pool_name : String = check_pool_name(pool_name, -1)
	
	var pool_id : int
	
	pool_id = RRFunctions.generate_pool_id(OS.get_unix_time(), final_pool_name)
	
	var NewPoolItem : ItemListBoxItem = PoolItemListBox.add_item(final_pool_name, pool_id)
	
	pools_dict[pool_id] = {
				"name" : final_pool_name,
				"note" : "",
				"clients": [],
				"jobs" : []
			}
	
	if select_pool:
		PoolItemListBox.select_item(NewPoolItem)
		pool_selected(pool_id)
	
	return pool_id



# check a desired pool name against the already existing pools. Returns the name with a number suffix if name already exists
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



func delete_selected_pools() -> void:
	for DelPoolItem in PoolItemListBox.get_all_items():
		if DelPoolItem.selected == true:
			PoolItemListBox.SelectedItems.erase(DelPoolItem)
			DelPoolItem.queue_free()
			pools_dict.erase(DelPoolItem.item_id)
			pool_selection_cleared()



# update the clients shown in the two lists to the right + update the transfer button
func pool_selected(pool_id : int) -> void:
	currently_displayed_pool = pool_id
	PoolNoteTextEdit.text = pools_dict[pool_id].note
	
	ClientsInPool_ItemListBox.clear()
	ClientsAvailable_ItemListBox.clear()
	
	for client in pools_dict[pool_id].clients:
		ClientsInPool_ItemListBox.add_item(RaptorRender.rr_data.clients[client].machine_properties.name, client)
	
	ClientsInPool_ItemListBox.sort_items_by_name()
		
	for client in RaptorRender.rr_data.clients.keys():
		if pools_dict[pool_id].clients.has(client) == false:
			ClientsAvailable_ItemListBox.add_item(RaptorRender.rr_data.clients[client].machine_properties.name, client)
	
	ClientsAvailable_ItemListBox.sort_items_by_name()
	
	TransferClientsButton.text = ""
	TransferClientsButton.disabled = true




func pool_selection_cleared() -> void:
	PoolNoteTextEdit.text = ""
	
	TransferClientsButton.text = ""
	TransferClientsButton.disabled = true



func pool_name_changed(Item : ItemListBoxItem) -> void:
	pools_dict[Item.item_id].name = Item.item_name


func _on_PoolNote_text_changed() -> void:
	pools_dict[currently_displayed_pool].note = PoolNoteTextEdit.text


func _on_ClientsInPool_ItemListBox_item_selected(item_id : int) -> void:
	ClientsAvailable_ItemListBox.clear_selection()
	TransferClientsButton.text = "=>"
	TransferClientsButton.disabled = false


func _on_ClientsAvailable_ItemListBox_item_selected(item_id : int) -> void:
	ClientsInPool_ItemListBox.clear_selection()
	TransferClientsButton.text = "<="
	TransferClientsButton.disabled = false


func _on_Pool_ItemListBox_item_selected(item_id : int) -> void:
	pool_selected(item_id)



func _on_TransferClientsButton_pressed() -> void:
	
	# remove clients from pool
	if ClientsInPool_ItemListBox.SelectedItems.size() > 0:
		for Item in ClientsInPool_ItemListBox.SelectedItems:
			var client_id = Item.item_id
			
			pools_dict[currently_displayed_pool].clients.erase(client_id)
			
	
	# add clients to pool
	else:
		for Item in ClientsAvailable_ItemListBox.SelectedItems:
			var client_id = Item.item_id
			
			pools_dict[currently_displayed_pool].clients.append(client_id)
	
	# to update the two lists again
	pool_selected(currently_displayed_pool)




func _on_Create_Button_pressed() -> void:
	create_new_pool("new pool", true)




func _on_Duplicate_Button_pressed() -> void:
	if PoolItemListBox.SelectedItems.size() > 0:
		for SelectedItem in PoolItemListBox.SelectedItems:
			var id_of_duplicated_pool : int = create_new_pool(SelectedItem.item_name, false)
			pools_dict[id_of_duplicated_pool].note = pools_dict[SelectedItem.item_id].note
			pools_dict[id_of_duplicated_pool].clients = pools_dict[SelectedItem.item_id].clients
			pools_dict[id_of_duplicated_pool].jobs = pools_dict[SelectedItem.item_id].jobs



func _on_Delete_Button_pressed() -> void:
	delete_selected_pools()





func _on_Pool_ItemListBox_selection_cleared() -> void:
	ClientsInPool_ItemListBox.clear()
	ClientsAvailable_ItemListBox.clear()
