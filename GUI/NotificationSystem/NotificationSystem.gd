extends Control


var notifications_array = []


#### preloads ####
var ErrorNotificationRes = preload("res://GUI/NotificationSystem/Dialogs/InheritedDialogs/ErrorNotification.tscn")
var InfoNotificationRes = preload("res://GUI/NotificationSystem/Dialogs/InheritedDialogs/InfoNotification.tscn")





func _ready():
	
	pass


func _input(event):
		
	if Input.is_key_pressed(KEY_M):
		add_info_notification("INFO", "Something happened!", 4)
	if Input.is_key_pressed(KEY_N):
		add_error_notification("Error", "Something went wrong!", 4)


func add_info_notification(heading, message, self_destruction_time):
	
	var InfoNotification = InfoNotificationRes.instance()
	InfoNotification.heading = heading
	InfoNotification.message = message
	InfoNotification.self_destruction_time = self_destruction_time
	add_child(InfoNotification)
	
	notifications_array.append(InfoNotification)
	
	

func add_error_notification(heading, message, self_destruction_time):
	
	var ErrorNotification = ErrorNotificationRes.instance()
	ErrorNotification.heading = heading
	ErrorNotification.message = message
	ErrorNotification.self_destruction_time = self_destruction_time
	add_child(ErrorNotification)
	
	



#func _process(delta):
#	pass
