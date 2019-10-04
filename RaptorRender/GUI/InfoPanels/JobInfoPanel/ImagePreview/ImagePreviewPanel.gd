#///////////////////#
# ImagePreviewPanel #
#///////////////////#

# This panel enables you to quickly have a look at all your rendered images.
# ImagePreviewPanel will create one ThumbnailBox.tscn for each directory where final images of the job are rendered to.
# Each of theses ThumbnailBox elements will hold the respective thumbnails.


extends VSplitContainer

### PRELOAD RESOURCES
var ThumbnailBoxRes = preload("res://RaptorRender/GUI/InfoPanels/JobInfoPanel/ImagePreview/ThumbnailBox.tscn")

### SIGNALS

### ONREADY VARIABLES
onready var ThumbnailsDirectoriesVBox : VBoxContainer = $"VBoxContainer/ThumbnailsScrollContainer/ThumbnailDirectoriesVBox"
onready var ThumbnailsScrollBox : ScrollContainer = $"VBoxContainer/ThumbnailsScrollContainer"
onready var ThumbnailWidthSlider : HSlider = $"VBoxContainer/ThumbnailSettingsBar/HBoxContainer/ThumbnailWidthSlider"
onready var FramenumberVisibilityCheckBox : CheckBox = $"VBoxContainer/ThumbnailSettingsBar/HBoxContainer/FramenumberVisibilityCheckBox"
onready var EnlargedPreviewContainer : MarginContainer = $"EnlargedPreviewContainer"
onready var PreviewImage : TextureRect = $"EnlargedPreviewContainer/Panel/MarginContainer/PreviewImage"
onready var RefreshButton : Button = $"VBoxContainer/ThumbnailSettingsBar/HBoxContainer/MarginContainer/RefreshButton"
onready var SizeLabel : Label = $"VBoxContainer/ThumbnailSettingsBar/HBoxContainer/SizeLabel" 



### EXPORTED VARIABLES

### VARIABLES
var currently_selected : ImageThumbnail
var desire_to_select_first_thumbnail : bool = false
var job_just_selected : bool = false

var previous_scroll_vertical : int = 0




########## FUNCTIONS ##########


func _ready():
	RefreshButton.text = "JOB_IMAGES_2" # refresh
	SizeLabel.text = "JOB_IMAGES_3" # size
	FramenumberVisibilityCheckBox.text = "JOB_IMAGES_4" # frame numbers

func _process(delta):
	EnlargedPreviewContainer.rect_min_size.x = RaptorRender.JobInfoPanel.rect_size.x - 15
	EnlargedPreviewContainer.rect_size.x = RaptorRender.JobInfoPanel.rect_size.x - 15


func _input(event):
	
	# save the position of the vertical scroll as soon as shift or control is pressed
	if Input.is_action_just_pressed("ui_ctrl") :
		previous_scroll_vertical = ThumbnailsScrollBox.scroll_vertical



# this function will make sure that the first thumbnail gets selected and that all thumbs show the loading image while loading.
# if you want to just update without changing selection or image use just "update_thumbnails()". For example if you want it to constantly update every 2 seconds.
func update_thumbnails_by_selecting_job():
	
	desire_to_select_first_thumbnail = true
	job_just_selected = true
	
	PreviewImage.visible = false
	
	update_thumbnails()


