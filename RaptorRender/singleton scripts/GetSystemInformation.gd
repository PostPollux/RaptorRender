#////////////////////////#
# Get System Information #
#////////////////////////#

# This script provides all the functions to get specific information and specs of the computer it is running on.
# It is supposed to be autoloaded.


extends Node


### PRELOAD RESOURCES

### SIGNALS

### ONREADY VARIABLES

### EXPORTED VARIABLES

### VARIABLES
var platform : String # to decide which function to call depending on os
var hostname : String
var username : String
var platform_info : Array # First item: platform name (Linux/Windows/OSX), second item: version (kernel version, Windows version (XP,7,10)), third item: additional info (Linux Distribution, Windows version (Pro, Home, Ultimate))
var mac_addresses : Array # all mac addresses as strings formatted like xx:xx:xx:xx:xx:xx
var ip_addresses : Array # all used ip addresses
var total_memory : int # total memory in kb
var cpu_info : Array # [Model Name, MHz, number of sockets, number of cores, number of threads] 
var graphic_cards : Array # names of all graphic cards found in the system
var hard_drives : Array # array with a dict for each hard drive. The dict has the following keys:  name, label, size, percentage_used, type

var memory_usage : int # percentage of memory used (int Value between 0 and 100)
var cpu_usage : int # percentage of cpu usage (int Value between 0 and 100)

var recent_cpu_stat_values : Array = [] # only relevant for Linux. Used to calculate cpu usage

var user_data_dir : String

var collect_hardware_info_thread : Thread

var own_client_id : int




########## FUNCTIONS ##########


func _ready():
	
	# get current platform to call correct functions
	platform  = OS.get_name()
	
	# save user data directory to a variable
	user_data_dir = OS.get_user_data_dir()
	
	# create .bat file to read cpu usage (only for Windows)
	if OS.get_name() == "Windows":
		
		var bat_file : File = File.new()
		
		if bat_file.open("user://get_win_cpu_usage.bat", File.WRITE) != 0:
			print("Error opening file")
		else:
			bat_file.store_line('cd ' + user_data_dir + '\r\n') # .bat seems to only write a file if the cmd first switches to the correct location
			bat_file.store_line('wmic cpu get loadpercentage /Value | findstr /C:"=">win_cpu_usage.txt')
			bat_file.close()
	
	
	# create a new thread used for constantly updating the hardware info in the background
	collect_hardware_info_thread = Thread.new()
	
	# create timer to constantly get the cpu and memory load
	var hardware_info_timer : Timer = Timer.new()
	hardware_info_timer.name = "Hardware Info Timer"
	hardware_info_timer.wait_time = 2
	hardware_info_timer.connect("timeout",self,"_on_hardware_info_timer_timeout")
	var root_node : Node = get_tree().get_root().get_node("RaptorRenderMainScene")
	if root_node != null:
		root_node.add_child(hardware_info_timer)
	print("timer created")
	hardware_info_timer.start()
	
	# fill the variables
	hostname = get_hostname()
	username = get_username()
	platform_info = get_platform_info()
	mac_addresses = get_MAC_addresses()
	ip_addresses = get_IP_addresses()
	total_memory = get_total_memory()
	cpu_info = get_cpu_info()
	graphic_cards = get_graphic_cards()
	hard_drives = get_hard_drive_info()
	memory_usage = 0
	cpu_usage = 0
	
	
	# add the client to the clients dictionary
	own_client_id = mac_addresses[0].hash()
	RaptorRender.rr_data.clients[own_client_id] = create_client_dict()


func create_client_dict() -> Dictionary:
	var new_client = {
		"machine_properties" : {
			"name": hostname,
			"username": username,
			"mac_addresses": mac_addresses,
			"ip_addresses": ip_addresses,
			"platform": platform_info,
			"cpu": cpu_info,
			"cpu_usage": cpu_usage,
			"memory": total_memory,
			"memory_usage": memory_usage,
			"graphics": graphic_cards,
			"hard_drives": hard_drives,
		},
		"status": RRStateScheme.client_available,
		"current_job_id": -1,
		"last_render_log": [0,0,0],
		"error_count": 0,
		"pools": [],
		"rr_version": 0.2,
		"time_connected": 1528759663,
		"software": ["Blender", "Natron"],
		"note": ""
	}
	return new_client




