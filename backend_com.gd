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

func check_for_game(proc_list: Array) -> void:
	#{ "pid": 69025.0, "name": "Godot_v4.4.1-stable_linux.x86_64", "username": "federov" }
	for proc in proc_list:
		if proc["username"] != "root":
			#print(proc["name"])
			if "Godot" in proc["name"]:
				print(proc)
				#print(type_string(typeof(proc)))
				GlobalSignal.running_game.emit(proc)

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
	var json = JSON.parse_string(body.get_string_from_utf8())
	#print(json["name"])
	#print(json)
	if json != null:
		check_for_game(json)
	# remove req_node when finished
	var http_req = get_node("running_procs_call")
	http_req.queue_free()
	
	
