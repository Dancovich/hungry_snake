extends Node2D

const SPEED := 240.0
const ROTATION_SPEED = 2.5

export var snake_body: PackedScene = preload("res://snake/snake_body_part.tscn")

onready var _head: Node2D = $SnakeHead

var _body_parts := []
var _speed := Vector2.DOWN * SPEED

func add_body_part() -> void:
	var previous: Node2D
	if _body_parts.empty():
		previous = _head
	else:
		previous = _body_parts.back()
	
	var inst: Node2D = snake_body.instance()
	add_child(inst)
	move_child(inst, 0)
	_body_parts.push_back(inst)
	inst.position = previous.position

func _ready() -> void:
	add_body_part()
	add_body_part()
	add_body_part()
	add_body_part()

func _physics_process(delta: float) -> void:
	var move := Vector2( \
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"), \
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up"))
	
	if move == Vector2.ZERO:
		if _speed == Vector2.ZERO:
			_speed = Vector2.DOWN * SPEED
		move = _speed
	
	var angle_delta := _speed.angle_to(move)
	_speed = _speed.rotated(angle_delta * delta * ROTATION_SPEED).normalized() * SPEED
	_head.move_and_slide(_speed)
	
	_head.rotation = Vector2.DOWN.angle_to(_speed)

	if !_body_parts.empty():
		var previous := _head
		for part in _body_parts:
			var distance_squared: float = part.position.distance_squared_to(previous.position)
			
			var direction: Vector2 = part.position.direction_to(previous.position)
			part.rotation = Vector2.DOWN.angle_to(direction)
			
			if distance_squared >= 6100.0:
				direction = direction.normalized() * SPEED
				part.move_and_slide(direction)
			
			
			previous = part
