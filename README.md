# DVUI Examples

This repo serves as an example for how to integrate [dvui](https://github.com/david-vanderson/dvui).

- `zig build sdl3-app` or `zig build raylib-app`
  - you want to build a new app
  - you want dvui to handle the mainloop
  - src in [app.zig](app.zig)

- `zig build sdl3-standalone` or `zig build raylib-standalone`
  - you want to build a new app
  - dvui will paint the whole window
  - use this repo's build.zig and build.zig.zon as a starting point
  - src in [sdl-standalone.zig](sdl-standalone.zig) or [raylib-standalone.zig](raylib-standalone.zig)

- `zig build sdl3-ontop` or `zig build raylib-ontop`
  - you already have an app or game
  - you want to add some gui stuff (like floating windows to for debugging)
  - use this example for integration
  - src in [sdl-ontop.zig](sdl-ontop.zig) or [raylib-ontop.zig](raylib-ontop.zig)

- `zig build web-app`
  - you want to put an app or game in a web canvas
  - src in [app.zig](app.zig)
