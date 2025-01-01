extends Node

# ref for timers: https://gamedevbeginner.com/how-to-make-a-timer-in-godot-count-up-down-in-minutes-seconds/
signal timer_updated(time_left: float)
signal time_elapsed_updated(time: float)
#Exports
@export var main_time:float = 10

#Onready
@onready var main_timer:Timer = get_node("MainTimer")  # Referens till din TimerNode
@onready var reset_button:Button = get_node("BaseGUI/MainPage/MainContainer/ButtonContainer/ResetButton")
@onready var pause_button:Button = get_node("BaseGUI/MainPage/MainContainer/ButtonContainer/PauseButton")
@onready var time_elapsed := 0.0

func _ready():
	set_main_timer(main_time)
	main_timer.start()  # Starta timern
	main_timer.connect("timeout", Callable(self, "_on_timeout"))  # Koppla timeout-signalen
	# Connect buttons
	reset_button.connect("pressed", Callable(self, "_on_reset_pressed"))
	pause_button.connect("pressed", Callable(self, "_on_pause_pressed"))

func _process(delta: float):
	time_elapsed += delta
	emit_signal("time_elapsed_updated", time_elapsed)
	emit_signal("timer_updated", main_timer.time_left)  # Skicka kontinuerligt tid kvar som signal

func _on_timeout():
	#print("Timer is done!")  # Exempel: Vad som händer när tiden är slut
	print("Timer ran out!")

func set_main_timer(time: float):
	main_timer.wait_time = time
	

func _on_reset_pressed() -> void:
	print('reset pressed')
	main_timer.stop()
	main_timer.start()

func _on_pause_pressed() -> void:
	print('pause pressed')
	if main_timer.paused == true:
		main_timer.paused = false
	else:
		main_timer.paused = true
