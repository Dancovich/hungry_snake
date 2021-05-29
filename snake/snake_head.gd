class_name SnakeHead
extends Area2D

const BASE_SIZE := 78.0
const BASE_COLLISION_RADIUS := 35.0

onready var _sprite: Sprite = $Sprite
onready var _sweat_sprite: Sprite = $SweatSprite
onready var _collision: CollisionShape2D = $Collision
onready var _collision_shape: CircleShape2D = _collision.shape
onready var _shake_anim: AnimationPlayer = $ShakePlayer

export var scale_head := 1.0 setget set_scale_head,get_scale_head

func set_scale_head(scale: float) -> void:
	scale_head = scale
	var vscale := Vector2(scale, scale)
	_sprite.scale = vscale
	_sweat_sprite.scale = vscale
	_collision_shape.radius = BASE_COLLISION_RADIUS * scale

func get_scale_head() -> float:
	return scale_head

func shake(level: int = 1) -> void:
	if level <= 0:
		_shake_anim.play("not_shake")
	elif level == 1:
		_shake_anim.play("shake")
	else:
		_shake_anim.play("shake2")
