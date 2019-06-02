extends Node

# the numbers in front of each string are important for sorting based on state

# job states
var job_rendering : String = "1_rendering"
var job_rendering_paused_deferred : String = "2_rendering_paused_deferred"
var job_queued : String = "2_queued"
var job_error : String = "3_error"
var job_paused : String = "4_paused"
var job_finished : String = "5_finished"
var job_cancelled : String = "6_cancelled"

# chunk states
var chunk_rendering : String = "1_rendering"
var chunk_queued : String = "2_queued"
var chunk_error : String = "3_error"
var chunk_paused : String = "4_paused"
var chunk_finished: String = "5_finished"
var chunk_cancelled: String = "6_cancelled"


# client states
var client_rendering : String = "1_rendering"
var client_rendering_paused_deferred : String = "2_rendering_paused_deferred"
var client_available : String = "2_available"
var client_error : String = "3_error"
var client_disabled : String = "4_disabled"
var client_offline : String = "5_offline"





