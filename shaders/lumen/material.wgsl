// Block surfaces: coloured block light from the [[lights]] in the manifest, blocks that
// shine (lava, glowstone, torches) kept bright so the bloom picks them up, and darker,
// richer surfaces open to the sky while it rains.
override colored_lights: f32 = 0.75;
override emissive_glow: f32 = 0.6;
override wet_surfaces: bool = true;

fn material(input: MaterialInput) -> Surface {
    var albedo = input.albedo.rgb;

    // Rain: open, upward-facing surfaces look wet (darker and a little more saturated).
    if wet_surfaces && !input.translucent && input.fluid == 0u {
        let exposed = smoothstep(0.85, 1.0, input.light.y) * smoothstep(0.5, 0.9, input.normal.y);
        let wet = frame.wetness * exposed * overworld();
        let l = luminance(albedo);
        albedo = mix(albedo, mix(vec3<f32>(l), albedo, 1.25) * 0.78, wet);
    }

    var lit = albedo * input.tint.rgb * input.lightmap;

    // Coloured block light, where block light outshines the sky's.
    let bl = block_light_color(input.position);
    let block_share = input.light.x * (1.0 - input.light.y * daylight());
    let strength = clamp(bl.a, 0.0, 1.0) * block_share * colored_lights;
    let light_rgb = bl.rgb / max(max(bl.r, max(bl.g, bl.b)), 1e-3);
    lit *= mix(vec3<f32>(1.0), light_rgb * 1.15, strength);

    // Blocks that shine stay bright whatever the light around them.
    let shine = input.emission * emissive_glow;
    lit = mix(lit, albedo * input.tint.rgb * 1.1, shine);

    return Surface(vec4<f32>(clamp(lit, vec3<f32>(0.0), vec3<f32>(1.0)), input.albedo.a));
}