############################################
### Debug function to print retrieved values
############################################

func print_hardware_info():
	
	var mem_available : int = get_available_memory()
	
	print(" ")
	print ("Hostname: " + hostname)
	print ("Username: " + username)
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





############################################
### Functions to retrieve System Information
############################################


# returns the MAC Adresses as a String Array with ":" inbetween
func get_MAC_addresses() -> Array:
	
	var mac_addresses : Array = []
	
	match platform:
		
		# Linux
		"X11" : 
			
			# In linux networkadapter files ar stored in "/sys/class/net/" it's easy to read the mac addresses from there 
			
			var dir : Directory = Directory.new()
			var network_adapters_directory_path : String = "/sys/class/net/"
			
			if dir.dir_exists( network_adapters_directory_path ):
				var adapter_directories : Array = []
				
				dir.open(network_adapters_directory_path)
				
				dir.list_dir_begin()
				
				while true:
					var adapter_dir : String = dir.get_next()
					if adapter_dir == "":
						break
					elif not adapter_dir.begins_with("."):
						adapter_directories.append(adapter_dir)
						
				dir.list_dir_end()
				
				if adapter_directories.size() > 0:
					
					for adapter_dir in adapter_directories:
						
						var address_file_path : String = network_adapters_directory_path + adapter_dir + "/address"
						
						var address_file : File = File.new()
						
						if address_file.file_exists(address_file_path):
							address_file.open(address_file_path,1)
							var mac_address : String = address_file.get_as_text().strip_edges(true,true)
							if mac_address != "00:00:00:00:00:00":
								mac_addresses.append(mac_address)
						
					
					return mac_addresses
		
		# Windows
		"Windows" :
		
			# invoke getmac with format option csv
			var getmac_output : Array = []
			var arguments : Array = ["/fo", "csv"]
			OS.execute("getmac", arguments, true, getmac_output)   
			
			# split String in lines
			var splitted_output : Array = getmac_output[0].split('\n', false, 0)  
			
			# extract the mac addresses from the second line onwards
			for i in range( 1, splitted_output.size()):
				var mac_address : String = splitted_output[i].right(1).left(17)  # cut off beginning and ending of the line to extract the mac-address
				mac_address = mac_address.replace("-",":")
				
				mac_addresses.append(mac_address)
				
			
			return mac_addresses
	
	return mac_addresses



# returns the IP Adresses as a String Array
func get_IP_addresses() -> Array:
	
	var ip_addresses : Array = []
	
	match platform:
		
		# Linux
		"X11" : 
			# get a list of ip addresses by filtering the "ip addr show" command
			var output : Array = []
			var arguments : Array = ["-c","ip addr show  | grep -Eo 'inet ([0-9]*\\.){3}[0-9]*' | grep -Eo '([0-9]*\\.){3}[0-9]*' | grep -v '127.0.0.1'"]
			OS.execute("bash", arguments, true, output)
			
			# split String in lines
			var splitted_output : Array = output[0].split('\n', false, 0)  
			
			for line in splitted_output:
				ip_addresses.append(line)
			
			return ip_addresses
		
		
		# Windows
		"Windows" :
			# get a list of ip addresses by filtering the "arp -a" command
			var output : Array = []
			var arguments : Array = ['/C arp -a | findstr /C:"---"']
			OS.execute('CMD.exe', arguments, true, output)
			
			# split String in lines
			var splitted_output : Array = output[0].split('\n', false, 0)  
			
			for line in splitted_output:
				var splitted_line : Array = line.split(" ", false, 0)
				
				ip_addresses.append(splitted_line[1])
			
			
			return ip_addresses
	
	return ip_addresses



