extends Control

# custom signals
signal setting_main_timer_updated(new_main_time: float)
signal setting_snooze_timer_updated(new_snooze_time: float)
signal setting_snooze_limit_updated(new_snooze_limit: int)
signal admin_passwd_submitted(passwd: String)

# Connect vars to elemets
# Buttons
@onready var pause_button: Button = get_node("MainPage/MainContainer/ButtonContainer/PauseButton")
@onready var settings_button: Button = get_node("SideMenu/MainMenu/SettingsButton")
@onready var exit_button:Button = $ExitButton
@onready var lock_button: Button = $LockButton
@onready var button_locked: bool = true

@onready var main_page: Control = get_node("MainPage")
@onready var menu_button:Button = get_node("SideMenu/MenuButton")
@onready var mainmenu_container:VBoxContainer = get_node("SideMenu/MainMenu")

# Settingspage
@onready var settings_page: Control = get_node("SettingsPage")
@onready var save_settings_button: Button = get_node("SettingsPage/VBoxContainer/SaveSettingsButton")
@onready var exit_settings_button: Button = get_node("SettingsPage/VBoxContainer/ExitSettingsButton")

@onready var timeleft_label: RichTextLabel = get_node("MainPage/MainContainer/TimeLeftText")

# admin page
@onready var admin_page: Control = get_node("AdminLoginPage")
@onready var admin_submit_button: Button = get_node("AdminLoginPage/AdminSubmit")

func _ready():
	var main_node = get_parent()  # Main är föräldern till GUI
	# connect signals
	main_node.connect("timer_updated", Callable(self, "_on_timer_updated"))  # Koppla signalen för timern
	main_node.connect("time_elapsed_updated", Callable(self, "_on_elapsed_updated"))
	main_node.connect("time_out", Callable(self,"_on_time_out"))
	
	#Connect buttons
	pause_button.connect("pressed", Callable(self, "_on_pause_pressed"))
	settings_button.connect("pressed", Callable(self, "_on_settings_pressed"))
	menu_button.connect("pressed", Callable(self, "_on_mainmenu_pressed"))
	exit_button.connect("pressed", Callable(self, "_on_exit_pressed"))
	
	# Connect settings page
	save_settings_button.connect("pressed", Callable(self, "_on_settings_submit"))
	exit_settings_button.connect("pressed", Callable(self, "_on_exit_settings_pressed"))

	# Connect admin page
	admin_submit_button.connect("pressed", Callable(self, "_on_admin_submit_pressed"))

func _on_exit_pressed() -> void:
	exit_app()

func exit_app() -> void:
	get_tree().quit()

func switch_lock_icon() -> void:
	button_locked = !button_locked
	if button_locked == false:
		lock_button.text = ""
	elif button_locked == true:
		lock_button.text  = ""

func _on_time_out() -> void:
	print('Time is out!')
	var text = "Time is out!"
	timeleft_label.text = "[center]" + text + "[/center]"

func _on_timer_updated(time_left: float) -> void:
	if time_left > 0:
		var minutes = int(time_left / 60)  # Hela minuter
		var seconds = int(time_left) % 60  # Resterande sekunder
		var text = "Time Left: %d min %d sec" % [minutes, seconds]  # Uppdatera Label
		#var text = str(round(time_left)) + " seconds left"  # Uppdatera label
		timeleft_label.text = "[center]" + text + "[/center]"

func _on_elapsed_updated(time:float):
	var label: RichTextLabel = get_node("MainPage/MainContainer/TimeElapsedText")
	var minutes = int(time / 60)  # Hela minuter
	var seconds = int(time) % 60  # Resterande sekunder
	var text = "Total: %d min %d sec" % [minutes, seconds]  # Uppdatera Label
	label.text = "[center]" + text + "[/center]"
	
func _on_pause_pressed() -> void:
	if pause_button.text == 'Pause':
		pause_button.text = 'Unpause'
	else:
		pause_button.text = 'Pause'

func toggle_main_menu() -> void:
	if mainmenu_container.visible == true:
		mainmenu_container.visible = false
	else:
		mainmenu_container.visible = true

func _on_mainmenu_pressed() -> void:
	toggle_main_menu()

func show_settings_page() -> void:
	main_page.visible = false
	admin_page.visible = false
	settings_page.visible = true

func show_main_page() -> void:
	settings_page.visible = false
	admin_page.visible = false
	main_page.visible = true

func show_admin_page() -> void:
	main_page.visible = false
	admin_page.visible = true

func _on_settings_pressed() -> void:
	show_settings_page()

func _on_exit_settings_pressed() -> void:
	show_main_page()
	toggle_main_menu()
	
func _on_settings_submit() -> void:
	# Submit new settings
	# get content of Fields
	var snooze_time_entry: LineEdit = get_node("SettingsPage/VBoxContainer/SnoozeTimeEntry")
	var snooze_limit_entry: LineEdit = get_node("SettingsPage/VBoxContainer/SnoozeLimitEntry")
	var time_limit_entry: LineEdit = get_node("SettingsPage/VBoxContainer/TimeLimitEntry")
	
	#TODO: add verification of content type, now i just convert blindly
	var new_main_time = float(time_limit_entry.text)
	var new_snooze_time = float(snooze_time_entry.text)
	var new_snooze_limit = int(snooze_limit_entry.text)
	if typeof(new_main_time) == TYPE_FLOAT:
		emit_signal("setting_main_timer_updated", new_main_time)
	if typeof(new_snooze_time) == TYPE_FLOAT:
		emit_signal("setting_snooze_timer_updated", new_snooze_time)
	if typeof(new_snooze_limit) == TYPE_INT:
		#print("attemting to signal: " + str(new_snooze_limit))
		emit_signal("setting_snooze_limit_updated", new_snooze_limit)
	
	show_main_page()
	toggle_main_menu()

func _on_admin_submit_pressed() -> void:
	var passwd_entry: LineEdit = get_node("AdminLoginPage/AdminPasswdLine")
	var passwd = passwd_entry.text
	# check password
	emit_signal("admin_passwd_submitted", passwd)
	show_main_page()
