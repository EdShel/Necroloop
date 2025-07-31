shader_type canvas_item;

uniform vec4 outline_color: source_color;

void fragment() {
	float source_alpha = texture(TEXTURE, UV).a;
	COLOR = vec4(outline_color.rgb, outline_color.a * source_alpha);
}
