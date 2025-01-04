extends Node

# ref for timers: https://gamedevbeginner.com/how-to-make-a-timer-in-godot-count-up-down-in-minutes-seconds/
signal timer_updated(time_left: float)
signal time_elapsed_updated(time: float)
signal time_out()
#Exports
#@export var main_time:float = 10

#Onready locals
@onready var main_timer:Timer = get_node("MainTimer")  # Referens till din TimerNode
@onready var time_elapsed := 0.0
@onready var audiostream_player: AudioStreamPlayer = get_node("AudioStreamPlayer")
@onready var times_snoozed:int = 0
@onready var admin_locked: bool = true

# BaseGUI
@onready var base_gui_node: Control = get_node("BaseGUI")
@onready var reset_button:Button = get_node("BaseGUI/MainPage/MainContainer/ButtonContainer/ResetButton")
@onready var pause_button:Button = get_node("BaseGUI/MainPage/MainContainer/ButtonContainer/PauseButton")
@onready var lock_button: Button = get_node("BaseGUI/LockButton")


#window
@onready var popup_window: Window = $PopUpWindow
@onready var popup_snooze_button: Button = get_node("PopUpWindow/PopUpGui/SnoozeButton")
@onready var popup_limit_text: RichTextLabel = get_node("PopUpWindow/PopUpGui/SnoozeLimitText")

# load settings
@onready var file_handler:Node = get_node("FileParser")
@onready var main_time = file_handler.get_setting_main_time()
@onready var snooze_time = file_handler.get_setting_snooze_time()
@onready var snooze_limit = file_handler.get_setting_snooze_limit()
@onready var admin_passwd = file_handler.get_setting_admin_passwd()


func _ready():
	set_main_timer(main_time)
	main_timer.start()  # Starta timern
	main_timer.connect("timeout", Callable(self, "_on_timeout"))  # Koppla timeout-signalen

	# Connect buttons signals
	reset_button.connect("pressed", Callable(self, "_on_reset_pressed"))
	pause_button.connect("pressed", Callable(self, "_on_pause_pressed"))
	popup_snooze_button.connect("pressed", Callable(self, "_on_popup_snooze_pressed"))
	
	# connect other signals from GUI node
	base_gui_node.connect("setting_main_timer_updated", Callable(self, "_on_setting_main_timer_updated"))
	base_gui_node.connect("setting_snooze_timer_updated", Callable(self, "_on_snooze_timer_updated"))
	base_gui_node.connect("setting_snooze_limit_updated", Callable(self, "_on_snooze_limit_updated"))
	base_gui_node.connect("admin_passwd_submitted", Callable(self, "_on_admin_login_submitted"))

func _process(delta: float):
	time_elapsed += delta
	emit_signal("time_elapsed_updated", time_elapsed)
	emit_signal("timer_updated", main_timer.time_left)  # Skicka kontinuerligt tid kvar som signal

func _on_popup_snooze_pressed() -> void:
	hide_popup_window()
	times_snoozed += 1
	if times_snoozed >= snooze_limit:
		# disable snooze button, show different text
		print('Snooze limit reached')
		popup_snooze_button.disabled = true
		popup_limit_text.visible = true
	snooze()

func _on_admin_login_submitted(passwd: String) -> void:
	if check_admin_login(passwd):
		print('Login success!')
		admin_locked = false
		base_gui_node.unlock_icon()
	else:
		print('Failed to login')

func check_admin_login(passwd: String) -> bool:
	if passwd == admin_passwd:
		return true
	else:
		return false

func snooze() -> void:
	set_main_timer(snooze_time)
	reset_main_timer()

func _on_timeout():
	audiostream_player.play()
	unhide_popup_window()

func unhide_popup_window():
	popup_window.visible = true

func hide_popup_window():
	popup_window.visible = false

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
	# save new time to file
	file_handler.set_settings_main_time(new_main_time)
	# set timer to new value
	set_main_timer(new_main_time)
	reset_main_timer()
	
func _on_snooze_timer_updated(new_snooze_time: float) -> void:
	print("new snooze time: " + str(new_snooze_time))
	file_handler.set_settings_snooze_timer(new_snooze_time)

func _on_snooze_limit_updated(new_snooze_limit: int) -> void:
	print("new snooze limit: " + str(new_snooze_limit))
	file_handler.set_settings_snooze_limit(new_snooze_limit)
