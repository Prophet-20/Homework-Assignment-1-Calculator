import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:calculator_app/main.dart';
import 'package:calculator_app/calculator_model.dart';

void enter(CalculatorModel m, String s) {
  for (final k in s.split(' ')) {
    if (k == 'AC') {
      m.clear();
    } else if (k == '=') {
      m.equals();
    } else if (['+', '-', '*', '/'].contains(k)) {
      m.operator(k);
    } else {
      for (final d in k.split('')) {
        m.digit(d);
      }
    }
  }
}

void main() {
  test('left to right intermediate total', () {
    final m = CalculatorModel();
    enter(m, '2 + 3');
    expect(m.display, '3');
    m.operator('*');
    expect(m.display, '5');
    enter(m, '4 =');
    expect(m.display, '20');
  });
  for (final e in {
    '8 + 2 =': '10',
    '8 - 12 =': '-4',
    '8 * 2 =': '16',
    '9 / 2 =': '4.5',
    '20 - 4 / 2 + 3 * 2 =': '22',
    '9 + * 2 =': '18',
    '2 + 3 = 4 + 1 =': '5',
    '2 + 3 = =': '5',
  }.entries) {
    test(e.key, () {
      final m = CalculatorModel();
      enter(m, e.key);
      expect(m.display, e.value);
    });
  }
  test('digit after operator', () {
    final m = CalculatorModel();
    enter(m, '12 + 3');
    expect(m.operand, '3');
    expect(m.accumulator, 12);
  });
  test('incomplete equals preserves state and recovers', () {
    final m = CalculatorModel();
    enter(m, '7 + =');
    expect(m.display, '7');
    expect(m.accumulator, 7);
    expect(m.pendingOperator, '+');
    expect(m.phase, InputPhase.awaitingOperand);
    expect(m.message, contains('Enter a number'));
    enter(m, '2 =');
    expect(m.display, '9');
  });
  test('AC resets pending and completed state', () {
    for (final p in ['9 +', '9 + 2 =']) {
      final m = CalculatorModel();
      enter(m, '$p AC');
      expect(m.display, '0');
      expect(m.accumulator, isNull);
      expect(m.pendingOperator, isNull);
      expect(m.phase, InputPhase.entering);
      enter(m, '2 + 3 =');
      expect(m.display, '5');
    }
  });
  test('division by zero recovery', () {
    for (final end in ['=', '+']) {
      final m = CalculatorModel();
      enter(m, '8 / 0 $end');
      expect(m.display, 'Error');
      expect(m.message, contains('zero'));
      enter(m, '4 + 2 =');
      expect(m.display, '6');
      enter(m, 'AC');
      expect(m.message, isNull);
    }
  });
  test('format whole numbers', () {
    expect(CalculatorModel.format(100), '100');
    expect(CalculatorModel.format(0), '0');
  });
  testWidgets('UI flow themes semantics narrow layout', (tester) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(const CalculatorApp());
    for (final k in ['2', '+', '3', '×', '4', '=']) {
      await tester.tap(find.byKey(Key('key_$k')));
      await tester.pump();
    }
    expect(find.text('20'), findsOneWidget);
    expect(find.bySemanticsLabel('All clear'), findsOneWidget);
    expect(find.bySemanticsLabel('Divide'), findsOneWidget);
    await tester.tap(find.byTooltip('Use dark theme'));
    await tester.pumpAndSettle();
    expect(find.text('20'), findsOneWidget);
    expect(
      Theme.of(tester.element(find.byType(Scaffold))).brightness,
      Brightness.dark,
    );
    await tester.tap(find.byTooltip('Use light theme'));
    await tester.pumpAndSettle();
    expect(
      Theme.of(tester.element(find.byType(Scaffold))).brightness,
      Brightness.light,
    );
    await tester.tap(find.byKey(const Key('key_AC')));
    await tester.pump();
    expect(tester.widget<Text>(find.byKey(const Key('display'))).data, '0');
    expect(tester.takeException(), isNull);
    semantics.dispose();
  });
  testWidgets('large text landscape scrolls without overflow', (tester) async {
    tester.view.physicalSize = const Size(640, 360);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2)),
          child: CalculatorPage(dark: false, toggleTheme: () {}),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    await tester.ensureVisible(find.byKey(const Key('key_+')));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
