extends TextureProgress

### PRELOAD RESOURCES

### SIGNALS

### ONREADY VARIABLES 

### EXPORTED VARIABLES

### VARIABLES
var client_id : int = -1
var CpuUsageTween : Tween
var last_shown_client : int

var update_interval : float = 2




########## FUNCTIONS ##########


func _ready() -> void:
	
	# create a tween node
	CpuUsageTween = Tween.new()
	self.add_child(CpuUsageTween)
	
	# create timer for self destruction
	var timer : Timer = Timer.new()
	timer.wait_time = update_interval
	timer.connect("timeout",self,"update_cpu_usage_bar") 
	self.add_child(timer)
	timer.start()
	


func update_cpu_usage_bar() -> void:
	
	if client_id != -1:
		
		# smooth animate the value when we stay at this client
		if last_shown_client == client_id:
			CpuUsageTween.stop_all()
			CpuUsageTween.interpolate_property(self,"value", self.get_value(), RaptorRender.rr_data.clients[client_id].machine_properties.cpu_usage, update_interval, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			CpuUsageTween.start()
		
		# immediately show the value when we just switched to this client from another one
		else:
			CpuUsageTween.stop_all()
			self.set_value(RaptorRender.rr_data.clients[client_id].machine_properties.cpu_usage)
			last_shown_client = client_id

