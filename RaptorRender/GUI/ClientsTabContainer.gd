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
	
	var tab_count : int = 1
	
	for pool in RaptorRender.rr_data.pools.keys():
		
		var Clients_SortableTable = Clients_SortableTableRes.instance()
		Clients_SortableTable.column_names = RaptorRender.ClientsTable.column_names
		Clients_SortableTable.column_widths = RaptorRender.ClientsTable.column_widths
		Clients_SortableTable.margin_bottom = 0
		Clients_SortableTable.margin_left = 0
		Clients_SortableTable.margin_right = 0
		Clients_SortableTable.margin_top = 0
		Clients_SortableTable.anchor_top = 0
		Clients_SortableTable.anchor_left = 0
		Clients_SortableTable.anchor_right = 1
		Clients_SortableTable.anchor_bottom = 1
		
		
		var tab : Tabs = Tabs.new()
		tab.name = RaptorRender.rr_data.pools[pool]
		tab.add_child(Clients_SortableTable)
		
		self.add_child(tab)
		
		tabs_pools_dict[tab_count] = pool
		
		Clients_SortableTable.connect("refresh_table_content", RaptorRender, "refresh_clients_table")
		Clients_SortableTable.connect("something_just_selected", RaptorRender, "client_selected")
		Clients_SortableTable.connect("selection_cleared", RaptorRender, "client_selection_cleared")
		Clients_SortableTable.connect("context_invoked", RaptorRender, "client_context_menu_invoked")
		
		tab_count += 1





func _on_TabContainerClients_tab_changed(tab: int) -> void:
	
	var PreviousActiveClientsTable : SortableTable = get_child(previous_active_tab).get_child(0)
	var ClientsTable : SortableTable = get_child(tab).get_child(0)
	
	RaptorRender.clients_pool_filter = tabs_pools_dict[tab]
	
	ClientsTable.viusally_sync_with_other_SortableTable( PreviousActiveClientsTable )
	
	RaptorRender.ClientsTable = ClientsTable
	
	RaptorRender.refresh_clients_table()
	
	
	
	
	
	
	
	previous_active_tab = tab
