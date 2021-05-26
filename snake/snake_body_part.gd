class_name SnakeBodyPart
extends Area2D

var _kill_direction: Vector2
var _killed := false

func kill(direction: Vector2) -> void:
	_kill_direction = direction.normalized() * 100.0
	_killed = true

func _process(delta: float) -> void:
	if _killed:
		position += _kill_direction * delta
		modulate.a -= delta * 2.0
