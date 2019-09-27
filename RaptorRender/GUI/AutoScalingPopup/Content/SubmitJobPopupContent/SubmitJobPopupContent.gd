extends VBoxContainer


### PRELOAD RESOURCES
var HBoxContainerSep15Res = preload("res://RaptorRender/GUI/AutoScalingPopup/Content/HBoxContainerSep15.tscn")
var ActivateCheckBoxRes = preload("res://RaptorRender/GUI/AutoScalingPopup/Content/SubmitJobSettingActivateCheckBox.tscn")

### SIGNALS
signal job_successfully_created

### ONREADY VARIABLES
onready var JobTypeOptionButton : OptionButton = $"JobTypeContainer/HBoxContainer/JobTypeOptionButton"
onready var TypeVersionOptionButton : OptionButton = $"JobTypeContainer/HBoxContainer/JobTypeVersionButton"

onready var JobTypeLabel : Label = $"JobTypeContainer/HBoxContainer/JobTypeLabel"
onready var JobVersionLabel : Label = $"JobTypeContainer/HBoxContainer/JobVersionLabel"

onready var ContentScrollContainer : ScrollContainer = $"ScrollContainer"
onready var MinimumSizeContianer : MarginContainer = $"ScrollContainer/MinimumSizeContainer"
onready var TypeMaskContent : VBoxContainer = $"ScrollContainer/MinimumSizeContainer/TypeMaskContent"
onready var SpecificJobSettings : VBoxContainer = $"ScrollContainer/MinimumSizeContainer/TypeMaskContent/SpecificJobSettings"

# Basic job info references
onready var JobNameLabel : Label = $"ScrollContainer/MinimumSizeContainer/TypeMaskContent/BasicJobInfo/JobName/JobNameLabel"
onready var SceneFileLabel : Label = $"ScrollContainer/MinimumSizeContainer/TypeMaskContent/BasicJobInfo/SceneFile/SceneFileLabel"
onready var RenderRangeLabel : Label = $"ScrollContainer/MinimumSizeContainer/TypeMaskContent/BasicJobInfo/RenderRange/RenderRangeLabel"
onready var ChunkSizeLabel : Label = $"ScrollContainer/MinimumSizeContainer/TypeMaskContent/BasicJobInfo/ChunkSize/ChunkSizeLabel"
onready var PriorityLabel : Label = $"ScrollContainer/MinimumSizeContainer/TypeMaskContent/BasicJobInfo/Priority/PriorityLabel"
onready var PoolLabel : Label = $"ScrollContainer/MinimumSizeContainer/TypeMaskContent/BasicJobInfo/Pool/PoolLabel"
onready var NoteLabel : Label = $"ScrollContainer/MinimumSizeContainer/TypeMaskContent/BasicJobInfo/Note/NoteLabel"
onready var StartPausedLabel : Label = $"ScrollContainer/MinimumSizeContainer/TypeMaskContent/BasicJobInfo/StartPaused/StartPausedLabel"

onready var JobNameLineEdit : LineEdit = $"ScrollContainer/MinimumSizeContainer/TypeMaskContent/BasicJobInfo/JobName/JobNameLineEdit"
onready var SceneFileLineEdit : LineEdit = $"ScrollContainer/MinimumSizeContainer/TypeMaskContent/BasicJobInfo/SceneFile/SceneFileLineEdit"
onready var RenderRangeLineEdit : LineEdit = $"ScrollContainer/MinimumSizeContainer/TypeMaskContent/BasicJobInfo/RenderRange/RenderRangeLineEdit"
onready var ChunkSizeSpinBox : SpinBox = $"ScrollContainer/MinimumSizeContainer/TypeMaskContent/BasicJobInfo/ChunkSize/ChunkSizeSpinBox"
onready var PrioritySlider : HSlider = $"ScrollContainer/MinimumSizeContainer/TypeMaskContent/BasicJobInfo/Priority/PriorityHSlider"
onready var PrioritySpinBox : SpinBox = $"ScrollContainer/MinimumSizeContainer/TypeMaskContent/BasicJobInfo/Priority/PriorityValueSpinBox"
onready var NoteLineEdit : LineEdit = $"ScrollContainer/MinimumSizeContainer/TypeMaskContent/BasicJobInfo/Note/NoteLineEdit"
onready var StartPausedCheckBox : CheckBox = $"ScrollContainer/MinimumSizeContainer/TypeMaskContent/BasicJobInfo/StartPaused/StartPausedCheckBox"

