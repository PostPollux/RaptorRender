extends Node



func _ready():
	
	print ("MAC Addresses:")
	print (get_MAC_addresses())
	


# returns the MAC Adresses as a String Array
func get_MAC_addresses():
	
	var mac_addresses = []
	var platform = OS.get_name()
			
	match platform:
		
		# Linux
		"X11" : 
			
			# In linux networkadapter files ar stored in "/sys/class/net/" it's easy to read the mac addresses from there 
			
			var dir = Directory.new()
			var network_adapters_directory_path = "/sys/class/net/"
						
			if	dir.dir_exists( network_adapters_directory_path ):
				var adapter_directories = []
				
				dir.open(network_adapters_directory_path)
				
				dir.list_dir_begin()

				while true:
					var adapter_dir = dir.get_next()
					if adapter_dir == "":
						break
					elif not adapter_dir.begins_with("."):
						adapter_directories.append(adapter_dir)
						
				dir.list_dir_end()
					
				if adapter_directories.size() > 0:
					
					for adapter_dir in adapter_directories:
						
						var address_file_path = network_adapters_directory_path + adapter_dir + "/address"
						
						var address_file = File.new()
						
						if address_file.file_exists(address_file_path):
							address_file.open(address_file_path,1)
							var mac_address = address_file.get_as_text().strip_edges(true,true)
							if mac_address != "00:00:00:00:00:00":
								mac_addresses.append(mac_address)
						
					
					return mac_addresses
		
		# Windows
		"Windows" :	
			var getmac_output = []
			var arguments = []
			OS.execute("getmac", arguments, true, getmac_output)
			print ( getmac_output )
			