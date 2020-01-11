extends TabContainer

### PRELOAD RESOURCES
var Clients_SortableTableRes = preload("res://RaptorRender/GUI/SortableTable/SortableTable.tscn")

### SIGNALS

### ONREADY VARIABLES

### EXPORTED VARIABLES

### VARIABLES
var previous_active_tab : int = 0
var tabs_pools_dict : Dictionary = { 0 : -1}




########## FUNCTIONS ##########


func _ready() -> void:
	update_tabs()

func update_tabs() -> void:
	
	var current_tab_count : int = self.get_child_count()
	var needed_tab_count : int = RaptorRender.rr_data.pools.keys().size() + 1
	
	var tab_iterator : int = 1
	
	for pool in RaptorRender.rr_data.pools.keys():
		
		# change info for the tab
		if tab_iterator < current_tab_count:
			
			tabs_pools_dict[tab_iterator] = pool
		
		
		# create a new tab
		else:
			var Clients_SortableTable = Clients_SortableTableRes.instance()
			var BaseTable : SortableTable = self.get_child(0).get_child(0)
			Clients_SortableTable.set_columns(BaseTable.column_names, BaseTable.column_widths)
			Clients_SortableTable.margin_bottom = 0
			Clients_SortableTable.margin_left = 0
			Clients_SortableTable.margin_right = 0
			Clients_SortableTable.margin_top = 0
			Clients_SortableTable.anchor_top = 0
			Clients_SortableTable.anchor_left = 0
			Clients_SortableTable.anchor_right = 1
			Clients_SortableTable.anchor_bottom = 1
			
			
			
			
			var tab : Tabs = Tabs.new()
			tab.name = RaptorRender.rr_data.pools[pool].name
			tab.add_child(Clients_SortableTable)
			
			self.add_child(tab)
			
			tabs_pools_dict[tab_iterator] = pool
			
			Clients_SortableTable.connect("refresh_table_content", RaptorRender, "refresh_clients_table")
			Clients_SortableTable.connect("something_just_selected", RaptorRender, "client_selected")
			Clients_SortableTable.connect("selection_cleared", RaptorRender, "client_selection_cleared")
			Clients_SortableTable.connect("context_invoked", RaptorRender, "client_context_menu_invoked")
			
		
		tab_iterator += 1
	
	# activate previous visible tab again if possible
	if RaptorRender.clients_pool_filter != -1:
		for tab in tabs_pools_dict.keys():
			if tabs_pools_dict[tab] == RaptorRender.clients_pool_filter:
				current_tab = tab
	else:
		current_tab = 0
	
	
	# remove all tabs that are not needed anymore
	if current_tab_count > needed_tab_count:
		for i in range (needed_tab_count, current_tab_count ):
			self.get_child(i).queue_free()


func clear_all_pool_tabs_SortableTables() -> void:
	if self.get_child_count() > 1:
		for i in range (1, self.get_child_count()):
			var TableToClear : SortableTable = self.get_child(i).get_child(0)
			TableToClear.clear_table()


func _on_TabContainerClients_tab_changed(tab: int) -> void:
	
	var PreviousActiveClientsTable : SortableTable = get_child(previous_active_tab).get_child(0)
	var ClientsTable : SortableTable = get_child(tab).get_child(0)
	
	RaptorRender.clients_pool_filter = tabs_pools_dict[tab]
	
	ClientsTable.viusally_sync_with_other_SortableTable( PreviousActiveClientsTable )
	
	RaptorRender.ClientsTable = ClientsTable
	
	RaptorRender.ClientsTable.clear_table()
	RaptorRender.ClientInfoPanel.visible = false
	RaptorRender.refresh_clients_table()
	
	previous_active_tab = tab
