extends Button


onready var NameLabel = $"MarginContainer/HBoxContainer/Label"
onready var ArrowDown = $"MarginContainer/HBoxContainer/MarginContainer/Arrow_down"
onready var ArrowUp = $"MarginContainer/HBoxContainer/MarginContainer/Arrow_up"
onready var TopRow = $"../.."

var column_button_name
var id

var active_sort_column = false
var sort_reversed = false
var arrow_down_visible = false
var arrow_up_visible = false


signal column_button_pressed




func _ready():
	set_name(column_button_name)
	ArrowDown.visible = arrow_down_visible
	ArrowUp.visible = arrow_up_visible
	
func set_name(button_name):
	NameLabel.text = button_name

func reset_button():
	active_sort_column = false
	sort_reversed = false
	ArrowDown.visible = false
	ArrowUp.visible = false



func _on_ColumnButton_pressed():
	
	if !active_sort_column and !sort_reversed:
		active_sort_column = true
		sort_reversed = false
		ArrowDown.visible = true
		ArrowUp.visible = false
	
	elif active_sort_column and !sort_reversed:
		active_sort_column = true
		sort_reversed = true
		ArrowDown.visible = false
		ArrowUp.visible = true
	
	elif active_sort_column and sort_reversed:
		active_sort_column = true
		sort_reversed = false
		ArrowDown.visible = true
		ArrowUp.visible = false
	
	emit_signal("column_button_pressed", id)