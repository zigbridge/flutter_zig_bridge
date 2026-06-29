import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_zig_bridge/flutter_zig_bridge.dart';

void main() {
  // ============================================================
  // ZigBridge.add
  // ============================================================
  group('ZigBridge.add', () {
    test('adds positive numbers', () {
      expect(ZigBridge.add(2, 3), equals(5));
    });

    test('adds negative numbers', () {
      expect(ZigBridge.add(-2, -3), equals(-5));
    });

    test('adds mixed sign', () {
      expect(ZigBridge.add(-1, 1), equals(0));
    });

    test('adds zero', () {
      expect(ZigBridge.add(0, 0), equals(0));
    });

    test('i32 max boundary', () {
      // 2^31 - 1 = 2147483647
      expect(ZigBridge.add(2147483646, 1), equals(2147483647));
    });

    test('i32 min boundary', () {
      // -(2^31) = -2147483648
      expect(ZigBridge.add(-2147483647, -1), equals(-2147483648));
    });

    test('large positive + large negative', () {
      expect(ZigBridge.add(1000000, -1000000), equals(0));
    });
  });

  // ============================================================
  // ZigBridge.multiply
  // ============================================================
  group('ZigBridge.multiply', () {
    test('multiplies positive numbers', () {
      expect(ZigBridge.multiply(4, 5), equals(20));
    });

    test('multiplies by zero', () {
      expect(ZigBridge.multiply(42, 0), equals(0));
    });

    test('multiplies negative numbers', () {
      expect(ZigBridge.multiply(-2, -3), equals(6));
    });

    test('multiplies mixed sign', () {
      expect(ZigBridge.multiply(-3, 4), equals(-12));
    });

    test('multiplies by one (identity)', () {
      expect(ZigBridge.multiply(12345, 1), equals(12345));
    });

    test('multiplies by negative one (negation)', () {
      expect(ZigBridge.multiply(42, -1), equals(-42));
    });

    test('squares a number', () {
      expect(ZigBridge.multiply(100, 100), equals(10000));
    });
  });

  // ============================================================
  // ZigBridge.fibonacci
  // ============================================================
  group('ZigBridge.fibonacci', () {
    test('fib(0) = 0', () {
      expect(ZigBridge.fibonacci(0), equals(0));
    });

    test('fib(1) = 1', () {
      expect(ZigBridge.fibonacci(1), equals(1));
    });

    test('fib(2) = 1', () {
      expect(ZigBridge.fibonacci(2), equals(1));
    });

    test('fib(10) = 55', () {
      expect(ZigBridge.fibonacci(10), equals(55));
    });

    test('fib(20) = 6765', () {
      expect(ZigBridge.fibonacci(20), equals(6765));
    });

    test('negative input returns -1', () {
      expect(ZigBridge.fibonacci(-1), equals(-1));
    });

    test('large negative input returns -1', () {
      expect(ZigBridge.fibonacci(-100), equals(-1));
    });

    test('fib(50) = large number', () {
      expect(ZigBridge.fibonacci(50), equals(12586269025));
    });

    test('fib(92) = max safe i64 fibonacci', () {
      // fib(92) = 7540113804746346429 — fits in i64
      expect(ZigBridge.fibonacci(92), equals(7540113804746346429));
    });

    test('sequential fibonacci values are consistent', () {
      // fib(n) = fib(n-1) + fib(n-2) for several values
      for (int n = 2; n <= 30; n++) {
        expect(
          ZigBridge.fibonacci(n),
          equals(ZigBridge.fibonacci(n - 1) + ZigBridge.fibonacci(n - 2)),
          reason: 'fib($n) should equal fib(${n - 1}) + fib(${n - 2})',
        );
      }
    });
  });

  // ============================================================
  // ZigBridge.reverseString
  // ============================================================
  group('ZigBridge.reverseString', () {
    // Basic ASCII
    test('reverses ASCII string', () {
      expect(ZigBridge.reverseString('hello'), equals('olleh'));
    });

    test('reverses empty string', () {
      expect(ZigBridge.reverseString(''), equals(''));
    });

    test('single character', () {
      expect(ZigBridge.reverseString('a'), equals('a'));
    });

    test('palindrome stays same', () {
      const palindrome = 'racecar';
      expect(ZigBridge.reverseString(palindrome), equals(palindrome));
    });

    test('string with spaces', () {
      expect(ZigBridge.reverseString('hello world'), equals('dlrow olleh'));
    });

    test('string with numbers', () {
      expect(ZigBridge.reverseString('abc123'), equals('321cba'));
    });

    // Unicode: multi-byte codepoints
    test('reverses string with accented characters', () {
      expect(ZigBridge.reverseString('café'), equals('éfac'));
    });

    test('reverses string with CJK characters', () {
      expect(ZigBridge.reverseString('你好世界'), equals('界世好你'));
    });

    test('reverses emoji string', () {
      expect(ZigBridge.reverseString('🎉🚀⚡'), equals('⚡🚀🎉'));
    });

    test('reverses mixed ASCII and Unicode', () {
      expect(ZigBridge.reverseString('hi🌍'), equals('🌍ih'));
    });

    test('reverses string with accented Latin', () {
      expect(ZigBridge.reverseString('naïve'), equals('evïan'));
    });

    // Stress / longer strings
    test('reverses longer string correctly', () {
      final input = 'a' * 1000;
      final result = ZigBridge.reverseString(input);
      expect(result.length, equals(1000));
      expect(result, equals(input)); // all same char => palindrome
    });

    test('reverses long mixed string', () {
      final input = 'abcdefghij' * 100; // 1000 chars
      final expected = ('jihgfedcba') * 100;
      expect(ZigBridge.reverseString(input), equals(expected));
    });

    // Double-reverse roundtrip
    test('double reverse returns original (ASCII)', () {
      const original = 'The quick brown fox';
      expect(ZigBridge.reverseString(ZigBridge.reverseString(original)),
          equals(original));
    });

    test('double reverse returns original (Unicode)', () {
      const original = '日本語テスト🎌';
      expect(ZigBridge.reverseString(ZigBridge.reverseString(original)),
          equals(original));
    });

    // Special characters
    test('reverses string with newlines', () {
      expect(ZigBridge.reverseString('ab\ncd'), equals('dc\nba'));
    });

    test('string with embedded null truncates at null (C string behavior)', () {
      // Dart's toNativeUtf8 produces a null-terminated C string.
      // Embedded null bytes cause truncation — this is expected behavior.
      // 'ab\x00cd' → only 'ab' is passed to Zig → reversed to 'ba'
      expect(ZigBridge.reverseString('ab\x00cd'), equals('ba'));
    });
  });
}
