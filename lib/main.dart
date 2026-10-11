import 'package:flutter/material.dart';

import 'calculator_model.dart';

void main() => runApp(const CalculatorApp());

class CalculatorApp extends StatefulWidget {
  const CalculatorApp({super.key});
  @override
  State<CalculatorApp> createState() => _CalculatorAppState();
}

class _CalculatorAppState extends State<CalculatorApp> {
  bool dark = false;
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Calculator State Lab',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff225c55)),
      useMaterial3: true,
    ),
    darkTheme: ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xff72d3bf),
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
    ),
    themeMode: dark ? ThemeMode.dark : ThemeMode.light,
    themeAnimationDuration: const Duration(milliseconds: 300),
    home: CalculatorPage(
      dark: dark,
      toggleTheme: () => setState(() => dark = !dark),
    ),
  );
}

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({
    super.key,
    required this.dark,
    required this.toggleTheme,
  });
  final bool dark;
  final VoidCallback toggleTheme;
  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  final model = CalculatorModel();
  String announcement = 'Ready';
  void press(String key) => setState(() {
    if (key == 'AC') {
      model.clear();
      announcement = 'Cleared. Result 0';
    } else if (key == '=') {
      model.equals();
      announcement = model.message ?? 'Result ${model.display}';
    } else if (['+', '−', '×', '÷'].contains(key)) {
      model.operator({'−': '-', '×': '*', '÷': '/'}[key] ?? key);
      announcement = model.message ?? 'Running total ${model.display}';
    } else {
      model.digit(key);
      if (model.message != null) announcement = model.message!;
    }
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    const keys = [
      '7',
      '8',
      '9',
      '÷',
      '4',
      '5',
      '6',
      '×',
      '1',
      '2',
      '3',
      '−',
      'AC',
      '0',
      '=',
      '+',
    ];
    const labels = {
      'AC': 'All clear',
      '=': 'Equals',
      '+': 'Add',
      '−': 'Subtract',
      '×': 'Multiply',
      '÷': 'Divide',
    };
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculator'),
        actions: [
          IconButton(
            tooltip: widget.dark ? 'Use light theme' : 'Use dark theme',
            onPressed: widget.toggleTheme,
            icon: Icon(widget.dark ? Icons.light_mode : Icons.dark_mode),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'STATE LAB / UNDERGRADUATE',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        const SizedBox(height: 8),
                        const Text('Operations run from left to right.'),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: colors.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                model.pendingOperator == null
                                    ? (model.phase == InputPhase.result
                                          ? 'RESULT'
                                          : 'READY')
                                    : 'RUNNING TOTAL ${CalculatorModel.format(model.accumulator ?? 0)}  ${model.pendingOperator}',
                                key: const Key('runningTotal'),
                              ),
                              const SizedBox(height: 12),
                              Semantics(
                                label: 'Display ${model.display}',
                                excludeSemantics: true,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    model.display,
                                    key: const Key('display'),
                                    style: Theme.of(context)
                                        .textTheme
                                        .displayLarge,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Semantics(
                          liveRegion: true,
                          label: announcement,
                          excludeSemantics: true,
                          child: Text(
                            model.message ??
                                'Enter a number, then choose an operation.',
                            key: const Key('feedback'),
                            style: TextStyle(
                              color: model.message == null
                                  ? colors.onSurfaceVariant
                                  : colors.error,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        GridView.count(
                          crossAxisCount: 4,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          childAspectRatio: 1.05,
                          children: keys.map((key) {
                            final special = labels.containsKey(key);
                            return Semantics(
                              label: labels[key] ?? key,
                              button: true,
                              excludeSemantics: true,
                              child: FilledButton(
                                key: Key('key_$key'),
                                onPressed: () => press(key),
                                style: FilledButton.styleFrom(
                                  padding: const EdgeInsets.all(4),
                                  minimumSize: const Size(48, 48),
                                  backgroundColor: special
                                      ? colors.primaryContainer
                                      : colors.surfaceContainerHighest,
                                  foregroundColor: special
                                      ? colors.onPrimaryContainer
                                      : colors.onSurface,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    key,
                                    style: const TextStyle(fontSize: 26),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'AC resets every part of the calculation.',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
