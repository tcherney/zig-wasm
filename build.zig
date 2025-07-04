const std = @import("std");
const builtin = @import("builtin");
const emcc = @import("src/emcc.zig");

pub fn build(b: *std.Build) !void {
    const target = b.resolveTargetQuery(.{
        .cpu_arch = .wasm32,
        .cpu_model = .{ .explicit = &std.Target.wasm.cpu.mvp },
        .cpu_features_add = std.Target.wasm.featureSet(&.{
            .atomics,
            .bulk_memory,
        }),
        .os_tag = .emscripten,
    });
    const optimize = std.builtin.OptimizeMode.ReleaseSmall;
    const emcc_module = b.addModule("emcc", .{
        .root_source_file = b.path("src/emcc.zig"),
        .target = target,
        .optimize = optimize,
    });

    const lib = b.addLibrary(.{
        .linkage = .static,
        .name = "zig-wasm",
        .root_module = emcc_module,
    });

    b.installArtifact(lib);

    _ = try emcc.Build(b, lib, null, target, optimize, b.path("src/main.zig"), null, "src/shell.html", null);
}
