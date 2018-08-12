

extends Control




onready var Background = $"BasicDialogContainer/Background"
onready var ProgressTexture = $"BasicDialogContainer/MarginContainer/VBoxContainer/CenterContainerProgress/ProgressTexture"
onready var Heading = $"BasicDialogContainer/MarginContainer/VBoxContainer/Heading"
onready var Message = $"BasicDialogContainer/MarginContainer/VBoxContainer/Text"

onready var TweenAnimateIn = $"TweenAnimateIn"
onready var TweenAnimateOut = $"TweenAnimateOut"


var self_destruction = true
var currently_self_destructing = false
var self_destruction_time = 7
var self_destruct_timer

var heading = "error"
var message = "Some error message!"

var animation_in_finshed = false


func _ready():


	# set texts
	set_heading_and_text()
	
	
	# set self destruction progress bar to correct size
	ProgressTexture.rect_min_size.x = ProgressTexture.get_parent().rect_size.x
	
	
	# show or hide the self destruction progress bar
	if self_destruction:
		ProgressTexture.set_modulate(Color("40ffffff"))
	else:
		ProgressTexture.set_modulate(Color("00ffffff"))
	
	
	self.margin_right = self.margin_right + 400
	self.margin_left= self.margin_left + 400
	
	animate_in()



func animate_in():
	
	# animate in
	var start_color = Color(1.0, 1.0, 1.0, 0.0)
	var end_color = Color(1.0, 1.0, 1.0, 1.0)
	TweenAnimateIn.interpolate_property(self, "modulate", start_color,  end_color, 1.5,Tween.TRANS_QUINT,Tween.EASE_OUT, 0)
	TweenAnimateIn.interpolate_property(self, "margin_right", self.margin_right, 0, 0.5,Tween.TRANS_QUART,Tween.EASE_OUT, 0)
	TweenAnimateIn.interpolate_property(self, "margin_left", self.margin_left, -24, 0.5,Tween.TRANS_QUART,Tween.EASE_OUT, 0)
	TweenAnimateIn.start()
	

func _process(delta):
	
	# animate the self destruction progress bar
	if currently_self_destructing:
		var size = ProgressTexture.get_parent().rect_size.x  *  ( self_destruct_timer.get_time_left() / float(self_destruction_time) )
		ProgressTexture.rect_min_size.x = int(size)



func set_heading_and_text():
	
	if heading != "":
		Heading.text = heading
	else:
		Heading.visible = false
	
	if message != "":
		Message.text = message
	else:
		Message.visible = false





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
	
	# animate out
	var start_color = Color(1.0, 1.0, 1.0, 1.0)
	var end_color = Color(1.0, 1.0, 1.0, 0.0)
	TweenAnimateOut.interpolate_property(self, "modulate", start_color,  end_color, 1.5,Tween.TRANS_QUINT,Tween.EASE_OUT, 0)
	TweenAnimateOut.interpolate_property(self, "margin_right", self.margin_right, self.margin_right + 400, 1.5,Tween.TRANS_CUBIC,Tween.EASE_OUT, 0)
	TweenAnimateOut.interpolate_property(self, "margin_left", self.margin_left, self.margin_left + 400, 1.5,Tween.TRANS_CUBIC,Tween.EASE_OUT, 0)
	TweenAnimateOut.start()
	





func _on_BasicDialogContainer_mouse_entered():
	
	if TweenAnimateOut.is_active():
		TweenAnimateOut.stop_all()
		#animation_in_finshed = false
		animate_in()
	
	if currently_self_destructing:
		currently_self_destructing = false
		self_destruct_timer.queue_free()
		
		ProgressTexture.rect_min_size.x = ProgressTexture.get_parent().rect_size.x



func _on_BasicDialogContainer_mouse_exited():
	
	if self_destruction:
		start_timer_for_self_destruct(self_destruction_time)




func _on_BasicDialogContainer_gui_input(ev):
	
	if ev.is_action_pressed("ui_middle_mouse_button") or ev.is_action_pressed("ui_left_mouse_button") or Input.is_key_pressed(KEY_X):
		
		self_destruct()



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



