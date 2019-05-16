extends MarginContainer

onready var LogRichTextField : RichTextLabel = $"LogText"

# Called when the node enters the scene tree for the first time.
func _ready():
	CommandLineManager.connect("log_partly_read",self, "add_text_to_log")




func add_text_to_log(text : String):
	LogRichTextField.append_bbcode( text )




func _on_StartButton_pressed():
	CommandLineManager.start_render_process("blender --background /home/johannes/Schreibtisch/renderfarmtest.blend --frame-start 0 --frame-end 3 --render-anim", "testoutput")


func _on_KillButton_pressed():
	CommandLineManager.kill_current_render_process()

