extends Node

var hostname
var platform_info # Array. First item: platform name (Linux/Windows/OSX), second item: version (kernel version, Windows version)
var mac_addresses # array of all mac addresses as strings formatted like xx:xx:xx:xx:xx:xx
var ip_addresses # array of all used ip addresses
var total_memory # total memory in kb
var cpu_info  # array: [Model Name, MHz, number of sockets, number of cores, number of threads] 
var graphic_cards # array with the name of all graphic cards found in the system

var memory_load # percentage of memory used (int Value between 0 and 100)
var cpu_load # percentage of cpu usage (int Value between 0 and 100)


var recent_cpu_stat_values = []




func _ready():
	
	# create timer to constantly get the cpu and memory load
	var hardware_info_timer = Timer.new()
	hardware_info_timer.name = "Hardware Info Timer"
	hardware_info_timer.wait_time = 2
	hardware_info_timer.connect("timeout",self,"_on_hardware_info_timer_timeout") 
	get_tree().get_root().get_node("Node").add_child(hardware_info_timer)
	hardware_info_timer.start()
	
	
	# fill the variables that don't change
	hostname = get_hostname()
	platform_info = get_platform_info()
	mac_addresses = get_MAC_addresses()
	ip_addresses = get_IP_addresses()
	total_memory = get_total_memory()
	cpu_info = get_cpu_info()
	graphic_cards = get_graphic_cards()
	
	
	# print
	print_hardware_info()
	



func _on_hardware_info_timer_timeout():
	
	# set memory_load
	var mem_available = get_available_memory()
	var mem_load_as_float = ( float(total_memory) - float(mem_available) )  / float(total_memory) * 100
	
	memory_load = int(mem_load_as_float)
	
	
	# set cpu load
	cpu_load = int (get_cpu_load() )
	

	# print results
	print ( "Memory Load: " + String( memory_load )  + " %"  )
	print ( "CPU Load: " + String( cpu_load )  + " %"  )




func print_hardware_info():
	# Print
	var mem_available = get_available_memory()
	
	print(" ")
	print ("Hostname: " + hostname)
	print ("Platform: " + platform_info[0])
	print ("Version: " + platform_info[1])
	print(" ")
	print ("MAC Addresses:")
	print (mac_addresses)
	print(" ")
	print ("IP Addresses:")
	print (ip_addresses)
	print(" ")
	print ("CPU:")
	print ("Model Name: " + cpu_info[0])
	print ("GHz: " + String( cpu_info[1] ) +" GHz")
	print ("Sockets: " + String( cpu_info[2]))
	print ("Cores: " + String( cpu_info[3]))
	print ("Threads: " + String( cpu_info[4]))
	print(" ")
	print ("Memory:")
	print ("total: " + String( total_memory / 1024 ) +" MB")
	print ("available: " + String( mem_available / 1024 ) +" MB")
	print ("used: " + String( (total_memory - mem_available) / 1024 ) +" MB")
	print(" ")
	print ("Graphic Cards:")
	for card in graphic_cards:
		print (card)
	print(" ")



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
			
			if dir.dir_exists( network_adapters_directory_path ):
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
			



# returns the IP Adresses as a String Array
func get_IP_addresses():
	
	var ip_addresses = []
	
	var platform = OS.get_name()
	
	match platform:
		
		# Linux
		"X11" : 
			# get a list of ip addresses by filtering the "ip addr show" command
			var output = []
			var arguments = ["-c","ip addr show  | grep -Eo 'inet ([0-9]*\\.){3}[0-9]*' | grep -Eo '([0-9]*\\.){3}[0-9]*' | grep -v '127.0.0.1'"]
			OS.execute("bash", arguments, true, output)
			
			# split String in lines
			var splitted_output = output[0].split('\n', false, 0)  
			
			for line in splitted_output:
				ip_addresses.append(line)
			
			return ip_addresses
		
		# Windows
		"Windows" :
			# not implemented yet
			
			return ip_addresses



