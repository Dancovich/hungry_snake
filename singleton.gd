# This class is loaded as a singleton (Project Settings -> Autoload).
# It handles global events like toggling fullscreen mode, which
# can be done from anywhere in the game
class_name SingletonEventHandler
extends Node


func _unhandled_key_input(event: InputEventKey) -> void:
	if event.is_action_released("fullscreen"):
		get_tree().set_input_as_handled()
		OS.window_fullscreen = !OS.window_fullscreen