onready var SelectSceneFileDialog : FileDialog = $"ScrollContainer/MinimumSizeContainer/TypeMaskContent/BasicJobInfo/SceneFile/SelectSceneButton/SelectSceneFileDialog"

### EXPORTED VARIABLES

### VARIABLES
var type_mask_content_label_min_size : float = 0
var job_type_settings_path : String

var last_selected_path : String = ""

var specific_input_fields : Dictionary




########## FUNCTIONS ##########


func _ready():
	
	get_parent().connect("popup_shown", self, "initialize_on_show")
	get_parent().connect("ok_pressed", self, "validate_input_mask")
	
	specific_input_fields = {}
	
	initialize_on_show()



func initialize_on_show():
	
	# load path to job type settings
	job_type_settings_path = RRPaths.job_types_default_path
	
	# set labels
	JobTypeLabel.text = "POPUP_SUBMIT_JOB_2" # Job Type:
	JobVersionLabel.text = "POPUP_SUBMIT_JOB_3" # Type Version:
	
	JobNameLabel.text =  "POPUP_SUBMIT_JOB_4" # Job Name:
	SceneFileLabel.text = "POPUP_SUBMIT_JOB_5" # Scene File:
	RenderRangeLabel.text = "POPUP_SUBMIT_JOB_6" # Render Range:
	ChunkSizeLabel.text = "POPUP_SUBMIT_JOB_7" # Chunk Size:
	PriorityLabel.text = "POPUP_SUBMIT_JOB_8" # Priority:
	PoolLabel.text = "POPUP_SUBMIT_JOB_9" # Pools:
	NoteLabel.text = "POPUP_SUBMIT_JOB_10" # Note:
	StartPausedLabel.text = "POPUP_SUBMIT_JOB_11" # Start Paused:
	
	# set tooltips
	RenderRangeLabel.hint_tooltip = "POPUP_SUBMIT_JOB_TOOLTIP_1"
	RenderRangeLineEdit.hint_tooltip = "POPUP_SUBMIT_JOB_TOOLTIP_1"
	ChunkSizeLabel.hint_tooltip = "POPUP_SUBMIT_JOB_TOOLTIP_2"
	ChunkSizeSpinBox.hint_tooltip = "POPUP_SUBMIT_JOB_TOOLTIP_2"
	PriorityLabel.hint_tooltip = "POPUP_SUBMIT_JOB_TOOLTIP_3"
	PrioritySlider.hint_tooltip = "POPUP_SUBMIT_JOB_TOOLTIP_3"
	PrioritySpinBox.hint_tooltip = "POPUP_SUBMIT_JOB_TOOLTIP_3"
	
	# fill job type option buttons
	fill_job_type_option_button(job_type_settings_path)
	fill_type_version_option_button( job_type_settings_path + JobTypeOptionButton.get_item_text(JobTypeOptionButton.get_selected_id()) )
	
	# reset values to default values
	JobNameLineEdit.text = tr("POPUP_SUBMIT_JOB_12") # New Job
	SceneFileLineEdit.text = ""
	RenderRangeLineEdit.text = "1-100"
	ChunkSizeSpinBox.value = 5
	PrioritySlider.value = 50
	PrioritySpinBox.value = 50
	NoteLineEdit.text = ""
	StartPausedCheckBox.pressed = false
	
	# load elements mask
	load_type_mask()



