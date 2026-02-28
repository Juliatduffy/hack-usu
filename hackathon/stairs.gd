extends Node2D

# -------------------------
# Size / spacing
# -------------------------
@export var tile_w: float = 100.0
@export var tile_h: float = 500.0 

@export var same_height_chance: float = 0.15
@export var height_step: float = 50.0

# -------------------------
# Speed (discrete stepping)
# -------------------------
@export var step_interval: float = 1.5

# -------------------------
# Vertical constraints
# -------------------------
@export var max_jump_height_diff: float = 100.0
@export var min_jump_height_diff: float = 100.0

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
var _steps: Array[StaticBody2D] = []
var _t_accum: float = 0.0

func _ready() -> void:
	randomize()
	_collect_steps()
	_force_collision_sizes()
	_initial_layout()

# IMPORTANT: use physics tick so CharacterBody2D collision stays stable
func _physics_process(delta: float) -> void:
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
		if n != null and n is StaticBody2D:
			_steps.append(n)

	# Fallback: grab StaticBody2D children
	if _steps.is_empty():
		for c in get_children():
			if c is StaticBody2D:
				_steps.append(c)

func _force_collision_sizes() -> void:
	# Replace Control sizing with real collision sizing
	for s in _steps:
		var col := s.get_node_or_null("CollisionShape2D") as CollisionShape2D
		if col == null:
			push_warning("%s missing CollisionShape2D" % s.name)
			continue

		# Ensure it has a RectangleShape2D
		if col.shape == null or not (col.shape is RectangleShape2D):
			col.shape = RectangleShape2D.new()

		(col.shape as RectangleShape2D).size = Vector2(tile_w, tile_h)

func _initial_layout() -> void:
	var x := start_pos.x
	var y := _bounce_y(start_pos.y)

	for i in range(_steps.size()):
		_steps[i].global_position = Vector2(x, y)
		x += tile_w

# -------------------------
# Core logic (discrete, no drift)
# -------------------------

func _advance_one_step() -> void:
	for s in _steps:
		s.global_position.x -= tile_w

	var left_edge := -tile_w
	for s in _steps:
		if s.global_position.x < left_edge:
			_respawn_at_right_end(s)

func _respawn_at_right_end(s: StaticBody2D) -> void:
	var rightmost := _rightmost_step()
	var new_x := rightmost.global_position.x + tile_w

	var delta := _pick_quantized_delta()
	var new_y := _bounce_y(rightmost.global_position.y + delta)

	s.global_position = Vector2(new_x, new_y)

func _rightmost_step() -> StaticBody2D:
	var best := _steps[0]
	var best_x := best.global_position.x

	for i in range(1, _steps.size()):
		var x := _steps[i].global_position.x
		if x > best_x:
			best_x = x
			best = _steps[i]

	return best

# -------------------------
# Height selection
# -------------------------

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

# -------------------------
# Vertical band behavior
# -------------------------

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
