shader_type canvas_item;

uniform sampler2D distortionTexture : repeat_enable;
uniform vec2 scrollRate = vec2(0.1, 0.1);
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment() {
	vec2 distortion = SCREEN_UV + texture(distortionTexture, UV + scrollRate * TIME).b * 0.02;
	vec4 pixelColor = texture(SCREEN_TEXTURE, distortion);
	COLOR = pixelColor;
}