# returns total memory in kb
func get_total_memory():
	
	var mem_total = 0
	
	var platform = OS.get_name()
	
	match platform:
		
		# Linux
		"X11" : 
			
			# just read the file /proc/meminfo
			
			var meminfo_file_path = "/proc/meminfo"
			
			var meminfo_file = File.new()
			
			if meminfo_file.file_exists(meminfo_file_path):
				
				
				
				
				meminfo_file.open(meminfo_file_path,1)
				
				while true:
					var line = meminfo_file.get_line()
					
					if line.begins_with("MemTotal"):
						line = line.right(10) #cut off beginning
						line = line.left(line.rfind("kB", -1)) # cut off kB
						line = line.strip_edges(true,true) # remove nonprintable characters
						mem_total = int (line)	
						
					# break loop when value is set
					if (mem_total != 0) :
						break
					
					# break loop if end of file is reached
					if line == "":
						break
			
			return mem_total
		
		
		# Windows
		"Windows" :
		
			# get total memory
			var output = []
			var arguments = ['/C','wmic OS get TotalVisibleMemorySize /Value']
			
			OS.execute('CMD.exe', arguments, true, output)
			
			var mem_total_str = output[0].strip_edges(true,true)  # strip away empty stuff
			mem_total_str = mem_total_str.split("=")[1]  # Take the string behind the "="
			mem_total = int(mem_total_str)
			
			return mem_total
			




# returns available memory in kb
func get_available_memory():
	
	var mem_available = 0
	
	var platform = OS.get_name()
	
	match platform:
		
		# Linux
		"X11" : 
			
			# just read the file /proc/meminfo
			
			var meminfo_file_path = "/proc/meminfo"
			
			var meminfo_file = File.new()
			
			if meminfo_file.file_exists(meminfo_file_path):
				
				
				
				meminfo_file.open(meminfo_file_path,1)
				
				while true:
					var line = meminfo_file.get_line()
					
					if line.begins_with("MemAvailable"):
						line = line.right(13) #cut off beginning
						line = line.left(line.rfind("kB", -1)) # cut off kB
						line = line.strip_edges(true,true) # remove nonprintable characters
						mem_available = int (line)
						
					# break loop when both values are set	
					if (mem_available != 0) :
						break
					
					# break loop if end of file is reached
					if line == "":
						break
			
			return mem_available
		
		
		
		# Windows
		"Windows" :
			
			# get free memory
			var output = []
			var arguments = ['/C','wmic OS get FreePhysicalMemory /Value']
			
			OS.execute('CMD.exe', arguments, true, output)
			
			var mem_available_str = output[0].strip_edges(true,true)  # strip away empty stuff
			mem_available_str = mem_available_str.split("=")[1]  # Take the string behind the "="
			mem_available = int(mem_available_str)
			
			return mem_available
			
			
			




# returns an array [Model Name, MHz, number of sockets, number of cores, number of threads] 
func get_cpu_info():
	
	var cpu = []
	
	var model_name = ""
	var GHz = 0.0
	var sockets = 0
	var cores = 0
	var threads = 0
	
	var platform = OS.get_name()
	
	match platform:
		
		# Linux
		"X11" : 
			
			# just read the file /proc/cpuinfo
			
			var cpuinfo_file_path = "/proc/cpuinfo"
			
			var cpuinfo_file = File.new()
			
			if cpuinfo_file.file_exists(cpuinfo_file_path):
				
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
			
			# get model name and GHz
			var output = []
			var arguments = ['/C','wmic cpu get Name /Value']
			
			OS.execute('CMD.exe', arguments, true, output)
			
			model_name = output[0].strip_edges(true,true)  # strip away empty stuff
			model_name = model_name.split("=")[1]  # Take the string behind the "="
			
			GHz = model_name.right(model_name.rfind(" ", -1) + 1) # remove beginning from model name to get the GHz
			GHz = GHz.left(GHz.rfind("GHz", -1))
			GHz = float (GHz)
			
			
			# get number of sockets
			output = []
			arguments = ['/C','wmic COMPUTERSYSTEM get NumberOfProcessors /Value']
			
			OS.execute('CMD.exe', arguments, true, output)
			
			sockets = output[0].strip_edges(true,true)  # strip away empty stuff
			sockets = sockets.split("=")[1]  # Take the string behind the "="
			sockets = int(sockets)
			
			
			# get number of cores
			output = []
			arguments = ['/C','wmic cpu get NumberOfCores /Value']
			
			OS.execute('CMD.exe', arguments, true, output)
			
			cores = output[0].strip_edges(true,true)  # strip away empty stuff
			cores = cores.split("=")[1]  # Take the string behind the "="
			cores = int(cores)
			
			
			# get number of threads
			output = []
			arguments = ['/C','wmic cpu get NumberOfLogicalProcessors /Value']
			
			OS.execute('CMD.exe', arguments, true, output)
			
			threads = output[0].strip_edges(true,true)  # strip away empty stuff
			threads = threads.split("=")[1]  # Take the string behind the "="
			threads = int(threads)
			
			# build the array
			cpu.append(model_name)
			cpu.append(GHz)
			cpu.append(sockets)
			cpu.append(cores)
			cpu.append(threads)
		
			return cpu
			
			



