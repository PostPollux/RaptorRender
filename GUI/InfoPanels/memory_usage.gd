extends TextureProgress


var client_id = ""
var MemoryUsageTween

func _ready():
	MemoryUsageTween = Tween.new()
	self.add_child(MemoryUsageTween)


func _process(delta):
	
	if client_id != "":
		MemoryUsageTween.stop_all()
		MemoryUsageTween.interpolate_property(self,"value", self.get_value(), RaptorRender.rr_data.clients[client_id].memory_usage , 2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		MemoryUsageTween.start() 