# returns total memory in kb
func get_total_memory() -> int:
	
	var mem_total : int = 0
	
	match platform:
		
		# Linux
		"X11" : 
			
			# just read the file /proc/meminfo
			
			var meminfo_file_path : String = "/proc/meminfo"
			
			var meminfo_file : File = File.new()
			
			if meminfo_file.file_exists(meminfo_file_path):
				
				meminfo_file.open(meminfo_file_path,1)
				
				while true:
					var line : String = meminfo_file.get_line()
					
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
			var output : Array = []
			var arguments : Array = ['/C','wmic OS get TotalVisibleMemorySize /Value']
			
			OS.execute('CMD.exe', arguments, true, output)
			
			var mem_total_str : String = output[0].strip_edges(true,true)  # strip away empty stuff
			mem_total_str = mem_total_str.split("=")[1]  # Take the string behind the "="
			mem_total = int(mem_total_str)
			
			return mem_total
		
	return mem_total



# returns available memory in kb
func get_available_memory() -> int:
	
	var mem_available : int = 0
	
	match platform:
		
		# Linux
		"X11" : 
			
			# just read the file /proc/meminfo
			
			var meminfo_file_path : String = "/proc/meminfo"
			
			var meminfo_file : File = File.new()
			
			if meminfo_file.file_exists(meminfo_file_path):
						
				meminfo_file.open(meminfo_file_path,1)
				
				while true:
					var line : String = meminfo_file.get_line()
					
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
			var output : Array = []
			var arguments : Array = ['/C','wmic OS get FreePhysicalMemory /Value']
			
			OS.execute('CMD.exe', arguments, true, output)
			
			var mem_available_str : String = output[0].strip_edges(true,true)  # strip away empty stuff
			mem_available_str = mem_available_str.split("=")[1]  # Take the string behind the "="
			mem_available = int(mem_available_str)
			
			return mem_available
	
	return mem_available





# returns an array [Model Name, MHz, number of sockets, number of cores, number of threads] 
func get_cpu_info() -> Array:
	
	var cpu : Array = []
	
	var model_name : String = ""
	var GHz : float = 0.0
	var sockets : int = 0
	var cores : int = 0
	var threads : int  = 0
	
	match platform:
		
		# Linux
		"X11" : 
			
			# just read the file /proc/cpuinfo
			
			var cpuinfo_file_path : String = "/proc/cpuinfo"
			
			var cpuinfo_file : File = File.new()
			
			if cpuinfo_file.file_exists(cpuinfo_file_path):
				
				var number_of_empty_lines : int = 0
				
				cpuinfo_file.open(cpuinfo_file_path,1)
				
				while true:
					
					var line : String = cpuinfo_file.get_line()
					
					if line.begins_with("model name"):
						line = line.right(10) #cut off beginning
						line = line.strip_edges(true,true) # remove nonprintable characters
						line = line.right(1) # cut off ":" 
						line = line.strip_edges(true,true) # remove nonprintable characters
						model_name = line
						
						var GHz_string : String = model_name.right(model_name.rfind(" ", -1) + 1) # remove beginning from model name to get the GHz
						GHz_string = GHz_string.left(GHz_string.rfind("GHz", -1))
						GHz = float (GHz_string)
						
						
						
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
						var physical_id : int = int(line)	
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
			var output : Array = []
			var arguments : Array = ['/C','wmic cpu get Name /Value']
			
			OS.execute('CMD.exe', arguments, true, output)
			
			model_name = output[0].strip_edges(true,true)  # strip away empty stuff
			model_name = model_name.split("=")[1]  # Take the string behind the "="
			
			var GHz_string : String = model_name.right(model_name.rfind(" ", -1) + 1) # remove beginning from model name to get the GHz
			GHz_string = GHz_string.left(GHz_string.rfind("GHz", -1))
			GHz = float (GHz_string)
			
			
			# get number of sockets
			output = []
			arguments = ['/C','wmic COMPUTERSYSTEM get NumberOfProcessors /Value']
			
			OS.execute('CMD.exe', arguments, true, output)
			
			var sockets_string : String = output[0].strip_edges(true,true)  # strip away empty stuff
			sockets_string = sockets_string.split("=")[1]  # Take the string behind the "="
			sockets = int(sockets_string)
			
			
			# get number of cores
			output = []
			arguments = ['/C','wmic cpu get NumberOfCores /Value']
			
			OS.execute('CMD.exe', arguments, true, output)
			
			var cores_string : String = output[0].strip_edges(true,true)  # strip away empty stuff
			cores_string = cores_string.split("=")[1]  # Take the string behind the "="
			cores = int(cores)
			
			
			# get number of threads
			output = []
			arguments = ['/C','wmic cpu get NumberOfLogicalProcessors /Value']
			
			OS.execute('CMD.exe', arguments, true, output)
			
			var threads_string : String = output[0].strip_edges(true,true)  # strip away empty stuff
			threads_string = threads_string.split("=")[1]  # Take the string behind the "="
			threads = int(threads_string)
			
			# build the array
			cpu.append(model_name)
			cpu.append(GHz)
			cpu.append(sockets)
			cpu.append(cores)
			cpu.append(threads)
			
			return cpu
		
	return cpu