# Function is supposed to get the path where the job type configuration folders lie. For each folder it will add an item to the option button.
func fill_job_type_option_button(path : String):
	
	JobTypeOptionButton.clear()
	
	var dir : Directory = Directory.new()
	
	if dir.dir_exists(path):
		dir.open(path)
		
		dir.list_dir_begin()
		
		var count : int = 0
		
		while true:
			var directory_name : String = dir.get_next()
			
			if directory_name == "":
				break
			elif directory_name.find(".") == -1:
				JobTypeOptionButton.add_item(directory_name, count)
			
			count += 1
		
		dir.list_dir_end()



# Function is supposed to get the path where the type version configuration files lie. For each .cfg file it will add an item to the option button.
func fill_type_version_option_button(path : String):
	
	TypeVersionOptionButton.clear()
	
	var dir : Directory = Directory.new()
	
	if dir.dir_exists(path):
		dir.open(path)
		
		dir.list_dir_begin()
		
		var count : int = 0
		
		while true:
			var file_name : String = dir.get_next()
			
			if file_name == "":
				break
			
			# only list files that end with .cfg
			elif file_name.find(".cfg") != -1:
				file_name = file_name.split(".cfg", false, 0)[0]
				TypeVersionOptionButton.add_item(file_name, count)
			
			count += 1
			
		dir.list_dir_end()
		
		load_type_mask()




