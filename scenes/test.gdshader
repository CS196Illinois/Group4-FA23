shader_type canvas_item;

void fragment() {
	vec2 scrollUV = vec2(UV.x + TIME, UV.y);
	COLOR.rgba = texture(TEXTURE, scrollUV).rgba;
}
