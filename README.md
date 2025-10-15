
This branch is for trying to get raylib stuff working with wasm/emscripten.

`zig build raylib-standalone -Dtarget=wasm32-emscripten -Doptimize=ReleaseFast`

`zig build raylib-ontop -Dtarget=wasm32-emscripten -Doptimize=ReleaseFast`

Note: if you get a zig error about `module.base_address` missing field, then apply this patch to zig std lib:

```
--- debug.zig	2025-10-15 14:43:08.850757204 -0400
+++ debugHACK.zig	2025-10-15 14:43:01.600766196 -0400
@@ -909,16 +909,17 @@
             else => {},
         }
 
-        if (try module.getDwarfInfoForAddress(unwind_state.debug_info.allocator, unwind_state.dwarf_context.pc)) |di| {
-            return SelfInfo.unwindFrameDwarf(
-                unwind_state.debug_info.allocator,
-                di,
-                module.base_address,
-                &unwind_state.dwarf_context,
-                &it.ma,
-                null,
-            );
-        } else return error.MissingDebugInfo;
+        return error.MissingDebugInfo;
+        //if (try module.getDwarfInfoForAddress(unwind_state.debug_info.allocator, unwind_state.dwarf_context.pc)) |di| {
+        //    return SelfInfo.unwindFrameDwarf(
+        //        unwind_state.debug_info.allocator,
+        //        di,
+        //        module.base_address,
+        //        &unwind_state.dwarf_context,
+        //        &it.ma,
+        //        null,
+        //    );
+        //} else return error.MissingDebugInfo;
     }
```



# DVUI Examples

This repo serves as an example for how to integrate [dvui](https://github.com/david-vanderson/dvui).

- `zig build sdl3-app` or `zig build raylib-app`
  - you want to build a new app
  - you want dvui to handle the mainloop

- `zig build sdl3-standalone` or `zig build raylib-standalone`
  - you want to build a new app
  - dvui will paint the whole window
  - use this repo's build.zig and build.zig.zon as a starting point

- `zig build sdl3-ontop` or `zig build raylib-ontop`
  - you already have an app or game
  - you want to add some gui stuff (like floating windows to for debugging)
  - use this example for integration

- `zig build web-app`
  - you want to put an app or game in a web canvas
