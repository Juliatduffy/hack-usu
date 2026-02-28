shader_type canvas_item;

uniform float scroll_speed = 0.05;

void fragment() {
    vec2 uv = UV;
    uv.x += scroll_speed * TIME;
    uv.x = fract(uv.x);
    COLOR = texture(TEXTURE, uv);
}