func get_cpu_load():
	
	var cpu_load_as_float = 0.0
	
	var platform = OS.get_name()
	
	match platform:
		
		# Linux
		"X11" :
			
			# read the file /proc/stat 
			# the first line is the time accumulation of all the cores. It looks something like: 
			# "cpu  337190 187 61395 3331872 1319 0 4453 0 0 0"
			#         ^          ^      ^
			#        user      system  idle
			
			# read the file twice with a time offset. Substract the first values from the second ones. 
			# load = time spent by user and system devided by total time spent ( user + system + idle)
			
			var cpu_load_file_path = "/proc/stat"
			
			var cpu_load_file = File.new()
			
			if cpu_load_file.file_exists(cpu_load_file_path):
				
				var number_of_empty_lines = 0
				
				cpu_load_file.open(cpu_load_file_path,1)
				
				var line = cpu_load_file.get_line() # get the first line
				
				line = line.strip_edges(true, true) # remove nonprintable characters
				var current_cpu_stat_values = line.split(" ", false, 0) # convert the line to an array
				
				if (recent_cpu_stat_values.size() > 0):
					var time_spent_user_plus_system = int(current_cpu_stat_values[1]) - int(recent_cpu_stat_values[1]) + int(current_cpu_stat_values[3]) - int(recent_cpu_stat_values[3])
					var time_spent_user_plus_system_plus_idle = int(current_cpu_stat_values[1]) - int(recent_cpu_stat_values[1]) + int(current_cpu_stat_values[3]) - int(recent_cpu_stat_values[3]) + int(current_cpu_stat_values[4]) - int(recent_cpu_stat_values[4])
					cpu_load_as_float = time_spent_user_plus_system * 100 / time_spent_user_plus_system_plus_idle

				recent_cpu_stat_values = current_cpu_stat_values
			
			return cpu_load_as_float
			
			
		# Windows
		"Windows" :
			
			# get number of threads
			var output = []
			var arguments = ['/C','wmic cpu get loadpercentage /Value>test.txt']  # unfortunately saving to a text file only works in blocking mode :(
			
			#OS.execute('CMD.exe', arguments, false, output)
			
			#var cpu_load_str = output[0].strip_edges(true,true)  # strip away empty stuff
			#cpu_load_str = cpu_load_str.split("=")[1]  # Take the string behind the "="
			#cpu_load_as_float = float(cpu_load_str)
			
			return cpu_load_as_float




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
		
			var hostname_output = []
			var arguments = []
			OS.execute("hostname", arguments, true, hostname_output)
			
			hostname = hostname_output[0]
			
			return hostname



# returns the name of the platform
func get_platform_info():
	
	var platform_info_array = []
	
	var platform = OS.get_name()
	
	match platform:
		
		# Linux
		"X11" :
			# Platform Name
			platform_info_array.append("Linux")
			
			# Kernel Version
			var output = []
			var arguments = ["-r"]
			
			OS.execute("uname", arguments, true, output)
			
			var position_to_split = output[0].find_last("-")
			
			var kernel_version = output[0].left(position_to_split) # take the left part of the string
			
			platform_info_array.append(kernel_version) 
			
			
			return platform_info_array
		
		
		# Windows
		"Windows" :
			# Platform name
			platform_info_array.append("Windows")
			
			# Windows Version
			
			
			return platform_info_array
			
			
		# Mac OS
		"OSX" :
			platform_info_array.append("OSX")
			
			return platform_info_array



# returns the name of the platform
func get_graphic_cards():
	
	var graphic_cards_array = []
	
	var platform = OS.get_name()
	
	match platform:
		
		# Linux
		"X11" :
			
			# run "lspci | grep -E 'VGA|3D'" to get a list of all graphics devices
			var output = []
			var arguments = ["-c","lspci | grep -E 'VGA|3D'"] # filter the output of lspci by VGA and 3D
			OS.execute("bash", arguments, true, output)
			
			# split String in lines
			var splitted_output = output[0].split('\n', false, 0)  
			
			for line in splitted_output:
				
				# remove stuff at the beginning of the line
				var position_to_split = line.find(": ")
				line = line.right(position_to_split + 2)
				
				# remove stuff at the end of the line
				position_to_split = line.find_last("(")
				if position_to_split > -1:
					line = line.left(position_to_split)
				
				# remove the word "Corporation"
				line = line.replacen("Corporation ","")
				
				# add the result to the array
				graphic_cards_array.append(line)
				
			
			return graphic_cards_array
		
		
		# Windows
		"Windows" :
			pass
			


