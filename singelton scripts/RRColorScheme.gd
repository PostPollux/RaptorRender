extends Node

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
var log_success :  String = "77B223"
var log_warning : String = "FAD25C"
var log_error : String = "DF8731"
var log_critical_error : String = "E44642"
var log_critical_error_ignored : String = "D157F9"