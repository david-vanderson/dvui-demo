const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const test_step = b.step("test", "Test the examples");

    // Testing
    {
        // dvui's testing backend doesn't draw anything, for testing behavior
        const dvui_dep = b.dependency("dvui", .{ .target = target, .optimize = optimize, .backend = .testing });

        const mod = b.createModule(.{
            .root_source_file = b.path("examples/app.zig"),
            .target = target,
            .optimize = optimize,
        });

        mod.addImport("dvui", dvui_dep.module("dvui_testing"));
        mod.addImport("backend", dvui_dep.module("testing"));

        const test_cmd = b.addRunArtifact(b.addTest(.{ .root_module = mod, .name = "testing-app" }));
        // We skip the snapshots in the demo project to avoid them getting out of sync too easily
        test_cmd.setEnvironmentVariable("DVUI_SNAPSHOT_IGNORE", "1");
        test_step.dependOn(&test_cmd.step);
    }

    // Raylib (C api) Examples
    {
        var system_include_path: ?std.Build.LazyPath = null;
        if (b.lazyDependency("emsdk", .{})) |emsdk_dep| {
            if (target.query.os_tag == .emscripten) {
                system_include_path = emsdk_dep.path("upstream/emscripten/cache/sysroot/include");
            }
        }

        const dvui_dep = b.dependency("dvui", .{
            .target = target,
            .optimize = optimize,
            .backend = .raylib,
            .freetype = false,
            .@"tree-sitter" = false,
            .system_include_path = system_include_path,
        });

        const names = [_][]const u8{
            "raylib-standalone",
            "raylib-ontop",
            "raylib-app",
        };

        const files = [_]std.Build.LazyPath{
            b.path("examples/raylib-standalone.zig"),
            b.path("examples/raylib-ontop.zig"),
            b.path("examples/app.zig"),
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
                emcc_settings.put("STACK_SIZE", "1000000") catch {};
                //emcc_settings.put("ALLOW_MEMORY_GROWTH", "1") catch {};

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

    // Raylib (zig api) Examples
    //{
    //    const dvui_dep = b.dependency("dvui", .{ .target = target, .optimize = optimize, .backend = .raylib_zig });

    //    const names = [_][]const u8{
    //        "raylib-zig-standalone",
    //        "raylib-zig-ontop",
    //        "raylib-zig-app",
    //    };

    //    const files = [_]std.Build.LazyPath{
    //        b.path("examples/raylib-zig-standalone.zig"),
    //        b.path("examples/raylib-zig-ontop.zig"),
    //        b.path("examples/app.zig"),
    //    };

    //    inline for (names, 0..) |name, i| {
    //        const exe = b.addExecutable(.{
    //            .name = name,
    //            .root_module = b.createModule(.{
    //                .root_source_file = files[i],
    //                .target = target,
    //                .optimize = optimize,
    //            }),
    //        });

    //        exe.root_module.addImport("dvui", dvui_dep.module("dvui_raylib_zig"));
    //        exe.root_module.addImport("raylib-zig-backend", dvui_dep.module("raylib_zig")); // for zls

    //        const compile_step = b.step("compile-" ++ name, "Compile " ++ name);
    //        compile_step.dependOn(&b.addInstallArtifact(exe, .{}).step);
    //        b.getInstallStep().dependOn(compile_step);

    //        const run_cmd = b.addRunArtifact(exe);
    //        run_cmd.step.dependOn(compile_step);

    //        const run_step = b.step(name, "Run " ++ name);
    //        run_step.dependOn(&run_cmd.step);
    //    }
    //}

}
