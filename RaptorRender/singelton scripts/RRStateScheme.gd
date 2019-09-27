#///////////////#
# RRStateScheme #
#///////////////#

# This script holds all the various states a job, chunk, try or client can have.
# the numbers in front of each string are important for sorting based on state.


extends Node


### PRELOAD RESOURCES

### SIGNALS

### ONREADY VARIABLES

### EXPORTED VARIABLES

### VARIABLES

# job states
var job_rendering : String = "1_rendering"
var job_rendering_paused_deferred : String = "2_rendering_paused_deferred"
var job_queued : String = "3_queued"
var job_error : String = "4_error"
var job_paused : String = "5_paused"
var job_finished : String = "6_finished"
var job_cancelled : String = "7_cancelled"

# chunk states
var chunk_rendering : String = "1_rendering"
var chunk_queued : String = "2_queued"
var chunk_error : String = "3_error"
var chunk_paused : String = "4_paused"
var chunk_finished: String = "5_finished"
var chunk_cancelled: String = "6_cancelled"

# try states
var try_rendering : String = "1_rendering"
var try_error : String = "2_error"
var try_finished: String = "3_finished"
var try_cancelled: String = "4_cancelled"
var try_marked_as_finished: String = "5_marked_as_finished"

# client states
var client_rendering : String = "1_rendering"
var client_available : String = "2_available"
var client_error : String = "3_error"
var client_disabled : String = "4_disabled"
var client_offline : String = "5_offline"




########## FUNCTIONS ##########