func get_cpu_usage() -> float:
	
	var cpu_usage_as_float = 0.0
	
	match platform:
		
		# Linux
		"X11" :
			
			# read the file /proc/stat 
			# the first line is the time accumulation of all the cores. It looks something like: 
			# "cpu  337190 187 61395 3331872 1319 0 4453 0 0 0"
			#         ^          ^      ^
			#        user      system  idle
			#
			# read the file twice with a time offset. Substract the first values from the second ones. 
			# usage = time spent by user and system devided by total time spent ( user + system + idle)
			
			var cpu_usage_file_path : String = "/proc/stat"
			
			var cpu_usage_file : File = File.new()
			
			if cpu_usage_file.file_exists(cpu_usage_file_path):
				
				var number_of_empty_lines : int = 0
				
				cpu_usage_file.open(cpu_usage_file_path,1)
				
				var line : String = cpu_usage_file.get_line() # get the first line
				
				line = line.strip_edges(true, true) # remove nonprintable characters
				var current_cpu_stat_values : Array = line.split(" ", false, 0) # convert the line to an array
				
				if (recent_cpu_stat_values.size() > 0):
					var time_spent_user_plus_system : int = int(current_cpu_stat_values[1]) - int(recent_cpu_stat_values[1]) + int(current_cpu_stat_values[3]) - int(recent_cpu_stat_values[3])
					var time_spent_user_plus_system_plus_idle : int = int(current_cpu_stat_values[1]) - int(recent_cpu_stat_values[1]) + int(current_cpu_stat_values[3]) - int(recent_cpu_stat_values[3]) + int(current_cpu_stat_values[4]) - int(recent_cpu_stat_values[4])
					cpu_usage_as_float = time_spent_user_plus_system * 100 / time_spent_user_plus_system_plus_idle
					
				recent_cpu_stat_values = current_cpu_stat_values
			
			return cpu_usage_as_float
			
			
		# Windows
		"Windows" :
			
			# the command "wmic cpu get loadpercentage /Value" takes one second to return a value. So we can't use this with a blocking OS.execute, as it would constantly block the whole RaptorRender application.
			# As a solution we should execute it in a none blocking way and save the result to a file, which can be read afterwards without the need to wait 1 sec.
			# unfortunately saving a file via cmd (e.g: echo hello>test.txt) only works when blocking is enabled in OS.execute
			# The work around now is: 
			# 1. generate a ".bat" file with "wmic cpu get loadpercentage /Value>win_cpu_load.text"
			# 2. execute this ".bat" file everytime this function is called. It will generate the "win_cpu_load.txt" file that contains the value
			# 3. read this file with OS.execute 
			
			
			
			# read the win_cpu_load.txt file
			
			var win_cpu_usage_file_path : String = user_data_dir + "/win_cpu_usage.txt"
			win_cpu_usage_file_path = win_cpu_usage_file_path.replace("/","\\")
			
			var win_cpu_usage_file : File = File.new()
			
			if win_cpu_usage_file.file_exists(win_cpu_usage_file_path):
				
				var output : Array = []
				var arguments : Array = ['/C', 'type ' + win_cpu_usage_file_path]
				
				OS.execute('CMD.exe', arguments, true, output)
				var cpu_usage_str : String = output[0].strip_edges(true,true)  # strip away empty stuff
				
				if cpu_usage_str.find("=") >= 0:
					cpu_usage_str = cpu_usage_str.split("=")[1]  # Take the string behind the "="
					cpu_usage_as_float = float(cpu_usage_str)
			
			
			# execute the ".bat" file to save current cpu load which will be read next time
			var bat_file_path : String = user_data_dir + "\\get_win_cpu_usage.bat"
			bat_file_path = bat_file_path.replace("/","\\")
			
			var output : Array = []
			var arguments : Array = ['/C', bat_file_path]
			
			OS.execute("CMD.exe", arguments, false, output)
			
			
			return cpu_usage_as_float

	return cpu_usage_as_float


