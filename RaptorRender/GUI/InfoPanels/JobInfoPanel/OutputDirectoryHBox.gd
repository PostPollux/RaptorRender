extends HBoxContainer

### PRELOAD RESOURCES

### SIGNALS

### ONREADY VARIABLES
onready var label : Label = $"OutputDirectoryLabel"

### EXPORTED VARIABLES
export (bool) var show_only_path : bool = false

### VARIABLES
var output_directory : String = ""




########## FUNCTIONS ##########


func _ready() -> void:
	if show_only_path:
		label.text = output_directory
	else:
		label.text = tr("JOB_DETAIL_12") + ":   " + output_directory


func set_output_directory( dir_str : String) -> void:
	output_directory = dir_str
	
	if label != null:
		if show_only_path:
			label.text = output_directory
		else:
			label.text = tr("JOB_DETAIL_12") + ":   " + output_directory


func _on_OpenOutputFolderButton_pressed() -> void:
	JobFunctions.open_folder( output_directory )
