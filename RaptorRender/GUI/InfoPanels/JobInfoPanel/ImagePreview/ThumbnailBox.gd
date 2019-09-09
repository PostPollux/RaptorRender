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
var thumbnail_size_x : int = 162

var currently_selected : String = ""

var load_thumbnails_thread : Thread
var mutex : Mutex

var files : Array = []

var currently_updating_thumbs : bool = false

var self_destruct_as_soon_as_possible = false





func _ready():
	
	DirectoryPath.set_output_directory(image_directory)
	
	# initialize thread
	load_thumbnails_thread = Thread.new()
	mutex = Mutex.new()
	
	start_load_thumbnails_thread()



func _process(delta):
	# This is for rearanging the thumbs on resizing. Note: resized() or draw() signals don't really work, as it doesn't get resized or redrawn if get's pushed and clipped outside
	if ThumbnailGridContainer != null and RaptorRender.JobInfoPanel.get_current_tab() == 3:
		ThumbnailGridContainer.columns = RaptorRender.JobInfoPanel.rect_size.x / (thumbnail_size_x + 10)
	
	if self_destruct_as_soon_as_possible:
		if !currently_updating_thumbs:
			self.queue_free()



# For performance reasons we only delete or create thumbnail nodes when necessary and update the ones that are already there
# It also helps not to loose the visual change on hover or selection caused by deleting and recreating the node.
func refresh_thumbnails():
	
	# It is important to execute the code that adds or removes nodes from the tree in the main thread, as manipulating the tree in a thread is not safe.
	# You would have to add the nodes by .call_deferred("add_child", your node) which would effectively add it in the main thread at the end of the frame. But then you can't access the node in the thread later on, because it's not there yet.
	# So manipulate the tree first and then start the thread
	
	if !currently_updating_thumbs:
		
		currently_updating_thumbs = true
		
		DirectoryPath.set_output_directory(image_directory)
		
		
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
		var thumbnail_difference : int = files.size() - ThumbnailGridContainer.get_children().size()
		
		if thumbnail_difference > 0:
			# create that amount of thumbnail nodes
			for i in range(0, thumbnail_difference):
				var ImageThumbnail = ImageThumbnailRes.instance()
				ImageThumbnail.connect("thumbnail_pressed", self, "thumbnail_selected")
				ThumbnailGridContainer.add_child(ImageThumbnail) # important to use here call_dfferred otherwise the thread will crash
			
		if thumbnail_difference < 0:
			# remove that amount of thumbnail nodes
			var childs : Array = ThumbnailGridContainer.get_children()
			var child_count : int = childs.size()
			for i in range(1, abs(thumbnail_difference) + 1):
				childs[child_count - i].queue_free()
		
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
		
		if currently_selected == ImageThumbnail.image_name and currently_selected != "":
			ImageThumbnail.call_deferred("set_selected")
		else:
			ImageThumbnail.call_deferred("reset_selected")
		
		var original_filename = file.right(file.find("thn_") + 4).replace(".png","")
		ImageThumbnail.image_path = thumbnail_directory + files[count]
		ImageThumbnail.image_name = original_filename
		ImageThumbnail.image_number = file.left(file.find("_"))
		
		ImageThumbnail.load_image()
		
		count += 1
	
	# call_deferred has to call another function in order to join the thread with the main thread. Otherwise it will just stay active.
	call_deferred("join_load_thumbnail_thread")



func join_load_thumbnail_thread():
	# this will effectively stop the thread
	load_thumbnails_thread.wait_to_finish()
	currently_updating_thumbs = false




func deselect_all_thumbnails():
	for child in ThumbnailGridContainer.get_children():
		child.reset_selected()



func thumbnail_selected( framenumber, Thumb : ImageThumbnail):
	currently_selected = Thumb.image_name
	for child in ThumbnailGridContainer.get_children():
		if child == Thumb:
			child.set_selected()
		else:
			child.reset_selected()
		
	print (framenumber)