# returns the name of the computer
func get_hostname() -> String:
	
	var hostname = ""
	
	match platform:
		
		# Linux
		"X11" : 
			
			var hostname_output : Array = []
			var arguments : Array = []
			OS.execute("hostname", arguments, true, hostname_output)
			
			hostname = hostname_output[0].strip_edges(true,true)
			
			return hostname
		
		
		# Windows
		"Windows" :
		
			var hostname_output : Array = []
			var arguments : Array= []
			OS.execute("hostname", arguments, true, hostname_output)
			
			hostname = hostname_output[0].strip_edges(true,true)
			
			return hostname
	
	return hostname


# returns the current logged in username
func get_username() -> String:
	
	var username = ""
	
	var platform : String = OS.get_name()
	
	match platform:
		
		# Linux
		"X11" : 
			
			var username_output : Array = []
			var arguments : Array = []
			
			OS.execute('whoami', arguments, true, username_output)
			
			username = username_output[0].strip_edges(true,true)
			
			return username
		
		
		# Windows
		"Windows" :
		
			var username_output : Array = []
			var arguments : Array = ['/C','echo %username%']
			
			OS.execute('CMD.exe', arguments, true, username_output)
			
			username = username_output[0].strip_edges(true,true)
			
			return username
	
	return username	



# returns the name of the platform
func get_platform_info() -> Array:
	
	var platform_info_array = []
	
	match platform:
		
		# Linux
		"X11" :
			# Platform Name
			platform_info_array.append("Linux")
			
			# Kernel Version
			var output : Array = []
			var arguments : Array = ["-r"]
			
			OS.execute("uname", arguments, true, output)
			
			var position_to_split : Array = output[0].find_last("-")
			
			var kernel_version : String = output[0].left(position_to_split) # take the left part of the string
			
			platform_info_array.append(kernel_version) 
			
			
			return platform_info_array
		
		
		# Windows
		"Windows" :
			# Platform name
			platform_info_array.append("Windows")
			
			# Windows Version
			var output : Array = []
			var arguments : Array = ['/C','wmic os get Caption /Value']
			
			OS.execute('CMD.exe', arguments, true, output)
			
			var version_str : String = output[0].strip_edges(true,true)  # strip away empty stuff
			version_str = version_str.split("=")[1]  # Take the string behind the "="
			version_str = version_str.replace("Microsoft","").replace("Windows","").strip_edges(true,true)
			var version_str_splitted : Array = version_str.split(" ")
			
			platform_info_array.append(version_str_splitted[0])
			if version_str_splitted.size() > 1:
				platform_info_array.append(version_str_splitted[1])
			
			return platform_info_array
			
			
		# Mac OS
		"OSX" :
			platform_info_array.append("OSX")
			
			return platform_info_array

	return platform_info_array
	
	
	

