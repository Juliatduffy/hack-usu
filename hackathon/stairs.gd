extends Control

# Movement (pixels/sec)
@export var speed_left: float = 100.0
@export var speed_down: float = 30.0

# Step geometry
@export var tile_size: Vector2 = Vector2(100, 30)
@export var step_spacing: Vector2 = Vector2(100, 30) # right 100, up 30 (negative y)

# How many steps you have (you said 15)
@export var step_count: int = 15

# Where the staircase "starts" (bottom-left-ish)
@export var start_pos: Vector2 = Vector2(0, 870)

# Offscreen padding
@export var pad: float = 20.0

var _steps: Array[Control] = []
var _d: Vector2 # direction from one step to the next (up-right)

func _ready() -> void:
	_d = Vector2(step_spacing.x, -step_spacing.y) # up-right in Godot coords

	_collect_steps()
	_size_steps()
	_layout_initial()

func _process(delta: float) -> void:
	var screen := get_viewport_rect().size
	var move := Vector2(-speed_left, speed_down) * delta

	# Move all steps
	for s in _steps:
		s.global_position += move

	# Wrap any step that left the screen
	for s in _steps:
		if _is_offscreen(s, screen):
			var front := _frontmost_step()
			s.global_position = front.global_position + _d

func _collect_steps() -> void:
	_steps.clear()

	# Prefer s1..s15 if they exist (your setup)
	for i in range(1, step_count + 1):
		var n := get_node_or_null("s%d" % i)
		if n != null and n is Control:
			_steps.append(n)

	# Fallback: if naming isn't perfect, just grab children
	if _steps.size() == 0:
		for c in get_children():
			if c is Control:
				_steps.append(c)

func _size_steps() -> void:
	for s in _steps:
		s.custom_minimum_size = tile_size
		s.size = tile_size

func _layout_initial() -> void:
	# Make a clean staircase: bottom-left -> up-right
	# s1 at start_pos, s2 one step up-right, etc.
	# Uses GLOBAL positions so Control layout doesn’t fight you.
	for i in range(_steps.size()):
		_steps[i].global_position = start_pos + _d * float(i)

func _is_offscreen(s: Control, screen: Vector2) -> bool:
	var p := s.global_position
	var off_left := (p.x + tile_size.x) < -pad
	var off_bottom := p.y > screen.y + pad
	return off_left or off_bottom

func _frontmost_step() -> Control:
	# "Front" means furthest along the up-right diagonal direction _d.
	# We use a dot product projection to find that.
	var best := _steps[0]
	var best_t := best.global_position.dot(_d)

	for i in range(1, _steps.size()):
		var t := _steps[i].global_position.dot(_d)
		if t > best_t:
			best_t = t
			best = _steps[i]

	return best
