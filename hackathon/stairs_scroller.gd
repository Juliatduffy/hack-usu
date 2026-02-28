extends Control

@export var tile_w: float = 100.0
@export var tile_h: float = 80.0
@export var same_height_chance: float = 0.15
@export var height_step: float = 50.0

@export var step_interval: float = 1.5

@export var max_jump_height_diff: float = 200.0
@export var min_jump_height_diff: float = 100.0

@export var y_min: float = 500.0
@export var y_max: float = 850.0

@export var start_pos: Vector2 = Vector2(0, 700)
@export var step_count: int = 17

var _steps: Array[Control] = []
var _t_accum: float = 0.0

func _ready() -> void:
	randomize()
	_collect_steps()
	_force_sizes()
	_initial_layout()

func _process(delta: float) -> void:
	_t_accum += delta
	while _t_accum >= step_interval:
		_t_accum -= step_interval
		_advance_one_step()

func _collect_steps() -> void:
	_steps.clear()

	for i in range(1, step_count + 1):
		var n := get_node_or_null("s%d" % i)
		if n != null and n is Control:
			_steps.append(n)

	if _steps.is_empty():
		for c in get_children():
			if c is Control:
				_steps.append(c)

func _force_sizes() -> void:
	for s in _steps:
		s.custom_minimum_size = Vector2(tile_w, tile_h)
		s.size = Vector2(tile_w, tile_h)

func _initial_layout() -> void:
	var x := start_pos.x
	var y := _bounce_y(start_pos.y)

	for i in range(_steps.size()):
		_steps[i].position = Vector2(x, y)
		x += tile_w

func _advance_one_step() -> void:
	for s in _steps:
		s.position.x -= tile_w

	var left_edge := -tile_w
	for s in _steps:
		if (s.position.x + tile_w) < left_edge:
			_respawn_at_right_end(s)

func _respawn_at_right_end(s: Control) -> void:
	var rightmost := _rightmost_step()
	var new_x := rightmost.position.x + tile_w

	var delta := _pick_quantized_delta()
	var new_y := _bounce_y(rightmost.position.y + delta)

	s.position = Vector2(new_x, new_y)

func _rightmost_step() -> Control:
	var best := _steps[0]
	var best_x := best.position.x
	for i in range(1, _steps.size()):
		var x := _steps[i].position.x
		if x > best_x:
			best_x = x
			best = _steps[i]
	return best

func _pick_quantized_delta() -> float:
	if randf() < same_height_chance:
		return 0.0

	var allowed: Array[float] = []

	var min_q = ceil(min_jump_height_diff / height_step) * height_step
	var max_q = floor(max_jump_height_diff / height_step) * height_step
	if min_q > max_q:
		min_q = max_q

	var d = min_q
	while d <= max_q:
		allowed.append(-d)
		allowed.append(d)
		d += height_step

	if allowed.is_empty():
		allowed.append(-max_jump_height_diff)
		allowed.append(max_jump_height_diff)

	return allowed[randi() % allowed.size()]

func _bounce_y(y: float) -> float:
	var span := y_max - y_min
	if span <= 0.0:
		return y_min

	var t := y - y_min
	var period := 2.0 * span
	t = fposmod(t, period)

	if t > span:
		t = period - t

	return y_min + t
