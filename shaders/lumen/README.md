# Lumen

A cinematic shader pack for [Horizon](https://github.com/horizon-rust/horizon), written in Horizon's own
shader format (WGSL, shader API 0.1). It stays close to vanilla: the same colours, just nicer.

- **Sky:** a deeper blue overhead, a golden glow around a low sun with a rosy belt opposite it, a deep blue
  night sky instead of black.
- **Moonlight:** outdoors at night, shadows turn a cool moonlit blue instead of sinking into black.
- **Coloured light:** torches and lanterns a touch warmer, soul fire blue, redstone red, amethyst purple.
- **Glowing blocks:** lava, glowstone and other shining blocks stay bright in the dark.
- **Wet surfaces:** ground open to the sky looks wet while it rains.
- **Bloom:** a soft glow around real lights only (the sun, lava, flames, glowstone, redstone), never on white
  blocks or the daytime sky.
- **Distant haze:** far land fades softly into the air.
- **Colour grade:** a touch of contrast that leaves the shadows alone, golden light around sunrise and sunset.
- **Film touches:** a light vignette, optional film grain, and optional 2.39:1 letterbox bars.

Every effect has an option on the pack's Shader Options page (Sky and light, Effects, Colour).

## Install

1. Download a packaged `.hshader` from this folder's parent, or use this `lumen` folder as it is.
2. In Horizon: Options > Horizon Settings > Shader Packs > Open Pack Folder, and put it there.
3. Click **Lumen** on the Shader Packs page. Click it again to turn it off.

## Build and check

With Horizon's `horizon-shader` tool (`cargo install --path crates/horizon-shader-api` in a Horizon checkout):

```sh
horizon-shader check shaders/lumen
horizon-shader pack shaders/lumen
```

While a pack runs, Horizon reloads it within half a second of a file being saved, so you can tweak the WGSL
and see the result live.

## License

MIT. Not affiliated with Mojang, Microsoft or the Horizon project.
