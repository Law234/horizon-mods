// A deeper sky overhead, a warm glow around a low sun with a rosy belt opposite it,
// and a deep blue (not black) at night. Rain greys it all out.
override sky_glow: f32 = 0.5;

fn sky(input: SkyInput) -> vec4<f32> {
    let d = input.direction;
    var c = input.color.rgb;
    let clear = 1.0 - frame.rain * 0.85;
    let up = smoothstep(0.0, 1.0, d.y);
    let horizon = 1.0 - smoothstep(0.0, 0.35, abs(d.y));

    // Day: a richer blue toward the zenith (vanilla's blue is already at full, so only red
    // and green come down).
    let day = daylight() * clear;
    c = mix(c, c * vec3<f32>(0.8, 0.9, 1.0), up * day * 0.3);

    // Sunrise and sunset: gold around the sun, a soft pink belt opposite it. The glow is
    // blended in rather than added, so the blue around it turns warm instead of grey-mauve.
    let sun_flat = normalize(vec3<f32>(frame.sun_direction.x, 0.0, frame.sun_direction.z) + vec3<f32>(1e-4, 0.0, 0.0));
    let toward = max(dot(normalize(vec3<f32>(d.x, 0.0, d.z) + vec3<f32>(1e-4, 0.0, 0.0)), sun_flat), 0.0);
    let away = max(-dot(normalize(vec3<f32>(d.x, 0.0, d.z) + vec3<f32>(1e-4, 0.0, 0.0)), sun_flat), 0.0);
    let facing = max(dot(d, frame.sun_direction), 0.0);
    let halo = pow(facing, 10.0);
    let low = sun_low() * clear * sky_glow;
    c = mix(c, vec3<f32>(1.0, 0.7, 0.4), clamp(halo * (0.35 + 0.5 * horizon) * low, 0.0, 1.0));
    c += vec3<f32>(0.5, 0.26, 0.1) * pow(facing, 48.0) * low;
    c += vec3<f32>(1.0, 0.5, 0.18) * horizon * toward * toward * 0.4 * low;
    c += vec3<f32>(0.55, 0.32, 0.45) * horizon * away * 0.22 * low;

    // Night: a deep blue overhead instead of black, and a faint glow along the horizon.
    let night = nightness() * clear;
    c = max(c, vec3<f32>(0.01, 0.016, 0.04) * night * sky_glow * 2.0 * (0.6 + 0.4 * up));
    c += vec3<f32>(0.04, 0.06, 0.12) * horizon * night * sky_glow;

    return vec4<f32>(max(c, vec3<f32>(0.0)), input.color.a);
}
