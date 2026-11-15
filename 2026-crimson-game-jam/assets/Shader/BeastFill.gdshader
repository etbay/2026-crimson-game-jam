
shader_type canvas_item;
render_mode unshaded;

// Main Beast Bar colors
uniform vec4 base_color : source_color = vec4(0.55, 0.12, 0.85, 1.0);
uniform vec4 glow_color : source_color = vec4(1.0, 0.7, 1.0, 1.0);


// Controlled by hud.gd
uniform bool overflowing = false;

// Animation settings
uniform float glow_speed = 150.0;
uniform float glow_spacing = 110.0;
uniform float glow_width = 20.0;
uniform float glow_strength = 1.5;
uniform float opacity : hint_range(0.0, 1.0) = 0.6;

void fragment() {
    // Subtle pulsing effect
    float pulse = 1.0 + sin(TIME * 3.0) * 0.1;

    vec3 color = base_color.rgb * pulse * 1.3;

    if (overflowing) {
        // Moving diagonal streaks
        float position = FRAGCOORD.x
            + FRAGCOORD.y * 0.5
            - TIME * glow_speed;

        // Repeat streaks along the bar
        float distance_to_streak = abs(
            mod(position + glow_spacing * 0.5, glow_spacing)
            - glow_spacing * 0.5
        );

        // Bright center of each streak
        float streak = 1.0 - smoothstep(
            0.0,
            glow_width,
            distance_to_streak
        );

        // Softer light around each streak
        float halo = 1.0 - smoothstep(
            glow_width,
            glow_width * 3.0,
            distance_to_streak
        );

        // Add glowing energy
        color = mix(
            color,
            glow_color.rgb * glow_strength,
            streak * 0.25
        );

        color += glow_color.rgb * halo * 0.08;
    }

    COLOR = vec4(color, opacity);
}
