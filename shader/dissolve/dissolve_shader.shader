shader_type canvas_item;

uniform sampler2D Mask : hint_white; 
uniform float Clip : hint_range(0.0, 1.0, 0.005) = 1.0;
uniform float EdgeThickness = 0.05;
uniform vec4 EdgeColor : hint_color;

void fragment() {
    float AlphaCut = 1.0;
	vec3 color = textureLod(TEXTURE, UV, 0.0).rgb;

    //First we color the material
    if (texture(Mask,UV).r  < Clip) {
        color = EdgeColor.rgb
    }
    //This is the transparent cut, it has to be a little above the color
    //to get the edge
    if (texture(Mask,UV).r +EdgeThickness < Clip) {
        AlphaCut = 0.0;
    }
    COLOR = vec4(color, AlphaCut);
}