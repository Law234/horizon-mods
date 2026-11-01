// Bloom, step 1 (half resolution): keep the brightest parts of the picture and blur
// them sideways. The bright daytime sky is mostly left out so the bloom stays on lights.
override bloom: f32 = 0.25;

fn bright(uv: vec2<f32>) -> vec3<f32> {
    let c = textureSampleLevel(previous, linear_sampler, uv, 0.0).rgb;
    let sky = select(1.0, 0.0, depth_at(uv) == 0.0);
    return c * smoothstep(0.88, 1.0, luminance(c)) * sky;
}

fn post(input: PostInput) -> vec4<f32> {
    if bloom <= 0.0 {
        return vec4<f32>(0.0);
    }
    // Same look at any resolution: offsets scale with the picture's height.
    let step = vec2<f32>(frame.resolution.y / 720.0 * 2.0 / frame.resolution.x, 0.0);
    var sum = bright(input.uv) * 0.2270;
    sum += (bright(input.uv + step * 1.3846) + bright(input.uv - step * 1.3846)) * 0.3162;
    sum += (bright(input.uv + step * 3.2308) + bright(input.uv - step * 3.2308)) * 0.0703;
    return vec4<f32>(sum, 1.0);
}
