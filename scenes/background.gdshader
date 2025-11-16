shader_type canvas_item;

uniform float swirl_strength : hint_range(0.0, 2.0) = 0.45;
uniform float noise_scale : hint_range(0.5, 8.0) = 2.0;
uniform float smoke_speed : hint_range(0.1, 4.0) = 0.8;
uniform float swirl_speed : hint_range(0.1, 3.0) = 0.6;
uniform float density : hint_range(0.0, 1.0) = 0.55;
uniform vec4 smoke_color : source_color = vec4(0.85, 0.85, 0.85, 1.0);

// Simple random function
float rand(vec2 n) {
    return fract(sin(dot(n, vec2(12.9898, 78.233))) * 43758.5453);
}

// Value noise (pseudo-Perlin)
float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    
    float a = rand(i);
    float b = rand(i + vec2(1.0, 0.0));
    float c = rand(i + vec2(0.0, 1.0));
    float d = rand(i + vec2(1.0, 1.0));

    vec2 u = f * f * (3.0 - 2.0 * f);

    return mix(a, b, u.x) +
           (c - a) * u.y * (1.0 - u.x) +
           (d - b) * u.x * u.y;
}

void fragment() {
    vec2 uv = UV;

    // Time components
    float t = TIME * smoke_speed;
    float swirl_t = TIME * swirl_speed;

    // Smoke swirling motion
    float swirl = sin(uv.y * 3.5 + swirl_t) *
                  cos(uv.x * 4.0 + swirl_t * 0.8) *
                  swirl_strength;

    // Turbulent UV distortion
    vec2 distort_uv = uv + vec2(
        swirl * 0.04,
        swirl * 0.02
    );

    // Layered noise (smoke thickness)
    float n1 = noise(distort_uv * noise_scale + vec2(t, 0.0));
    float n2 = noise(distort_uv * noise_scale * 1.7 + vec2(-t * 0.7, t * 0.4));
    float n3 = noise(distort_uv * noise_scale * 0.6 + vec2(t * 0.3, -t * 0.6));

    float combined = (n1 * 0.55 + n2 * 0.35 + n3 * 0.25);

    // Fade edges — smoke looks centered and mystical
    float vignette = smoothstep(1.2, 0.3, length((uv - 0.5) * 1.4));

    float smoke = combined * vignette * density;

    vec4 col = smoke_color;
    col.a = smoke;

    COLOR = col;
}
