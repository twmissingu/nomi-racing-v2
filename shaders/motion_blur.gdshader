shader_type canvas_item;

// Screen-space motion blur post-processing effect
// Applied as a full-screen pass

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
uniform sampler2D depth_texture : hint_depth_texture, repeat_disable, filter_nearest;
uniform float blur_strength : hint_range(0.0, 1.0) = 0.3;
uniform int samples : hint_range(2, 16) = 8;
uniform vec2 velocity_scale = vec2(1.0, 0.0);

void fragment() {
	vec2 uv = SCREEN_UV;
	vec4 color = texture(screen_texture, uv);

	// Simple velocity-based blur using screen-space direction
	vec2 blur_dir = velocity_scale * blur_strength / float(samples);
	vec4 blurred = color;

	for (int i = 1; i <= samples; i++) {
		float t = float(i) / float(samples);
		vec2 offset = blur_dir * t;
		blurred += texture(screen_texture, uv + offset);
	}

	blurred /= float(samples + 1);

	// Blend based on blur strength
	COLOR = mix(color, blurred, blur_strength);
}
