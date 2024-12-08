extends Control

func _ready():
	var main_node = get_parent()  # Main är föräldern till GUI
	main_node.connect("timer_updated", Callable(self, "_on_timer_updated"))  # Koppla signalen

func _on_timer_updated(time_left: float):
	var label: RichTextLabel = get_node("TimeLeftText")
	var text = str(round(time_left)) + " seconds left"  # Uppdatera label
	label.text = "[center]" + text + "[/center]"
