extends Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var main_node  = get_parent()
	main_node.connect("main_timer_updated", _on_timer_updated)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_timer_updated(time_left: float):
	var label: RichTextLabel = get_node("TimeLeftText")
	label.text = "[center]" + str(round(time_left)) + " seconds left"  + "[/center]" # Uppdatera GUI
