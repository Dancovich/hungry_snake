class_name SnakeHead
extends Area2D

const BASE_SIZE := 78.0
const BASE_COLLISION_RADIUS := 38.0

onready var _sprite: Sprite = $Sprite
onready var _collision: CollisionShape2D = $Collision
onready var _collision_shape: CircleShape2D = _collision.shape

export var scale_head := 1.0 setget set_scale_head,get_scale_head

func set_scale_head(scale: float) -> void:
	scale_head = scale
	_sprite.scale = Vector2(scale, scale)
	_collision_shape.radius = BASE_COLLISION_RADIUS * scale

func get_scale_head() -> float:
	return scale_head
