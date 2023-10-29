shader_type canvas_item;
uniform vec2 scrollRate = vec2(0.1, 0.1);
void fragment() {
	vec2 scrollUV = UV + texture(TEXTURE, UV + scrollRate * TIME).a * 0.05;
	COLOR.rgba = texture(TEXTURE, scrollUV).rgba;
}
