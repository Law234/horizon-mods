// Light shafts (half resolution): march from each pixel toward the sun and count how much
// open sky lies on the way, so sunlight streams past trees and hills. The final pass tints
// and adds the result.
override light_shafts: f32 = 0.5;

fn post(input: PostInput) -> vec4<f32> {
    if light_shafts <= 0.0 || frame.sun_direction.y < -0.05 || overworld() == 0.0 {
        return vec4<f32>(0.0);
    }
    // Where the sun is on the screen; nothing when it is behind the camera.
    let clip = frame.projection * (frame.view * vec4<f32>(frame.sun_direction * 100.0, 1.0));
    if clip.w <= 0.0 {
        return vec4<f32>(0.0);
    }
    let sun = vec2<f32>(clip.x / clip.w * 0.5 + 0.5, 0.5 - clip.y / clip.w * 0.5);

    // Sixteen steps toward the sun (at most half the screen), started at a random offset per
    // pixel so the steps don't show as bands.
    let steps = 16.0;
    var to_sun = sun - input.uv;
    let span = length(to_sun);
    to_sun *= min(span, 0.5) / max(span, 1e-4);
    let step = to_sun / steps;
    var uv = input.uv + step * hash21(input.pixel);
    var sum = 0.0;
    var weight = 1.0;
    for (var i = 0; i < 16; i++) {
        let inside = uv.x >= 0.0 && uv.y >= 0.0 && uv.x <= 1.0 && uv.y <= 1.0;
        if inside && depth_at(uv) == 0.0 {
            sum += weight;
        }
        weight *= 0.93;
        uv += step;
    }
    // Strongest near the sun, fading over most of the screen.
    let aspect = frame.resolution.x / frame.resolution.y;
    let near_sun = 1.0 - smoothstep(0.0, 0.8, length((input.uv - sun) * vec2<f32>(aspect, 1.0)));
    return vec4<f32>(vec3<f32>(sum / steps * near_sun), 1.0);
}
