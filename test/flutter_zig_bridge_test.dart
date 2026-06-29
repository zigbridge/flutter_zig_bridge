import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_zig_bridge/flutter_zig_bridge.dart';

void main() {
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
  });

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
  });

  group('ZigBridge.fibonacci', () {
    test('fib(0) = 0', () {
      expect(ZigBridge.fibonacci(0), equals(0));
    });

    test('fib(1) = 1', () {
      expect(ZigBridge.fibonacci(1), equals(1));
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

    test('fib(50) = large number', () {
      expect(ZigBridge.fibonacci(50), equals(12586269025));
    });
  });

  group('ZigBridge.reverseString', () {
    test('reverses ASCII string', () {
      expect(ZigBridge.reverseString('hello'), equals('olleh'));
    });

    test('reverses empty string', () {
      expect(ZigBridge.reverseString(''), equals(''));
    });

    test('single character', () {
      expect(ZigBridge.reverseString('a'), equals('a'));
    });

    test('reverses string with accented characters', () {
      expect(ZigBridge.reverseString('café'), equals('éfac'));
    });

    test('palindrome', () {
      const palindrome = 'racecar';
      expect(ZigBridge.reverseString(palindrome), equals(palindrome));
    });
  });
}