# return the names of the graphics devices
func get_graphic_cards() -> Array:
	
	var graphic_cards_array = []
	
	match platform:
		
		# Linux
		"X11" :
			
			# run "lspci | grep -E 'VGA|3D'" to get a list of all graphics devices
			var output : Array = []
			var arguments : Array = ["-c","lspci | grep -E 'VGA|3D'"] # filter the output of lspci by lines containing "VGA" or "3D"
			OS.execute("bash", arguments, true, output)
			
			# split String in lines
			var splitted_output : Array = output[0].split('\n', false, 0)  
			
			for line in splitted_output:
				
				# remove stuff at the beginning of the line
				var position_to_split : int = line.find(": ")
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
			
			# get number of threads
			var output : Array = []
			var arguments : Array = ['/C','wmic path win32_VideoController get name /Value']
			
			OS.execute('CMD.exe', arguments, true, output)
			
			var graphics : String = output[0].strip_edges(true,true)  # strip away empty stuff
			graphics = graphics.split("=")[1]  # Take the string behind the "="
			
			graphic_cards_array.append(graphics)
			
			return graphic_cards_array
			
	return graphic_cards_array



# Get Hard Drive Information
func get_hard_drive_info():
	
	# a array with an universal dictionary for each drive. The dict will hold the following keys: 
	# name, label, size, percentage_used, type (1 Local Disk, 2 Removable Disk, 3 Network Drive)
	var drive_dict_array : Array = [] 
		
	match platform:
		
		# Linux
		"X11" :
		
			# use "lsblk" and "df" in terminal to get some hard drive infos
			
			var linux_drive_array : Array = [] # a array with a dictionary for each drive. The dict will hold the following keys: name, mountpoint, label, size, rm, used
			
			var output : Array = [] #                     show these columns   |  format as json  | filter only mounted ones | remove line with "boot" |  remove snap mounted drives
									#                                v                      v          v             .------------------'     .------------------'
			var arguments : Array = ["-c","lsblk --output 'NAME,MOUNTPOINT,LABEL,SIZE,RM' --json | grep '/' | grep -v 'boot' | grep -v 'snapd\/snap'"]
			OS.execute("bash", arguments, true, output)
			
			# each line is one mounted hard drive. Now clean the string and convert that json output to a dict
			
			# split String in lines
			var splitted_output : Array = output[0].split('\n', false, 0)  
			
			for line in splitted_output:
				line = line.strip_edges(true,true)
				
				# remove "," at the end
				if line.right(line.length() - 1) == ",":
					line = line.left(line.length() - 1)
					
				# Convert String to Dictionaries and add them to the array
				linux_drive_array.append(parse_json(line))
			
			
			# now get the percentage of used disk space. As "lsblk" does not show this we have to use "df" and filter it by the names received in the step before
			for drive in linux_drive_array:
				
				# use the "df" command to find the percentage
				arguments = ["-c","df | grep '" + drive.name + "'"]
				OS.execute("bash", arguments, true, output)
				
				var used : String = output[0].left (output[0].find("%") ) # take the left part of the string befor "%"
				used = used.right ( used.length() - 3 ) # take the last three characters
				used =  used.strip_edges(true,true) # remove white spaces
				
				drive.percentage_used = int(used)
			
			
			# fill the "drive_dict_array"
			for drive in linux_drive_array:
				
				# format size string #
				
				var size_str : String = drive.size.insert( drive.size.length() - 1 , " ") # add space
				
				# remove decimals if size is GBs
				if size_str.ends_with("G"):
					if size_str.find(",") > 0:
						size_str.erase( size_str.find(",") , 2)
					if size_str.find(".") > 0:
						size_str.erase( size_str.find(".") , 2)
				
				size_str = size_str.insert(size_str.length(), "B") # add a B at the end
				
				
				# handling null in drive label
				var label_str : String
				if drive.label == null:
					label_str = ""
				else:
					label_str = drive.label
				
				
				# set correct type
				var type : int
				if drive.rm == false:
					type = 1 # local disk
				else: 
					type = 2 # removable disk
					
					
				# create the final dict
				drive_dict_array.append( { 
					"name": drive.name, 
					"label": label_str, 
					"size": size_str, 
					"percentage_used": drive.percentage_used, 
					"type": type } )
			
			
			return drive_dict_array
		
		
		
		# Windows
		"Windows" :
		
			# get drive info output
			var output : Array = []
			var arguments : Array = ['/C','wmic logicaldisk get DriveType,FreeSpace,Name,Size,VolumeName']
			
			OS.execute('CMD.exe', arguments, true, output)
			
			
			# split String in lines
			var splitted_output : Array = output[0].split('\n', false, 0)  # split and don't allow empty
			
			# start from second row (because first one are the labels
			for line in range (1, splitted_output.size() - 1):
				
				# split each row into it's values and remove the empty spaces
				var line_values : Array = splitted_output[line].split(' ', false, 0)  
			
			
				# set correct type
				# (windows drivetypes: 0 Unknown, 1 No Root Directory, 2 Removable Disk, 3 Local Disk,4 Network Drive, 5 Compact Disc, 6 RAM Disk)
				var type : int
				if line_values[0] == "3":
					type = 1 # local disk
				elif line_values[0] == "2":
					type = 2 # removable disk
				elif line_values[0] == "4":
					type = 3 # network dive
				
				
				# create size string
				var size : int = int(line_values[3])
				var size_str : String = ""
				
				if size > 1099511627776: # 1 TB
					size_str = String(float(size) / 1024 / 1024 / 1024 / 1024) + " TB"
					
					# if there is a "." then show only one decimal
					if size_str.find(".") > 0:
						size_str = size_str.left( size_str.find(".") + 1 ) + size_str.right ( size_str.find(" ") - 1)
					
				elif size > 1073741824: # 1 GB
					size_str = String(size / 1024 / 1024 / 1024 ) + " GB"
					
				elif size > 1048576: # 1 MB
					size_str = String(size / 1024 / 1024 ) + " MB"
					
				else:
					size_str = "wtf! That's small!"
				
				
				
				# calculate percentage used
				var percentage_used : float = float ( int(line_values[3]) - int(line_values[1]) )    / float (line_values[3]) * 100
				
				
				# create the drive_dict_array
				
				drive_dict_array.append( { 
					"name": line_values[2], 
					"label": line_values[4], 
					"size": size_str, 
					"percentage_used": percentage_used, 
					"type": type } )
			
			
			
			return drive_dict_array





