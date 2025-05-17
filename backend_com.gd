extends Node

@onready var http_request: HTTPRequest = %HTTPRequest

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	http_request.request_completed.connect(_on_http_req_completed)
	get_backend_status()
	#TODO: verkar som http request bara kan köras 1 gång eller varför körs inte nedan om ovan inte kommenteras bort ?
	get_running_procs()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func get_backend_status() -> void:
	var endpoint = "http://localhost:8000/v1/public/"
	http_request.request(endpoint)

func get_running_procs() -> void:
	var endpoint = "http://localhost:8000/v1/public/processes"
	http_request.request(endpoint)

func _on_http_req_completed(result, response_code, headers, body) -> void:
	var json = JSON.parse_string(body.get_string_from_utf8())
	#print(json["name"])
	print(json)
	
