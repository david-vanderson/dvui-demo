const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // SDL Examples
    {
        const dvui_dep = b.dependency("dvui", .{ .target = target, .optimize = optimize, .backend = .sdl3 });

        const names = [_][]const u8{
            "sdl3-standalone",
            "sdl3-ontop",
            "sdl3-app",
        };

        const files = [_]std.Build.LazyPath{
            b.path("sdl-standalone.zig"),
            b.path("sdl-ontop.zig"),
            b.path("app.zig"),
        };

        inline for (names, 0..) |name, i| {
            const exe = b.addExecutable(.{
                .name = name,
                .root_source_file = files[i],
                .target = target,
                .optimize = optimize,
            });

            // Can either link the backend ourselves:
            // const dvui_mod = dvui_dep.module("dvui");
            // const sdl = dvui_dep.module("sdl");
            // @import("dvui").linkBackend(dvui_mod, sdl);
            // exe.root_module.addImport("dvui", dvui_mod);

            // Or use a prelinked one:
            exe.root_module.addImport("dvui", dvui_dep.module("dvui_sdl3"));

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
            .root_source_file = b.path("app.zig"),
            .target = web_target,
            .optimize = optimize,
            .link_libc = false,
            .strip = if (optimize == .ReleaseFast or optimize == .ReleaseSmall) true else false,
        });

        web_test.entry = .disabled;
        web_test.root_module.addImport("dvui", dvui_dep.module("dvui_web"));

        const install_wasm = b.addInstallArtifact(web_test, .{
            .dest_dir = .{ .override = .{ .custom = "bin" } },
        });

        const install_noto = b.addInstallBinFile(b.path("NotoSansKR-Regular.ttf"), "NotoSansKR-Regular.ttf");

        const compile_step = b.step("web-app", "Compile the Web app");
        compile_step.dependOn(&install_wasm.step);
        compile_step.dependOn(&install_noto.step);
        compile_step.dependOn(&b.addInstallFileWithDir(b.path("index.html"), .prefix, "bin/index.html").step);
        const web_js = dvui_dep.namedLazyPath("web.js");
        compile_step.dependOn(&b.addInstallFileWithDir(web_js, .prefix, "bin/web.js").step);
        b.getInstallStep().dependOn(compile_step);
    }
}
