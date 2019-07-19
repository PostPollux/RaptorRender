extends Node


# convert a hex string to a PoolByteArray 
# (hex string can be marked with 0x at the beginning, but doesn't have to)

func hex_string_to_PoolByteArray(hex_string : String) -> Array:
	
	# convert to lower case
	hex_string = hex_string.to_lower() 
	
	# remove "0x" from the beginning
	if hex_string.begins_with("0x"):
		hex_string = hex_string.right(2)
	
	# abort, if string has odd numbers of characters
	if hex_string.length() % 2 > 0:
		print ("Hex string seems wrong, it has an odd number of characters!")
		return []
	
	# split the string to a string array where each element contains one hex-blob
	var hex_string_splitted : Array = []
	
	for i in range(0, hex_string.length()/2):
		hex_string_splitted.append(hex_string.substr(i*2,2))
		
		
	# convert each hex-blob to an integer
	var converted_int_array : Array = []
	
	for hex_blob in hex_string_splitted:
		
		var converted_int : int = 0
		
		var first_digit : int = 0 
		var second_digit : int = 0 
		
		match hex_blob.substr(0,1):
			"0": first_digit = 0
			"1": first_digit = 1 
			"2": first_digit = 2
			"3": first_digit = 3
			"4": first_digit = 4
			"5": first_digit = 5 
			"6": first_digit = 6
			"7": first_digit = 7
			"8": first_digit = 8
			"9": first_digit = 9 
			"a": first_digit = 10
			"b": first_digit = 11
			"c": first_digit = 12
			"d": first_digit = 13
			"e": first_digit = 14
			"f": first_digit = 15
		
		match hex_blob.substr(1,1):
			"0": second_digit = 0
			"1": second_digit = 1 
			"2": second_digit = 2
			"3": second_digit = 3
			"4": second_digit = 4
			"5": second_digit = 5 
			"6": second_digit = 6
			"7": second_digit = 7
			"8": second_digit = 8
			"9": second_digit = 9 
			"a": second_digit = 10
			"b": second_digit = 11
			"c": second_digit = 12
			"d": second_digit = 13
			"e": second_digit = 14
			"f": second_digit = 15
		
		converted_int = first_digit * 16 + second_digit
		
		converted_int_array.append(converted_int)
	
	
	var hex_as_PoolByteArray : Array = PoolByteArray(converted_int_array)
	
	return hex_as_PoolByteArray




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






# Returns the size the input rectangle has to be scaled to in order to perfectly fit into the desired rectangle without changing the ratio of the first one.
# Can be used to fit image into a box without cutting anything off. In Raptor Render it is used to calculate thumbnail sizes.
func calculate_size_for_specific_box(input_size : Vector2, fit_box_size : Vector2 ) -> Vector2:
	
	var new_size: Vector2 = Vector2(0,0)
	
	if input_size.x != 0 and input_size.y != 0:
		
		# calculate ratio values. Value is high for landscape input_size and low for portrait.
		var ratio_fit_box : float = float(fit_box_size.x) / float(fit_box_size.y)
		var ratio_input : float = float(input_size.x) / float(input_size.y)
		
		
		# input more landscape than desired output
		if ratio_input > ratio_fit_box:
			var scale_ratio : float = float(fit_box_size.x) / float(input_size.x)
			new_size = Vector2(fit_box_size.x, input_size.y * scale_ratio)
			
		# input less landscape than desired output
		else:
			var scale_ratio : float = float(fit_box_size.y) / float(input_size.y)
			new_size = Vector2( input_size.x * scale_ratio, fit_box_size.y)
		
	return new_size



# this function converts an input integer to a string with leading zeros. E.g.: 49 -> 0049
func convert_int_to_padded_number_string(number : int, number_of_digits : int) -> String:
	
	var padded_str : String = ""
	
	var number_of_needed_zeros : int = number_of_digits -  String(number).length()
	
	if number_of_needed_zeros > 0:
		for i in range(0, number_of_needed_zeros):
			padded_str += "0"
			
	padded_str += String(number)
	
	return padded_str



# returns the number of padding a file sequence is supposed to have by counting the number of hashtag signs at the end of a file name pattern.
func get_padding_from_string_with_hashtags(input_str : String) -> int:
	
	var hashtags : String = input_str.right( input_str.find("#", 0) - 1 ) # cut off the left part of the first hashtag sign
	hashtags = hashtags.left( hashtags.find_last("#") + 1 ) # cut off the right part of the last hashtag sign
	
	# make sure that only tha last hashtag signs are left. So that a filename like "example#3_new_####.png" returns 4 and not 11.
	var corrected_hashtags : String = hashtags
	
	for i in range(0, hashtags.length()):
		if hashtags[i] != "#":
			corrected_hashtags = hashtags.right(i)
	
	return corrected_hashtags.length()



#  converts a string like "test_####.png" with a given number of for example 49 to: "test_0049.png"
func replace_frame_number_placeholders_with_number(filename_pattern : String, frame_number : int) -> String:
	
	var used_frame_padding : int = get_padding_from_string_with_hashtags( filename_pattern)
	
	var padded_frame_number : String = convert_int_to_padded_number_string(frame_number, used_frame_padding)
	
	var placeholder : String = ""
	for i in range (0, used_frame_padding):
		placeholder += "#"
			
	return filename_pattern.replace(placeholder, padded_frame_number)


func generate_job_id(time_created : int, job_name : String) -> int:
	var job_string_to_hash : String = job_name + String(time_created)
	return job_string_to_hash.hash()