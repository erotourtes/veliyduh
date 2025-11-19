shader_type canvas_item;

uniform float time_speed : hint_range(0.0, 5.0) = 1.0;
uniform float swirl_strength : hint_range(0.0, 4.0) = 1.2;
uniform float zoom : hint_range(0.5, 3.0) = 1.0;
uniform vec3 tint_color : source_color = vec3(0.8, 0.4, 1.0);
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment() {
    vec2 uv = UV;

    // Centered coords in [-1, 1]
    vec2 p = (uv - 0.5) * 2.0;
    float r = length(p);
    float angle = atan(p.y, p.x);

    float t = TIME * time_speed;

    // Swirling distortion based on radius & time
    float swirl = swirl_strength * (1.0 - smoothstep(0.0, 1.0, r));
    angle += swirl * sin(t + r * 6.2831);

    // Zoom in/out slightly with time
    float dynamic_zoom = zoom + 0.05 * sin(t * 0.7);
    float new_r = r * dynamic_zoom;

    vec2 polar_to_cart = vec2(cos(angle), sin(angle)) * new_r;

    // Back to [0,1] UV space
    vec2 distorted_uv = polar_to_cart * 0.5 + 0.5;

    // Wrap UV so it tiles instead of hard-clipping
    distorted_uv = fract(distorted_uv);

    // Sample the screen texture if used as a post-process, otherwise just color
    vec4 base_col = texture(SCREEN_TEXTURE, distorted_uv);

    // Combine with tint
    vec3 final_col = mix(base_col.rgb, tint_color, 0.4 + 0.3 * sin(t + r * 10.0));

    COLOR = vec4(final_col, base_col.a);
}
