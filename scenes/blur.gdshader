shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

// --- Blur Parameters ---
uniform float blur_amount : hint_range(0.0, 5.0) = 2.0; // How strong the background blur is
uniform float blur_brightness_factor : hint_range(0.5, 2.0) = 1.0; // Adjust brightness after blur

// --- Soul / Ethereal Effect Parameters ---
uniform float soul_intensity : hint_range(0.0, 1.0) = 0.4; // How visible the soul effect is
uniform float soul_speed : hint_range(0.1, 2.0) = 0.5; // Speed of the soul movement
uniform float soul_scale : hint_range(0.1, 20.0) = 5.0; // Size/density of the soul wisps
uniform vec4 soul_color_low : source_color = vec4(0.5, 0.8, 1.0, 1.0); // Light blue/cyan
uniform vec4 soul_color_high : source_color = vec4(0.8, 0.2, 1.0, 1.0); // Purple/magenta
uniform float soul_glow_threshold : hint_range(0.0, 1.0) = 0.4; // At what noise value does glow start
uniform float soul_glow_power : hint_range(1.0, 10.0) = 3.0; // How strong the glow is

// --- Overall Tint / Overlay ---
uniform float overall_tint_alpha : hint_range(0.0, 1.0) = 0.2; // Overall semi-transparent overlay
uniform vec4 overall_tint_color : source_color = vec4(0.0, 0.0, 0.0, 1.0); // Darkening tint

// --- Noise function (Simplex Noise - common for organic patterns) ---
// Not a true Simplex Noise implementation, but a common 2D noise approximation
// Source: https://thebookofshaders.com/10/
float random (vec2 st) {
    return fract(sin(dot(st.xy,
                         vec2(12.9898,78.233)))*
        43758.5453123);
}

float noise (vec2 st) {
    vec2 i = floor(st);
    vec2 f = fract(st);

    // Four corners in 2D of a unit cell
    float a = random(i);
    float b = random(i + vec2(1.0, 0.0));
    float c = random(i + vec2(0.0, 1.0));
    float d = random(i + vec2(1.0, 1.0));

    vec2 u = f*f*(3.0-2.0*f); // Smooth interpolation
    // Or simpler: vec2 u = smoothstep(0.,1.,f);

    return mix(a, b, u.x) +
            (c - a)*u.y * (1.0 - u.x) +
            (d - b)*u.y * u.x;
}

// Multi-octave Fractal Brownian Motion (FBM) for more complex noise
float fbm(vec2 st) {
    float value = 0.0;
    float amplitude = 0.5;
    float frequency = 0.0;
    for (int i = 0; i < 4; i++) { // Number of octaves
        value += amplitude * noise(st);
        st *= 2.0; // Increase frequency for next octave
        amplitude *= 0.5; // Decrease amplitude for next octave
    }
    return value;
}


void fragment() {
    // 1. Get Blurred Background
    vec4 bg_color = textureLod(SCREEN_TEXTURE, SCREEN_UV, blur_amount);
    bg_color.rgb *= blur_brightness_factor; // Adjust brightness

    // 2. Generate "Soul" Noise Pattern
    vec2 noise_uv = SCREEN_UV * soul_scale;
    noise_uv.x += TIME * soul_speed * 0.5; // Move horizontally
    noise_uv.y += TIME * soul_speed * 0.2; // Move vertically (slower)
    
    // Use FBM for a more organic, cloudy look
    float soul_noise = fbm(noise_uv);
    
    // Create a color gradient based on noise value
    vec4 spectral_color = mix(soul_color_low, soul_color_high, soul_noise);
    
    // Add glow effect: make brighter based on threshold
    float glow_mask = max(0.0, soul_noise - soul_glow_threshold);
    spectral_color.rgb += spectral_color.rgb * pow(glow_mask, soul_glow_power); // Enhance glow
    
    // 3. Blend Soul Effect with Blurred Background
    // The alpha of the spectral_color should be derived from the noise to control its visibility
    // Higher noise = more visible soul
    spectral_color.a = clamp(soul_noise * 1.5 - 0.5, 0.0, 1.0); // Adjust for more control
    
    // Mix the blurred background with the spectral color, controlled by soul_intensity
    vec4 final_color = mix(bg_color, spectral_color, spectral_color.a * soul_intensity);

    // 4. Apply Overall Tint
    final_color.rgb = mix(final_color.rgb, overall_tint_color.rgb, overall_tint_alpha);
    final_color.a = mix(final_color.a, overall_tint_color.a, overall_tint_alpha);

    COLOR = final_color;
}