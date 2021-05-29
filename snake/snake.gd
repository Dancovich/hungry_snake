class_name Snake
extends Node2D

signal food_eaten(snake, food)
signal food_swallowed(snake, qtd_food_swallowed)
signal dead

const SPEED := 220.0
#const SPEED := 1.0
const ROTATION_SPEED := deg2rad(360.0)
const DEFAULT_SIZE := 0.85
const SIZE_INCREMENT := 0.08

export var snake_body: PackedScene = preload("res://snake/snake_body_part.tscn")

onready var _head: SnakeHead = $SnakeHead
onready var _anim: AnimationPlayer = $AnimationPlayer
onready var _sound_eat: AudioStreamPlayer2D = $SnakeHead/Sounds/Eat
onready var _sound_swallow: AudioStreamPlayer2D = $SnakeHead/Sounds/Swallow
onready var _sound_hit: AudioStreamPlayer2D = $SnakeHead/Sounds/Hit
onready var _sound_die: AudioStreamPlayer2D = $SnakeHead/Sounds/Die
onready var _sound_move: AudioStreamPlayer2D = $SnakeHead/Sounds/Move

var _body_parts := []
var _speed := Vector2.RIGHT * SPEED
var _direction := Vector2.RIGHT
var _size := DEFAULT_SIZE
var _queue_kill := false

func set_snake_position(pos: Vector2) -> void:
	_head.position = pos
	for part in _body_parts:
		part.position = pos

func increase_size() -> void:
	_sound_eat.pitch_scale = rand_range(0.98, 1.2)
	_sound_eat.play()
	_size += SIZE_INCREMENT
	_head.scale_head = _size
	var increments := count_size_increments()
	if increments >= 3 && increments < 6:
		_head.shake(1)
	elif increments >= 6:
		_head.shake(2)

func count_size_increments() -> int:
	var value := (_size - DEFAULT_SIZE) / SIZE_INCREMENT
	return int(round(value))

func count_body_parts() -> int:
	return _body_parts.size()

func reset_size() -> void:
	_size = DEFAULT_SIZE
	_head.scale_head = _size
	_head.shake(0)

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
	
	_sound_move.stop()
	_head.shake(0)
	
	_sound_hit.play()
	_anim.play("die")
	yield(_anim, "animation_finished")
	
	var previous = _head
	for part in _body_parts:
		part.kill(previous.position.direction_to(part.position))
		previous = part

	_sound_die.play()
	_anim.play("dissapear")
	
	yield(_anim, "animation_finished")
	yield(_sound_die, "finished")
	
	emit_signal("dead")
	queue_free()

func _ready() -> void:
	reset_size()
	# warning-ignore:return_value_discarded
	_head.connect("area_entered", self, "_on_object_contact")
	# warning-ignore:return_value_discarded
	_head.connect("body_entered", self, "_on_object_contact")
	
	add_body_part()
	_sound_move.play()

func _unhandled_input(event: InputEvent) -> void:
	if !_queue_kill && \
			_size > DEFAULT_SIZE && \
			event.is_action_pressed("eat"):
		get_tree().set_input_as_handled()
		_sound_swallow.play()
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
	
	if move != Vector2.ZERO:
		_direction = move.normalized()
	
	var delta_angle = _speed.angle_to(_direction)
	if delta_angle != 0.0:
		if delta_angle >= 0.0:
			var angle := ROTATION_SPEED * delta
			if abs(angle) > abs(delta_angle):
				angle = delta_angle
			_speed = _speed.rotated(angle)
		else:
			var angle := -ROTATION_SPEED * delta
			if abs(angle) > abs(delta_angle):
				angle = delta_angle
			_speed = _speed.rotated(angle)
	
	_speed = _speed.normalized() * SPEED * delta
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
				var delta_distance := SPEED * 1.5 * delta
				if delta_distance  > distance - previous_distance:
					delta_distance = distance - previous_distance
				direction = direction.normalized() * delta_distance
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
