# Lumen Ultra

The heavier sibling of [Lumen](../lumen) for [Horizon](https://github.com/horizon-rust/horizon), in Horizon's own
shader format (WGSL, shader API 0.1). It keeps Lumen's skies, bloom, moonlit nights and grade, and adds real light:

- **Sun and moon shadows:** trees, hills and buildings cast soft shade (2048 shadow map, 128 blocks). Shade is a cool
  blue, sunlight a little warm. Torchlight is never shaded; rain all but hides it.
- **Water reflections:** water open to the sky mirrors the world and the sky, most at shallow angles.
- **Light shafts:** sunlight streams past trees, hills and clouds around the sun, gold near sunset.

Every effect has an option on the pack's Shader Options page (Sky and light, Effects, Colour).

## Performance

About 5 ms of GPU time per frame at 2560x1440 on an RTX 5070 Ti, most of it the water mirror (about 3 ms), which
draws the world a second time. Setting **Water reflections** to 0 stops drawing the mirror and saves that. Shadows
cost about 1.5 ms, light shafts almost nothing.

## Install

Put this `lumen_ultra` folder in Horizon's shader pack folder (Options > Horizon Settings > Shader Packs > Open Pack
Folder) and click **Lumen Ultra** on the Shader Packs page. One pack runs at a time.

## License

MIT. Not affiliated with Mojang, Microsoft or the Horizon project.
