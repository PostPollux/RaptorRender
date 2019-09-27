#////////////////////#
# NotificationSystem #
#////////////////////#

# A simple system to show notifications that pop up on the right side of the application. 
# The notification boxes are animated and they disappear automatically after a given time.
# If a new notification comes in, all others that are still visible are moving down.



extends Control

class_name NotificationSystem


### PRELOAD RESOURCES
var ErrorNotificationRes = preload("res://RaptorRender/GUI/NotificationSystem/NotificationBoxes/InheritedNotificationBoxes/ErrorNotification.tscn")
var InfoNotificationRes = preload("res://RaptorRender/GUI/NotificationSystem/NotificationBoxes/InheritedNotificationBoxes/InfoNotification.tscn")

### SIGNALS

### ONREADY VARIABLES 

### EXPORTED VARIABLES

### VARIABLES





########## FUNCTIONS ##########


func _ready():
	
	register_notification_system()



# register to RaptorRender script
func register_notification_system():
	if RaptorRender != null:
		RaptorRender.register_notification_system(self)



# move existing notifications if a new one is incoming
func move_all_notifications_down(height_of_new_notification):
	
	var notifications = self.get_children()
	
	if notifications.size() > 1:
		notifications.pop_back()
	
		for notification in notifications:
			notification.move_vertical(height_of_new_notification + 30)




#########################
### add new notifications
#########################

func add_info_notification(heading : String, message : String, self_destruction_time : int):
	
	var InfoNotification = InfoNotificationRes.instance()
	InfoNotification.heading = heading
	InfoNotification.message = message
	InfoNotification.self_destruction_time = self_destruction_time
	add_child(InfoNotification)
	
	move_all_notifications_down( InfoNotification.height )



func add_error_notification(heading : String, message : String, self_destruction_time : int):
	
	var ErrorNotification = ErrorNotificationRes.instance()
	ErrorNotification.heading = heading
	ErrorNotification.message = message
	ErrorNotification.self_destruction_time = self_destruction_time
	add_child(ErrorNotification)
	
	move_all_notifications_down( ErrorNotification.height )






