
shader_type canvas_item;
render_mode unshaded;

uniform vec4 glow_color : source_color = vec4(0.6, 0.2, 1.0, 0.4);

uniform vec2 rect_size = vec2(300.0, 60.0);
uniform float padding = 18.0;

void fragment() {
    vec2 pixel_pos = UV * rect_size;

    // Boundaries of the actual fill
    vec2 min_corner = vec2(padding);
    vec2 max_corner = rect_size - vec2(padding);

    // Find distance from the fill
    vec2 closest = clamp(
        pixel_pos,
        min_corner,
        max_corner
    );

    float distance_to_fill = length(pixel_pos - closest);

    // Fade the glow outward
    float glow = 1.0 - smoothstep(
        0.0,
        padding,
        distance_to_fill
    );

    // Make the fade softer
    glow = pow(glow, 1.5);

    COLOR = vec4(
        glow_color.rgb,
        glow_color.a * glow
    );
}
