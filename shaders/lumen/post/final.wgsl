// The finished picture: distant haze, bloom, a filmic curve, the colour grade
// (golden hours, moonlit nights), then vignette, film grain and optional letterbox bars.
override bloom: f32 = 0.45;
override haze: f32 = 0.35;
override warmth: f32 = 0.5;
override contrast: f32 = 1.1;
override saturation: f32 = 1.12;
override vignette: f32 = 0.3;
override grain: f32 = 0.02;
override letterbox: bool = false;

fn post(input: PostInput) -> vec4<f32> {
    let uv = input.uv;
    var c = input.color.rgb;
    let depth = depth_at(uv);

    // Haze: distant land fades softly toward the fog colour, more by day and in rain.
    if haze > 0.0 && depth > 0.0 && frame.eye_in == 0u {
        let dist = length(view_position(uv, depth));
        let reach = max(frame.render_distance, 32.0);
        let amount = (1.0 - exp(-dist / reach * 2.2)) * haze * (0.35 + 0.65 * daylight()) * (1.0 + frame.rain);
        let tint = mix(frame.fog_color, vec3<f32>(0.62, 0.74, 0.92), 0.3 * daylight());
        c = mix(c, tint, clamp(amount * overworld() * 0.6, 0.0, 0.6));
    }

    // Bloom.
    if bloom > 0.0 {
        let glow = textureSampleLevel(bloom_b, linear_sampler, uv, 0.0).rgb;
        c += glow * bloom * 1.6;
    }

    // Filmic curve: a soft shoulder (bright colours roll off instead of clipping) and contrast around mid-grey.
    c = c / (1.0 + 0.3 * c) * 1.3;
    c = clamp((c - 0.5) * contrast + 0.5, vec3<f32>(0.0), vec3<f32>(1.0));
    c = c * c * (3.0 - 2.0 * c) * 0.25 + c * 0.75;

    // Grade: golden light when the sun is low, cool moonlight at night, warm highlights and cool shadows.
    let outdoors = smoothstep(0.3, 0.9, frame.eye_light_smooth.y);
    let golden = warmth * mix(0.25, 1.0, sun_low()) * daylight() * (1.0 - frame.rain * 0.7);
    c *= mix(vec3<f32>(1.0), vec3<f32>(1.1, 1.0, 0.84), golden);
    c *= mix(vec3<f32>(1.0), vec3<f32>(0.86, 0.94, 1.12), nightness() * outdoors * 0.8);
    let l = luminance(c);
    c += (vec3<f32>(0.03, 0.015, -0.02) * smoothstep(0.5, 1.0, l) + vec3<f32>(-0.01, 0.0, 0.02) * (1.0 - smoothstep(0.0, 0.4, l))) * warmth;
    c = mix(vec3<f32>(luminance(c)), c, saturation);

    // Vignette.
    let aspect = frame.resolution.x / frame.resolution.y;
    let r = length((uv - 0.5) * vec2<f32>(aspect, 1.0)) / length(vec2<f32>(aspect, 1.0) * 0.5);
    c *= 1.0 - smoothstep(0.5, 1.15, r) * vignette;

    // Film grain, changing every frame.
    if grain > 0.0 {
        let n = hash21(input.pixel + f32(frame.frame_index % 64u) * 17.0) - 0.5;
        c += n * grain;
    }

    // Letterbox: 2.39:1 bars, off by default.
    if letterbox {
        let target_h = aspect / 2.39;
        let bar = (1.0 - min(target_h, 1.0)) * 0.5;
        if uv.y < bar || uv.y > 1.0 - bar {
            c = vec3<f32>(0.0);
        }
    }

    return vec4<f32>(clamp(c, vec3<f32>(0.0), vec3<f32>(1.0)), input.color.a);
}
