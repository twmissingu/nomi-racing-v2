shader_type spatial;

// Metallic car paint shader with clearcoat and metallic flake effect
// Inspired by PBR car paint workflows

uniform vec4 base_color : source_color = vec4(0.0, 0.63, 0.88, 1.0); // NIO Blue
uniform vec4 flake_color : source_color = vec4(0.8, 0.85, 0.9, 1.0);
uniform float metallic : hint_range(0.0, 1.0) = 0.7;
uniform float roughness : hint_range(0.0, 1.0) = 0.2;
uniform float clearcoat : hint_range(0.0, 1.0) = 0.8;
uniform float clearcoat_roughness : hint_range(0.0, 1.0) = 0.1;
uniform float flake_density : hint_range(0.0, 1.0) = 0.3;
uniform float flake_size : hint_range(0.0, 100.0) = 50.0;
uniform float flake_brightness : hint_range(0.0, 2.0) = 0.5;
uniform float fresnel_power : hint_range(0.0, 5.0) = 3.0;
uniform float fresnel_intensity : hint_range(0.0, 1.0) = 0.3;

// Hash function for flake noise
float hash(vec2 p) {
	vec3 p3 = fract(vec3(p.xyx) * 0.1031);
	p3 += dot(p3, p3.yzx + 33.33);
	return fract((p3.x + p3.y) * p3.z);
}

void fragment() {
	// Base paint color
	vec4 paint = base_color;

	// Metallic flake effect (view-dependent sparkles)
	vec2 flake_uv = UV * flake_size;
	vec2 flake_id = floor(flake_uv);
	float flake_val = hash(flake_id);
	if (flake_val < flake_density) {
		float sparkle = hash(flake_id + 0.5);
		vec3 view_dir = normalize(VIEW);
		vec3 normal = normalize(NORMAL);
		float fresnel = pow(1.0 - max(dot(view_dir, normal), 0.0), 2.0);
		paint.rgb += flake_color.rgb * sparkle * flake_brightness * (0.5 + fresnel * 0.5);
	}

	// Fresnel rim light (edge glow)
	vec3 view_dir = normalize(VIEW);
	vec3 normal = normalize(NORMAL);
	float fresnel = pow(1.0 - max(dot(view_dir, normal), 0.0), fresnel_power);
	paint.rgb += base_color.rgb * fresnel * fresnel_intensity;

	// Apply to material
	ALBEDO = paint.rgb;
	METALLIC = metallic;
	ROUGHNESS = roughness;
	CLEARCOAT = clearcoat;
	CLEARCOAT_ROUGHNESS = clearcoat_roughness;
}
