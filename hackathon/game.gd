extends Control

#@export var scroll_speed_px_per_sec: float = 5.0  
#
@onready var bg: TextureRect = $TextureRect
#
#var _uv_offset_y: float = 0.0
#var _uv_speed: float = 0.0
#var dead : bool = false
#
#func _ready() -> void:
	#bg.z_index = -1  # keep it behind UI
#
	#if bg.texture == null:
		#push_error("TextureRect has no texture.")
		#return
#
	#var tex_h := float(bg.texture.get_height())
	#_uv_speed = scroll_speed_px_per_sec / tex_h
#
	## Looping vertical shader
	#var shader := Shader.new()
	#shader.code = """
#shader_type canvas_item;
#
#uniform float y_offset = 0.0;
#
#void fragment() {
	#vec2 uv = UV;
	#uv.y = fract(uv.y - y_offset); // NEGATIVE makes it move DOWN
	#COLOR = texture(TEXTURE, uv);
#}
#"""
	#var mat := ShaderMaterial.new()
	#mat.shader = shader
	#bg.material = mat

func _process(delta: float) -> void:
	if bg.material == null:
		return

	#_uv_offset_y = fmod(_uv_offset_y + _uv_speed * delta, 1.0)
	#(bg.material as ShaderMaterial).set_shader_parameter("y_offset", _uv_offset_y)
	#
	if get_node("CharacterBody2D/CollisionShape2D").global_position.x < get_node("left_wall_test").global_position.x:
		get_tree().change_scene_to_file("res://End.tscn")
		
	if get_node("CharacterBody2D/Camera2D").limit_left < get_node("left_wall_test").global_position.x:
		get_node("CharacterBody2D/Camera2D").limit_left = int(get_node("left_wall_test").global_position.x)
		
	if get_node("CharacterBody2D/Camera2D").limit_bottom < get_node("floor").global_position.y + 1000:
		get_node("CharacterBody2D/Camera2D").limit_bottom = int(get_node("floor").global_position.y)
		
#func _on_end_game_pressed() -> void:
	#get_tree().change_scene_to_file("res://End.tscn")
