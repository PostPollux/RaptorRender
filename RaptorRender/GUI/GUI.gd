extends Node

# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass


func _on_CreateJobButton_pressed() -> void:
	if RaptorRender.SubmitJobPopup.visible == false:
			RaptorRender.SubmitJobPopup.show_popup()


func _on_PoolManagerButton_pressed() -> void:
	if RaptorRender.PoolManagerPopup.visible == false:
			RaptorRender.PoolManagerPopup.show_popup()


func _on_SwitchLanguageButton_pressed() -> void:
	if TranslationServer.get_locale() == "de":
		TranslationServer.set_locale("en")
	else:
		TranslationServer.set_locale("de")


func _on_ColorizeRowsButton_pressed() -> void:
	if RaptorRender.colorize_erroneous_table_rows:
		RaptorRender.colorize_erroneous_table_rows = false
	else:
		RaptorRender.colorize_erroneous_table_rows = true
	RaptorRender.JobsTable.refresh()
	RaptorRender.ClientsTable.refresh()