func load_type_mask():
	
	var job_type : String = JobTypeOptionButton.get_item_text(JobTypeOptionButton.get_selected_id())
	var job_type_version : String = TypeVersionOptionButton.get_item_text(TypeVersionOptionButton.get_selected_id())
	
	# load job type config file
	var job_type_config : ConfigFile = ConfigFile.new()
	job_type_config.load( job_type_settings_path + job_type + "/" + job_type_version + ".cfg" )
	
	# set filters for the file dialog
	SelectSceneFileDialog.clear_filters()
	
	var file_extensions : Array = job_type_config.get_section_keys( "FileExtensions" ) 
	var filters : PoolStringArray= []
	for extension in file_extensions:
		if not extension.ends_with("_description"):
			var extension_str : String = job_type_config.get_value("FileExtensions", extension, "")
			var extension_description : String = job_type_config.get_value("FileExtensions", extension + "_description", "")
			
			if not extension_str.begins_with("."):
				extension_str = "." + extension_str
				
			if extension_description != "":
				filters.append("*" + extension_str + " ; " + extension_description)
			else:
				filters.append("*" + extension_str + " ; " + extension_str)
		
	SelectSceneFileDialog.set_filters(filters)
	
	
	# Create an array to hold all MaskElements (which are HBoxContainers).
	var MaskLabels : Array = []
	
	# fill MaskLabels array
	MaskLabels.append(JobNameLabel)
	MaskLabels.append(SceneFileLabel)
	MaskLabels.append(RenderRangeLabel)
	MaskLabels.append(ChunkSizeLabel)
	MaskLabels.append(PriorityLabel)
	MaskLabels.append(PoolLabel)
	MaskLabels.append(NoteLabel)
	MaskLabels.append(StartPausedLabel)
	
	
	# remove all children of SpecificJobSettings
	for child in SpecificJobSettings.get_children():
		SpecificJobSettings.remove_child(child)
	
	# clear specific_input_fields dictionary
	specific_input_fields.clear()
	
	# create all the specific job settings
	var specific_job_type_settings : Array = job_type_config.get_section_keys( "SpecificJobSettings" ) 
	
	for specific_setting in specific_job_type_settings:
		if specific_setting.find("__") == -1:
			
			# load additional specific setting information
			var display_text : String = job_type_config.get_value("SpecificJobSettings", specific_setting + "__display_text", "")
			var tooltip : String = job_type_config.get_value("SpecificJobSettings", specific_setting + "__tooltip", "")
			var type : String = job_type_config.get_value("SpecificJobSettings", specific_setting + "__type", "")
			var activatable : String = job_type_config.get_value("SpecificJobSettings", specific_setting + "__activatable", "").to_lower()
			var cmd_value : String = job_type_config.get_value("SpecificJobSettings", specific_setting + "__cmd_value", "")
			
			# split array ones
			var type_array : Array = type.split(";;", true)
			var activatable_array : Array = activatable.split(";;", true)
			var cmd_value_array : Array = cmd_value.split(";;", true)
			
			# check arrays if they have the correct length. Return and show error, if that is not the case.
			if type_array.size() != 2:
				var error_message : String = tr("MSG_ERROR_16") + "\n\n" + specific_setting + "__type"
				RaptorRender.NotificationSystem.add_error_notification(tr("MSG_ERROR_1"), error_message, 10) # There is an error in your job type configuration file. The following setting has to be a string containing two values separated by „;;“:
				return
			if activatable_array.size() != 2:
				var error_message : String = tr("MSG_ERROR_16") + "\n\n" + specific_setting + "__activatable"
				RaptorRender.NotificationSystem.add_error_notification(tr("MSG_ERROR_1"), error_message, 10) # There is an error in your job type configuration file. The following setting has to be a string containing two values separated by „;;“:
				return
			if cmd_value_array.size() != 3:
				var error_message : String = tr("MSG_ERROR_17") + "\n\n" + specific_setting + "__cmd_value"
				RaptorRender.NotificationSystem.add_error_notification(tr("MSG_ERROR_1"), error_message, 10) # There is an error in your job type configuration file. The following setting has to be a string containing three values separated by „;;“:
				return
			
			# create HBoxContainer
			var SpecificHBoxContainer : HBoxContainer = HBoxContainerSep15Res.instance()
			SpecificHBoxContainer.name = specific_setting
			SpecificJobSettings.add_child(SpecificHBoxContainer)
			
			# Create Label
			var SpecificLabel : Label = Label.new()
			SpecificLabel.name = specific_setting + "Label"
			SpecificLabel.text = display_text + ":"
			SpecificLabel.align = Label.ALIGN_RIGHT
			SpecificLabel.mouse_filter = MOUSE_FILTER_STOP
			if tooltip != "":
				SpecificLabel.hint_tooltip = tooltip
			SpecificHBoxContainer.add_child(SpecificLabel)
			
			# Create checkbox for activating or deactivating the setting if it is an activatable setting
			if activatable_array[0] == "true":
				# create HBoxContainer
				var ActivateCheckBox : CheckBox = ActivateCheckBoxRes.instance()
				ActivateCheckBox.name = specific_setting + "ActivateCheckBox"
				specific_input_fields[specific_setting + "ActivateCheckBox"] = ActivateCheckBox
				ActivateCheckBox.connect("toggled", ActivateCheckBox, "set_editable_state_of_input")
				if activatable_array[1] == "true":
					ActivateCheckBox.pressed = true
				else:
					ActivateCheckBox.pressed = false
					
				SpecificHBoxContainer.add_child(ActivateCheckBox)
				
			
			
			# Create Value Edit Element
			
			# send error message if specific setting type is unsupported or not set
			var type_lower : String = type_array[0].to_lower()
			if type_lower != "string" and type_lower != "int" and type_lower != "float" and type_lower != "bool":
				var error_message : String = tr("MSG_ERROR_5") + "\n\n" + specific_setting
				RaptorRender.NotificationSystem.add_error_notification(tr("MSG_ERROR_1"), error_message, 10) # There is an error in your job type configuration file. The type of the following specific job setting has not been set:
				return
				
			elif type_lower == "int":
				var SpecificSpinBox : SpinBox = SpinBox.new()
				SpecificSpinBox.name = specific_setting + "SpinBox"
				specific_input_fields[specific_setting + "SpinBox"] = SpecificSpinBox
				SpecificSpinBox.size_flags_horizontal = SIZE_EXPAND_FILL
				SpecificSpinBox.rounded = true
				if type_array[1] != "":
					SpecificSpinBox.value = int(type_array[1])
				if tooltip != "":
					SpecificSpinBox.hint_tooltip = String(tooltip)
				if activatable_array[0] == "true":
					if activatable_array[1] == "true":
						SpecificSpinBox.editable = true
					else:
						SpecificSpinBox.editable = false
						
				SpecificHBoxContainer.add_child(SpecificSpinBox)
				
			elif type_lower == "float":
				var SpecificSpinBox : SpinBox = SpinBox.new()
				SpecificSpinBox.name = specific_setting + "SpinBox"
				specific_input_fields[specific_setting + "SpinBox"] = SpecificSpinBox
				SpecificSpinBox.size_flags_horizontal = SIZE_EXPAND_FILL
				SpecificSpinBox.rounded = false
				if type_array[1] != "":
					SpecificSpinBox.value = float(type_array[1])
				if tooltip != "":
					SpecificSpinBox.hint_tooltip = String(tooltip)
				if activatable_array[0] == "true":
					if activatable_array[1] == "true":
						SpecificSpinBox.editable = true
					else:
						SpecificSpinBox.editable = false
						
				SpecificHBoxContainer.add_child(SpecificSpinBox)
				
			elif type_lower == "string":
				var SpecificLineEdit : LineEdit = LineEdit.new()
				SpecificLineEdit.name = specific_setting + "LineEdit"
				specific_input_fields[specific_setting + "LineEdit"] = SpecificLineEdit
				SpecificLineEdit.size_flags_horizontal = SIZE_EXPAND_FILL
				if type_array[1] != "":
					SpecificLineEdit.text = type_array[1]
				if tooltip != "":
					SpecificLineEdit.hint_tooltip = String(tooltip)
				if activatable_array[0] == "true":
					if activatable_array[1] == "true":
						SpecificLineEdit.editable = true
					else:
						SpecificLineEdit.editable = false
						
				SpecificHBoxContainer.add_child(SpecificLineEdit)
				
			elif type_lower == "bool":
				var SpecificCheckBox : CheckBox = CheckBox.new()
				SpecificCheckBox.name = specific_setting + "CheckBox"
				specific_input_fields[specific_setting + "CheckBox"] = SpecificCheckBox
				
				if type_array[1] != "":
					if type_array[1].to_lower() == "true" or type_array[1].to_lower() == "1":
						SpecificCheckBox.pressed = true
					elif type_array[1].to_lower() == "false" or type_array[1].to_lower() == "0":
						SpecificCheckBox.pressed = false
							
				if tooltip != "":
					SpecificCheckBox.hint_tooltip = String(tooltip)
					
				SpecificHBoxContainer.add_child(SpecificCheckBox )
				
			
			# add Label to Labels
			MaskLabels.append(SpecificLabel)
	
	# make all Labels the same size
	RRFunctions.set_min_size_to_longest(MaskLabels, true, false)



