#//////////////////////#
# BasicNotificationBox #
#//////////////////////#

# The BasicNotificationBox is a control element to display a notification message. 
# It's ment to be used with the "NotificationSystem". So each notification will be shown in a BasicNotificationBox.
# It's basically a box with the following features built-in:
# Automatically animate in, show time left until notification dissapears, automatically animate out after specified time



extends Control


# variables set by NotificationSystem when creating a notification
var heading = ""
var message = ""
var self_destruction_time = 7

# internal variables needed for logic
var self_destruction = true
var currently_self_destructing = false
var self_destruct_timer
var animation_in_finshed = false
var supposed_position_y = 50
var height

# references to child nodes
onready var Background = $"BasicNotificationContainer/Background"
onready var ProgressTexture = $"BasicNotificationContainer/MarginContainer/VBoxContainer/CenterContainerProgress/ProgressTexture"
onready var Heading = $"BasicNotificationContainer/MarginContainer/VBoxContainer/Heading"
onready var Message = $"BasicNotificationContainer/MarginContainer/VBoxContainer/Text"
onready var TweenAnimateIn = $"TweenAnimateIn"
onready var TweenAnimateOut = $"TweenAnimateOut"
onready var TweenMoveVertical = $"TweenMoveVertical"








func _ready():


	# set texts
	if heading != "":
		Heading.text = heading
	else:
		Heading.visible = false
	
	if message != "":
		Message.text = message
	else:
		Message.visible = false
	
	
	# calculate height of the notification box
	height = (Message.get_line_count() * ( Message.get_line_height() + 3 ) ) + 36
	
	
	# set self destruction progress bar to correct size
	ProgressTexture.rect_min_size.x = ProgressTexture.get_parent().rect_size.x
	
	
	# make notification not self destructing when self destruction time is set to 0
	if self_destruction_time == 0:
		self_destruction = false
	
	
	# show or hide the self destruction progress bar
	if self_destruction:
		ProgressTexture.set_modulate(Color("40ffffff"))
	else:
		ProgressTexture.set_modulate(Color("00ffffff"))
	
	
	# move it to the right and start animation
	self.margin_right = self.margin_right + 400
	self.margin_left= self.margin_left + 400
	animate_in()




func _process(delta):
	
	# animate the self destruction progress bar
	if currently_self_destructing:
		var size = ProgressTexture.get_parent().rect_size.x  *  ( self_destruct_timer.get_time_left() / float(self_destruction_time) )
		ProgressTexture.rect_min_size.x = int(size)



func start_timer_for_self_destruct(sec):
	
	self_destruction = true
	
	self_destruction_time = sec
	
	
	# create timer for self destruction
	self_destruct_timer = Timer.new()
	self_destruct_timer.name = "SelfDestructTimer"
	self_destruct_timer.wait_time = sec
	self_destruct_timer.connect("timeout",self,"self_destruct") 
	self_destruct_timer.one_shot = true
	add_child(self_destruct_timer)
	self_destruct_timer.start()
	
	currently_self_destructing = true



func self_destruct():
	
	# set self destruction progress bar to correct size
	ProgressTexture.rect_min_size.x = 0
	
	# animate out - notification box will remove itself from the tree as soon as this animation has finished
	animate_out()
	




####################
### Signals Handling
####################

func _on_BasicNotificationContainer_mouse_entered():
	
	# self destruct while mouse button is pressed too quickly remove several notifications
	if Input.is_action_pressed("ui_left_mouse_button") or Input.is_action_pressed("ui_middle_mouse_button"):
		 self_destruct()
	
	# reset timer so the notification does not go away so quickly
	else:
	
		if TweenAnimateOut.is_active():
			TweenAnimateOut.stop_all()
			animate_in()
		
		if currently_self_destructing:
			currently_self_destructing = false
			self_destruct_timer.queue_free()
			
			ProgressTexture.rect_min_size.x = ProgressTexture.get_parent().rect_size.x



func _on_BasicNotificationContainer_mouse_exited():
	
	if self_destruction:
		start_timer_for_self_destruct(self_destruction_time)



func _on_BasicNotificationContainer_gui_input(ev):
	
	if ev.is_action_pressed("ui_middle_mouse_button") or ev.is_action_pressed("ui_left_mouse_button") or Input.is_key_pressed(KEY_X):
		
		self_destruct()







#############################################
### Animations and Animation Signals Handling
#############################################

func animate_in():
	
	# animate in
	var start_color = Color(1.0, 1.0, 1.0, 0.0)
	var end_color = Color(1.0, 1.0, 1.0, 1.0)
	TweenAnimateIn.interpolate_property(self, "modulate", start_color,  end_color, 1.5,Tween.TRANS_QUINT,Tween.EASE_OUT, 0)
	TweenAnimateIn.interpolate_property(self, "margin_right", self.margin_right, 0, 0.5,Tween.TRANS_QUART,Tween.EASE_OUT, 0)
	TweenAnimateIn.interpolate_property(self, "margin_left", self.margin_left, -24, 0.5,Tween.TRANS_QUART,Tween.EASE_OUT, 0)
	TweenAnimateIn.start()



func animate_out():
	
	# animate out
	var start_color = Color(1.0, 1.0, 1.0, 1.0)
	var end_color = Color(1.0, 1.0, 1.0, 0.0)
	TweenAnimateOut.interpolate_property(self, "modulate", start_color,  end_color, 1.5,Tween.TRANS_QUINT,Tween.EASE_OUT, 0)
	TweenAnimateOut.interpolate_property(self, "margin_right", self.margin_right, self.margin_right + 400, 1.5,Tween.TRANS_CUBIC,Tween.EASE_OUT, 0)
	TweenAnimateOut.interpolate_property(self, "margin_left", self.margin_left, self.margin_left + 400, 1.5,Tween.TRANS_CUBIC,Tween.EASE_OUT, 0)
	TweenAnimateOut.start()



func move_vertical(amout_to_move_down):
	
	supposed_position_y += amout_to_move_down
	
	# animate to new position
	TweenMoveVertical.stop_all()
	TweenMoveVertical.interpolate_property(self, "margin_top", self.margin_top, supposed_position_y, 0.5,Tween.TRANS_QUART,Tween.EASE_OUT, 0)
	TweenMoveVertical.interpolate_property(self, "margin_bottom", self.margin_bottom, supposed_position_y + 24, 0.5,Tween.TRANS_QUART,Tween.EASE_OUT, 0)
	TweenMoveVertical.start()



func _on_TweenAnimateIn_tween_completed(object, key):
	
	
	if !animation_in_finshed:
		if self_destruction:
			print("fired")
			start_timer_for_self_destruct(self_destruction_time)
			ProgressTexture.set_modulate(Color("40ffffff"))
	
	animation_in_finshed = true



func _on_TweenAnimateOut_tween_completed(object, key):
	
	# remove the Dialogbox from the tree
	self.queue_free()