##############################################################
### Timer Function to get cpu and memory usage every x seconds
##############################################################

func _on_hardware_info_timer_timeout():
	
	# collect the current hardware info in a separate thread. Whithout threading we would have a lag in the UI under Windows each time the function were called.
	start_collect_hardware_info_thread()
	
	
func start_collect_hardware_info_thread():
	if collect_hardware_info_thread.is_active():
		# stop here if already working
		return
		
	# start the thread	
	collect_hardware_info_thread.start(self, "collect_current_hardware_info","")
	
	
	
func collect_current_hardware_info(args):
	
	# set memory usage
	var mem_available : int = get_available_memory()
	var mem_usage_as_float : float = ( float(total_memory) - float(mem_available) )  / float(total_memory) * 100
	
	memory_usage = int(mem_usage_as_float)
	
	
	# set cpu usage
	cpu_usage = int (get_cpu_usage() )
	
	
	# hard drive info
	hard_drives = get_hard_drive_info()
	
	
	# change the values
	for client in RRNetworkManager.management_gui_clients:
		RRNetworkManager.rpc_id(client, "update_client_hw_stats", own_client_id, cpu_usage, memory_usage, hard_drives)
	
	# call_deferred has to call another function in order to join the thread with the main thread. Otherwise it will just stay active.
	call_deferred("join_collect_hardware_info_thread")
	
	
	
func join_collect_hardware_info_thread():
	
	# this will effectively stop the thread
	collect_hardware_info_thread.wait_to_finish()
	
