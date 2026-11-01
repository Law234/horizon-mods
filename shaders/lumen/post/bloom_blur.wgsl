// Bloom, step 2 (half resolution): blur step 1 up and down, a little wider.
override bloom: f32 = 0.45;

fn tap(uv: vec2<f32>) -> vec3<f32> {
    return textureSampleLevel(bloom_a, linear_sampler, uv, 0.0).rgb;
}

fn post(input: PostInput) -> vec4<f32> {
    if bloom <= 0.0 {
        return vec4<f32>(0.0);
    }
    let step = vec2<f32>(0.0, 2.5 / 720.0);
    var sum = tap(input.uv) * 0.2270;
    sum += (tap(input.uv + step * 1.3846) + tap(input.uv - step * 1.3846)) * 0.3162;
    sum += (tap(input.uv + step * 3.2308) + tap(input.uv - step * 3.2308)) * 0.0703;
    return vec4<f32>(sum, 1.0);
}
