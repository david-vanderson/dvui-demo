# DVUI Examples

This repo serves as an example for how to integrate [dvui](https://github.com/david-vanderson/dvui).

- `zig build sdl-standalone`
  - you want to build a new app
  - dvui will paint the whole window
  - use this repo's build.zig and build.zig.zon as a starting point

- `zig build sdl-ontop`
  - you already have an app or game
  - you want to add some gui stuff (like floating windows to for debugging)
  - use this example for integration

- `zig build web-test`
  - you want to put an app or game in a web canvas
