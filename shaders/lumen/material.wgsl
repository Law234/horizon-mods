// Block surfaces: a gentle colour from nearby lights (brightness stays vanilla's), shining
// blocks kept bright so the bloom picks them up, and darker ground open to the sky in rain.
override colored_lights: f32 = 0.35;
override emissive_glow: f32 = 0.35;
override wet_surfaces: bool = true;

fn material(input: MaterialInput) -> Surface {
    var albedo = input.albedo.rgb;

    // Rain: open, upward-facing surfaces look a little darker, as if wet.
    if wet_surfaces && !input.translucent && input.fluid == 0u {
        let exposed = smoothstep(0.85, 1.0, input.light.y) * smoothstep(0.5, 0.9, input.normal.y);
        albedo *= 1.0 - 0.15 * frame.wetness * exposed * overworld();
    }

    var lit = albedo * input.tint.rgb * input.lightmap;

    // Coloured block light, only where block light outshines the sky's. The tint is scaled
    // so it keeps the brightness the same: it changes the hue a little, never darkens.
    let bl = block_light_color(input.position);
    let block_share = input.light.x * (1.0 - input.light.y * max(daylight(), 0.3));
    let strength = clamp(bl.a, 0.0, 1.0) * block_share * colored_lights;
    let hue = bl.rgb / max(luminance(bl.rgb), 1e-3);
    lit *= mix(vec3<f32>(1.0), clamp(hue, vec3<f32>(0.5), vec3<f32>(1.5)), strength * 0.5);

    // Blocks that shine stay bright whatever the light around them.
    lit = mix(lit, albedo * input.tint.rgb, input.emission * emissive_glow);

    return Surface(vec4<f32>(clamp(lit, vec3<f32>(0.0), vec3<f32>(1.0)), input.albedo.a));
}
