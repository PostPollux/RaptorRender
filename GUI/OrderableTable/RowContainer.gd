extends VBoxContainer

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

onready var rows = get_children()
onready var rows_selected = []

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	setColumnWidth(1, 20)
	setColumnWidth(2, 60)
	setColumnWidth(3, 10)
	setColumnWidth(4, 200)
	
	#create test labels
	
	var l = Label.new()
	l.name = "label"
	l.text = "text"
	#l.size_flags_vertical = 0
	#l.set_v_size_flags(4)
	
	add_cellContent(1,1,l)
	
	print (OS.get_name())
	print ('Number of Threads: ' + String(OS.get_processor_count()) )
	print (OS.get_model_name ( ))
	print (OS.get_dynamic_memory_usage ( ))
	
	$OrderabelTableRow.connect("row_clicked", self, "select_rows")
	$OrderabelTableRow2.connect("row_clicked", self, "select_rows")
	$OrderabelTableRow3.connect("row_clicked", self, "select_rows")
	$OrderabelTableRow4.connect("row_clicked", self, "select_rows")
	$OrderabelTableRow5.connect("row_clicked", self, "select_rows")
	$OrderabelTableRow6.connect("row_clicked", self, "select_rows")
	$OrderabelTableRow7.connect("row_clicked", self, "select_rows")
	$OrderabelTableRow8.connect("row_clicked", self, "select_rows")
	
	
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass

func setColumnWidth(column, width):
	
	for r in rows:
		r.set_cellWidth(column,width)
		
		
func add_cellContent(row, column, child):
	if row <= rows.size():
		rows[row-1].add_cellContent(column, child)
	


func select_rows(row_id):
	
	var clickedRow = rows[row_id - 1]
	
	if Input.is_key_pressed(KEY_CONTROL):
		if clickedRow.get_selected() == false:
			clickedRow.set_selected(true)
			clickedRow.set_color_select()
			rows_selected.append(clickedRow)
		
		
	elif Input.is_key_pressed(KEY_SHIFT):
		var previous_selected_row_id = rows_selected[rows_selected.size() - 1].get_row_id()
		
		if row_id > previous_selected_row_id:
			
			for i in range(previous_selected_row_id, row_id + 1):
				if rows[i-1].get_selected() == false:
					rows[i-1].set_selected(true)
					rows[i-1].set_color_select()
					rows_selected.append(rows[i-1])
		
		if row_id < previous_selected_row_id:
			
			for i in range(row_id, previous_selected_row_id):
				if rows[i-1].get_selected() == false:
					rows[i-1].set_selected(true)
					rows[i-1].set_color_select()
					rows_selected.append(rows[i-1])
		
	else:
		for row in rows:
			row.set_selected(false)
			row.set_color_reset()
		rows_selected.clear()
		
		clickedRow.set_selected(true)
		clickedRow.set_color_select()
		rows_selected.append(clickedRow)
	
	print (rows_selected)
	pass
	