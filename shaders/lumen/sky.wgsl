// A deeper sky overhead, a warm band around a low sun with a rosy belt opposite it,
// and a cool, darker blue at night. Rain greys it all out.
override sky_glow: f32 = 0.5;

fn sky(input: SkyInput) -> vec4<f32> {
    let d = input.direction;
    var c = input.color.rgb;
    let clear = 1.0 - frame.rain * 0.85;
    let up = smoothstep(0.0, 1.0, d.y);
    let horizon = 1.0 - smoothstep(0.0, 0.35, abs(d.y));

    // Day: a richer blue toward the zenith.
    let day = daylight() * clear;
    c = mix(c, c * vec3<f32>(0.72, 0.86, 1.08), up * day * 0.3);

    // Sunrise and sunset: gold around the sun, a soft pink belt opposite it.
    let sun_flat = normalize(vec3<f32>(frame.sun_direction.x, 0.0, frame.sun_direction.z) + vec3<f32>(1e-4, 0.0, 0.0));
    let toward = max(dot(normalize(vec3<f32>(d.x, 0.0, d.z) + vec3<f32>(1e-4, 0.0, 0.0)), sun_flat), 0.0);
    let away = max(-dot(normalize(vec3<f32>(d.x, 0.0, d.z) + vec3<f32>(1e-4, 0.0, 0.0)), sun_flat), 0.0);
    let halo = pow(max(dot(d, frame.sun_direction), 0.0), 8.0);
    let low = sun_low() * clear * sky_glow;
    c += vec3<f32>(1.0, 0.5, 0.18) * (halo * 0.7 + horizon * toward * toward * 0.45) * low;
    c += vec3<f32>(0.55, 0.32, 0.45) * horizon * away * 0.22 * low;

    // Night: cool and deep overhead, a faint glow along the horizon.
    let night = nightness();
    c = mix(c, c * vec3<f32>(0.55, 0.7, 1.15) + vec3<f32>(0.0, 0.006, 0.02), night * (0.25 + 0.25 * up));
    c += vec3<f32>(0.04, 0.06, 0.12) * horizon * night * clear * sky_glow;

    return vec4<f32>(max(c, vec3<f32>(0.0)), input.color.a);
}
