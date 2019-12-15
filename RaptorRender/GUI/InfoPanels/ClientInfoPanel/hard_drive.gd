extends VBoxContainer


### PRELOAD RESOURCES

### SIGNALS

### ONREADY VARIABLES 
onready var NameLabel = $"HBoxContainer/Name"
onready var SizeLabel = $"HBoxContainer/Size"
onready var UsageBar = $"TextureProgress"

### EXPORTED VARIABLES

### VARIABLES
var client_id
var drive_number




########## FUNCTIONS ##########


func _ready():
	set_label(client_id, drive_number)
	set_percentage_used(client_id, drive_number)


func set_label(client_id, drive_number):
	var drive = RaptorRender.rr_data.clients[client_id].machine_properties.hard_drives[drive_number]
	
	# Name
	if drive.label != "":
		NameLabel.text = drive.name + " \"" + drive.label + "\""
	else:
		NameLabel.text = drive.name + " "
	
	# Size
	SizeLabel.text =   drive.size 


func set_percentage_used(client_id, drive_number):
	
	UsageBar.value = RaptorRender.rr_data.clients[client_id].machine_properties.hard_drives[drive_number].percentage_used

