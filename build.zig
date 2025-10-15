const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Raylib Examples
    {
        const dvui_dep = b.dependency("dvui", .{ .target = target, .optimize = optimize, .backend = .raylib });
        const emsdk_dep = b.dependency("emsdk", .{});

        const names = [_][]const u8{
            "raylib-standalone",
            "raylib-ontop",
            "raylib-app",
        };

        const files = [_]std.Build.LazyPath{
            b.path("raylib-standalone.zig"),
            b.path("raylib-ontop.zig"),
            b.path("app.zig"),
        };

        inline for (names, 0..) |name, i| {
            const mod = b.createModule(.{
                .root_source_file = files[i],
                .target = target,
                .optimize = optimize,
            });

            if (target.query.os_tag == .emscripten) {
                const wasm = b.addLibrary(.{
                    .name = name,
                    .root_module = mod,
                });

                wasm.root_module.addImport("dvui", dvui_dep.module("dvui_raylib"));
                wasm.root_module.addImport("raylib-backend", dvui_dep.module("raylib")); // for zls
                dvui_dep.module("dvui_raylib").addIncludePath(emsdk_dep.path("upstream/emscripten/cache/sysroot/include"));
                dvui_dep.module("raylib").addIncludePath(emsdk_dep.path("upstream/emscripten/cache/sysroot/include"));

                const emsdk = @import("dvui").emsdk;
                const install_dir: std.Build.InstallDir = .{ .custom = "web" };
                const emcc_flags = emsdk.emccDefaultFlags(b.allocator, .{
                    .optimize = .Debug,
                    //.asyncify = !std.mem.endsWith(u8, ex.name, "web"),
                });
                var emcc_settings = emsdk.emccDefaultSettings(b.allocator, .{
                    .optimize = .Debug,
                });

                //emcc_settings.put("INITIAL_HEAP", "33554432") catch {};
                emcc_settings.put("STACK_SIZE", "100000") catch {};

                const emcc_step = emsdk.emccStep(b, wasm, wasm, .{
                    .optimize = .Debug,
                    .flags = emcc_flags,
                    .settings = emcc_settings,
                    //.shell_file_path = emsdk.shell(b),
                    .install_dir = install_dir,
                    //.embed_paths = &.{.{ .src_path = "resources/" }},
                });

                const html_filename = try std.fmt.allocPrint(b.allocator, "{s}.html", .{wasm.name});
                const emrun_step = emsdk.emrunStep(
                    b,
                    b.getInstallPath(install_dir, html_filename),
                    &.{},
                );
                emrun_step.dependOn(emcc_step);

                const run_option = b.step(name, "Run it");
                run_option.dependOn(emrun_step);
            } else {
                const exe = b.addExecutable(.{
                    .name = name,
                    .root_module = mod,
                });

                exe.root_module.addImport("dvui", dvui_dep.module("dvui_raylib"));
                exe.root_module.addImport("raylib-backend", dvui_dep.module("raylib")); // for zls

                const compile_step = b.step("compile-" ++ name, "Compile " ++ name);
                compile_step.dependOn(&b.addInstallArtifact(exe, .{}).step);
                b.getInstallStep().dependOn(compile_step);

                const run_cmd = b.addRunArtifact(exe);
                run_cmd.step.dependOn(compile_step);

                const run_step = b.step(name, "Run " ++ name);
                run_step.dependOn(&run_cmd.step);
            }
        }
    }
}
