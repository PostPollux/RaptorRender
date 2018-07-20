extends Button


onready var NameLabel = $"MarginContainer/HBoxContainer/Label"
onready var PrimaryDown = $"MarginContainer/HBoxContainer/MarginContainer/primary_down"
onready var PrimaryUp = $"MarginContainer/HBoxContainer/MarginContainer/primary_up"
onready var SecondaryDown = $"MarginContainer/HBoxContainer/MarginContainer/secondary_down"
onready var SecondaryUp = $"MarginContainer/HBoxContainer/MarginContainer/secondary_up"
onready var TopRow = $"../.."

var column_button_name
var id

var primary_sort_column = false
var secondary_sort_column = false
var sort_column_primary_reversed = false
var sort_column_secondary_reversed = false
var primary_down_visible = false
var primary_up_visible = false
var secondary_down_visible = false
var secondary_up_visible = false


signal column_button_pressed




func _ready():
	set_name(column_button_name)
	PrimaryDown.visible = primary_down_visible
	PrimaryUp.visible = primary_up_visible
	SecondaryDown.visible = secondary_down_visible
	SecondaryUp.visible = secondary_up_visible



func set_name(button_name):
	NameLabel.text = button_name



func reset_button():
	primary_sort_column = false
	sort_column_primary_reversed = false
	secondary_sort_column = false
	sort_column_secondary_reversed = false
	PrimaryDown.visible = false
	PrimaryUp.visible = false
	SecondaryDown.visible = false
	SecondaryUp.visible = false



func show_correct_icon():
	
	if primary_sort_column:
		
		if !sort_column_primary_reversed:
			
			PrimaryDown.visible = true
			PrimaryUp.visible = false
			SecondaryDown.visible = false
			SecondaryUp.visible = false
		
		else:
			
			PrimaryDown.visible = false
			PrimaryUp.visible = true
			SecondaryDown.visible = false
			SecondaryUp.visible = false
			
	elif secondary_sort_column:
		
		if !sort_column_secondary_reversed:
			
			PrimaryDown.visible = false
			PrimaryUp.visible = false
			SecondaryDown.visible = true
			SecondaryUp.visible = false
		
		else:
			
			PrimaryDown.visible = false
			PrimaryUp.visible = false
			SecondaryDown.visible = false
			SecondaryUp.visible = true




func _on_ColumnButton_pressed():
	
	# if ctrl, shift or alt pressed: set the column as secondary sort column
	if Input.is_key_pressed(KEY_CONTROL) or Input.is_key_pressed(KEY_ALT) or Input.is_key_pressed(KEY_SHIFT):
		
		if !secondary_sort_column and !sort_column_secondary_reversed:
			secondary_sort_column = true
			sort_column_secondary_reversed = false
			show_correct_icon()
		
		elif secondary_sort_column and !sort_column_secondary_reversed:
			secondary_sort_column = true
			sort_column_secondary_reversed = true
			show_correct_icon()
		
		elif secondary_sort_column and sort_column_secondary_reversed:
			secondary_sort_column = true
			sort_column_secondary_reversed = false
			show_correct_icon()
	
	# else, set it as primary sort column
	else:
		if !primary_sort_column and !sort_column_primary_reversed:
			primary_sort_column = true
			sort_column_primary_reversed = false
			show_correct_icon()
		
		elif primary_sort_column and !sort_column_primary_reversed:
			primary_sort_column = true
			sort_column_primary_reversed = true
			show_correct_icon()
		
		elif primary_sort_column and sort_column_primary_reversed:
			primary_sort_column = true
			sort_column_primary_reversed = false
			show_correct_icon()
	
	# emit a signal which is catched by TopRow
	emit_signal("column_button_pressed", id)