#///////////////#
# RRColorScheme #
#///////////////#

# This script holds all important interface colors.
# As most other scripts get their colors from here, this is the place where you want to change colors.


extends Node

### PRELOAD RESOURCES

### SIGNALS

### ONREADY VARIABLES

### EXPORTED VARIABLES

### VARIABLES

# Background colors for interface elements (eg. shades of grey)
var bg_0 : Color = Color("262626") #  | dark
var bg_1 : Color = Color("313131") #  |
var bg_2 : Color = Color("4d4d4d") #  V brighter

# select color
var selected : Color = Color("956248") # orange

# transparent background for popups to darken the rest
var popup_black_transparent : Color = Color("cc000000")

# SortableTable colors
var ST_row_default : Color = Color("3c3c3c")
var ST_row_error : Color =  Color("643f3b")
var ST_row_error_selected : Color = Color ("C35A58") # red

# state colors
var state_finished_or_online : Color = Color("77B223")
var state_active : Color = Color ("009EBA")
var state_queued : Color = Color ("FAD25C")
var state_error : Color = Color ("E44642")
var state_paused : Color = Color ("8D8D8D")
var state_paused_deferred : Color = Color ("5DACBA")
var state_offline_or_cancelled : Color = Color ("181818")

# Chunk Time Graph
var chunk_time_graph_shortest : Color = Color("77B223")
var chunk_time_graph_longest : Color = Color ("E44642")
var chunk_time_graph_not_started : Color = Color ("8D8D8D")


# log colors
var log_software_start_success :  String = "009EBA"
var log_success :  String = "77B223"
var log_warning : String = "FAD25C"
var log_error : String = "DF8731"
var log_critical_error : String = "E44642"
var log_critical_error_ignored : String = "D157F9"




########## FUNCTIONS ##########
