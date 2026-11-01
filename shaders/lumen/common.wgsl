// Shared by every stage of Lumen.

fn luminance(c: vec3<f32>) -> f32 {
    return dot(c, vec3<f32>(0.2126, 0.7152, 0.0722));
}

fn overworld() -> f32 {
    return select(0.0, 1.0, frame.dimension == 0);
}

// 1 while the sun is up in the Overworld, fading out around the horizon.
fn daylight() -> f32 {
    return smoothstep(-0.12, 0.12, frame.sun_direction.y) * overworld();
}

// 1 at night in the Overworld.
fn nightness() -> f32 {
    return (1.0 - smoothstep(-0.2, 0.05, frame.sun_direction.y)) * overworld();
}

// 1 when the sun is on the horizon, 0 from about a third of the way up.
fn sun_low() -> f32 {
    return (1.0 - smoothstep(0.0, 0.35, abs(frame.sun_direction.y))) * overworld();
}

// A cheap per-pixel hash, 0..1.
fn hash21(p: vec2<f32>) -> f32 {
    var q = fract(p * vec2<f32>(123.34, 456.21));
    q += dot(q, q + 45.32);
    return fract(q.x * q.y);
}
