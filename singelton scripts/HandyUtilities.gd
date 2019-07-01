extends Node


# This function takes an array of control nodes, compares their actual width or height and sets all to the longest one by manipulating the rect_min_size value.
# Can be used for example if you want to create an illusion of a table where all the labels are the same size, so the next "column" starts from the same position.
func set_min_size_to_longest(ControlElements : Array, x : bool, y : bool):
	
	for Element in ControlElements:
		if x: Element.rect_min_size.x = 0
		if y: Element.rect_min_size.y = 0
	
	var biggest_size_x : int = 0
	var biggest_size_y : int = 0
	
	for Element in ControlElements:
		if x:
			if Element.rect_size.x > biggest_size_x:
				biggest_size_x = Element.rect_size.x
		if y:
			if Element.rect_size.y > biggest_size_y:
				biggest_size_y = Element.rect_size.y
	
	for Element in ControlElements:
		if x: Element.rect_min_size.x = biggest_size_x
		if y: Element.rect_min_size.y = biggest_size_y