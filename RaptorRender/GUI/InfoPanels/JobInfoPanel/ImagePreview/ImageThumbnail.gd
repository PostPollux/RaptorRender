extends ColorRect

class_name ImageThumbnail


### preload Resources

### signals
signal thumbnail_pressed

### onready vars
onready var ImageName : Label = $"MarginContainer/ImageTexture/Label"
onready var ThumbnailButton : Button = $"MarginContainer/ImageTexture/Button"
onready var ThumbnailTexture : TextureRect = $"MarginContainer/ImageTexture"

### exported vars

### variables
var image_path : String
var image_name : String
var image_number : String

var selected : bool = false
var hovered : bool = false



# Called when the node enters the scene tree for the first time.
func _ready():
	self.color = RRColorScheme.bg_2
	var thumbnail = ImageTexture.new()
	thumbnail.load(image_path)
	ThumbnailTexture.set_texture(thumbnail)
	
	ThumbnailButton.hint_tooltip = image_name
	
	ImageName.text = image_number
	


func load_image():
	
	var thumbnail = ImageTexture.new()
	thumbnail.load(image_path)
	ThumbnailTexture.set_texture(thumbnail)
	
	ThumbnailButton.hint_tooltip = image_name
	
	ImageName.text = image_number



func reset_selected():
	selected = false
	if hovered:
		self.color = RRColorScheme.bg_2.lightened(0.1)
	else:
		self.color = RRColorScheme.bg_2


func set_selected():
	selected = true
	if hovered: 
		self.color = RRColorScheme.selected.lightened(0.1)
	else:
		self.color = RRColorScheme.selected


func set_hovered():
	hovered = true
	
	if selected:
		self.color = RRColorScheme.selected.lightened(0.1)
	else:
		self.color = RRColorScheme.bg_2.lightened(0.1)


func reset_hovered():
	hovered = false
	
	if selected:
		self.color = RRColorScheme.selected
	else:
		self.color = RRColorScheme.bg_2


func _on_Button_button_down():
	emit_signal("thumbnail_pressed", image_number, self)


func _on_Button_mouse_entered():
	set_hovered()


func _on_Button_mouse_exited():
	reset_hovered()
