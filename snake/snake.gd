class_name Snake
extends Node2D

signal food_eaten(snake, food)
signal food_swallowed(snake, qtd_food_swallowed)
signal dead

const SPEED := 200.0
const ROTATION_SPEED := 2.2
const DEFAULT_SIZE := 0.85
const SIZE_INCREMENT := 0.2

export var snake_body: PackedScene = preload("res://snake/snake_body_part.tscn")

onready var _head: SnakeHead = $SnakeHead
onready var _anim: AnimationPlayer = $AnimationPlayer

var _body_parts := []
var _speed := Vector2.RIGHT * SPEED
var _size := DEFAULT_SIZE
var _queue_kill := false

func set_snake_position(pos: Vector2) -> void:
	_head.position = pos
	for part in _body_parts:
		part.position = pos

func increase_size() -> void:
	_size += SIZE_INCREMENT
	_head.scale_head = _size

func count_size_increments() -> int:
	var value := (_size - DEFAULT_SIZE) / SIZE_INCREMENT
	return int(round(value))

func count_body_parts() -> int:
	return _body_parts.size()

func reset_size() -> void:
	_size = DEFAULT_SIZE
	_head.scale_head = _size

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
	
	# warning-ignore:return_value_discarded
	inst.connect("area_entered", self, "_on_object_contact")
	# warning-ignore:return_value_discarded
	inst.connect("body_entered", self, "_on_object_contact")

func get_body_parts() -> Node2D:
	var value = [_head]
	if !_body_parts.empty():
		value.append_array(_body_parts)
	return value

func kill() -> void:
	_queue_kill = true
	_anim.play("die")
	yield(_anim, "animation_finished")
	
	var previous = _head
	for part in _body_parts:
		part.kill(previous.position.direction_to(part.position))
		previous = part

	_anim.play("dissapear")
	yield(_anim, "animation_finished")
	emit_signal("dead")
	queue_free()

func _ready() -> void:
	reset_size()
	# warning-ignore:return_value_discarded
	_head.connect("area_entered", self, "_on_object_contact")
	# warning-ignore:return_value_discarded
	_head.connect("body_entered", self, "_on_object_contact")
	
	add_body_part()

func _unhandled_input(event: InputEvent) -> void:
	if !_queue_kill && \
			_size > DEFAULT_SIZE && \
			event.is_action_pressed("eat"):
		get_tree().set_input_as_handled()
		var qtd_food_swallowed := count_size_increments()
		reset_size()
		add_body_part()
		emit_signal("food_swallowed", self, qtd_food_swallowed)

func _physics_process(delta: float) -> void:
	if _queue_kill:
		return
	
	var move := Vector2( \
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"), \
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up"))
	
	if move == Vector2.ZERO:
		if _speed == Vector2.ZERO:
			_speed = Vector2.DOWN * SPEED
		move = _speed
	
	var angle_delta := _speed.angle_to(move)
	_speed = _speed.rotated(angle_delta * delta * ROTATION_SPEED).normalized() * SPEED * delta
	_head.position += _speed
	
	_head.rotation = Vector2.DOWN.angle_to(_speed)

	if !_body_parts.empty():
		var previous: Node2D = _head
		var previous_distance = (_head.BASE_SIZE / 2.0) + ((_head.BASE_SIZE / 2.0) * _size)
		for part in _body_parts:
			var distance: float = part.position.distance_to(previous.position)
			
			var direction: Vector2 = part.position.direction_to(previous.position)
			part.rotation = Vector2.DOWN.angle_to(direction)
			
			if distance >= previous_distance:
				direction = direction.normalized() * SPEED * delta
				part.position += direction
			
			
			previous = part
			previous_distance = 70.0

func _on_object_contact(area) -> void:
	if _queue_kill:
		return
	
	if area is Food && area.active:
		increase_size()
		emit_signal("food_eaten", self, area)
	elif area is Thorn && area.active:
		kill()
	elif area is TileMap:
		kill()
