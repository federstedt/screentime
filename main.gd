extends Node

# ref for timers: https://gamedevbeginner.com/how-to-make-a-timer-in-godot-count-up-down-in-minutes-seconds/
signal timer_updated(time_left: float)
signal time_elapsed_updated(time: float)
#Exports
#@export var main_time:float = 10

#Onready
@onready var main_timer:Timer = get_node("MainTimer")  # Referens till din TimerNode
@onready var reset_button:Button = get_node("BaseGUI/MainPage/MainContainer/ButtonContainer/ResetButton")
@onready var pause_button:Button = get_node("BaseGUI/MainPage/MainContainer/ButtonContainer/PauseButton")
@onready var time_elapsed := 0.0
@onready var base_gui_node: Control = get_node("BaseGUI")

# load settings
@onready var file_handler:Node = get_node("FileParser")
@onready var main_time = file_handler.get_setting_main_time()
@onready var snooze_time = file_handler.get_setting_snooze_time()

func _ready():
	set_main_timer(main_time)
	main_timer.start()  # Starta timern
	main_timer.connect("timeout", Callable(self, "_on_timeout"))  # Koppla timeout-signalen
	# Connect buttons
	reset_button.connect("pressed", Callable(self, "_on_reset_pressed"))
	pause_button.connect("pressed", Callable(self, "_on_pause_pressed"))
	# connect other signals
	base_gui_node.connect("setting_main_timer_updated", Callable(self, "_on_setting_main_timer_updated"))
	

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
	reset_main_timer()

func reset_main_timer() -> void:
	main_timer.stop()
	main_timer.start()

func _on_pause_pressed() -> void:
	if main_timer.paused == true:
		main_timer.paused = false
	else:
		main_timer.paused = true

func _on_setting_main_timer_updated(new_main_time: float) -> void:
	print("new time: " + str(new_main_time))
	# save new time to file
	file_handler.set_settings_main_time(new_main_time)
	# set timer to new value
	set_main_timer(new_main_time)
	reset_main_timer()
	
