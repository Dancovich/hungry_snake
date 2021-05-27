extends ColorRect

export var game_scene: PackedScene = preload("res://stage/stage.tscn")

onready var _start_button: TextureButton = $TextureButton

func _ready() -> void:
	_start_button.grab_focus()

func _on_start_pressed() -> void:
	get_tree().change_scene_to(game_scene)
