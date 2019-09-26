extends ColorRect

class_name ImageThumbnail


### preload Resources

### signals
signal thumbnail_pressed
signal thumbnail_updated

### onready vars
onready var ImageName : Label = $"MarginContainer/ImageTexture/FrameNumberLabel"
onready var ThumbnailButton : Button = $"MarginContainer/ImageTexture/Button"
onready var ThumbnailTexture : TextureRect = $"MarginContainer/ImageTexture"

### exported vars

### variables
var image_path : String
var image_name : String  # without extension
var image_number : String  # with padding
var image_size : Vector2
var dir_index : int
var thumbnail_scale_factor = 1.0
var original_image_directory : String

var LoadingImage : ImageTexture

var selected : bool = false
var hovered : bool = false



# Called when the node enters the scene tree for the first time.
func _ready():
	
	self.color = RRColorScheme.bg_2
	LoadingImage = load("res://RaptorRender/GUI/images/loading_thumbnail.png")
	ImageName.text = ""
	
	display_loading_image()
	



func load_image():
	
	var thumbnail = ImageTexture.new()
	var file = File.new()
	
	if file.file_exists(image_path):
		thumbnail.load(image_path)
	else:
		if ThumbnailTexture.get_texture() != null:
			thumbnail = load("res://RaptorRender/GUI/images/image_load_failed_192x108.png")
		else:
			thumbnail = LoadingImage
			
	image_size = thumbnail.get_size()
	
	ThumbnailTexture.set_texture(thumbnail)
	
	ThumbnailButton.hint_tooltip = image_name
	
	ImageName.text = image_number
	
	set_thumbnail_size(thumbnail_scale_factor)
	
	emit_signal("thumbnail_updated")


func display_loading_image():
	
	ThumbnailTexture.set_texture(LoadingImage)
	set_thumbnail_size(thumbnail_scale_factor)



func set_thumbnail_size(scale_factor : float):
	
	thumbnail_scale_factor = scale_factor
	
	var thumbnail_size_x : float = (scale_factor * image_size.x) + 6  # +6 because of padding left (3) + padding right (3)
	self.rect_min_size.x = thumbnail_size_x 
	self.rect_size.x = thumbnail_size_x
	
	var thumbnail_size_y : float = (scale_factor * image_size.y) + 6  # +6 because of padding top (3) + padding bottom (3)
	
	self.rect_min_size.y = thumbnail_size_y
	self.rect_size.y = thumbnail_size_y


func set_framenumber_visibility(visible: bool):
	if visible:
		ImageName.visible = true
	else:
		ImageName.visible = false


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


func select():
	emit_signal("thumbnail_pressed", image_number, self)
	


func _on_Button_button_down():
	select()


func _on_Button_mouse_entered():
	set_hovered()


func _on_Button_mouse_exited():
	reset_hovered()
