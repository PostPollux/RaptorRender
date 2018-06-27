extends Node



func _ready():
	
	var hostname = get_hostname()
	var mac_addresses = get_MAC_addresses()
	var cpu = get_cpu_info()
	var mem = get_memory()
	
	print(" ")
	print ("Hostname: " + hostname)
	print(" ")
	print ("MAC Addresses:")
	print (mac_addresses)
	print(" ")
	print ("CPU:")
	print ("Model Name: " + cpu[0])
	print ("GHz: " + String( cpu[1] ) +" GHz")
	print ("Sockets: " + String( cpu[2]))
	print ("Cores: " + String( cpu[3]))
	print ("Threads: " + String( cpu[4]))
	print(" ")
	print ("Memory:")
	print ("total: " + String( mem[0]/1000 ) +" MB")
	print ("available: " + String( mem[1]/1000 ) +" MB")
	print ("used: " + String( (mem[0]-mem[1])/1000 ) +" MB")
	
	


# returns the MAC Adresses as a String Array with ":" inbetween
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
		
			# invoke getmac with format option csv
			var getmac_output = []
			var arguments = ["/fo", "csv"]
			OS.execute("getmac", arguments, true, getmac_output)   
			
			# split String in lines
			var splitted_output = getmac_output[0].split('\n', false, 0)  
			
			# extract the mac addresses from the second line onwards
			for i in range( 1, splitted_output.size()):
				var mac_address = splitted_output[i].right(1).left(17)  # cut off beginning and ending of the line to extract the mac-address
				mac_address = mac_address.replace("-",":")
				
				mac_addresses.append(mac_address)
				
			
			return mac_addresses
			





# returns an array [MemTotal, MemAvailable] (in kb)
func get_memory():
	
	var memory = []
	
	var platform = OS.get_name()
			
	match platform:
		
		# Linux
		"X11" : 
			
			# just read the file /proc/meminfo
						
			var meminfo_file_path = "/proc/meminfo"
						
			var meminfo_file = File.new()
						
			if meminfo_file.file_exists(meminfo_file_path):
				
				var mem_total = 0
				var mem_available = 0
				
				meminfo_file.open(meminfo_file_path,1)
				
				while true:
					var line = meminfo_file.get_line()
					
					if line.begins_with("MemTotal"):
						line = line.right(10) #cut off beginning
						line = line.left(line.rfind("kB", -1)) # cut off kB
						line = line.strip_edges(true,true) # remove nonprintable characters
						mem_total = int (line)
						
						
					if line.begins_with("MemAvailable"):
						line = line.right(13) #cut off beginning
						line = line.left(line.rfind("kB", -1)) # cut off kB
						line = line.strip_edges(true,true) # remove nonprintable characters
						mem_available = int (line)
						
					# break loop when both values are set	
					if (mem_total != 0 and mem_available != 0) :
						break
					
					# break loop if end of file is reached
					if line == "":
						break
					
				memory.append(mem_total)
				memory.append(mem_available)
				
			
			return memory
		
		
		# Windows
		"Windows" :	
		
			# not implemented
			var erg = [0,0]
			return erg
			
			
			
			
# returns an array [Model Name, MHz, number of sockets, number of cores, number of threads] 
func get_cpu_info():
	
	var cpu = []
	
	var platform = OS.get_name()
			
	match platform:
		
		# Linux
		"X11" : 
			
			# just read the file /proc/cpuinfo
						
			var cpuinfo_file_path = "/proc/cpuinfo"
						
			var cpuinfo_file = File.new()
						
			if cpuinfo_file.file_exists(cpuinfo_file_path):
				
				var model_name = ""
				var GHz = 0.0
				var sockets = 0
				var cores = 0
				var threads = 0
				
				var number_of_empty_lines = 0
				
				cpuinfo_file.open(cpuinfo_file_path,1)
				
				while true:
					
					var line = cpuinfo_file.get_line()
					
					if line.begins_with("model name"):
						line = line.right(10) #cut off beginning
						line = line.strip_edges(true,true) # remove nonprintable characters
						line = line.right(1) # cut off ":" 
						line = line.strip_edges(true,true) # remove nonprintable characters
						model_name = line
						
						GHz = model_name.right(model_name.rfind(" ", -1) + 1) # remove beginning from model name to get the GHz
						GHz = GHz.left(GHz.rfind("GHz", -1))
						GHz = float (GHz)
						
							
						
					if line.begins_with("cpu cores"):
						line = line.right(9) #cut off beginning
						line = line.strip_edges(true,true) # remove nonprintable characters
						line = line.right(1) # cut off ":" 
						line = line.strip_edges(true,true) # remove nonprintable characters
						cores = int(line)
						
						
					if line.begins_with("siblings"):
						line = line.right(8) #cut off beginning
						line = line.strip_edges(true,true) # remove nonprintable characters
						line = line.right(1) # cut off ":" 
						line = line.strip_edges(true,true) # remove nonprintable characters
						threads = int(line)
						
						
					if line.begins_with("physical id"):
						line = line.right(11) #cut off beginning
						line = line.strip_edges(true,true) # remove nonprintable characters
						line = line.right(1) # cut off ":" 
						line = line.strip_edges(true,true) # remove nonprintable characters
						var physical_id = int(line)	
						if physical_id > sockets:
							sockets = physical_id
					
					# break loop if end of file is reached (more then 2 empty lines in a row)
					if line == "":
						number_of_empty_lines += 1
						if number_of_empty_lines > 2:
							break
					else:
						number_of_empty_lines = 0
					
				
				cpu.append(model_name)
				cpu.append(GHz)
				cpu.append(sockets + 1)
				cpu.append(cores)
				cpu.append(threads)
				
			return cpu
		
		
		# Windows
		"Windows" :	
			return ("not implemented")
			
			

# returns the name of the computer
func get_hostname():
	
	var hostname = ""
	
	var platform = OS.get_name()
			
	match platform:
		
		# Linux
		"X11" : 
			
			# just read the file /etc/hostname
						
			var hostname_file_path = "/etc/hostname"
						
			var hostname_file = File.new()
						
			if hostname_file.file_exists(hostname_file_path):
				
				hostname_file.open(hostname_file_path,1)
				
				hostname = hostname_file.get_as_text().strip_edges(true,true)
				
			return hostname
		
		
		# Windows
		"Windows" :	
			return ( "not implemented")
			
			
			