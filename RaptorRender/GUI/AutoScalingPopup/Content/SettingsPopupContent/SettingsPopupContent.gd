#/////////////////////////////#
# GeneralSettingsPopupContent #
#/////////////////////////////#



extends HBoxContainer



### PRELOAD RESOURCES
var OSPathMappingSettingsRes = preload("SpecificSettings/OsPathMapping/OSPathMappingSettings.tscn")

### SIGNALS
signal changes_applied_successfully

### ONREADY VARIABLES
onready var CategoriesItemListBox : ItemListBox = $"CategoriesSection/MarginContainer/CategoriesItemListBox"
onready var SettingsSection : MarginContainer = $"SettingsSection"

### EXPORTED VARIABLES

### VARIABLES
var settings_type : String

var category_dict : Dictionary = {}

var currently_shown_category : int = -1



########## FUNCTIONS ##########

func _ready() -> void:
	
	get_parent().connect("popup_shown", self, "settings_just_opened")
	get_parent().connect("ok_pressed", self, "apply_changes")
	
	CategoriesItemListBox.connect("item_selected", self, "category_selected")



func settings_just_opened () -> void:
	
	CategoriesItemListBox.clear_immediately()
	
	var category_index_iterator : int = 0
	
	match settings_type: 
		
		
			
		"default_client":
			
			for category in RaptorRender.rr_data.settings.default_client.keys():
				CategoriesItemListBox.add_item(RaptorRender.rr_data.settings.default_client[category].category_name, category_index_iterator)
				category_dict[category_index_iterator] = category
				category_index_iterator += 1
			
			
		# if nothing matches show general settings by default
		_:
			for category in RaptorRender.rr_data.settings.general.keys():
				CategoriesItemListBox.add_item(RaptorRender.rr_data.settings.general[category].category_name, category_index_iterator)
				category_dict[category_index_iterator] = category
				category_index_iterator += 1
	
	
	# Always select the first item on showing up
	if CategoriesItemListBox.has_items():
		CategoriesItemListBox.select_item( CategoriesItemListBox.get_first_item() )


func category_selected(category_id : int) -> void:
	
	if currently_shown_category != category_id:
		
		if SettingsSection.get_child_count() > 0:
			SettingsSection.get_child(0).free()
			
		currently_shown_category = category_id
		
		var category : String = category_dict[category_id]
		
		match category:
			
			"availibility" : 
				pass
			
			"paths" : 
				pass
				
			"os_path_mapping" :
				
				var CategorySettingContent : Node = OSPathMappingSettingsRes.instance()
				SettingsSection.add_child(CategorySettingContent)


	
