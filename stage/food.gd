class_name Food
extends Area2D

onready var _anim: AnimationPlayer = $AnimationPlayer
onready var _sprite: Sprite = $Sprite

export var active := false

var _queue_kill := false

func activate() -> void:
	_anim.play("appear")
	yield(_anim, "animation_finished")
	active = true
	_anim.play("swing")

func kill() -> void:
	_queue_kill = true
	active = false
	queue_free()

func _ready() -> void:
	visible = false

func _process(delta: float) -> void:
	if _queue_kill:
		return
	
	if !active && !_anim.is_playing():
		visible = true
		activate()
