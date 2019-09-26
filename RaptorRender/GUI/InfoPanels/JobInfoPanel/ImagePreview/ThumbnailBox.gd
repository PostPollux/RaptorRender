extends VBoxContainer

### preload Resources
var ImageThumbnailRes = preload("res://RaptorRender/GUI/InfoPanels/JobInfoPanel/ImagePreview/ImageThumbnail.tscn")

### signals
signal thumbnail_selected
signal thumbnails_updated
signal first_thumbnail_updated

### onready vars
onready var HeaderColorRect = $"Header/ColorRect"
onready var DirectoryPath = $"Header/MarginContainer/OutputFilesHBox"
onready var ThumbnailGridContainer : GridContainer = $"ThumbnailGridContainer"

### exported vars


### variables
var original_image_directory : String
var thumbnail_directory : String
var dir_index : int
var file_name_patterns : Array = []
var show_frame_numbers : bool = true
var thumbnail_scale_factor : float = 1.0

var currently_selected : ImageThumbnail

var load_thumbnails_thread : Thread

var files : Array = []

var currently_updating_thumbs : bool = false

var self_destruct_as_soon_as_possible = false





func _ready():
	
	HeaderColorRect.color = RRColorScheme.bg_1
	
	DirectoryPath.set_output_directory(original_image_directory)
	
	# initialize thread
	load_thumbnails_thread = Thread.new()
	
	start_load_thumbnails_thread()



func _process(delta):
	# This is for rearanging the thumbs on resizing. Note: Needs to be in _process() as resized() or draw() signals will not be triggered if the content get's pushed and clipped outside
	calculate_numb_of_colums()
	
	if self_destruct_as_soon_as_possible:
		if !currently_updating_thumbs:
			self.queue_free()


func calculate_numb_of_colums():
	
	if ThumbnailGridContainer != null and RaptorRender.JobInfoPanel.get_current_tab() == 3:
		if ThumbnailGridContainer.get_children().size() > 0:
			if ThumbnailGridContainer.get_child(0) != null:
				var thumbnail_node_size_x : float = thumbnail_scale_factor * ThumbnailGridContainer.get_child(0).image_size.x + 6 + 10 # 6 pading for border of each thumbnail; 10 for GridContainer spacing
				ThumbnailGridContainer.columns = (RaptorRender.JobInfoPanel.rect_size.x - 15) / thumbnail_node_size_x
		
		
func set_thumbnail_size(thumbnail_scale_factor : float):
	for Thumbnail in ThumbnailGridContainer.get_children():
		Thumbnail.set_thumbnail_size(thumbnail_scale_factor)


func set_framenumber_visibility(visible : bool):
	for Thumbnail in ThumbnailGridContainer.get_children():
		Thumbnail.set_framenumber_visibility(visible)


# For performance reasons we only delete or create thumbnail nodes when necessary and update the ones that are already there
# It also helps not to loose the visual change on hover or selection caused by deleting and recreating the node.
func refresh_thumbnails():
	
	# It is important to execute the code that adds or removes nodes from the tree in the main thread, as manipulating the tree in a thread is not safe.
	# You would have to add the nodes by .call_deferred("add_child", your node) which would effectively add them in the main thread at the end of the frame. But then you can't access those nodes through the scene tree later on in the thread, because they are not there yet.
	# So we manipulate the tree first and then start the thread for actually loading the images from disk to the TextureRect node.
	
	if !currently_updating_thumbs:
		
		currently_updating_thumbs = true
		
		DirectoryPath.set_output_directory(original_image_directory)
		
		
		# load all filenames of the thumbnails into the files array
		
		files.clear()
		
		var dir : Directory = Directory.new()
		
		dir.open(thumbnail_directory)
		dir.list_dir_begin()
		
		while true:
			var file = dir.get_next()
			
			if file == "":
				break
			if file.ends_with(".png"):
				files.append(file)
				
		dir.list_dir_end()
		
		# create or delete Thumbnail nodes
		var already_existing_thumbnail_nodes : int = ThumbnailGridContainer.get_children().size()
		var thumbnail_difference : int = files.size() - already_existing_thumbnail_nodes
		
		if thumbnail_difference > 0:
			# create that amount of thumbnail nodes
			for i in range(0, thumbnail_difference):
				var ImageThumbnail = ImageThumbnailRes.instance()
				ImageThumbnail.connect("thumbnail_pressed", self, "thumbnail_selected")
				if already_existing_thumbnail_nodes == 0 and i == 0:
					ImageThumbnail.connect("thumbnail_updated", self, "first_thumbnail_updated")
				ThumbnailGridContainer.add_child(ImageThumbnail) # important to use here call_dfferred otherwise the thread will crash
			
		if thumbnail_difference < 0:
			# remove that amount of thumbnail nodes
			var childs : Array = ThumbnailGridContainer.get_children()
			var child_count : int = childs.size()
			for i in range(1, abs(thumbnail_difference) + 1):
				childs[child_count - i].queue_free()
			
		set_thumbnail_size(thumbnail_scale_factor)
		set_framenumber_visibility(show_frame_numbers)
		
		# now start the thread that will actually load the textures from disk. (If this is not in a thread the UI will stutter on refresh)
		start_load_thumbnails_thread()


func start_load_thumbnails_thread():
	if load_thumbnails_thread.is_active():
		# stop here if already working
		print ("load_thumbnails_thread still active")
		return
		
	# start the thread
	load_thumbnails_thread.start(self, "threaded_thumbnail_update","")




func threaded_thumbnail_update(args):
	files.sort()
	
	# update Thumbnail nodes
	var count = 0
	for file in files:
		var ImageThumbnail : ImageThumbnail = ThumbnailGridContainer.get_child(count)
		
		if currently_selected == ImageThumbnail and currently_selected != null:
			ImageThumbnail.call_deferred("set_selected")
		else:
			ImageThumbnail.call_deferred("reset_selected")
		
		var original_filename = file.right(file.find("thn_") + 4).replace(".png","")
		ImageThumbnail.image_path = thumbnail_directory + files[count]
		ImageThumbnail.image_name = original_filename
		ImageThumbnail.image_number = file.left(file.find("_"))
		
		ImageThumbnail.original_image_directory = original_image_directory
		ImageThumbnail.dir_index = dir_index
		
		ImageThumbnail.load_image()
		
		count += 1
	
	# always has to be called in order to join the thread with the main thread. Otherwise it will just stay active.
	call_deferred("join_load_thumbnail_thread")



func join_load_thumbnail_thread():
	# this will effectively stop the thread
	load_thumbnails_thread.wait_to_finish()
	currently_updating_thumbs = false
	emit_signal("thumbnails_updated")




func deselect_all_thumbnails():
	for child in ThumbnailGridContainer.get_children():
		child.reset_selected()



func thumbnail_selected( framenumber : String, Thumb : ImageThumbnail):
	emit_signal("thumbnail_selected", framenumber, Thumb)


func first_thumbnail_updated():
	emit_signal("first_thumbnail_updated")