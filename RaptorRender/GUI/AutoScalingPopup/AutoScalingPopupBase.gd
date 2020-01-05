extends Control

class_name AutoScalingPopup


### PRELOAD RESOURCES

### SIGNALS
signal cancel_pressed
signal ok_pressed
signal popup_shown
signal popup_hidden

### ONREADY VARIABLES
onready var TitleLabel : Label = $"MainBGPanel/VBoxContainer/Header/HeaderColorRect/HeadingLabel"

onready var TransparentBackground : ColorRect = $"TransparentBackground"
onready var MainBg : ColorRect = $"MainBGPanel"
onready var HeaderBg : ColorRect = $"MainBGPanel/VBoxContainer/Header/HeaderColorRect"
onready var ButtonsBg : ColorRect = $"MainBGPanel/VBoxContainer/PopupButtons/ColorRect"

onready var ContentContainer : MarginContainer = $"MainBGPanel/VBoxContainer/Content"

onready var CancelButton : Button = $"MainBGPanel/VBoxContainer/PopupButtons/ColorRect/CenterContainer/HBoxContainer/CancelButton"
onready var OkButton : Button = $"MainBGPanel/VBoxContainer/PopupButtons/ColorRect/CenterContainer/HBoxContainer/OkButton"

### EXPORTED VARIABLES
export (String) var popup_id : String = "popup-id"

export (String) var title : String = "title"
export (String) var cancel_button_string : String = "POPUP_BUTTON_CANCEL"
export (String) var ok_button_string : String = "POPUP_BUTTON_OK"

export (float) var margin_left_percent : float = 10
export (float) var margin_right_percent : float = 10
export (float) var margin_top_percent : float  = 5
export (float) var margin_bottom_percent : float = 5

export (bool) var auto_destroy_on_close : bool = true

### VARIABLES
var content : Node




########## FUNCTIONS ##########


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	# register to RaptorRender script
	if RaptorRender != null:
		RaptorRender.register_popup(self)
	
	# set title
	TitleLabel.text = title
	
	# set button strings
	CancelButton.text = cancel_button_string
	OkButton.text = ok_button_string
	
	# set colors of color rects
	TransparentBackground.color = RRColorScheme.popup_black_transparent
	MainBg.color = RRColorScheme.bg_2
	HeaderBg.color = RRColorScheme.bg_0
	ButtonsBg.color = RRColorScheme.bg_0
	
	ContentContainer.popup_base = self
	
	if content != null and ContentContainer.get_child_count() == 0:
		ContentContainer.add_child( content )
	
	# set margins
	MainBg.margin_left = get_viewport_rect().size.x * (margin_left_percent / 100)
	MainBg.margin_right = -get_viewport_rect().size.x * (margin_right_percent / 100)
	MainBg.margin_top = get_viewport_rect().size.y * (margin_top_percent / 100)
	MainBg.margin_bottom = -get_viewport_rect().size.y * (margin_bottom_percent / 100)
	
	# connect signals (this will ensure that the "Content" container will also emit these signals emitted by the popup buttons. This will make it easier for the conntent to subscribe to that signals)
	connect("cancel_pressed", ContentContainer, "cancel_pressed")
	connect("ok_pressed", ContentContainer, "ok_pressed")
	connect("popup_shown", ContentContainer, "popup_shown")
	connect("popup_hidden", ContentContainer, "popup_hidden")



func set_content(popup_content : Node) -> void:
	content = popup_content
	if is_instance_valid(ContentContainer):
		ContentContainer.add_child( popup_content )

func set_title(new_tilte : String) -> void:
	title = new_tilte
	if is_instance_valid(TitleLabel):
		TitleLabel.text = title


func set_button_texts (cancel_button : String, ok_button : String) -> void:
	cancel_button_string = cancel_button
	ok_button_string = ok_button
	
	if is_instance_valid(CancelButton):
		CancelButton.text = cancel_button_string
	if is_instance_valid(OkButton):
		OkButton.text = ok_button_string


func hide_popup() -> void:
	self.visible = false
	emit_signal("popup_hidden")
	
	if auto_destroy_on_close:
		queue_free()


func show_popup() -> void:
	# set margins
	MainBg.margin_left = get_viewport_rect().size.x * (margin_left_percent / 100)
	MainBg.margin_right = -get_viewport_rect().size.x * (margin_right_percent / 100)
	MainBg.margin_top = get_viewport_rect().size.y * (margin_top_percent / 100)
	MainBg.margin_bottom = -get_viewport_rect().size.y * (margin_bottom_percent / 100)
	
	print (get_viewport_rect())
	print (get_viewport_rect().size.x * (margin_left_percent / 100))
	
	self.visible = true
	emit_signal("popup_shown")



func _on_TransparentBackground_gui_input(event) -> void:
	if event.is_action_pressed("ui_left_mouse_button"):
		hide_popup()


func _on_CancelButton_pressed() -> void:
	emit_signal("cancel_pressed")
	hide_popup()
	


func _on_OkButton_pressed() -> void:
	emit_signal("ok_pressed")
	


func _on_AutoScalingPopup_item_rect_changed() -> void:
	# set margins
	if is_instance_valid(MainBg):
		MainBg.margin_left = get_viewport_rect().size.x * (margin_left_percent / 100)
		MainBg.margin_right = -get_viewport_rect().size.x * (margin_right_percent / 100)
		MainBg.margin_top = get_viewport_rect().size.y * (margin_top_percent / 100)
		MainBg.margin_bottom = -get_viewport_rect().size.y * (margin_bottom_percent / 100)
