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



# Called when the node enters the scene tree for the first time.
func _ready():
	self.color = RRColorScheme.bg_2
	var thumbnail = ImageTexture.new()
	thumbnail.load(image_path)
	ThumbnailTexture.set_texture(thumbnail)
	
	ThumbnailButton.hint_tooltip = image_name
	
	ImageName.text = image_number
	



func load_image(path : String):
	image_path = path
	var thumbnail = ImageTexture.new()
	thumbnail.load(image_path)
	ThumbnailTexture.set_texture(thumbnail)
	
	ThumbnailButton.hint_tooltip = image_name
	
	ImageName.text = image_number



func reset_selected():
	self.color = RRColorScheme.bg_2
	
func set_selected():
	self.color = RRColorScheme.selected



func _on_Button_button_down():
	emit_signal("thumbnail_pressed", image_number, self)
