extends Node2D

onready var _score_label: Label = $ScoreLabel
onready var _anim: AnimationPlayer = $AnimationPlayer

export var final_score := 0 setget set_final_score

func set_final_score(value: int) -> void:
	final_score = value
	_score_label.text = "FINAL SCORE: " + str(final_score)

