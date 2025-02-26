extends Node

# https://docs.godotengine.org/en/stable/tutorials/io/saving_games.html

@onready var settings_file = "user://settings.json" #"res://settings.json"
@onready var settings_dict = {}
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("user:// points to:", ProjectSettings.globalize_path("user://"))
	ensure_settings_file_exists()
	settings_dict = load_settings()
	
func ensure_settings_file_exists():
	if not FileAccess.file_exists(settings_file):
		var default_settings = '{"settings": {"admin_passwd":"admin", "main_time":3300,"snooze_limit":3,"snooze_time":300} }'
		var file = FileAccess.open(settings_file, FileAccess.WRITE)
		if file:
			file.store_string(default_settings)
			file.close()
			print("Default settings written to:", settings_file)

func load_settings() -> Dictionary:
	var file_content = FileAccess.get_file_as_string(settings_file)
	return JSON.parse_string(file_content)

func get_setting_main_time() -> float:
	return settings_dict['settings']['main_time']

func set_settings_main_time(new_main_time: float) -> void:
	# uppdatera värdet för maintime till settings_dict och spara till fil.
	settings_dict['settings']['main_time'] = new_main_time
	store_settings_to_file()

func get_setting_snooze_time() -> int:
	return settings_dict['settings']['snooze_time']

func set_settings_snooze_timer(new_snooze_time: float) -> void:
	settings_dict['settings']['snooze_time'] = new_snooze_time
	store_settings_to_file()

func get_setting_snooze_limit() -> int:
	return settings_dict['settings']['snooze_limit']

func set_settings_snooze_limit(new_snooze_limit: int) -> void:
	settings_dict['settings']['snooze_limit'] = new_snooze_limit
	store_settings_to_file()

func get_setting_admin_passwd() -> String:
	return settings_dict['settings']['admin_passwd']

func set_settings_admin_passwd(new_admin_passwd: String) -> void:
	settings_dict['settings']['admin_passwd'] = new_admin_passwd
	store_settings_to_file()

func store_settings_to_file() -> void:
	# convert to json-string
	var json_content = JSON.stringify(settings_dict, "\t") # \t adds tab indentation

	# write to file
	var file = FileAccess.open(settings_file, FileAccess.ModeFlags.WRITE)
	if file:
		file.store_string(json_content)
		file.close()
	else:
		print("Error: Unable to open file for writing")
