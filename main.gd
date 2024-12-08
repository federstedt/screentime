extends Node
# https://gamedevbeginner.com/how-to-make-a-timer-in-godot-count-up-down-in-minutes-seconds/#stopwatch

signal main_timer_updated(time_left: float)

@onready var main_timer:Timer = get_node('MainTimer')
@export var main_screentime:float = 60.0

@onready var time_elapsed := 0.0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	main_timer.start()
	main_timer.connect("main_timer_updated",_on_timer_tick) # För att få tid kvar kontinuerligt

func _on_timer_tick():
	emit_signal("main_timer_updated", main_timer.time_left)  # Skicka signal med tiden kvar

func set_main_screentime(float) -> void:
	main_screentime = float

func get_main_screentime() -> float:
	return main_timer.time_left

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time_elapsed += delta

func get_time_elapsed() -> float:
	return time_elapsed
