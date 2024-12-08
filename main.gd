extends Node

signal timer_updated(time_left: float)

@export var main_time:float = 10
@onready var main_timer:Timer = get_node("MainTimer")  # Referens till din TimerNode

func _ready():
	set_main_timer(main_time)
	main_timer.start()  # Starta timern
	main_timer.connect("timeout", Callable(self, "_on_timeout"))  # Koppla timeout-signalen

func _process(delta: float):
	emit_signal("timer_updated", main_timer.time_left)  # Skicka kontinuerligt tid kvar som signal

func _on_timeout():
	#print("Timer is done!")  # Exempel: Vad som händer när tiden är slut
	pass

func set_main_timer(time: float):
	main_timer.wait_time = time
