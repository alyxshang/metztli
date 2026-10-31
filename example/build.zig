// METZTLI by Alyx Shang.
// Licensed under the FSL v1.

// Importing the "std" namespace.
const std = @import("std");

// The function that invokes the
// build script.
pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const mod = b.addModule(
        "metztli_example",
        .{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
        },
    );
    const exe = b.addExecutable(
        .{
            .name = "example",
            .root_module = mod,
        }
    );
    const metztli_dep = b.dependency(
        "metztli", 
        .{
            .target = target,
            .optimize = optimize,
        }
    );
    exe.root_module.addImport(
        "metztli", 
        metztli_dep.module("metztli")
    );
    b.installArtifact(exe);
    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    run_cmd.addPassthruArgs();
    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
