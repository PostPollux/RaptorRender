extends VBoxContainer

### preload Resources
var ImageThumbnailRes = preload("res://RaptorRender/GUI/InfoPanels/JobInfoPanel/ImagePreview/ImageThumbnail.tscn")

### signals
signal thumbnail_selected

### onready vars
onready var DirectoryPath = $"Header/MarginContainer/OutputFilesHBox"
onready var ThumbnailGridContainer : GridContainer = $"ThumbnailGridContainer"

### exported vars


### variables
var image_directory : String
var thumbnail_directory : String
var file_name_patterns : Array = []
var show_frame_numbers : bool = true
var thumbnail_size_x : int = 150


func _ready():
	DirectoryPath.set_output_directory(image_directory)
	
	load_thumbnails()



func _process(delta):
	# This is for rearanging the thumbs on resizing. Note: resized() or draw() signals don't really work, as it doesn't get resized or redrawn if get's pushed and clipped outside
	if ThumbnailGridContainer != null and RaptorRender.JobInfoPanel.get_current_tab() == 3:
		ThumbnailGridContainer.columns = RaptorRender.JobInfoPanel.rect_size.x / (thumbnail_size_x + 10)
		#ThumbnailGridContainer.hseparation =


func load_thumbnails():
	
	var dir : Directory = Directory.new()
	
	dir.open(thumbnail_directory)
	dir.list_dir_begin()

	while true:
		var file = dir.get_next()
		
		if file == "":
			break
		if file.ends_with(".png"):
			var ImageThumbnail = ImageThumbnailRes.instance()
			ImageThumbnail.image_path = thumbnail_directory + file
			var original_filename = file.right(file.find("thn_") + 4).replace(".png","")
			ImageThumbnail.image_name = original_filename
			ImageThumbnail.name = original_filename
			
			if show_frame_numbers:
				ImageThumbnail.image_number = file.left(file.find("_"))
			else:
				ImageThumbnail.image_number = ""
			
			ImageThumbnail.connect("thumbnail_pressed", self, "thumbnail_selected")
			
			ThumbnailGridContainer.add_child(ImageThumbnail)
	
	
	sort_thumbnails()
	
	dir.list_dir_end()



func sort_thumbnails():
	
	var sort_array : Array = []
	
	# create the array to sort
	for Thumb in ThumbnailGridContainer.get_children():
		sort_array.append([Thumb, Thumb.name])
	
	# sort the array
	sort_array.sort_custom ( self, "RR_thumbnail_custom_sort" )
	
	# update the grid by moving the thumbnail nodes
	var position : int = 0
	for thumb_sorted in sort_array:
		ThumbnailGridContainer.move_child(thumb_sorted[0], position)
		position += 1



func RR_thumbnail_custom_sort(a,b):
	return   a[1] < b[1]


func deselect_all_thumbnails():
	for child in ThumbnailGridContainer.get_children():
		child.reset_selected()


func thumbnail_selected( x, Thumb : ImageThumbnail):
	for child in ThumbnailGridContainer.get_children():
		if child == Thumb:
			child.set_selected()
		else:
			child.reset_selected()
		
	print (x)
