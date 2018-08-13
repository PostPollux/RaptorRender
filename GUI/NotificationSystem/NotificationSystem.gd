extends Control


var notifications_array = []


#### preloads ####
var ErrorNotificationRes = preload("res://GUI/NotificationSystem/Dialogs/InheritedDialogs/ErrorNotification.tscn")
var InfoNotificationRes = preload("res://GUI/NotificationSystem/Dialogs/InheritedDialogs/InfoNotification.tscn")





func _ready():
	
	pass


func _input(event):
		
	if Input.is_key_pressed(KEY_M):
		add_info_notification("INFO", "Something happened!", 7)
	if Input.is_key_pressed(KEY_N):
		add_error_notification("Error", "Something went wrong! Something went wrong! Something went wrong! Something went wrong! Something went wrong!", 7)



func add_info_notification(heading, message, self_destruction_time):
	
	var InfoNotification = InfoNotificationRes.instance()
	InfoNotification.heading = heading
	InfoNotification.message = message
	InfoNotification.self_destruction_time = self_destruction_time
	add_child(InfoNotification)
	
	move_all_notifications_down( InfoNotification.get_height() )





func add_error_notification(heading, message, self_destruction_time):
	
	var ErrorNotification = ErrorNotificationRes.instance()
	ErrorNotification.heading = heading
	ErrorNotification.message = message
	ErrorNotification.self_destruction_time = self_destruction_time
	add_child(ErrorNotification)
	
	move_all_notifications_down( ErrorNotification.get_height() )




func move_all_notifications_down(height_of_new_notification):
	
	var notifications = self.get_children()
	
	if notifications.size() > 1:
		notifications.pop_back()
	
		for notification in notifications:
			notification.move_vertical(height_of_new_notification + 30)


#func _process(delta):
#	pass
