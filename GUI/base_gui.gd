extends Control

@onready var pause_button: Button = get_node("PauseButton")

func _ready():
	var main_node = get_parent()  # Main är föräldern till GUI
	main_node.connect("timer_updated", Callable(self, "_on_timer_updated"))  # Koppla signalen för timern
	main_node.connect("time_elapsed_updated", Callable(self, "_on_elapsed_updated"))
	pause_button.connect("pressed", Callable(self, "_on_pause_pressed"))

func _on_timer_updated(time_left: float):
	var label: RichTextLabel = get_node("TimeLeftText")
	var text = str(round(time_left)) + " seconds left"  # Uppdatera label
	label.text = "[center]" + text + "[/center]"

func _on_elapsed_updated(time:float):
	var label: RichTextLabel = get_node("TimeElapsedText")
	var text = "Elapsed: " + str(round(time))
	label.text = "[center]" + text + "[/center]"
	
func _on_pause_pressed() -> void:
	if pause_button.text == 'Pause':
		pause_button.text = 'Unpause'
	else:
		pause_button.text = 'Pause'
