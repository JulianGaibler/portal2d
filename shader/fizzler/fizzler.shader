// Author: @patriciogv - 2015
// Title: Ridge

shader_type canvas_item;

uniform vec2 u_resolution;

// Some useful functions
vec3 mod289_vec3(vec3 x) { return x - floor(x * (1.0 / 289.0)) * 289.0; }
vec2 mod289_vec2(vec2 x) { return x - floor(x * (1.0 / 289.0)) * 289.0; }
vec3 permute(vec3 x) { return mod289_vec3(((x*34.0)+1.0)*x); }

uniform vec4 background : hint_color;
uniform vec4 foreground : hint_color;
uniform int OCTAVES = 4;
//
// Description : GLSL 2D simplex noise function
//      Author : Ian McEwan, Ashima Arts
//  Maintainer : ijm
//     Lastmod : 20110822 (ijm)
//     License :
//  Copyright (C) 2011 Ashima Arts. All rights reserved.
//  Distributed under the MIT License. See LICENSE file.
//  https://github.com/ashima/webgl-noise
//
float snoise(vec2 v) {

    // Precompute values for skewed triangular grid
    const vec4 C = vec4(0.211324865405187,
                        // (3.0-sqrt(3.0))/6.0
                        0.366025403784439,
                        // 0.5*(sqrt(3.0)-1.0)
                        -0.577350269189626,
                        // -1.0 + 2.0 * C.x
                        0.024390243902439);
                        // 1.0 / 41.0

    // First corner (x0)
    vec2 i  = floor(v + dot(v, C.yy));
    vec2 x0 = v - i + dot(i, C.xx);

    // Other two corners (x1, x2)
    vec2 i1 = vec2(0.0);
    i1 = (x0.x > x0.y)? vec2(1.0, 0.0):vec2(0.0, 1.0);
    vec2 x1 = x0.xy + C.xx - i1;
    vec2 x2 = x0.xy + C.zz;

    // Do some permutations to avoid
    // truncation effects in permutation
    i = mod289_vec2(i);
    vec3 p = permute(
            permute( i.y + vec3(0.0, i1.y, 1.0))
                + i.x + vec3(0.0, i1.x, 1.0 ));

    vec3 m = max(0.5 - vec3(
                        dot(x0,x0),
                        dot(x1,x1),
                        dot(x2,x2)
                        ), 0.0);

    m = m*m ;
    m = m*m ;

    vec3 x = 2.0 * fract(p * C.www) - 1.0;
    vec3 h = abs(x) - 0.5;
    vec3 ox = floor(x + 0.5);
    vec3 a0 = x - ox;

    // Normalise gradients implicitly by scaling m
    // Approximation of: m *= inversesqrt(a0*a0 + h*h);
    m *= 1.79284291400159 - 0.85373472095314 * (a0*a0+h*h);

    // Compute final noise value at P
    vec3 g = vec3(0.0);
    g.x  = a0.x  * x0.x  + h.x  * x0.y;
    g.yz = a0.yz * vec2(x1.x,x2.x) + h.yz * vec2(x1.y,x2.y);
    return 130.0 * dot(m, g);
}

// Ridged multifractal
// See "Texturing & Modeling, A Procedural Approach", Chapter 12
float ridge(float h, float offset) {
    h = abs(h);     // create creases
    h = offset - h; // invert so creases are at top
    h = h * h;      // sharpen creases
    return h;
}

float ridgedMF(vec2 p, float time) {
    float lacunarity = 2.0;
    float gain = 0.8;
    float offset = 0.8;

    float sum = 0.0;
    float freq = 0.2, amp = 0.5;
    float prev = 0.0;
    for(int i=0; i < OCTAVES; i++) {
        float n = ridge(snoise(p*freq+time * 0.05), offset);
        sum += n*amp;
        sum += n*amp*prev;  // scale by previous octave
        prev = n;
        freq *= lacunarity;
        amp *= gain;
    }
    return sum;
}

void fragment() {
    vec2 st = UV / u_resolution.xy * 2.0;

    float a = ridgedMF(st*3.0, TIME);

    vec2 bl = smoothstep(0.0, 0.2 * u_resolution.y ,UV);       // bottom-left
    vec2 tr = smoothstep(0.0, 0.2 * u_resolution.y ,1.0-UV);   // top-right
    float border_y = 1.0 -  bl.y * tr.y;
    float border_x = bl.x * tr.x;

    vec3 color = mix(background.rgb, foreground.rgb, max(a, border_y * 1.0));

    float trans = max(a, border_y*0.5) * 0.7 + 0.15;

    COLOR = vec4(color * 10.0, trans*0.15);
}
