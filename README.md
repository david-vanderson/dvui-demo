# GUI Examples

This repo serves as an example for how to integrate [gui](https://github.com/david-vanderson/gui).

- `zig build run-standalone-sdl`
  - you want to build a new app
  - gui will paint the whole window
  - use this repo's build.zig and build.zig.zon as a starting point

- `zig build run-ontop-sdl`
  - you already have an app or game
  - you want to add some gui stuff (like floating windows to for debugging)
  - use this example for integration
  - add [gui](https://github.com/david-vanderson/gui) as a git submodule

