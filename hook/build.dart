/// Build hook that compiles Zig code into a native asset.
///
/// This replaces the `native_toolchain_zig` dependency with an inline
/// implementation, avoiding the `meta ^1.18` version conflict that blocks
/// publishing to pub.dev.
import 'dart:io';

import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;

Future<void> main(List<String> arguments) async {
  await build(arguments, (input, output) async {
    if (!input.config.buildCodeAssets) return;

    final logger = Logger('ZigBuilder');

    // Verify Zig is installed.
    try {
      final ver = await Process.run('zig', ['version']);
      if (ver.exitCode != 0) throw Exception();
      logger.info('Using Zig ${(ver.stdout as String).trim()}');
    } catch (_) {
      throw BuildError(
        message: 'Zig is not installed or not in PATH.\n'
            'Install from https://ziglang.org/download/',
      );
    }

    final packageRoot = input.packageRoot.toFilePath();
    final zigDir = p.join(packageRoot, 'zig');
    final buildZig = File(p.join(zigDir, 'build.zig'));

    if (!buildZig.existsSync()) {
      throw BuildError(message: 'build.zig not found in $zigDir');
    }

    // Map Dart target → Zig target triple.
    final code = input.config.code;
    final triple = _zigTriple(code.targetOS, code.targetArchitecture,
        code.targetOS == OS.iOS ? code.iOS.targetSdk : null);

    // Determine link mode.
    final linkMode = switch (code.linkModePreference) {
      LinkModePreference.dynamic ||
      LinkModePreference.preferDynamic =>
        DynamicLoadingBundled(),
      LinkModePreference.static ||
      LinkModePreference.preferStatic =>
        StaticLinking(),
      _ => throw UnsupportedError(
          'Unsupported link mode: ${code.linkModePreference}'),
    };

    // Build.
    final prefixPath = input.outputDirectory.toFilePath();
    final result = await Process.run('zig', [
      'build',
      'install',
      '-Dtarget=$triple',
      '-Doptimize=ReleaseSafe',
      '--prefix', prefixPath,
      '--cache-dir', p.join(prefixPath, '.zig-cache'),
      '--global-cache-dir',
      p.join(input.outputDirectoryShared.toFilePath(), '.zig-cache-global'),
    ], workingDirectory: zigDir);

    if (result.exitCode != 0) {
      throw BuildError(
        message: 'zig build failed (exit ${result.exitCode}):\n'
            '${result.stderr}',
      );
    }

    // Locate the built library.
    final libName = input.packageName;
    final libFile = _locateLib(input.outputDirectory, libName, triple);

    // Register dependencies for incremental builds.
    output.dependencies.add(buildZig.uri);
    final buildZigZon = File(p.join(zigDir, 'build.zig.zon'));
    if (buildZigZon.existsSync()) {
      output.dependencies.add(buildZigZon.uri);
    }
    // Track all .zig source files.
    final srcDir = Directory(p.join(zigDir, 'src'));
    if (srcDir.existsSync()) {
      for (final entity in srcDir.listSync(recursive: true)) {
        if (entity is File && entity.path.endsWith('.zig')) {
          output.dependencies.add(entity.uri);
        }
      }
    }

    // Register the code asset.
    output.assets.code.add(
      CodeAsset(
        package: input.packageName,
        name: 'src/bindings.dart',
        linkMode: linkMode,
        file: libFile,
      ),
      routing: const ToAppBundle(),
    );

    logger.info('Built $libName for $triple.');
  });
}

/// Maps Dart OS + Architecture → Zig target triple string.
String _zigTriple(OS os, Architecture arch, [IOSSdk? iosSdk]) {
  return switch ((os, arch)) {
    // Android
    (OS.android, Architecture.arm64) => 'aarch64-linux-android',
    (OS.android, Architecture.arm) => 'arm-linux-androideabi',
    (OS.android, Architecture.x64) => 'x86_64-linux-android',
    // iOS
    (OS.iOS, Architecture.arm64) => switch (iosSdk) {
        IOSSdk.iPhoneOS || null => 'aarch64-ios',
        IOSSdk.iPhoneSimulator => 'aarch64-ios-simulator',
        _ => throw UnsupportedError('Unknown IOSSdk: $iosSdk'),
      },
    (OS.iOS, Architecture.x64) => 'x86_64-ios-simulator',
    // macOS
    (OS.macOS, Architecture.arm64) => 'aarch64-macos',
    (OS.macOS, Architecture.x64) => 'x86_64-macos',
    // Linux
    (OS.linux, Architecture.arm64) => 'aarch64-linux-gnu',
    (OS.linux, Architecture.x64) => 'x86_64-linux-gnu',
    // Windows
    (OS.windows, Architecture.arm64) => 'aarch64-windows-gnu',
    (OS.windows, Architecture.x64) => 'x86_64-windows-gnu',
    (_, _) => throw UnsupportedError('Unsupported target: $os on $arch'),
  };
}

/// Searches standard output directories for the compiled library.
Uri _locateLib(Uri outputDir, String libName, String triple) {
  final ext = triple.contains('windows')
      ? '.dll'
      : (triple.contains('macos') || triple.contains('ios'))
          ? '.dylib'
          : '.so';
  final prefix = triple.contains('windows') ? '' : 'lib';
  final fileName = '$prefix$libName$ext';

  for (final sub in ['lib/$fileName', 'bin/$fileName', fileName]) {
    final file = File.fromUri(outputDir.resolve(sub));
    if (file.existsSync()) return file.uri;
  }

  throw BuildError(
    message: 'Built library "$fileName" not found in ${outputDir.toFilePath()}',
  );
}
