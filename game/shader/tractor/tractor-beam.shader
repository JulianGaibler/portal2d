shader_type canvas_item;

uniform sampler2D helix_texture : hint_white; 
uniform sampler2D lines_texture : hint_white;
uniform vec4 color_low : hint_color;
uniform vec4 color_high : hint_color;
uniform float width;
uniform float speed = 1.0;
uniform bool up = true;

const float PI = 3.14159265359;

void fragment()
{
  float aperture = 178.0;
  float apertureHalf = 0.5 * aperture * (PI / 180.0);
  float maxFactor = sin(apertureHalf);
  
  vec2 fake_uv = vec2(0.5, UV.y);

  vec2 uv;
  vec2 xy = 2.0 * fake_uv.xy - 1.0;
  float d = length(xy);
  if (d < (2.0-maxFactor))
  {
    d = length(xy * maxFactor);
    float z = sqrt(1.0 - d * d);
    float r = atan(d, z) / PI;
    float phi = atan(xy.y, xy.x);
    
    uv.x = r * cos(phi) + 0.5;
    uv.y = r * sin(phi) + 0.5;
  }
  else
  {
    uv = fake_uv.xy;
  }

  float uvx = UV.x / width * 0.75;
  float uvy = up ? uv.y : 1.0 - uv.y;

  float a_beam1 = textureLod(helix_texture, vec2(uvx - TIME * 0.1 * speed, uvy), 0.0).r;
  float a_beam2 = textureLod(helix_texture, vec2(uvx + 0.2 - TIME * 0.1 * speed, uvy), 0.0).r;
  float a_lines = textureLod(lines_texture, vec2(uvx - TIME * 0.5, UV.y), 0.0).r;

  COLOR.rgb = max(mix(color_low.rgb, color_high.rgb * 3.0, a_lines), max(mix(color_low.rgb, color_high.rgb * 3.0, a_beam1), mix(color_low.rgb, color_high.rgb * 3.0, a_beam2)));

  COLOR.a = max(a_lines * 2.0, a_beam1) * 0.2 + 0.1;
}