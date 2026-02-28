extends Control

# -----------------------
# Background scroll stuff
# -----------------------
@export var scroll_speed_px_per_sec: float = 20.0
@onready var bg: TextureRect = $TextureRect

var _uv_offset_y: float = 0.0
var _uv_speed: float = 0.0

# -----------------------
# Stairs movement stuff
# -----------------------
@onready var stairs: Control = $Stairs
var _steps: Array[Control] = []

@export var speed_left: float = 140.0
@export var speed_down: float = 90.0
@export var respawn_pad_x: float = 60.0
@export var respawn_pad_y: float = 60.0
@export var respawn_jitter_y: float = 120.0

func _ready() -> void:
	# Background behind everything
	bg.z_index = -1

	if bg.texture == null:
		push_error("TextureRect has no texture.")
		return

	var tex_h := float(bg.texture.get_height())
	_uv_speed = scroll_speed_px_per_sec / tex_h

	var shader := Shader.new()
	shader.code = """
shader_type canvas_item;
uniform float y_offset = 0.0;
void fragment() {
	vec2 uv = UV;
	uv.y = fract(uv.y - y_offset);
	COLOR = texture(TEXTURE, uv);
}
"""
	var mat := ShaderMaterial.new()
	mat.shader = shader
	bg.material = mat


func _process(delta: float) -> void:
	# Background scroll
	if bg.material != null:
		_uv_offset_y = fmod(_uv_offset_y + _uv_speed * delta, 1.0)
		(bg.material as ShaderMaterial).set_shader_parameter("y_offset", _uv_offset_y)
