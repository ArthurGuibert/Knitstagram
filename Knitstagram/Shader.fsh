precision mediump float;

uniform sampler2D u_texture;
uniform sampler2D u_texture2;
uniform sampler2D u_texture3;

uniform float u_knot_size;

varying mediump vec2 v_tex_coord;

vec4 pixelAt(vec2 position) {
    vec2 coord;
    coord.x = floor(position.x * 80.0 * u_knot_size) / (80.0 * u_knot_size);
    coord.y = floor(position.y * 40.0 * u_knot_size) / (40.0 * u_knot_size);

    vec2 pattern_coord = vec2(position.x * 2.5 * u_knot_size, position.y * 1.5 * u_knot_size);
    float pattern = clamp(texture2D(u_texture2, pattern_coord).r + 0.1, 0.1, 1.0);
    
    vec4 color = texture2D(u_texture, coord) * pattern;
    color.r = clamp(color.r, 0.0, 1.0);
    color.g = clamp(color.g, 0.0, 1.0);
    color.b = clamp(color.b, 0.0, 1.0);
    color.a = 1.0;

    return color;
}

vec4 blur(vec2 coord, float size) {
    vec4 blur = vec4(0.0);
    
    // Y blurring
    blur += pixelAt(vec2(coord.x, coord.y - 4.0 * size)) * 0.05;
    blur += pixelAt(vec2(coord.x, coord.y - 3.0 * size)) * 0.09;
    blur += pixelAt(vec2(coord.x, coord.y - 2.0 * size)) * 0.12;
    blur += pixelAt(vec2(coord.x, coord.y - 1.0 * size)) * 0.15;
    blur += pixelAt(vec2(coord.x, coord.y - 0.0 * size)) * 0.16;
    blur += pixelAt(vec2(coord.x, coord.y + 1.0 * size)) * 0.15;
    blur += pixelAt(vec2(coord.x, coord.y + 2.0 * size)) * 0.12;
    blur += pixelAt(vec2(coord.x, coord.y + 3.0 * size)) * 0.09;
    blur += pixelAt(vec2(coord.x, coord.y + 4.0 * size)) * 0.05;
    
    // X blurring
    blur += pixelAt(vec2(coord.x - 4.0 * size, coord.y)) * 0.05;
    blur += pixelAt(vec2(coord.x - 3.0 * size, coord.y)) * 0.09;
    blur += pixelAt(vec2(coord.x - 2.0 * size, coord.y)) * 0.12;
    blur += pixelAt(vec2(coord.x - 1.0 * size, coord.y)) * 0.15;
    blur += pixelAt(vec2(coord.x - 0.0 * size, coord.y)) * 0.16;
    blur += pixelAt(vec2(coord.x + 1.0 * size, coord.y)) * 0.15;
    blur += pixelAt(vec2(coord.x + 2.0 * size, coord.y)) * 0.12;
    blur += pixelAt(vec2(coord.x + 3.0 * size, coord.y)) * 0.09;
    blur += pixelAt(vec2(coord.x + 4.0 * size, coord.y)) * 0.05;
    
    return blur * 0.5;
}

void main()
{
    // Blur size is progressive
    float size = 2.0 / 1024.0 * clamp(v_tex_coord.x + 0.2, 0.0, 1.0);
    vec4 blurred = blur(v_tex_coord, size);
    
    // Two levels of noise (grain + wool variations)
    vec4 noise_large = texture2D(u_texture3, v_tex_coord * 0.15) * 0.07;
    vec4 noise_small = texture2D(u_texture3, v_tex_coord * 2.0) * 0.1;

    gl_FragColor = blurred + noise_large + noise_small;
}

