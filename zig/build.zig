const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const root_module = b.createModule(.{
        .root_source_file = b.path("src/lib.zig"),
        .target = target,
        .optimize = optimize,
    });

    const lib = b.addLibrary(.{
        .name = "flutter_zig_bridge",
        .linkage = .dynamic,
        .root_module = root_module,
    });

    // macOS/iOS: Flutter's build system uses install_name_tool to rewrite
    // dylib paths, which requires extra Mach-O header space.
    const os_tag = target.result.os.tag;
    if (os_tag == .macos or os_tag == .ios) {
        lib.headerpad_max_install_names = true;
    }

    b.installArtifact(lib);

    // Unit tests
    const lib_unit_tests = b.addTest(.{
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/lib.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });

    const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_lib_unit_tests.step);
}
