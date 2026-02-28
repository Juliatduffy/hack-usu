extends Control

# -------------------------
# Size / spacing
# -------------------------

# Double-check this: 450 makes "stairs" look like giant walls.
# For platforms/steps, something like 30-80 is normal.
@export var tile_w: float = 100.0
@export var tile_h: float = 500.0
@export var same_height_chance: float = 0.15 

# Height changes only in multiples of this (50)
@export var height_step: float = 50.0

# -------------------------
# Speed (discrete stepping)
# -------------------------

# WAY slower: bigger = slower (seconds per shift)
@export var step_interval: float = 1.5

# -------------------------
# Vertical constraints
# -------------------------

# Max allowed height difference between consecutive tiles
@export var max_jump_height_diff: float = 100.0

# Minimum height difference between consecutive tiles
@export var min_jump_height_diff: float = 100.0

# Playable vertical band (smaller y = higher on screen)
@export var y_min: float = 500.0
@export var y_max: float = 850.0

# -------------------------
# Layout
# -------------------------

@export var start_pos: Vector2 = Vector2(0, 700)
@export var step_count: int = 17

# -------------------------
# Internal
# -------------------------

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

# -------------------------
# Setup helpers
# -------------------------

func _collect_steps() -> void:
	_steps.clear()

	# Prefer s1..sN if they exist
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
	# Place them left->right at constant spacing.
	# Y starts consistent; future tiles get jagged via respawn rules.
	var x := start_pos.x
	var y := _bounce_y(start_pos.y)

	for i in range(_steps.size()):
		_steps[i].global_position = Vector2(x, y)
		x += tile_w

# -------------------------
# Core logic (discrete, no drift)
# -------------------------

func _advance_one_step() -> void:
	# Move left by exactly one tile width per tick (keeps perfect sync)
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

	# GUARANTEED: delta is a multiple of 50 AND abs(delta) is in [100, 200]
	var delta := _pick_quantized_delta()

	var new_y := _bounce_y(rightmost.global_position.y + delta)
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

# -------------------------
# Height selection (fixed bug)
# -------------------------

func _pick_quantized_delta() -> float:
	# With some probability, keep the same height (delta = 0)
	if randf() < same_height_chance:
		return 0.0

	# Otherwise pick a quantized jump with abs(delta) in [min_jump_height_diff, max_jump_height_diff]
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

	# Fallback if settings are weird
	if allowed.is_empty():
		allowed.append(-max_jump_height_diff)
		allowed.append(max_jump_height_diff)

	return allowed[randi() % allowed.size()]

# -------------------------
# Vertical band behavior
# -------------------------

func _bounce_y(y: float) -> float:
	# Reflect (bounce) y into [y_min, y_max] so tiles don't pile up at the bottom.
	var span := y_max - y_min
	if span <= 0.0:
		return y_min

	var t := y - y_min
	var period := 2.0 * span
	t = fposmod(t, period)

	if t > span:
		t = period - t

	return y_min + t
