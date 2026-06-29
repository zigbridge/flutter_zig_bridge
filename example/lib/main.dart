import 'package:flutter/material.dart';
import 'package:flutter_zig_bridge/flutter_zig_bridge.dart';

void main() {
  runApp(const ZigBridgeApp());
}

class ZigBridgeApp extends StatelessWidget {
  const ZigBridgeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Zig Bridge',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFF7A41D), // Zig orange
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        fontFamily: 'Inter',
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Arithmetic
  final _aController = TextEditingController(text: '12');
  final _bController = TextEditingController(text: '7');
  String _addResult = '';
  String _mulResult = '';

  // Fibonacci
  final _fibController = TextEditingController(text: '30');
  String _fibResult = '';
  String _fibTime = '';

  // String
  final _strController = TextEditingController(text: 'Hello, Zig! 🚀');
  String _strResult = '';

  void _runArithmetic() {
    final a = int.tryParse(_aController.text) ?? 0;
    final b = int.tryParse(_bController.text) ?? 0;
    setState(() {
      _addResult = '${ZigBridge.add(a, b)}';
      _mulResult = '${ZigBridge.multiply(a, b)}';
    });
  }

  void _runFibonacci() {
    final n = int.tryParse(_fibController.text) ?? 0;
    final sw = Stopwatch()..start();
    final result = ZigBridge.fibonacci(n);
    sw.stop();
    setState(() {
      _fibResult = '$result';
      _fibTime = '${sw.elapsedMicroseconds} µs';
    });
  }

  void _runReverse() {
    final input = _strController.text;
    setState(() {
      _strResult = ZigBridge.reverseString(input);
    });
  }

  @override
  void initState() {
    super.initState();
    // Run all demos on start.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _runArithmetic();
      _runFibonacci();
      _runReverse();
    });
  }

  @override
  void dispose() {
    _aController.dispose();
    _bController.dispose();
    _fibController.dispose();
    _strController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7A41D).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text('⚡', style: TextStyle(fontSize: 28)),
                ),
                const SizedBox(width: 12),
                const Text('Flutter × Zig'),
              ],
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            sliver: SliverList.list(
              children: [
                // ── Arithmetic Card ──
                _SectionCard(
                  icon: Icons.calculate_outlined,
                  title: 'Arithmetic',
                  subtitle: 'Basic math via Zig FFI',
                  color: colorScheme.primary,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _InputField(
                              controller: _aController,
                              label: 'a',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _InputField(
                              controller: _bController,
                              label: 'b',
                            ),
                          ),
                          const SizedBox(width: 12),
                          FilledButton.icon(
                            onPressed: _runArithmetic,
                            icon: const Icon(Icons.play_arrow, size: 18),
                            label: const Text('Run'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _ResultRow(label: 'add(a, b)', value: _addResult),
                      const SizedBox(height: 8),
                      _ResultRow(label: 'multiply(a, b)', value: _mulResult),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ── Fibonacci Card ──
                _SectionCard(
                  icon: Icons.trending_up,
                  title: 'Fibonacci',
                  subtitle: 'Iterative computation in Zig',
                  color: const Color(0xFF4CAF50),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _InputField(
                              controller: _fibController,
                              label: 'n',
                            ),
                          ),
                          const SizedBox(width: 12),
                          FilledButton.icon(
                            onPressed: _runFibonacci,
                            icon: const Icon(Icons.play_arrow, size: 18),
                            label: const Text('Run'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _ResultRow(label: 'fibonacci(n)', value: _fibResult),
                      const SizedBox(height: 8),
                      _ResultRow(label: 'Time', value: _fibTime),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ── String Card ──
                _SectionCard(
                  icon: Icons.text_fields,
                  title: 'String Reversal',
                  subtitle: 'Unicode-aware, via Zig allocator',
                  color: const Color(0xFFE040FB),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _InputField(
                              controller: _strController,
                              label: 'input',
                            ),
                          ),
                          const SizedBox(width: 12),
                          FilledButton.icon(
                            onPressed: _runReverse,
                            icon: const Icon(Icons.play_arrow, size: 18),
                            label: const Text('Run'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _ResultRow(
                        label: 'reversed',
                        value: _strResult,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // ── Footer ──
                Center(
                  child: Text(
                    'Dart ↔ Zig via dart:ffi + build hooks',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.6,
                          ),
                        ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────
// Reusable widgets
// ───────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.child,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            child,
          ],
        ),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  const _InputField({required this.controller, required this.label});

  final TextEditingController controller;
  final String label;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontFamily: 'monospace',
                ),
          ),
          Flexible(
            child: Text(
              value.isEmpty ? '—' : value,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontFamily: 'monospace',
                  ),
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
