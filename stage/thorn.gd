class_name Thorn
extends Area2D

onready var _anim: AnimationPlayer = $AnimationPlayer
onready var _sprite: Sprite = $Sprite

export var active := false

func activate() -> void:
	_anim.play("appear")
	yield(_anim, "animation_finished")
	active = true
	_anim.play("swing")

func _ready() -> void:
	visible = false

func _process(delta: float) -> void:
	if !active && !_anim.is_playing():
		visible = true
		activate()
