shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform float wobble_speed : hint_range(0.1, 5.0) = 1.0;
uniform float wobble_strength : hint_range(0.0, 0.1) = 0.005;
uniform float wobble_scale : hint_range(1.0, 20.0) = 10.0;
uniform float tint_alpha : hint_range(0.0, 1.0) = 0.2;
uniform vec4 tint_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);

void fragment() {
    vec2 uv = SCREEN_UV;

    // Create a time-based wobble offset
    vec2 offset = vec2(
        sin(TIME * wobble_speed + uv.x * wobble_scale) * wobble_strength,
        cos(TIME * wobble_speed * 0.8 + uv.y * wobble_scale) * wobble_strength
    );

    vec4 bg_color = texture(SCREEN_TEXTURE, uv + offset);

    COLOR = mix(bg_color, tint_color, tint_alpha);
}
