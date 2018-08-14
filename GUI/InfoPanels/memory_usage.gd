extends TextureProgress


var client_id = ""
var MemoryUsageTween
var last_shown_client

func _ready():
	MemoryUsageTween = Tween.new()
	self.add_child(MemoryUsageTween)


func _process(delta):
	
	if client_id != "":
		
		# smooth animate the value when we stay at this client
		if last_shown_client == client_id:
			MemoryUsageTween.stop_all()
			MemoryUsageTween.interpolate_property(self,"value", self.get_value(), RaptorRender.rr_data.clients[client_id].memory_usage , 2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			MemoryUsageTween.start() 
		
		# immediately show the value when we just switched to this client from another one
		else:
			MemoryUsageTween.stop_all()
			self.set_value(RaptorRender.rr_data.clients[client_id].memory_usage)
			last_shown_client = client_id