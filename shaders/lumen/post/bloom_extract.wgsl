// Bloom, step 1 (half resolution): keep only what looks like a light and blur it sideways:
// the sun, and land that is both very bright and strongly coloured (lava, flames, glowstone,
// redstone). White and pale blocks and the bright daytime sky are left out, however bright.
override bloom: f32 = 0.25;

fn bright(at: vec2<f32>) -> vec3<f32> {
    let uv = clamp(at, vec2<f32>(0.0), vec2<f32>(1.0));
    let c = textureSampleLevel(previous, linear_sampler, uv, 0.0).rgb;
    let peak = max(c.r, max(c.g, c.b));
    var glow = 0.0;
    if depth_at(uv) == 0.0 {
        // The sun's disc (any depth gives the pixel's view ray).
        let ray = normalize(view_position(uv, 0.5));
        glow = smoothstep(0.985, 0.995, dot(ray, frame.sun_direction)) * smoothstep(0.6, 0.95, peak);
    } else {
        let chroma = (peak - min(c.r, min(c.g, c.b))) / max(peak, 1e-3);
        glow = smoothstep(0.8, 0.98, peak) * smoothstep(0.25, 0.6, chroma);
        // By day out under the sky, sunlit orange and yellow blocks would glow too: keep it faint.
        glow *= 1.0 - 0.85 * daylight() * frame.eye_light_smooth.y;
    }
    return c * glow;
}

fn post(input: PostInput) -> vec4<f32> {
    if bloom <= 0.0 {
        return vec4<f32>(0.0);
    }
    // Same look at any resolution: offsets scale with the picture's height.
    let step = vec2<f32>(frame.resolution.y / 720.0 * 2.5 / frame.resolution.x, 0.0);
    var sum = bright(input.uv) * 0.2270;
    sum += (bright(input.uv + step * 1.3846) + bright(input.uv - step * 1.3846)) * 0.3162;
    sum += (bright(input.uv + step * 3.2308) + bright(input.uv - step * 3.2308)) * 0.0703;
    return vec4<f32>(sum, 1.0);
}
