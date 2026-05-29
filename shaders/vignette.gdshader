shader_type canvas_item;

// Vignette post-processing effect
// Darkens screen edges for cinematic focus

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
uniform float vignette_intensity : hint_range(0.0, 1.0) = 0.4;
uniform float vignette_smoothness : hint_range(0.0, 1.0) = 0.5;
uniform vec4 vignette_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);

void fragment() {
	vec2 uv = SCREEN_UV;
	vec4 color = texture(screen_texture, uv);

	// Calculate vignette based on distance from center
	vec2 center = uv - 0.5;
	float dist = length(center);
	float vignette = smoothstep(vignette_smoothness, vignette_smoothness - vignette_intensity, dist);

	// Apply vignette darkening
	color.rgb = mix(vignette_color.rgb, color.rgb, vignette);

	COLOR = color;
}
