const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const dvui_dep = b.dependency("dvui", .{ .target = target, .optimize = optimize });

    const examples = [_][]const u8{
        "standalone-sdl",
        "ontop-sdl",
    };

    inline for (examples) |ex| {
        const exe = b.addExecutable(.{
            .name = ex,
            .root_source_file = .{ .path = ex ++ ".zig" },
            .target = target,
            .optimize = optimize,
        });

        exe.addModule("dvui", dvui_dep.module("dvui"));
        exe.addModule("SDLBackend", dvui_dep.module("SDLBackend"));

        link_deps(exe, dvui_dep.builder);

        const compile_step = b.step(ex, "Compile " ++ ex);
        compile_step.dependOn(&b.addInstallArtifact(exe, .{}).step);
        b.getInstallStep().dependOn(compile_step);

        const run_cmd = b.addRunArtifact(exe);
        run_cmd.step.dependOn(compile_step);

        const run_step = b.step("run-" ++ ex, "Run " ++ ex);
        run_step.dependOn(&run_cmd.step);
    }
}

fn link_deps(exe: *std.Build.Step.Compile, b: *std.Build) void {
    // TODO: remove this part about freetype (pulling it from the dvui_dep
    // sub-builder) once https://github.com/ziglang/zig/pull/14731 lands

    const freetype_dep = b.dependency("freetype", .{
        .target = exe.target,
        .optimize = exe.optimize,
    });
    exe.linkLibrary(freetype_dep.artifact("freetype"));

    // TODO: remove this part about stb_image once either:
    // - zig can successfully cimport stb_image.h
    // - zig can have a module depend on a c file
    const stbi_dep = b.dependency("stb_image", .{
        .target = exe.target,
        .optimize = exe.optimize,
    });
    exe.linkLibrary(stbi_dep.artifact("stb_image"));

    exe.linkLibC();

    if (exe.target.isWindows()) {
        const sdl_dep = b.dependency("sdl", .{
            .target = exe.target,
            .optimize = exe.optimize,
        });
        exe.linkLibrary(sdl_dep.artifact("SDL2"));

        exe.linkSystemLibrary("setupapi");
        exe.linkSystemLibrary("winmm");
        exe.linkSystemLibrary("gdi32");
        exe.linkSystemLibrary("imm32");
        exe.linkSystemLibrary("version");
        exe.linkSystemLibrary("oleaut32");
        exe.linkSystemLibrary("ole32");
    } else {
        if (exe.target.isDarwin()) {
            exe.linkSystemLibrary("z");
            exe.linkSystemLibrary("bz2");
            exe.linkSystemLibrary("iconv");
            exe.linkFramework("AppKit");
            exe.linkFramework("AudioToolbox");
            exe.linkFramework("Carbon");
            exe.linkFramework("Cocoa");
            exe.linkFramework("CoreAudio");
            exe.linkFramework("CoreFoundation");
            exe.linkFramework("CoreGraphics");
            exe.linkFramework("CoreHaptics");
            exe.linkFramework("CoreVideo");
            exe.linkFramework("ForceFeedback");
            exe.linkFramework("GameController");
            exe.linkFramework("IOKit");
            exe.linkFramework("Metal");
        }

        exe.linkSystemLibrary("SDL2");
        //exe.addIncludePath(.{.path = "/Users/dvanderson/SDL2-2.24.1/include"});
        //exe.addObjectFile(.{.path = "/Users/dvanderson/SDL2-2.24.1/build/.libs/libSDL2.a"});
    }
}
