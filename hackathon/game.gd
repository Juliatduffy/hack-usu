extends Control

@export var scroll_speed_px_per_sec: float = 5.0

# Time-based scoring
@export var points_per_second: float = 10.0
@export var elevation_per_second: float = 2.5  # units per second (meters, feet, whatever)

@onready var bg: TextureRect = $TextureRect
@onready var elevation_label: Label = $CanvasLayer/Control/Label

var _uv_offset_y := 0.0
var _uv_speed := 0.0

var elapsed_time := 0.0
var points := 0
var elevation := 0.0

func _ready() -> void:
	bg.z_index = -1

	if bg.texture == null:
		push_error("TextureRect has no texture.")
		return

	var tex_h := float(bg.texture.get_height())
	_uv_speed = scroll_speed_px_per_sec / tex_h

	# Looping vertical shader
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

	_update_ui()

func _process(delta: float) -> void:
	# background scroll
	if bg.material != null:
		_uv_offset_y = fmod(_uv_offset_y + _uv_speed * delta, 1.0)
		(bg.material as ShaderMaterial).set_shader_parameter("y_offset", _uv_offset_y)

	# time -> points/elevation
	elapsed_time += delta
	points = int(elapsed_time * points_per_second)
	elevation = elapsed_time * elevation_per_second

	_update_ui()

func _update_ui() -> void:
	if elevation_label:
		elevation_label.text = "Elevation: %d" % int(round(elevation))
