extends Control

# Connect vars to elemets
@onready var pause_button: Button = get_node("MainPage/MainContainer/ButtonContainer/PauseButton")
@onready var timers_button: Button = get_node("SideMenu/MainMenu/TimersButton")
@onready var settings_button: Button = get_node("SideMenu/MainMenu/SettingsButton")
@onready var main_page: Control = get_node("MainPage")
@onready var Settings_page: Control = get_node("SettingsPage")
@onready var menu_button:Button = get_node("SideMenu/MenuButton")
@onready var mainmenu_container:VBoxContainer = get_node("SideMenu/MainMenu")

func _ready():
	var main_node = get_parent()  # Main är föräldern till GUI
	# connect signals
	main_node.connect("timer_updated", Callable(self, "_on_timer_updated"))  # Koppla signalen för timern
	main_node.connect("time_elapsed_updated", Callable(self, "_on_elapsed_updated"))
	pause_button.connect("pressed", Callable(self, "_on_pause_pressed"))
	settings_button.connect("pressed", Callable(self, "_on_settings_pressed"))
	timers_button.connect("pressed", Callable(self, "_on_timers_pressed"))
	menu_button.connect("pressed", Callable(self, "_on_mainmenu_pressed"))

func _on_timer_updated(time_left: float):
	var label: RichTextLabel = get_node("MainPage/MainContainer/TimeLeftText")
	var text = str(round(time_left)) + " seconds left"  # Uppdatera label
	label.text = "[center]" + text + "[/center]"

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
