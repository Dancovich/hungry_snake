extends Node2D

const MAX_THORNS := 10

export var snake_scene: PackedScene = preload("res://snake/snake.tscn")
export var food_scene: PackedScene = preload("res://stage/food.tscn")
export var thorn_scene: PackedScene = preload("res://stage/thorn.tscn")

onready var _thorn_timer: Timer = $ThornSpawnTimer
onready var _food_timer: Timer = $FoodSpawnTimer
onready var _spawn_tl: Position2D = $SpawnTL
onready var _spawn_bl: Position2D = $SpawnBL
onready var _spawn_tr: Position2D = $SpawnTR

onready var _node_score: Label = $Hud/Score
onready var _node_multiplier: Label = $Hud/Multiplier
#onready var _node_score_grid: GridContainer = $Hud/GridContainer
onready var _gameover_screen: Node2D = $GameoverLayer/Gameover
onready var _gameover_restart_button: TextureButton = $GameoverLayer/Gameover/RestartButton
onready var _gameover_titlescreen_button: TextureButton = $GameoverLayer/Gameover/TitleScreenButton

var _snake: Snake
var _score := 0
var _multiplier := 1.0
var _qtd_thorns := 0
var _gameover := false

func _ready() -> void:
	reset_game()

func _physics_process(_delta: float) -> void:
	spawn_food()
	spawn_thorn()

func title_screen() -> void:
	get_tree().change_scene("res://main_scene.tscn")

func reset_game() -> void:
	randomize()
	
	_gameover_restart_button.release_focus()
	_gameover_restart_button.disabled = true
	_gameover_titlescreen_button.release_focus()
	_gameover_titlescreen_button.disabled = true
	_gameover_screen.visible = false
	
	_gameover = false
	_score = 0
	_multiplier = 1.0
	_qtd_thorns = 0
	_node_score.text = str(_score)
	_node_multiplier.text = "x" + str(_multiplier)
#	_node_score_grid.anchor_left = 1.0
#	_node_score_grid.anchor_right = 1.0
#	_node_score_grid.anchor_top = 0.0
#	_node_score_grid.anchor_bottom = 0.0
	
	var entities: Node2D = $Entities
	
	for entity in entities.get_children():
		entity.remove_from_group("spawn_obstacles")
		entity.queue_free()
	
	spawn_snake()

func can_spawn(position: Vector2, min_distance: float, min_distance_snake: float) -> bool:
	var min_distance_sqr := pow(min_distance, 2.0)
	var min_distance_snake_sqr := pow(min_distance_snake, 2.0)
	
	if _snake != null && is_instance_valid(_snake):
		var parts = _snake.get_body_parts()
		for obst in parts:
			if obst.global_position.distance_squared_to(position) <= min_distance_snake_sqr:
				return false

	var obstacles = get_tree().get_nodes_in_group("spawn_obstacles")
	for obst in obstacles:
		if obst.position.distance_squared_to(position) <= min_distance_sqr:
			return false
	return true

func spawn_snake() -> void:
	if _gameover:
		return
	
	var position := Vector2(\
		((_spawn_tr.position.x - _spawn_tl.position.x) / 2.0) + _spawn_tl.position.x, \
		((_spawn_bl.position.y - _spawn_tl.position.y) / 2.0) + _spawn_tl.position.y)
	
	var allowed := can_spawn(position, 200.0, 0.0)
	
	var attempts := 0
	while attempts < 100 && !allowed:
		position.x = rand_range(_spawn_tl.position.x, _spawn_tr.position.x)
		position.y = rand_range(_spawn_tl.position.y, _spawn_bl.position.y)
		allowed = can_spawn(position, 200.0, 0.0)
		attempts = attempts + 1

	if allowed:
		if _snake != null && is_instance_valid(_snake):
			_snake.queue_free()
		
		_snake = snake_scene.instance()
		$Entities.add_child(_snake)
		
		# warning-ignore:return_value_discarded
		_snake.connect("food_eaten", self, "_on_food_eaten")
		# warning-ignore:return_value_discarded
		_snake.connect("food_swallowed", self, "_on_food_swallowed")
		# warning-ignore:return_value_discarded
		_snake.connect("dead", self, "_on_snake_dead")
		
		_snake.position = Vector2.ZERO
		_snake.set_snake_position(position)

func spawn_thorn(force: bool = false) -> void:
	if _qtd_thorns > MAX_THORNS:
		return
	
	var value := randi()
	if !force:
		if _thorn_timer.is_stopped():
			_thorn_timer.start()
			yield(_thorn_timer, "timeout")
		else:
			return

	if _gameover:
		return

	var position := Vector2.ZERO
	var allowed := false
	var attempts := 0
	while attempts < 10 && !allowed:
		position.x = rand_range(_spawn_tl.position.x, _spawn_tr.position.x)
		position.y = rand_range(_spawn_tl.position.y, _spawn_bl.position.y)
		allowed = can_spawn(position, 80.0, 300.0)
		attempts = attempts + 1

	if allowed:
		var thorn: Thorn = thorn_scene.instance()
		$Entities.add_child(thorn)
		thorn.position = position
		thorn.add_to_group("spawn_obstacles")
		$Entities.move_child(thorn, 0)
		_qtd_thorns = _qtd_thorns + 1

func spawn_food() -> void:
	if _food_timer.is_stopped():
		_food_timer.start()
		yield(_food_timer, "timeout")
		
		if _gameover:
			return
		
		var position := Vector2.ZERO
		var allowed := false
		var attempts := 0
		while attempts < 10 && !allowed:
			position.x = rand_range(_spawn_tl.position.x, _spawn_tr.position.x)
			position.y = rand_range(_spawn_tl.position.y, _spawn_bl.position.y)
			allowed = can_spawn(position, 80.0, 180.0)
			attempts = attempts + 1

		if allowed:
			var food: Food = food_scene.instance()
			$Entities.add_child(food)
			food.position = position
			food.add_to_group("spawn_obstacles")
			$Entities.move_child(food, 0)

func _on_food_eaten(snake: Snake, food: Food) -> void:
	food.kill()
	var qtd_food := snake.count_size_increments()
	
	var multiplier_increase := floor(qtd_food / 3.0)
	_multiplier = 1.0 + multiplier_increase
	_node_multiplier.text = "x" + str(_multiplier)

func _on_food_swallowed(snake: Snake, qtd_food_swallowed: int) -> void:
	_score += int(round(qtd_food_swallowed * _multiplier)) * 10
	_node_score.text = str(_score)
	_multiplier = 1.0
	_node_multiplier.text = "x" + str(_multiplier)

func _on_snake_dead() -> void:
	_gameover = true
	_gameover_screen.final_score = _score
	_gameover_screen.visible = true
	_gameover_restart_button.disabled = false
	_gameover_titlescreen_button.disabled = false
	_gameover_restart_button.grab_focus()
