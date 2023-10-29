shader_type canvas_item;

uniform sampler2D NOISE_PATTERN;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture;

void fragment() {
	// Place fragment code here.
	vec2 distortedUV = SCREEN_UV + texture(TEXTURE, UV).r * 0.05;
	vec4 screenColor = texture(SCREEN_TEXTURE, distortedUV);
	COLOR = screenColor;
}
