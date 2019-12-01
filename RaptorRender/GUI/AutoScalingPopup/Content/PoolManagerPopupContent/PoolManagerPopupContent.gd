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
onready var PoolNoteTextEdit : TextEdit = $"PoolContainer/MarginContainer/VBoxContainer/PoolNote"
onready var PoolContainer : MarginContainer = $"PoolContainer/MarginContainer/VBoxContainer/ScrollContainer/PoolContainer"
onready var ClientsInPool_ItemListBox : ItemListBox = $"ClientsContainer/VBoxContainer/HBoxContainer/VBoxContainer/ScrollContainer/ClientsInPool_ItemListBox"
onready var ClientsAvailable_ItemListBox : ItemListBox = $"ClientsContainer/VBoxContainer/HBoxContainer/VBoxContainer2/ScrollContainer/ClientsAvailable_ItemListBox"
onready var MoveClientsButton : Button = $"ClientsContainer/VBoxContainer/HBoxContainer/VBoxContainer3/CenterContainer/MoveClientsButton"

### EXPORTED VARIABLES

### VARIABLES
var pools_dict : Dictionary = {}
var currently_displayed_pool : int





########## FUNCTIONS ##########

func _ready() -> void:
	get_parent().connect("popup_shown", self, "pool_manager_just_opened")
	get_parent().connect("ok_pressed", self, "apply_changes")
	PoolContainer.connect("pool_selected", self, "pool_selected")
	PoolContainer.connect("selection_cleared", self, "pool_selection_cleared")
	PoolContainer.connect("pool_created", self, "pool_created")
	


func pool_manager_just_opened() -> void:
	
	# make a local copy of the current pools dict, so changes don't do anything until we hit apply.
	pools_dict = str2var( var2str(RaptorRender.rr_data.pools) ) # conversion is needed to copy the dict. Otherwise you only get a reference
	PoolContainer.pools_dict = pools_dict
	
	# clear the pools container and generate the pool items again
	PoolContainer.clear_immediately()
	PoolContainer.load_existing_pools()
	
	# clear selection and select the first one in the list
	currently_displayed_pool = -1
	PoolContainer.clear_selection()
	
	# select first pool item
	if PoolContainer.PoolItemVBox.get_child_count() > 0:
		PoolContainer.select_PoolItem( PoolContainer.PoolItemVBox.get_child(0) )


func apply_changes() -> void:
	
	# make sure we create a dictionary where the ids of the pools resemble the child position of the pool items.
	# We need this as dictionaries are ordered by the key, NOT by the sequence the values were put in.
	var pools_dict_with_new_ids_in_correct_order : Dictionary
	
	var pool_iterator : int = 1
	for pool_item in PoolContainer.PoolItemVBox.get_children():
		pools_dict_with_new_ids_in_correct_order[pool_iterator] = str2var( var2str(pools_dict[pool_item.pool_id]) )
		pool_iterator += 1
	
	# override the rr_data pool dict with the local one
	RaptorRender.rr_data.pools = str2var( var2str(pools_dict_with_new_ids_in_correct_order) ) # conversion is needed to copy the dict. Otherwise you only get a reference
	
	RRFunctions.apply_pool_changes_to_all_jobs_and_clients()
	
	# update pool-tabs / client-tabs
	var PoolTabsContainer : TabContainer = RaptorRender.ClientsTable.get_parent().get_parent()
	#PoolTabsContainer.current_tab = 0 # important so it doesn't try to autoupdate a table with data that has already been deleted
	PoolTabsContainer.previous_active_tab = 0
	PoolTabsContainer.clear_all_pool_tabs_SortableTables()
	PoolTabsContainer.update_tabs()
	
	
	# refresh tables
	RaptorRender.refresh_clients_table()
	RaptorRender.refresh_jobs_table()
	
	
	
	emit_signal("changes_applied_successfully")



func pool_created(pool_id : int) -> void:
	pool_selected(pool_id)


func pool_selected(pool_id : int) -> void:
	currently_displayed_pool = pool_id
	PoolNoteTextEdit.text = pools_dict[pool_id].note
	
	ClientsInPool_ItemListBox.clear()
	ClientsAvailable_ItemListBox.clear()
	
	for client in pools_dict[pool_id].clients:
		ClientsInPool_ItemListBox.add_item(RaptorRender.rr_data.clients[client].name, client)
		
	for client in RaptorRender.rr_data.clients.keys():
		if pools_dict[pool_id].clients.has(client) == false:
			ClientsAvailable_ItemListBox.add_item(RaptorRender.rr_data.clients[client].name, client)
	
	MoveClientsButton.text = ""
	MoveClientsButton.disabled = true


func pool_selection_cleared() -> void:
	PoolNoteTextEdit.text = ""



func _on_PoolNote_text_changed() -> void:
	pools_dict[currently_displayed_pool].note = PoolNoteTextEdit.text


func _on_ClientsInPool_ItemListBox_item_selected(item_id : int) -> void:
	ClientsAvailable_ItemListBox.clear_selection()
	MoveClientsButton.text = "=>"
	MoveClientsButton.disabled = false


func _on_ClientsAvailable_ItemListBox_item_selected(item_id : int) -> void:
	ClientsInPool_ItemListBox.clear_selection()
	MoveClientsButton.text = "<="
	MoveClientsButton.disabled = false





func _on_MoveClientsButton_pressed() -> void:
	
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


