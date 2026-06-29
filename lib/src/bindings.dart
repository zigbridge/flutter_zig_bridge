/// Low-level FFI bindings to the Zig native library.
///
/// These functions use `@Native` annotations and are resolved automatically
/// by the Dart native assets system — no manual `DynamicLibrary.open()` needed.
// ignore_for_file: non_constant_identifier_names
library;

import 'dart:ffi';

import 'package:ffi/ffi.dart';

// ============================================================
// Arithmetic
// ============================================================

@Native<Int32 Function(Int32, Int32)>()
external int add(int a, int b);

@Native<Int32 Function(Int32, Int32)>()
external int multiply(int a, int b);

// ============================================================
// Fibonacci
// ============================================================

@Native<Int64 Function(Int32)>()
external int fibonacci(int n);

// ============================================================
// String processing
// ============================================================

@Native<Pointer<Utf8> Function(Pointer<Utf8>, Uint32)>()
external Pointer<Utf8> reverse_string(Pointer<Utf8> input, int len);

@Native<Void Function(Pointer<Utf8>)>()
external void free_string(Pointer<Utf8> ptr);
