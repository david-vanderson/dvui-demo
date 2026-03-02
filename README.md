# DVUI Examples

This repo serves as a template for using [dvui](https://github.com/david-vanderson/dvui).
* if you are building a new app, start with `zig build sdl3-app`
* if you want control over the mainloop, `zig build sdl3-standalone`
* if you want debugging windows in an existing app, `zig build sdl3-ontop`

<table>
  <thead>
    <tr>
      <th>Backend</th>
      <th>
        As app
        <br>
        <sub>
          dvui handles main loop
          <br>
          <a href="https://github.com/david-vanderson/dvui/blob/main/examples/app.zig"><code>app.zig</code></a>
        </sub>
      </th>
      <th>
        Standalone
        <br>
        <sub>
          you control main loop
          <br>
          <a href="https://github.com/david-vanderson/dvui/blob/main/examples"><code>*-standalone.zig</code></a>
        </sub>
      </th>
      <th>
        On top
        <br>
        <sub>
          debug HUD on existing app/game
          <br>
          <a href="https://github.com/david-vanderson/dvui/blob/main/examples"><code>*-ontop.zig</code></a>
        </sub>
      </th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><strong>SDL3</strong></td>
      <td><code>sdl3-app</code></td>
      <td><code>sdl3-standalone</code></td>
      <td><code>sdl3-ontop</code></td>
    </tr>
    <tr>
      <td>
        <strong>SDL3GPU</strong>
        <br>
        <sub>Rendering via SDL GPU</sub>
      </td>
      <td>todo</td>
      <td><code>sdl3gpu-standalone</code></td>
      <td><code>sdl3gpu-ontop</code></td>
    </tr>
    <tr>
      <td><strong>SDL2</strong></td>
      <td><code>sdl2-app</code></td>
      <td><code>sdl2-standalone</code></td>
      <td><code>sdl2-ontop</code></td>
    </tr>
    <tr>
      <td>
        <strong>Raylib</strong>
        <br>
        <sub>C API</sub>
      </td>
      <td><code>raylib-app</code></td>
      <td><code>raylib-standalone</code></td>
      <td><code>raylib-ontop</code></td>
    </tr>
    <tr>
      <td>
        <strong>Raylib</strong>
        <br>
        <sub>Bindings <a href="https://github.com/raylib-zig/raylib-zig"><code>raylib-zig</code></a></sub>
      </td>
      <td><code>raylib-zig-app</code></td>
      <td><code>raylib-zig-standalone</code></td>
      <td><code>raylib-zig-ontop</code></td>
    </tr>
    <tr>
      <td><strong>DX11</strong></td>
      <td><code>dx11-app</code></td>
      <td><code>dx11-standalone</code></td>
      <td><code>dx11-ontop</code></td>
    </tr>
    <tr>
      <td><strong>GLFW</strong></td>
      <td><code>glfw-opengl-app</code></td>
      <td>todo</td>
      <td><code>glfw-opengl-ontop</code></td>
    </tr>
    <tr>
      <td><strong>Web</strong></td>
      <td><code>web-app</code></td>
      <td>none</td>
      <td>none</td>
    </tr>
  </tbody>
</table>

