/// Flutter Zig Bridge — call Zig from Dart via FFI.
///
/// Provides a high-level Dart API over a Zig native library compiled
/// automatically during the Flutter build via Dart build hooks.
///
/// ```dart
/// import 'package:flutter_zig_bridge/flutter_zig_bridge.dart';
///
/// final result = ZigBridge.add(2, 3); // 5
/// final fib = ZigBridge.fibonacci(10); // 55
/// final reversed = ZigBridge.reverseString('hello'); // 'olleh'
/// ```
library;

import 'dart:ffi';

import 'package:ffi/ffi.dart';

import 'src/bindings.dart' as ffi;

/// High-level interface to the Zig native library.
///
/// All methods are static and synchronous — they call directly into
/// the compiled Zig shared library with zero overhead beyond the FFI call.
class ZigBridge {
  ZigBridge._(); // Prevent instantiation.

  /// Add two integers.
  ///
  /// ```dart
  /// ZigBridge.add(2, 3); // 5
  /// ```
  static int add(int a, int b) => ffi.add(a, b);

  /// Multiply two integers.
  ///
  /// ```dart
  /// ZigBridge.multiply(4, 5); // 20
  /// ```
  static int multiply(int a, int b) => ffi.multiply(a, b);

  /// Compute the n-th Fibonacci number.
  ///
  /// Returns -1 for negative inputs.
  ///
  /// ```dart
  /// ZigBridge.fibonacci(10); // 55
  /// ZigBridge.fibonacci(20); // 6765
  /// ```
  static int fibonacci(int n) => ffi.fibonacci(n);

  /// Reverse a string (Unicode-aware).
  ///
  /// Handles multi-byte UTF-8 codepoints correctly.
  ///
  /// ```dart
  /// ZigBridge.reverseString('hello');  // 'olleh'
  /// ZigBridge.reverseString('café');   // 'éfac'
  /// ```
  static String reverseString(String input) {
    if (input.isEmpty) return '';
    final nativeInput = input.toNativeUtf8();
    final byteLen = nativeInput.length;
    try {
      final result = ffi.reverse_string(nativeInput, byteLen);
      if (result == nullptr) {
        throw StateError('Zig reverse_string returned null (allocation failure)');
      }
      try {
        return result.toDartString();
      } finally {
        ffi.free_string(result);
      }
    } finally {
      calloc.free(nativeInput);
    }
  }
}
