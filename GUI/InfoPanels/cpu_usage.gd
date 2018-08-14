extends TextureProgress


var client_id = ""
var CpuUsageTween

func _ready():
	CpuUsageTween = Tween.new()
	self.add_child(CpuUsageTween)
	


func _process(delta):
	
	if client_id != "":
		CpuUsageTween.stop_all()
		CpuUsageTween.interpolate_property(self,"value", self.get_value(), RaptorRender.rr_data.clients[client_id].cpu_usage, 2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		CpuUsageTween.start() 