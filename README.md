# flutter_zig_bridge

A Flutter package that bridges Dart and Zig via FFI. Zig code is compiled
automatically during `flutter build` / `flutter run` using
[`native_toolchain_zig`](https://pub.dev/packages/native_toolchain_zig).

## Features

- **Zero-config compilation** — Zig builds happen automatically via Dart build hooks
- **Cross-platform** — macOS, iOS, Android, Linux, Windows all supported via Zig's cross-compilation
- **Unicode-aware string processing** — Handles multi-byte UTF-8 correctly
- **Memory-safe** — Dart wrapper handles pointer allocation/deallocation

## Getting Started

### Prerequisites

- Flutter 3.38+ (Dart 3.8+)
- [Zig 0.15.0+](https://ziglang.org/download/)

Or use the included nix flake:

```bash
nix develop
```

### Usage

Add `flutter_zig_bridge` to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_zig_bridge:
    path: ../flutter_zig_bridge  # or from git/pub
```

Then use it in your Dart code:

```dart
import 'package:flutter_zig_bridge/flutter_zig_bridge.dart';

// Arithmetic
final sum = ZigBridge.add(2, 3);        // 5
final product = ZigBridge.multiply(4, 5); // 20

// Fibonacci
final fib = ZigBridge.fibonacci(10);    // 55

// String reversal (Unicode-aware)
final reversed = ZigBridge.reverseString('hello');  // 'olleh'
final emoji = ZigBridge.reverseString('café');      // 'éfac'
```

## Architecture

```
Flutter App (Dart)
    │
    ├── @Native FFI bindings ──► dart:ffi
    │
    ├── hook/build.dart ──► ZigBuilder (native_toolchain_zig)
    │                              │
    │                              ▼
    │                        zig build (cross-compile)
    │                              │
    └──────────────────────────────┘
                        .dylib / .so / .dll
```

## Project Structure

```
flutter_zig_bridge/
├── hook/build.dart          # Dart build hook
├── lib/
│   ├── flutter_zig_bridge.dart  # Public API
│   └── src/bindings.dart        # @Native FFI bindings
├── zig/
│   ├── src/lib.zig          # Zig source code
│   ├── build.zig            # Zig build config
│   └── build.zig.zon        # Zig package manifest
├── example/                 # Demo Flutter app
├── test/                    # Dart tests
├── flake.nix                # Nix dev shell
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

## License

MIT — see [LICENSE](LICENSE).
