#//////////////#
# ThumbnailBox #
#//////////////#

# A ThumbnailBox holds all the available thumbnails that have been rendered to ONE directory.
# Each Thumbnail is a ImageThumbnail.tscn node that gets appended to "ThumbnailGridContainer".
# Multithreading is used in this script to make updating the thumbnails more performant and less laggy. 
# Thanks to multithreading it could run constantly in a timer without freezing the UI. But that is not the case for now as it would cause a lot of used bandwidth.


extends VBoxContainer


### PRELOAD RESOURCES
var ImageThumbnailRes = preload("ImageThumbnail.tscn")

### SIGNALS
signal thumbnail_selected
signal thumbnails_updated
signal first_thumbnail_updated

### ONREADY VARIABLES
onready var HeaderColorRect = $"Header/ColorRect"
onready var DirectoryPath = $"Header/MarginContainer/OutputFilesHBox"
onready var ThumbnailGridContainer : GridContainer = $"ThumbnailGridContainer"

### EXPORTED VARIABLES


### VARIABLES
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

var job_just_selected : bool = false




########## FUNCTIONS ##########


func _ready() -> void:
	
	HeaderColorRect.color = RRColorScheme.bg_1
	
	DirectoryPath.set_output_directory(original_image_directory)
	
	# initialize thread
	load_thumbnails_thread = Thread.new()



func _process(delta) -> void:
	# This is for rearanging the thumbs on resizing. Note: Needs to be in _process() as resized() or draw() signals will not be triggered if the content get's pushed and clipped outside
	calculate_and_set_number_of_columns()
	
	if self_destruct_as_soon_as_possible:
		if !currently_updating_thumbs:
			self.queue_free()


func calculate_and_set_number_of_columns() -> int:
	var num_of_columns : int = 0
	if ThumbnailGridContainer != null and RaptorRender.JobInfoPanel.get_current_tab() == 3:
		if ThumbnailGridContainer.get_children().size() > 0:
			if ThumbnailGridContainer.get_child(0) != null:
				var thumbnail_node_size_x : float = thumbnail_scale_factor * ThumbnailGridContainer.get_child(0).image_size.x + 6 + 10 # 6 pading for border of each thumbnail; 10 for GridContainer spacing
				num_of_columns = (RaptorRender.JobInfoPanel.rect_size.x - 15) / thumbnail_node_size_x
				ThumbnailGridContainer.columns = num_of_columns
	return num_of_columns



func set_thumbnail_size(thumbnail_scale_factor : float) -> void:
	for Thumbnail in ThumbnailGridContainer.get_children():
		Thumbnail.set_thumbnail_size(thumbnail_scale_factor)


func set_framenumber_visibility(visible : bool) -> void:
	for Thumbnail in ThumbnailGridContainer.get_children():
		Thumbnail.set_framenumber_visibility(visible)


# For performance reasons we only delete or create thumbnail nodes when necessary and update the ones that are already there
# It also helps not to loose the visual change on hover or selection caused by deleting and recreating the node.
func refresh_thumbnails() -> void:
	
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
		
		# this is for displaying the loading image when a job got selected
		if job_just_selected:
			if files.size() > 0:
				var thumbnail = ImageTexture.new()
				var file = File.new()
				var thumb_size : Vector2 = Vector2(192,108)
				
				if file.file_exists(thumbnail_directory + files[0]):
					thumbnail.load(thumbnail_directory + files[0])
					thumb_size = thumbnail.get_size()
					
				for i in range(0, files.size() ):
					ThumbnailGridContainer.get_child(i).image_size = thumb_size
					ThumbnailGridContainer.get_child(i).display_loading_image()
		job_just_selected = false
		
		
		# now start the thread that will actually load the textures from disk. (If this is not in a thread the UI will stutter on refresh)
		start_load_thumbnails_thread()


func start_load_thumbnails_thread() -> void:
	if load_thumbnails_thread.is_active():
		# stop here if already working
		print ("load_thumbnails_thread still active")
		return
		
	# start the thread
	load_thumbnails_thread.start(self, "threaded_thumbnail_update","")




func threaded_thumbnail_update(args) -> void:
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



func join_load_thumbnail_thread() -> void:
	# this will effectively stop the thread
	load_thumbnails_thread.wait_to_finish()
	currently_updating_thumbs = false
	emit_signal("thumbnails_updated")




func deselect_all_thumbnails() -> void:
	for child in ThumbnailGridContainer.get_children():
		child.reset_selected()



func thumbnail_selected( framenumber : String, Thumb : ImageThumbnail) -> void:
	emit_signal("thumbnail_selected", framenumber, Thumb)


func first_thumbnail_updated() -> void:
	emit_signal("first_thumbnail_updated")
