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
	

	