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

    // SDL3 Examples
    {
        const dvui_dep = b.dependency("dvui", .{ .target = target, .optimize = optimize, .backend = .sdl3 });

        const names = [_][]const u8{
            "sdl3-standalone",
            "sdl3-ontop",
            "sdl3-app",
        };

        const files = [_]std.Build.LazyPath{
            b.path("examples/sdl-standalone.zig"),
            b.path("examples/sdl-ontop.zig"),
            b.path("examples/app.zig"),
        };

        inline for (names, 0..) |name, i| {
            const mod = b.createModule(.{
                .root_source_file = files[i],
                .target = target,
                .optimize = optimize,
            });

            const exe = b.addExecutable(.{
                .name = name,
                .root_module = mod,
            });

            // Can either link the backend ourselves:
            // const dvui_mod = dvui_dep.module("dvui");
            // const sdl3_mod = dvui_dep.module("sdl3");
            // @import("dvui").linkBackend(dvui_mod, sdl3_mod);
            // mod.addImport("dvui", dvui_mod);

            // Or use a prelinked one:
            mod.addImport("dvui", dvui_dep.module("dvui_sdl3"));
            mod.addImport("sdl-backend", dvui_dep.module("sdl3")); // for zls

            const compile_step = b.step("compile-" ++ name, "Compile " ++ name);
            compile_step.dependOn(&b.addInstallArtifact(exe, .{}).step);
            b.getInstallStep().dependOn(compile_step);

            const run_cmd = b.addRunArtifact(exe);
            run_cmd.step.dependOn(compile_step);

            const run_step = b.step(name, "Run " ++ name);
            run_step.dependOn(&run_cmd.step);

            // This runs the tests in the examples with the sdl3 backend
            const test_cmd = b.addRunArtifact(b.addTest(.{ .root_module = mod, .name = "test-" ++ name }));
            test_step.dependOn(&test_cmd.step);
        }
    }

    // SDL3gpu Examples
    {
        const dvui_dep = b.dependency("dvui", .{ .target = target, .optimize = optimize, .backend = .sdl3gpu });

        const names = [_][]const u8{
            "sdl3gpu-standalone",
            "sdl3gpu-ontop",
        };

        const files = [_]std.Build.LazyPath{
            b.path("examples/sdl3gpu-standalone.zig"),
            b.path("examples/sdl3gpu-ontop.zig"),
        };

        inline for (names, 0..) |name, i| {
            const mod = b.createModule(.{
                .root_source_file = files[i],
                .target = target,
                .optimize = optimize,
            });

            const exe = b.addExecutable(.{
                .name = name,
                .root_module = mod,
            });

            mod.addImport("dvui", dvui_dep.module("dvui_sdl3gpu"));
            mod.addImport("sdl3gpu-backend", dvui_dep.module("sdl3")); // for zls

            const compile_step = b.step("compile-" ++ name, "Compile " ++ name);
            compile_step.dependOn(&b.addInstallArtifact(exe, .{}).step);
            b.getInstallStep().dependOn(compile_step);

            const run_cmd = b.addRunArtifact(exe);
            run_cmd.step.dependOn(compile_step);

            const run_step = b.step(name, "Run " ++ name);
            run_step.dependOn(&run_cmd.step);
        }
    }

    // Raylib (C api) Examples
    {
        const dvui_dep = b.dependency("dvui", .{ .target = target, .optimize = optimize, .backend = .raylib });

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
            const exe = b.addExecutable(.{
                .name = name,
                .root_module = b.createModule(.{
                    .root_source_file = files[i],
                    .target = target,
                    .optimize = optimize,
                }),
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

    // Raylib (zig api) Examples
    {
        const dvui_dep = b.dependency("dvui", .{ .target = target, .optimize = optimize, .backend = .raylib_zig });

        const names = [_][]const u8{
            "raylib-zig-standalone",
            "raylib-zig-ontop",
            "raylib-zig-app",
        };

        const files = [_]std.Build.LazyPath{
            b.path("examples/raylib-zig-standalone.zig"),
            b.path("examples/raylib-zig-ontop.zig"),
            b.path("examples/app.zig"),
        };

        inline for (names, 0..) |name, i| {
            const exe = b.addExecutable(.{
                .name = name,
                .root_module = b.createModule(.{
                    .root_source_file = files[i],
                    .target = target,
                    .optimize = optimize,
                }),
            });

            exe.root_module.addImport("dvui", dvui_dep.module("dvui_raylib_zig"));
            exe.root_module.addImport("raylib-zig-backend", dvui_dep.module("raylib_zig")); // for zls

            const compile_step = b.step("compile-" ++ name, "Compile " ++ name);
            compile_step.dependOn(&b.addInstallArtifact(exe, .{}).step);
            b.getInstallStep().dependOn(compile_step);

            const run_cmd = b.addRunArtifact(exe);
            run_cmd.step.dependOn(compile_step);

            const run_step = b.step(name, "Run " ++ name);
            run_step.dependOn(&run_cmd.step);
        }
    }

    // Web Example
    {
        const web_target = b.resolveTargetQuery(.{
            .cpu_arch = .wasm32,
            .os_tag = .freestanding,
        });

        const dvui_dep = b.dependency("dvui", .{ .target = web_target, .optimize = optimize, .backend = .web });

        const web_test = b.addExecutable(.{
            .name = "web",
            .root_module = b.createModule(.{
                .root_source_file = b.path("examples/app.zig"),
                .target = web_target,
                .optimize = optimize,
                .link_libc = false,
                .strip = if (optimize == .ReleaseFast or optimize == .ReleaseSmall) true else false,
            }),
        });

        web_test.entry = .disabled;
        web_test.root_module.addImport("dvui", dvui_dep.module("dvui_web"));
        web_test.root_module.addImport("web-backend", dvui_dep.module("web")); // for zls

        const install_wasm = b.addInstallArtifact(web_test, .{
            .dest_dir = .{ .override = .{ .custom = "bin" } },
        });

        const install_noto = b.addInstallBinFile(b.path("examples/NotoSansKR-Regular.ttf"), "NotoSansKR-Regular.ttf");

        const compile_step = b.step("web-app", "Compile the Web app");
        compile_step.dependOn(&install_wasm.step);
        compile_step.dependOn(&install_noto.step);
        compile_step.dependOn(&b.addInstallFileWithDir(b.path("examples/index.html"), .prefix, "bin/index.html").step);
        const web_js = dvui_dep.namedLazyPath("web.js");
        compile_step.dependOn(&b.addInstallFileWithDir(web_js, .prefix, "bin/web.js").step);
        b.getInstallStep().dependOn(compile_step);
    }

    // DX11 Examples
    if (target.result.os.tag == .windows) {
        const dvui_dep = b.dependency("dvui", .{ .target = target, .optimize = optimize, .backend = .dx11 });

        const names = [_][]const u8{
            "dx11-standalone",
            "dx11-ontop",
            "dx11-app",
        };

        const files = [_]std.Build.LazyPath{
            b.path("examples/dx11-standalone.zig"),
            b.path("examples/dx11-ontop.zig"),
            b.path("examples/app.zig"),
        };

        inline for (names, 0..) |name, i| {
            const exe = b.addExecutable(.{
                .name = name,
                .root_module = b.createModule(.{
                    .root_source_file = files[i],
                    .target = target,
                    .optimize = optimize,
                }),
            });

            exe.root_module.addImport("dvui", dvui_dep.module("dvui_dx11"));
            exe.root_module.addImport("dx11-backend", dvui_dep.module("dx11")); // for zls

            // This manifest makes hidpi work
            exe.win32_manifest = dvui_dep.path("./src/main.manifest");
            exe.subsystem = .Windows; // prevent console from showing

            // If using accesskit, needs:
            //exe.root_module.linkSystemLibrary("ws2_32", .{});
            //exe.root_module.linkSystemLibrary("Userenv", .{});

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
