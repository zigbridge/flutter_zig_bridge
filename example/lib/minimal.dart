// Minimal example of using flutter_zig_bridge.
//
// This is the simplest possible Flutter app that demonstrates
// calling Zig code from Dart via FFI.
import 'package:flutter/material.dart';
import 'package:flutter_zig_bridge/flutter_zig_bridge.dart';

void main() => runApp(const App());

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Zig Bridge — Minimal')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('2 + 3 = ${ZigBridge.add(2, 3)}'),
              Text('4 × 5 = ${ZigBridge.multiply(4, 5)}'),
              Text('fib(10) = ${ZigBridge.fibonacci(10)}'),
              Text('reverse("hello") = ${ZigBridge.reverseString("hello")}'),
            ],
          ),
        ),
      ),
    );
  }
}
