// The finished picture, kept close to vanilla: a little distant haze, bloom on lights,
// cool moonlit shadows at night, golden light only around sunrise and sunset, a touch of
// contrast and saturation, a light vignette, and optional film grain and letterbox bars.
override bloom: f32 = 0.25;
override haze: f32 = 0.15;
override moonlight: f32 = 0.5;
override warmth: f32 = 0.3;
override contrast: f32 = 1.05;
override saturation: f32 = 1.05;
override vignette: f32 = 0.12;
override grain: f32 = 0.0;
override letterbox: bool = false;

fn post(input: PostInput) -> vec4<f32> {
    let uv = input.uv;
    var c = input.color.rgb;
    let depth = depth_at(uv);

    // Haze: only far land, toward vanilla's own fog colour.
    if haze > 0.0 && depth > 0.0 && frame.eye_in == 0u {
        let dist = length(view_position(uv, depth));
        let reach = max(frame.render_distance, 32.0);
        let amount = smoothstep(0.3, 1.0, dist / reach) * haze * overworld();
        c = mix(c, frame.fog_color, clamp(amount, 0.0, 0.35));
    }

    // Bloom on lights.
    if bloom > 0.0 {
        c += textureSampleLevel(bloom_b, linear_sampler, uv, 0.0).rgb * bloom;
    }

    // Night outdoors: cool the shadows toward moonlit blue and lift them a little, so the
    // night reads blue instead of black. Torch-lit surfaces are brighter and keep their warmth.
    let outdoors = frame.eye_light_smooth.y * select(0.0, 1.0, frame.eye_in == 0u);
    let night = moonlight * nightness() * outdoors * select(0.0, 1.0, depth > 0.0);
    if night > 0.0 {
        let shadow = 1.0 - smoothstep(0.0, 0.35, luminance(c));
        c = mix(c, vec3<f32>(luminance(c)) * vec3<f32>(0.8, 0.95, 1.3), 0.5 * night * shadow);
        c += vec3<f32>(0.012, 0.02, 0.045) * night * shadow;
    }

    // Contrast that pushes the highlights and fades out toward black, so dark scenes (night,
    // caves, underwater) keep their shadows instead of sinking into mud; then saturation.
    c += (c - 0.3) * (contrast - 1.0) * smoothstep(vec3<f32>(0.0), vec3<f32>(0.3), c);
    let l = luminance(c);
    c = mix(vec3<f32>(l), c, saturation);

    // Golden light only while the sun is low, and only out under the sky.
    let golden = warmth * sun_low() * daylight() * (1.0 - frame.rain) * outdoors;
    c *= mix(vec3<f32>(1.0), vec3<f32>(1.08, 1.0, 0.9), golden);

    // Vignette: only the far corners.
    let aspect = frame.resolution.x / frame.resolution.y;
    let r = length((uv - 0.5) * vec2<f32>(aspect, 1.0)) / length(vec2<f32>(aspect, 1.0) * 0.5);
    c *= 1.0 - smoothstep(0.6, 1.3, r) * vignette;

    // Film grain (off by default).
    if grain > 0.0 {
        c += (hash21(input.pixel + f32(frame.frame_index % 64u) * 17.0) - 0.5) * grain;
    }

    // Letterbox: 2.39:1 bars (off by default).
    if letterbox {
        let bar = (1.0 - min(aspect / 2.39, 1.0)) * 0.5;
        if uv.y < bar || uv.y > 1.0 - bar {
            c = vec3<f32>(0.0);
        }
    }

    return vec4<f32>(clamp(c, vec3<f32>(0.0), vec3<f32>(1.0)), input.color.a);
}
