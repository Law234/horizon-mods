// Block surfaces: real shade from the sun (and the moon at night) with warm sunlight and cool
// shadows, a gentle colour from nearby lights, shining blocks kept bright so the bloom picks
// them up, darker ground open to the sky in rain, and water that mirrors the world.
override shadows: f32 = 0.6;
override reflections: f32 = 0.8;
override colored_lights: f32 = 0.35;
override emissive_glow: f32 = 0.35;
override wet_surfaces: bool = true;

// How much of the sun (or moon) reaches a point: 1 lit, 0 in shade. Four filtered taps
// around the point soften the edge.
fn sun_visibility(position: vec3<f32>, normal: vec3<f32>) -> f32 {
    if frame.has_shadow == 0u {
        return 1.0;
    }
    // Push the point off its surface so it doesn't shade itself (leaves speckle otherwise).
    let texel = max(frame.shadow_center_texel, 0.03);
    let p = shadow_position(position + normal * texel * 3.0);
    if p.x < 0.0 || p.y < 0.0 || p.x > 1.0 || p.y > 1.0 || p.z > 1.0 {
        return 1.0;
    }
    let r = 1.2 / frame.shadow_resolution;
    let z = p.z - 0.0005;
    var vis = textureSampleCompareLevel(shadow_map, shadow_sampler, p.xy + vec2<f32>(-r, -0.4 * r), z);
    vis += textureSampleCompareLevel(shadow_map, shadow_sampler, p.xy + vec2<f32>(r, 0.4 * r), z);
    vis += textureSampleCompareLevel(shadow_map, shadow_sampler, p.xy + vec2<f32>(-0.4 * r, r), z);
    vis += textureSampleCompareLevel(shadow_map, shadow_sampler, p.xy + vec2<f32>(0.4 * r, -r), z);
    return vis * 0.25;
}

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

    // Sun and moon: faces turned away and points something else blocks fall into a cool
    // shade, the rest gets a little warm sunlight. Only the sky's share of the light is
    // shaded (torchlight is not), the moon's shade is softer, and rain all but hides it.
    if shadows > 0.0 {
        let facing = smoothstep(0.0, 0.2, dot(input.normal, frame.light_direction));
        var sun = facing;
        if facing > 0.0 {
            sun *= sun_visibility(input.position, input.normal);
        }
        // Past the shadow map (and on distant terrain, whose normals can't be trusted) the
        // shading fades out, back to vanilla's.
        let near = 1.0 - smoothstep(0.75, 1.0, length(input.position.xz) / max(frame.shadow_distance, 1.0));
        let sky_share = input.light.y * (1.0 - block_share);
        let reach = shadows * sky_share * overworld() * (1.0 - 0.8 * frame.rain)
            * (daylight() + 0.5 * nightness()) * near;
        lit *= mix(vec3<f32>(1.0), vec3<f32>(0.45, 0.52, 0.66), reach * (1.0 - sun));
        lit *= mix(vec3<f32>(1.0), vec3<f32>(1.08, 1.03, 0.94), reach * sun * daylight());
    }

    // Blocks that shine stay bright whatever the light around them.
    lit = mix(lit, albedo * input.tint.rgb, input.emission * emissive_glow);

    // Water open to the sky mirrors the world, most at grazing angles (Fresnel), and grows
    // more opaque where it does.
    var alpha = input.albedo.a;
    if reflections > 0.0 && input.fluid == 1u && input.face == 1u && frame.has_reflection == 1u {
        let view = normalize(-input.position);
        let fresnel = 0.02 + 0.98 * pow(1.0 - clamp(view.y, 0.0, 1.0), 5.0);
        let mirror = textureSampleLevel(reflection, reflection_sampler, input.screen, 0.0).rgb;
        let k = clamp(fresnel * reflections * input.light.y, 0.0, 0.9);
        lit = mix(lit, mirror, k);
        alpha = mix(alpha, 1.0, k);
    }

    return Surface(vec4<f32>(clamp(lit, vec3<f32>(0.0), vec3<f32>(1.0)), alpha));
}
