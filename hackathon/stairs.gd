extends Control

# Tile size
@export var tile_w: float = 200.0
@export var tile_h: float = 400.0

# WAY slower (bigger = slower)
@export var step_interval: float = 1.2

# Vertical behavior
@export var base_drop_per_step: float = 20.0
@export var jagged_max: float = 120.0

# Max allowed height change between consecutive tiles
@export var max_jump_height_diff: float = 200.0

# Playable vertical band (smaller y = higher on screen)
@export var y_min: float = 200.0
@export var y_max: float = 900.0

@export var start_pos: Vector2 = Vector2(0, 870)
@export var step_count: int = 9

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

	# Fallback: grab children if naming isn't perfect
	if _steps.size() == 0:
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
		_steps[i].global_position = Vector2(x, y)
		x += tile_w

func _advance_one_step() -> void:
	# Move left by exactly one tile width per tick
	for s in _steps:
		s.global_position.x -= tile_w

	# Wrap tiles that exited left
	var left_edge := -tile_w
	for s in _steps:
		if s.global_position.x < left_edge:
			_respawn_at_right_end(s)

func _respawn_at_right_end(s: Control) -> void:
	var rightmost := _rightmost_step()
	var new_x := rightmost.global_position.x + tile_w

	# Propose a vertical change and strictly limit it to max_jump_height_diff
	var proposed_delta := base_drop_per_step + randf_range(-jagged_max, jagged_max)
	var clamped_delta = clamp(proposed_delta, -max_jump_height_diff, max_jump_height_diff)

	# Bounce into [y_min, y_max] so tiles don't get stuck at the bottom
	var new_y := _bounce_y(rightmost.global_position.y + clamped_delta)

	s.global_position = Vector2(new_x, new_y)

func _rightmost_step() -> Control:
	var best := _steps[0]
	var best_x := best.global_position.x

	for i in range(1, _steps.size()):
		var x := _steps[i].global_position.x
		if x > best_x:
			best_x = x
			best = _steps[i]

	return best

func _bounce_y(y: float) -> float:
	# Reflect (bounce) y into [y_min, y_max] instead of clamping or wrapping.
	# This prevents tiles from piling up at y_max and keeps motion varied.
	var span := y_max - y_min
	if span <= 0.0:
		return y_min

	var t := y - y_min
	var period := 2.0 * span
	t = fposmod(t, period)

	if t > span:
		t = period - t  # reflect back

	return y_min + t
