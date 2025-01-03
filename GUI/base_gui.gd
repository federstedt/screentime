extends Control

# custom signals
signal setting_main_timer_updated(new_main_time: float)

# Connect vars to elemets
@onready var pause_button: Button = get_node("MainPage/MainContainer/ButtonContainer/PauseButton")
@onready var timers_button: Button = get_node("SideMenu/MainMenu/TimersButton")
@onready var settings_button: Button = get_node("SideMenu/MainMenu/SettingsButton")
@onready var main_page: Control = get_node("MainPage")
@onready var Settings_page: Control = get_node("SettingsPage")
@onready var menu_button:Button = get_node("SideMenu/MenuButton")
@onready var mainmenu_container:VBoxContainer = get_node("SideMenu/MainMenu")
@onready var save_settings_button: Button = get_node("SettingsPage/SaveSettingsButton")

@onready var timeleft_label: RichTextLabel = get_node("MainPage/MainContainer/TimeLeftText")

func _ready():
	var main_node = get_parent()  # Main är föräldern till GUI
	# connect signals
	main_node.connect("timer_updated", Callable(self, "_on_timer_updated"))  # Koppla signalen för timern
	main_node.connect("time_elapsed_updated", Callable(self, "_on_elapsed_updated"))
	main_node.connect("time_out", Callable(self,"_on_time_out"))
	
	pause_button.connect("pressed", Callable(self, "_on_pause_pressed"))
	settings_button.connect("pressed", Callable(self, "_on_settings_pressed"))
	timers_button.connect("pressed", Callable(self, "_on_timers_pressed"))
	menu_button.connect("pressed", Callable(self, "_on_mainmenu_pressed"))
	save_settings_button.connect("pressed", Callable(self, "_on_settings_submit"))

func _on_time_out() -> void:
	print('Time is out!')
	var text = "Time is out!"
	timeleft_label.text = "[center]" + text + "[/center]"

func _on_timer_updated(time_left: float) -> void:
	if time_left > 0:
		var text = str(round(time_left)) + " seconds left"  # Uppdatera label
		timeleft_label.text = "[center]" + text + "[/center]"

func _on_elapsed_updated(time:float):
	var label: RichTextLabel = get_node("MainPage/MainContainer/TimeElapsedText")
	var text = "Elapsed: " + str(round(time))
	label.text = "[center]" + text + "[/center]"
	
func _on_pause_pressed() -> void:
	if pause_button.text == 'Pause':
		pause_button.text = 'Unpause'
	else:
		pause_button.text = 'Pause'

func _on_mainmenu_pressed() -> void:
	if mainmenu_container.visible == true:
		mainmenu_container.visible = false
	else:
		mainmenu_container.visible = true

func _on_settings_pressed() -> void:
	main_page.visible = false
	Settings_page.visible = true
	
func _on_timers_pressed() -> void:
	Settings_page.visible = false
	main_page.visible = true

func _on_settings_submit() -> void:
	# Submit new settings
	# get content of Fields
	var time_limit_entry: LineEdit = get_node("SettingsPage/TimeLimitEntry")
	var new_main_time = float(time_limit_entry.text)
	#TODO: add verification of content type, now i just convert blindly
	if typeof(new_main_time) == TYPE_FLOAT:
		emit_signal("setting_main_timer_updated", new_main_time)
	else:
		print('new_main_time entry is not an int or float')
