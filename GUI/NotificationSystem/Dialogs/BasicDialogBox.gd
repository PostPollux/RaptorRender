

extends Control




onready var Background = $"BasicDialogContainer/Background"
onready var ProgressTexture = $"BasicDialogContainer/MarginContainer/VBoxContainer/CenterContainerProgress/ProgressTexture"
onready var Heading = $"BasicDialogContainer/MarginContainer/VBoxContainer/Heading"
onready var Message = $"BasicDialogContainer/MarginContainer/VBoxContainer/Text"


var self_destruction = true
var currently_self_destructing = false
var self_destruction_time = 7
var self_destruct_timer

var heading = "error"
var message = "Some error message!"


func _ready():

	set_heading_and_text()
	
	if self_destruction:
	
		start_timer_for_self_destruct(self_destruction_time)
		ProgressTexture.set_modulate(Color("40ffffff"))
		
	else:
		
		ProgressTexture.set_modulate(Color("00ffffff"))




func _process(delta):
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
	currently_self_destructing = true
	self_destruction_time = sec
	
	
	# create timer for self destruction
	self_destruct_timer = Timer.new()
	self_destruct_timer.name = "SelfDestructTimer"
	self_destruct_timer.wait_time = sec
	self_destruct_timer.connect("timeout",self,"self_destruct") 
	add_child(self_destruct_timer)
	self_destruct_timer.start()



func self_destruct():
	
	self.queue_free()
	




func _on_BasicDialogContainer_mouse_entered():
	
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
