extends TextureProgress


var client_id = ""
var CpuUsageTween
var last_shown_client

func _ready():
	CpuUsageTween = Tween.new()
	self.add_child(CpuUsageTween)
	


func _process(delta):
	
	if client_id != "":
		
		# smooth animate the value when we stay at this client
		if last_shown_client == client_id:
			CpuUsageTween.stop_all()
			CpuUsageTween.interpolate_property(self,"value", self.get_value(), RaptorRender.rr_data.clients[client_id].cpu_usage, 2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			CpuUsageTween.start()
		
		# immediately show the value when we just switched to this client from another one
		else:
			CpuUsageTween.stop_all()
			self.set_value(RaptorRender.rr_data.clients[client_id].cpu_usage)
			last_shown_client = client_id