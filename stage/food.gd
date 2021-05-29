class_name Food
extends Area2D

onready var _anim: AnimationPlayer = $AnimationPlayer
onready var _sprite: Sprite = $Sprite
onready var _particles: CPUParticles2D = $PieceParticles
onready var _kill_timer: Timer = $KillTimer

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
	
	_sprite.visible = false
	_particles.emitting = true
	_kill_timer.start()
	yield(_kill_timer, "timeout")
	queue_free()

func _ready() -> void:
	visible = false

func _process(_delta: float) -> void:
	if _queue_kill:
		return
	
	if !active && !_anim.is_playing():
		visible = true
		activate()
