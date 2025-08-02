shader_type canvas_item;

uniform vec3 color_a: source_color;
uniform vec3 color_b: source_color;

uniform float inner_radius = 0.1;
uniform float outer_radius = 1;
uniform float dither_strength = 0.03;
uniform vec4 vignette_color: source_color;

void fragment() {
    float aspect = SCREEN_PIXEL_SIZE.x / SCREEN_PIXEL_SIZE.y;
    vec2 uv = FRAGCOORD.xy * SCREEN_PIXEL_SIZE.x;
    uv -= vec2(0.5, 0.5 * aspect);

    float rot = TIME * 0.02 * radians(45.0);
    float s = sin(rot);
    float c = cos(rot);

    float newX = uv.x * c - uv.y * s;
    float newY = uv.x * s + uv.y * c;

    uv = vec2(newX, newY);

    uv += vec2(0.5, 0.5 * aspect);
    uv.y += 0.5 * (1.0 - aspect);

    vec2 pos = 10.0 * uv;
    vec2 rep = fract(pos);
    float dist = 2.0 * min(min(rep.x, 1.0 - rep.x), min(rep.y, 1.0 - rep.y));
    float squareDist = length((floor(pos) + vec2(0.5)) - vec2(5.0));

    float edge = sin(TIME - squareDist * 0.5) * 0.5 + 0.5;
    edge = (TIME - squareDist * 0.5) * 0.5;
    edge = 2.0 * fract(edge * 0.5);

    float value = fract(dist * 2.0);
    value = mix(value, 1.0 - value, step(1.0, edge));
    edge = pow(abs(1.0 - edge), 2.0);
    value = smoothstep(edge - 0.05, edge, 0.95 * value);
    value += squareDist * 0.1;
	
	vec3 fractal_color = mix(color_a, color_b, value);
	
	float distt = distance(uv, vec2(0.5));
	float vignette = smoothstep(inner_radius, outer_radius, distt) * vignette_color.a;
	float dither = fract(sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453123) * dither_strength;

	vec3 vignette_and_fractal = mix(vignette_color.rgb, fractal_color, vignette + dither);
    COLOR = vec4(vignette_and_fractal, 1.0);
}