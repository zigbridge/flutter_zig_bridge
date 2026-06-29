# Changelog

## 0.1.1

- **Breaking free of `native_toolchain_zig`** — replaced with a self-contained
  ~140-line build hook. Eliminates the `meta ^1.18` version conflict that
  blocked clean dependency resolution.
- **Linux support fix** — explicitly link libc in `build.zig` so
  `std.heap.c_allocator` works on Linux (macOS links it implicitly).
- **GitHub Actions CI** — automated testing on ubuntu + macOS for both
  Zig and Flutter tests, plus a `dart pub publish --dry-run` check.
- **Expanded test suite** — 41 Dart tests + 10 Zig tests covering i32
  boundaries, fib(92), CJK/emoji/accented string reversal, 1000-char
  stress tests, and double-reverse roundtrips.
- **Minimal example** — added `example/lib/minimal.dart` for quick-start usage.
- Added `topics` field for pub.dev discoverability.
- Updated README with badges, expanded examples, and testing instructions.

## 0.1.0

- Initial release
- Arithmetic operations: `add`, `multiply`
- Fibonacci computation
- Unicode-aware string reversal
- Automatic Zig compilation via Dart build hooks
- Cross-platform support (macOS, iOS, Android, Linux, Windows)
