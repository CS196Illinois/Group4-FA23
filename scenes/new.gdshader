shader_type canvas_item;

uniform sampler2D distortionTexture;

void fragment() {
	vec2 distortion = SCREEN_UV + texture(distortionTexture, UV).r * 0.05;
	vec4 pixelColor = texture(TEXTURE, distortion);
	COLOR = pixelColor;
}
