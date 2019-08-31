extends HBoxContainer

### onready vars
onready var label : Label = $"OutputDirectoryLabel"

### variables
var output_directory : String = ""



func _ready():
	label.text = tr("JOB_DETAIL_12") + ":   " + output_directory


func set_output_directory( dir_str : String):
	output_directory = dir_str
	
	if label != null:
		label.text = tr("JOB_DETAIL_12") + ":   " + output_directory


func _on_OpenOutputFolderButton_pressed():
	JobFunctions.open_folder( output_directory )
