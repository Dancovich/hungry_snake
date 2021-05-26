extends Node2D

export var snake_scene: PackedScene = preload("res://snake/snake.tscn")
export var food_scene: PackedScene = preload("res://stage/food.tscn")
export var thorn_scene: PackedScene = preload("res://stage/thorn.tscn")

onready var _thorn_timer: Timer = $ThornSpawnTimer
onready var _food_timer: Timer = $FoodSpawnTimer
onready var _spawn_tl: Position2D = $SpawnTL
onready var _spawn_bl: Position2D = $SpawnBL
onready var _spawn_tr: Position2D = $SpawnTR

func _ready() -> void:
	reset_game()

func _physics_process(delta: float) -> void:
	spawn_food()

func reset_game() -> void:
	var entities: Node2D = $Entities
	
	for entity in entities.get_children():
		entity.queue_free()
	
	var snake: Snake = snake_scene.instance()
	entities.add_child(snake)
	snake.add_to_group("player")
	snake.connect("food_eaten", self, "_on_food_eaten")
	snake.position = Vector2(640, 360)

func can_spawn(position: Vector2, min_distance: float = 200.0) -> bool:
	var snakes = get_tree().get_nodes_in_group("player")
	if !snakes.empty():
		var snake: Snake = snakes.front()
		var parts = snake.get_body_parts()
		for obst in parts:
			if obst.position.distance_to(position) <= min_distance:
				return false

	var obstacles = get_tree().get_nodes_in_group("spawn_obstacles")
	for obst in obstacles:
		if obst.position.distance_to(position) <= min_distance:
			return false
	return true

func spawn_food() -> void:
	if _food_timer.is_stopped():
		_food_timer.start()
		yield(_food_timer, "timeout")
		
		var position := Vector2.ZERO
		var allowed := false
		while !allowed:
			position.x = rand_range(_spawn_tl.position.x, _spawn_tr.position.x)
			position.y = rand_range(_spawn_tl.position.y, _spawn_bl.position.y)
			allowed = can_spawn(position)
		
		var food: Food = food_scene.instance()
		$Entities.add_child(food)
		food.position = position
		food.add_to_group("spawn_obstacles")

func _on_food_eaten(food) -> void:
	food.kill()