# For performance reasons we only delete or create ThumbnailBox nodes when necessary and update the ones that are already there.
# It also helps not to loose the visual change on hover or selection caused by deleting and recreating the node.
func update_thumbnails():
	
	##### create or delete ThumbnailBox nodes
	
	# get how many ThumbnailBoxes we have to create or delete
	var already_existing_thumbnail_boxes : int = ThumbnailsDirectoriesVBox.get_children().size()
	var needed_amount_of_thumbnail_boxes : int = RaptorRender.rr_data.jobs[RaptorRender.JobInfoPanel.current_displayed_job_id].output_dirs_and_file_name_patterns.size()
	var dir_difference : int = needed_amount_of_thumbnail_boxes - already_existing_thumbnail_boxes
	
	if dir_difference > 0:
		# create that amount of ThumbnailBox nodes
		for i in range(0, dir_difference):
			var ThumbnailBox = ThumbnailBoxRes.instance()
			ThumbnailBox.connect("thumbnail_selected",self, "thumbnail_selected")
			if already_existing_thumbnail_boxes == 0 and i == 0:
				ThumbnailBox.connect("first_thumbnail_updated",self, "select_first_thumbnail")
			ThumbnailsDirectoriesVBox.add_child(ThumbnailBox)
		
	if dir_difference < 0:
		# remove that amount of ThumbnailBox nodes
		var childs : Array = ThumbnailsDirectoriesVBox.get_children()
		var child_count : int = childs.size()
		for i in range(1, abs(dir_difference) + 1):
			childs[child_count - i].self_destruct_as_soon_as_possible = true
	
	
	##### update ThumbnailBox nodes
	
	var dircount : int = 0
	for dir in RaptorRender.rr_data.jobs[RaptorRender.JobInfoPanel.current_displayed_job_id].output_dirs_and_file_name_patterns:
		if dir.size() > 0:
			var ThumbnailBox = ThumbnailsDirectoriesVBox.get_child(dircount)
			ThumbnailBox.original_image_directory = dir[0]
			ThumbnailBox.thumbnail_directory = RRPaths.get_job_thumbnail_path( RaptorRender.rr_data.jobs[RaptorRender.JobInfoPanel.current_displayed_job_id].id ) + String(dircount) + "/"
			ThumbnailBox.dir_index = dircount
			if dir.size() > 1:
				ThumbnailBox.file_name_patterns = dir[1]
			ThumbnailBox.thumbnail_scale_factor = ThumbnailWidthSlider.value
			ThumbnailBox.show_frame_numbers = FramenumberVisibilityCheckBox.pressed
			ThumbnailBox.job_just_selected = job_just_selected
			ThumbnailBox.refresh_thumbnails()
			dircount += 1
	job_just_selected = false 



func thumbnail_selected(framenumber : String, Thumb : ImageThumbnail):
	
	currently_selected = Thumb
	
	# visually deselect every thumbnail other than the selected one
	for ThumbnailBox in ThumbnailsDirectoriesVBox.get_children():
		ThumbnailBox.currently_selected == null
		for ThumbnailNode in ThumbnailBox.ThumbnailGridContainer.get_children():
			if ThumbnailNode == Thumb:
				ThumbnailNode.set_selected()
				ThumbnailBox.currently_selected = ThumbnailNode
			else:
				ThumbnailNode.reset_selected()
			
	# load selected original image
	var PreviewImageTexture = ImageTexture.new()
	var file_name_patterns_for_this_directory : Array = RaptorRender.rr_data.jobs[RaptorRender.JobInfoPanel.current_displayed_job_id].output_dirs_and_file_name_patterns[currently_selected.dir_index][1]
	var file_found : bool = false
	
	for pattern in file_name_patterns_for_this_directory:
		var extension : String = pattern.right(pattern.find_last("."))
		var orig_image_path : String = currently_selected.original_image_directory + currently_selected.image_name + extension
		
		var file = File.new()
	
		if file.file_exists(orig_image_path):
			file_found = true
			var load_return_value : int = PreviewImageTexture.load(orig_image_path)
		
			if load_return_value == 12:
				PreviewImageTexture = load("res://RaptorRender/GUI/images/image_load_failed_1280x720.png")
			break
			
			
	if not file_found:
		PreviewImageTexture = load("res://RaptorRender/GUI/images/image_load_failed_1280x720.png")
	
	PreviewImage.set_texture(PreviewImageTexture)
	PreviewImage.visible = true




func select_first_thumbnail():
	
	if desire_to_select_first_thumbnail:
		var ThumbnailBox = ThumbnailsDirectoriesVBox.get_child(0)
		
		ThumbnailBox.ThumbnailGridContainer.get_child(0).select()
		PreviewImage.visible = true
		
		desire_to_select_first_thumbnail = false


func _on_HSlider_value_changed(value):
	for ThumbnailBox in ThumbnailsDirectoriesVBox.get_children():
		ThumbnailBox.thumbnail_scale_factor = value
		ThumbnailBox.calculate_number_of_colums()
		ThumbnailBox.set_thumbnail_size(value)


func _on_CheckBox_toggled(button_pressed):
	for ThumbnailBox in ThumbnailsDirectoriesVBox.get_children():
		ThumbnailBox.set_framenumber_visibility(button_pressed)


func _on_RefreshButton_pressed():
	job_just_selected = true # this will lead to showing the loading images
	update_thumbnails()




func _on_ThumbnailsScrollContainer_gui_input(event):
	
	if Input.is_key_pressed(KEY_CONTROL):
		if event.is_action_pressed("ui_mouse_wheel_up"):
				ThumbnailWidthSlider.value = ThumbnailWidthSlider.value + 0.1
			
		if event.is_action_pressed("ui_mouse_wheel_down"):
				ThumbnailWidthSlider.value = ThumbnailWidthSlider.value - 0.1
		
		ThumbnailsScrollBox.scroll_vertical = previous_scroll_vertical