func validate_input_mask():
	
	# check if file exists
	var FileCheck : File = File.new()
	if not FileCheck.file_exists(SceneFileLineEdit.text):
		RaptorRender.NotificationSystem.add_error_notification(tr("MSG_ERROR_1"), tr("MSG_ERROR_7"), 10) # TScene file does not exist!
		return
	
	# auto correct some stuff
	RenderRangeLineEdit.text = RenderRangeLineEdit.text.replace(" ","")
	RenderRangeLineEdit.text = RenderRangeLineEdit.text.replace(",",";")
	
	# validate range input
	var RangeRegex : RegEx = RegEx.new()
	RangeRegex.compile("[0-9;\\-]+") # select all numbers, hyphens and semicolons
	var RegexResult : RegExMatch = RangeRegex.search(RenderRangeLineEdit.text)
	
	# check for correct characters
	if RegexResult != null:
		if RegexResult.get_string().length() != RenderRangeLineEdit.text.length():
			RaptorRender.NotificationSystem.add_error_notification(tr("MSG_ERROR_1"), tr("MSG_ERROR_8"), 10) # Range input can only have numbers, dashes and semicolons!
			return
	else:
		RaptorRender.NotificationSystem.add_error_notification(tr("MSG_ERROR_1"), tr("MSG_ERROR_8"), 10) # Range input can only have numbers, dashes and semicolons!
		return
	
	# auto correct some stuff
	RenderRangeLineEdit.text = RenderRangeLineEdit.text.replace(";;",";")
	if RenderRangeLineEdit.text.begins_with(";") or RenderRangeLineEdit.text.begins_with("-"):
		RenderRangeLineEdit.text = RenderRangeLineEdit.text.right(1)
	if RenderRangeLineEdit.text.ends_with(";") or RenderRangeLineEdit.text.ends_with("-"):
		RenderRangeLineEdit.text = RenderRangeLineEdit.text.left(RenderRangeLineEdit.text.length() - 1)	
	
	# check if there are more than one hypen in a render range
	if RenderRangeLineEdit.text.find("-") != -1:
		var render_ranges : Array = RenderRangeLineEdit.text.split(";")
		for render_range in render_ranges:
			var hyphen_split : Array = render_range.split("-")
			if hyphen_split.size() > 2:
				RaptorRender.NotificationSystem.add_error_notification(tr("MSG_ERROR_1"), tr("MSG_ERROR_9"), 10) # A range can only have one dash! It should look something like:  1-45;80-120
				return
			if hyphen_split.size() == 2:
				if int(hyphen_split[0]) > int(hyphen_split[1]):
					RaptorRender.NotificationSystem.add_error_notification(tr("MSG_ERROR_1"), tr("MSG_ERROR_10"), 10) # The first number of a render range have to be smaller than the second one!
					return
	
	create_new_job()


