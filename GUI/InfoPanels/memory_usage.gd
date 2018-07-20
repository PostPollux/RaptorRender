extends TextureProgress


var client_id

func _ready():
	pass

func _process(delta):
	
	if client_id != null:
		self.set_value( RaptorRender.rr_data.clients[client_id].memory_usage ) 