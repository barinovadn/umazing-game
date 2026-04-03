shader_type canvas_item;

uniform vec4 key_color : source_color = vec4(0.02, 0.05, 0.07, 1.0);
uniform float threshold = 0.22;

void fragment() {
	vec4 tex = texture(TEXTURE, UV);

	if (tex.a >= 0.01 && distance(tex.rgb, key_color.rgb) <= threshold) {
		tex.a = 0.0;
	}

	COLOR = tex;
}