func create_new_job():
	
	# Generate unique ID. To generate a new unique id we just hash the job name + it's creation time
	var time_created : int = OS.get_unix_time()
	
	var job_id : int = RRFunctions.generate_job_id(time_created, JobNameLineEdit.text)
	
	# create specific settings dictionary
	var specific_settings_dict : Dictionary = {}
	
	# load job type config file
	var job_type : String = JobTypeOptionButton.get_item_text(JobTypeOptionButton.get_selected_id())
	var job_type_version : String = TypeVersionOptionButton.get_item_text(TypeVersionOptionButton.get_selected_id())
	var job_type_config : ConfigFile = ConfigFile.new()
	job_type_config.load( job_type_settings_path + job_type + "/" + job_type_version + ".cfg" )
	
	var specific_job_type_settings : Array = job_type_config.get_section_keys( "SpecificJobSettings" ) 
	
	for specific_setting in specific_job_type_settings:
		if specific_setting.find("__") == -1:
			
			# load additional specific setting information
			var type : String = job_type_config.get_value("SpecificJobSettings", specific_setting + "__type", "")
			var activatable : String = job_type_config.get_value("SpecificJobSettings", specific_setting + "__activatable", "").to_lower()
			var cmd_value : String = job_type_config.get_value("SpecificJobSettings", specific_setting + "__cmd_value", "")
			
			# split array ones
			var type_array : Array = type.split(";;", true)
			var activatable_array : Array = activatable.split(";;", true)
			var cmd_value_array : Array = cmd_value.split(";;", true)
			
			# check arrays if they have the correct length. Return and show error, if that is not the case.
			if type_array.size() != 2:
				var error_message : String = tr("MSG_ERROR_16") + "\n\n" + specific_setting + "__type"
				RaptorRender.NotificationSystem.add_error_notification(tr("MSG_ERROR_1"), error_message, 10) # There is an error in your job type configuration file. The following setting has to be a string containing two values separated by „;;“:
				return
			if activatable_array.size() != 2:
				var error_message : String = tr("MSG_ERROR_16") + "\n\n" + specific_setting + "__activatable"
				RaptorRender.NotificationSystem.add_error_notification(tr("MSG_ERROR_1"), error_message, 10) # There is an error in your job type configuration file. The following setting has to be a string containing two values separated by „;;“:
				return
			if cmd_value_array.size() != 3:
				var error_message : String = tr("MSG_ERROR_17") + "\n\n" + specific_setting + "__cmd_value"
				RaptorRender.NotificationSystem.add_error_notification(tr("MSG_ERROR_1"), error_message, 10) # There is an error in your job type configuration file. The following setting has to be a string containing three values separated by „;;“:
				return
			
			
			# send error message if specific setting type is unsupported or not set
			var type_lower : String = type_array[0].to_lower()
			if type_lower != "string" and type_lower != "int" and type_lower != "float" and type_lower != "bool":
				var error_message : String = tr("MSG_ERROR_5") + "\n\n" + specific_setting
				RaptorRender.NotificationSystem.add_error_notification(tr("MSG_ERROR_1"), error_message, 10) # There is an error in your job type configuration file. The type of the following specific job setting has not been set:
				return
				
			elif type_lower == "int":
				
				# set if the specific setting is true or false and add to dict
				if activatable_array[0].to_lower() == "false":
					specific_settings_dict[specific_setting] = true
				else:
					specific_settings_dict[specific_setting] = specific_input_fields[specific_setting + "ActivateCheckBox"].pressed
				
				# set __cmd_value and add it to dict
				specific_settings_dict[specific_setting + "__cmd_value"] = cmd_value_array[0] + ";;" + String( specific_input_fields[specific_setting + "SpinBox"].value ) + ";;" + cmd_value_array[2]
				
				
			elif type_lower == "float":
				
				# set if the specific setting is true or false and add to dict
				if activatable_array[0].to_lower() == "false":
					specific_settings_dict[specific_setting] = true
				else:
					specific_settings_dict[specific_setting] = specific_input_fields[specific_setting + "ActivateCheckBox"].pressed
				
				# set __cmd_value and add it to dict
				specific_settings_dict[specific_setting + "__cmd_value"] = cmd_value_array[0] + ";;" + String( specific_input_fields[specific_setting + "SpinBox"].value ) + ";;" + cmd_value_array[2]
				
			elif type_lower == "string":
				
				# set if the specific setting is true or false and add to dict
				if activatable_array[0].to_lower() == "false":
					specific_settings_dict[specific_setting] = true
				else:
					specific_settings_dict[specific_setting] = specific_input_fields[specific_setting + "ActivateCheckBox"].pressed
				
				# set __cmd_value and add it to dict
				specific_settings_dict[specific_setting + "__cmd_value"] = cmd_value_array[0] + ";;" + specific_input_fields[specific_setting + "LineEdit"].text + ";;" + cmd_value_array[2]
				
				
			elif type_lower == "bool":
				
				# set if the specific setting is true or false and add to dict
				
				specific_settings_dict[specific_setting] = specific_input_fields[specific_setting + "CheckBox"].pressed
				
				# set __cmd_value and add it to dict
				specific_settings_dict[specific_setting + "__cmd_value"] = cmd_value
			
			
	
	var new_job : Dictionary = {
								"id": job_id,
								"name": JobNameLineEdit.text,
								"type": JobTypeOptionButton.get_item_text(JobTypeOptionButton.get_selected_id()),
								"type_version": TypeVersionOptionButton.get_item_text(TypeVersionOptionButton.get_selected_id()),
								"priority": PrioritySpinBox.value,
								"priority_boost": true,
								"creator": GetSystemInformation.username,
								"time_created": time_created,
								"frame_range": RenderRangeLineEdit.text.replace(";", "; "),
								"frames_total": 0,
								"status": RRStateScheme.job_paused if StartPausedCheckBox.pressed else RRStateScheme.job_queued,
								"progress": 0,
								"note": NoteLineEdit.text,
								"errors": 0,
								"pools": [],
								"scene_path" : SceneFileLineEdit.text,
								"output_dirs_and_file_name_patterns" : [],
								"render_time" : 0,
								"SpecificJobSettings" : specific_settings_dict,
								"chunks": {
									
								}
							}
	
	# create chunks for the job
	var render_ranges : Array = RenderRangeLineEdit.text.split(";")
	
	var chunk_count : int = 1
	var frames_total : int = 0
	
	for render_range in render_ranges:
		
		var chunk : Dictionary = {}
		
		var hyphen_split : Array = render_range.split("-")
		
		# frame range
		if hyphen_split.size() > 1:
			var frames_amount : int = int(hyphen_split[1]) - int(hyphen_split[0])
			var chunks_needed : int = ceil( float(frames_amount)/float(ChunkSizeSpinBox.value) )
			
			for c in range (0 , chunks_needed ):
				var frame_start : int = int(hyphen_split[0]) + c * ChunkSizeSpinBox.value
				var frame_end : int = int(hyphen_split[0]) + c * ChunkSizeSpinBox.value + ChunkSizeSpinBox.value
				
				chunk = {
						"status" : RRStateScheme.chunk_paused if StartPausedCheckBox.pressed else RRStateScheme.chunk_queued,
						"frame_start" : frame_start,
						"frame_end" : frame_end if frame_end < int(hyphen_split[1]) else int(hyphen_split[1]),
						"number_of_tries" : 0,
						"tries": {
							},
						"errors": 0
						}
						
				# add chunk to new job
				new_job.chunks[chunk_count] = chunk #str2var( var2str(chunk) )
				
				chunk_count += 1
			
			frames_total += frames_amount + 1
			
			
		# single frame
		else:
			chunk = {
					"status" : RRStateScheme.chunk_paused if StartPausedCheckBox.pressed else RRStateScheme.chunk_queued,
					"frame_start" : int(render_range),
					"frame_end" : int(render_range),
					"number_of_tries" : 0,
					"tries": {
						},
					"errors": 0
					}
			
			# add chunk to new job
			new_job.chunks[chunk_count] = chunk#str2var( var2str(chunk) )
			frames_total += 1
			chunk_count += 1
	
	
	# update total frame count
	new_job.frames_total = frames_total
	
	# add job to rr_data
	RaptorRender.rr_data.jobs[job_id] = new_job
	
	emit_signal("job_successfully_created")
	
	
	
	

func _on_JobTypeOptionButton_item_selected(ID):
	fill_type_version_option_button( job_type_settings_path + JobTypeOptionButton.get_item_text(ID) )

func _on_JobTypeVersionButton_item_selected(ID):
	load_type_mask()
	
func _on_MinimumSizeContainer_draw():
	MinimumSizeContianer.rect_min_size.x = ContentScrollContainer.rect_size.x - 15
	MinimumSizeContianer.rect_min_size.y = ContentScrollContainer.rect_size.y - 15




func _on_PriorityHSlider_value_changed(value):
	PrioritySpinBox.value = value

func _on_PriorityValueSpinBox_value_changed(value):
	PrioritySlider.value = value



func _on_SelectSceneFileDialog_confirmed():
	SceneFileLineEdit.text = SelectSceneFileDialog.current_path
	last_selected_path = SelectSceneFileDialog.current_path


func _on_SelectSceneButton_pressed():
	SelectSceneFileDialog.current_path = last_selected_path
	SelectSceneFileDialog.popup_centered_ratio(0.75)