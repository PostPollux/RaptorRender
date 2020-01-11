extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass



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


func _on_ClientButton_pressed() -> void:
	RRNetworkManager.connect_to_server()


func _on_ServerButton_pressed() -> void:
	RRNetworkManager.create_server()


func _on_GeneralSettingsButton_pressed() -> void:
	if RaptorRender.SettingsPopup.visible == false:
		var SettingsPopup : AutoScalingPopup = RaptorRender.SettingsPopup
		SettingsPopup.get_popup_content().settings_type = "default_client"
		SettingsPopup.show_popup()
