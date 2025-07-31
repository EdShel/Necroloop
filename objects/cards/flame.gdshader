shader_type canvas_item;

uniform sampler3D noise;
uniform float smooth_border: hint_range(0.0, 1.0, 0.01) = 0.5;
uniform float smooth_border_from: hint_range(0.0, 1.0, 0.01) = 1.0;
uniform vec4 color_a: source_color;
uniform vec4 color_b: source_color;

void fragment() {
	float frame_alpha = texture(TEXTURE, UV).a;
	vec3 noise_color = texture(noise, vec3(UV, fract(TIME * 0.4))).rgb;
	float noise_value = noise_color.r;
	float value = noise_value
		* smoothstep(smooth_border_from, smooth_border, 2.0 * abs(UV.x - 0.5))
		* smoothstep(smooth_border_from, smooth_border, 2.0 * abs(UV.y - 0.5))
		;
	value = pow(value, 1.5);
	float alpha = value * frame_alpha;
	vec4 mixed_color = mix(color_a, color_b, alpha);
	COLOR = vec4(mixed_color.rgb, mixed_color.a * alpha);
}
