extends MarginContainer



### PRELOAD RESOURCES

### SIGNALS

### ONREADY VARIABLES
onready var InfoLabel : Label = $"Label"

### EXPORTED VARIABLES

### VARIABLES
var popup_base : AutoScalingPopup
var info_text : String = ""






########## FUNCTIONS ##########



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	popup_base = get_parent().popup_base
	get_parent().connect("ok_pressed", self, "action_confirmed")
	
	InfoLabel.text = info_text


func action_confirmed() -> void:
	
	# close the popup
	popup_base.hide_popup()



func set_info_text(text : String) -> void:
	info_text = text
	if is_instance_valid(InfoLabel):
		InfoLabel.text = info_text
