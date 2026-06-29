# flutter_zig_bridge

[![pub.dev](https://img.shields.io/pub/v/flutter_zig_bridge.svg)](https://pub.dev/packages/flutter_zig_bridge)
[![tests](https://img.shields.io/badge/tests-41%20passing-brightgreen)](https://github.com/zigbridge/flutter_zig_bridge)
[![license](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

A Flutter package that bridges Dart and Zig via FFI. Zig code is compiled
automatically during `flutter build` / `flutter run` using Dart build hooks —
no manual build steps, no platform-specific configuration.

## Features

- **Zero-config compilation** — Zig builds happen automatically via Dart build hooks
- **Cross-platform** — macOS, iOS, Android, Linux, Windows all supported via Zig's cross-compilation
- **Unicode-aware string processing** — Handles multi-byte UTF-8 correctly (CJK, emoji, accented Latin)
- **Memory-safe** — Dart wrapper handles pointer allocation/deallocation
- **No dependency conflicts** — Self-contained build hook, no transitive version conflicts

## Quick Start

### Prerequisites

- Flutter 3.38+ (Dart 3.8+)
- [Zig 0.15.0+](https://ziglang.org/download/)

Or use the included nix flake:

```bash
nix develop
```

### Install

```yaml
dependencies:
  flutter_zig_bridge: ^0.1.0
```

### Use

```dart
import 'package:flutter_zig_bridge/flutter_zig_bridge.dart';

// Arithmetic
final sum = ZigBridge.add(2, 3);           // 5
final product = ZigBridge.multiply(4, 5);  // 20

// Fibonacci
final fib = ZigBridge.fibonacci(10);       // 55
final big = ZigBridge.fibonacci(92);       // 7540113804746346429

// String reversal (Unicode-aware)
final reversed = ZigBridge.reverseString('hello');  // 'olleh'
final cafe = ZigBridge.reverseString('café');       // 'éfac'
final cjk = ZigBridge.reverseString('你好世界');     // '界世好你'
final emoji = ZigBridge.reverseString('🎉🚀⚡');     // '⚡🚀🎉'
```

See [`example/lib/minimal.dart`](example/lib/minimal.dart) for the simplest possible app,
or [`example/lib/main.dart`](example/lib/main.dart) for an interactive demo.

## Architecture

```
Flutter App (Dart)
    │
    ├── @Native FFI bindings ──► dart:ffi
    │
    ├── hook/build.dart ──► zig build (cross-compile)
    │                              │
    └──────────────────────────────┘
                        .dylib / .so / .dll
```

The build hook (`hook/build.dart`) is a self-contained ~140-line Dart script that:

1. Maps the Flutter target (e.g., `macOS arm64`) → Zig target triple (`aarch64-macos`)
2. Runs `zig build install` with the right flags
3. Registers the compiled shared library as a native code asset

No external build tool dependencies. No `native_toolchain_zig` needed.

## Project Structure

```
flutter_zig_bridge/
├── hook/build.dart              # Dart build hook (self-contained)
├── lib/
│   ├── flutter_zig_bridge.dart  # Public API (ZigBridge class)
│   └── src/bindings.dart        # @Native FFI bindings
├── zig/
│   ├── src/lib.zig              # Zig source code
│   ├── build.zig                # Zig build config
│   └── build.zig.zon            # Zig package manifest
├── example/
│   └── lib/
│       ├── main.dart            # Interactive demo app
│       └── minimal.dart         # Minimal usage example
├── test/                        # 41 Dart tests
├── flake.nix                    # Nix dev shell
└── pubspec.yaml
```

## Adding New Zig Functions

1. Add your exported function in `zig/src/lib.zig`:
   ```zig
   export fn my_function(x: i32) i32 {
       return x * x;
   }
   ```

2. Add the `@Native` binding in `lib/src/bindings.dart`:
   ```dart
   @Native<Int32 Function(Int32)>()
   external int my_function(int x);
   ```

3. Add a high-level wrapper in `lib/flutter_zig_bridge.dart`:
   ```dart
   static int myFunction(int x) => ffi.my_function(x);
   ```

4. Run `flutter run` — the Zig code recompiles automatically.

## Testing

```bash
# Dart tests (41 tests)
flutter test

# Zig tests (10 tests)
cd zig && zig build test
```

## Part of [zigbridge](https://github.com/zigbridge)

This package is the first in the **zigbridge** family — ergonomic bridges from Zig to every framework. Contributions and ideas welcome!

## License

MIT — see [LICENSE](LICENSE).
