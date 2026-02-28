extends Node2D

@export var boulder_scene: PackedScene
@export var spawn_interval: float = 3.0
@export var move_speed: float = 2.0      # higher = faster oscillation
@export var move_distance: float = 900.0

var start_x: float
var time: float = 0.0

func _ready() -> void:
	start_x = global_position.x
	var timer := Timer.new()
	add_child(timer)
	timer.wait_time = spawn_interval
	timer.timeout.connect(_spawn_boulder)
	timer.start()

func _process(delta: float) -> void:
	time += delta
	global_position.x = start_x + sin(time * move_speed) * move_distance

func _spawn_boulder() -> void:
	if boulder_scene == null:
		return
	var boulder = boulder_scene.instantiate()
	get_tree().current_scene.add_child(boulder)
	boulder.global_position = global_position
