extends Node
# Handles communication with backend API running on localhost.
@onready var api_status: String = ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	#http_request.request_completed.connect(_on_http_req_completed)
	# get_backend_status()
	#get_running_procs()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# func check_for_game(proc_list: Array) -> void:
# 	#{ "pid": 69025.0, "name": "Godot_v4.4.1-stable_linux.x86_64", "username": "federov" }
# 	for proc in proc_list:
# 		if proc["username"] != "root":
# 			#print(proc["name"])
# 			if "steam" in proc["name"]:
# 				print(proc)
# 				#print(type_string(typeof(proc)))
# 				GlobalSignal.running_game.emit(proc)


func get_backend_status() -> void:
	 # Create an HTTP request node and connect its completion signal.
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.name = "backend_status_call"
	http_request.request_completed.connect(self._backend_status_check_completed)
	var endpoint = "http://localhost:8000/v1/public/"
	# Perform a GET request. The URL below returns JSON as of writing.
	print("getting:", endpoint)
	var error = http_request.request(endpoint)
	if error != OK:
		push_error("An error occurred in the HTTP request.")

func get_running_procs() -> void:
	 # Create an HTTP request node and connect its completion signal.
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.name = "running_procs_call"
	http_request.request_completed.connect(self._running_procs_call_completed)
	var endpoint = "http://localhost:8000/v1/public/procs/"
	print("getting:", endpoint)

	var error = http_request.request(endpoint)
	if error != OK:
		push_error("An error occurred in the HTTP request.")

func get_running_games() -> void:
	# create a HTTP request node and connect is completions signal.
	var http_req = HTTPRequest.new()
	add_child(http_req)
	http_req.name = "running_games_call"
	http_req.request_completed.connect(self._running_games_call_completed)
	var endpoint  = "http://localhost:8000/v1/public/procs/games/"
	var error = http_req.request(endpoint)
	if error != OK:
		push_error("An error occured in the HTTP request for running games")

func _backend_status_check_completed(result, response_code, headers, body) -> void:
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	var resp = json.get_data()
	#print(json["name"])
	GlobalSignal.api_status_update.emit(resp)
	# remove req_node when finished
	var http_req = get_node("backend_status_call")
	http_req.queue_free()
	
	

func _running_procs_call_completed(result, response_code, headers, body) -> void:
	# Get all running process. This is for future use
	var json = JSON.parse_string(body.get_string_from_utf8())
	#print(json["name"])
	#print(json)
	if json != null:
		#check_for_game(json)
		pass
	# remove req_node when finished
	var http_req = get_node("running_procs_call")
	http_req.queue_free()
	
func _running_games_call_completed(result, response_code, headers, body) -> void:
	# parse the data from API call
	var json = JSON.parse_string(body.get_string_from_utf8())
	if json != null:
		self._push_running_games(json)
	# remove the request node when finished
	var http_req = get_node("running_games_call")
	http_req.queue_free()

func _push_running_games(proc_dict: Dictionary) -> void:
	# push running games via signal
	print("Running games:")
	print(proc_dict)
	# if proc_dict is empty no games are running
	if proc_dict.size() < 1:
		var placehold_dict := {"name": "None"}
		GlobalSignal.running_game.emit(placehold_dict)
	for proc in proc_dict:
		print(proc)
		print(typeof(proc))
		# emit signal. pass dict where proc name is key of dict in dict
		GlobalSignal.running_game.emit(proc_dict[proc])
	
