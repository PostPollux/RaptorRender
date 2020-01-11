extends MarginContainer



### PRELOAD RESOURCES

### SIGNALS

### ONREADY VARIABLES
onready var RulesSortableTable : SortableTable = $"RulesSortableTable"

### EXPORTED VARIABLES

### VARIABLES



########## FUNCTIONS ##########


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	var column_names : Array = []
	var column_widths : Array = []
	
	# Set column names directly with the translation key. The label will change automatically and finding the position of the column in the refresh function is easier with a non changing nstring (translation key)
	column_names.append("id") # RuleId
	column_widths.append(50)
	column_names.append("path to replace") # Path to Replace
	column_widths.append(200)
	column_names.append("linux") # Linux
	column_widths.append(200)
	column_names.append("windows") # Windows
	column_widths.append(200)
	column_names.append("case sensitive") # Case Sensitive
	column_widths.append(100)
	
	RulesSortableTable.set_columns(column_names, column_widths)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass
