extends Control

class_name RRContextMenuBase

export (String) var context_menu_id
onready var ContextMenu = $"ContextMenu"

func _ready():
	# register to RaptorRender script
	if RaptorRender != null:
		RaptorRender.register_context_menu(self)

func _process(delta):
	
	# hide context menu when clicked somewhere else
	if ContextMenu.visible:
		
		if Input.is_action_just_pressed("ui_left_mouse_button") or Input.is_action_just_pressed("ui_right_mouse_button"):
			
			if !ContextMenu.get_rect().has_point( get_viewport().get_mouse_position() ):
				ContextMenu.hide()



func show_at_mouse_position():
	var popup_pos_x
	var popup_pos_y
	var margin = 6
	var popup_size_x = ContextMenu.rect_size.x
	var popup_size_y = ContextMenu.rect_size.y
	var mouse_pos = get_viewport().get_mouse_position()
	var viewport_rect = get_viewport().size
	
	# left and right border
	if mouse_pos.x < margin:
		popup_pos_x = margin
	elif mouse_pos.x + popup_size_x > viewport_rect.x - margin:
		popup_pos_x = viewport_rect.x - popup_size_x - margin
	else:
		popup_pos_x = mouse_pos.x
	
	# top and bottom border
	if mouse_pos.y < margin:
		popup_pos_y = margin
	elif mouse_pos.y + popup_size_y > viewport_rect.y - margin:
		popup_pos_y = viewport_rect.y - popup_size_y - margin
	else:
		popup_pos_y = mouse_pos.y
	
	ContextMenu.rect_position = Vector2(popup_pos_x, popup_pos_y)
	ContextMenu.set_item_names()
	ContextMenu.enable_disable_items()
	ContextMenu.show()
