enum InputPhase { entering, awaitingOperand, result, error }

/// Immediate, left-to-right evaluation. Display is derived from authoritative state.
class CalculatorModel {
  double? accumulator;
  String operand = '0';
  String? pendingOperator;
  InputPhase phase = InputPhase.entering;
  String? message;

  String get display =>
      phase == InputPhase.awaitingOperand || phase == InputPhase.result
      ? format(accumulator ?? 0)
      : phase == InputPhase.error
      ? 'Error'
      : operand;

  static String format(double value) => value == 0
      ? '0'
      : value.toStringAsPrecision(12).replaceFirst(RegExp(r'\.?0+(?=e|$)'), '');

  void clear() {
    accumulator = null;
    operand = '0';
    pendingOperator = null;
    phase = InputPhase.entering;
    message = null;
  }

  void digit(String digit) {
    if (phase == InputPhase.result || phase == InputPhase.error) clear();
    if (phase == InputPhase.awaitingOperand) operand = '0';
    phase = InputPhase.entering;
    message = null;
    if (operand.length >= 12) {
      message = 'Maximum 12 digits per number.';
      return;
    }
    operand = operand == '0' ? digit : '$operand$digit';
  }

  bool _apply() {
    final right = double.parse(operand);
    if (pendingOperator == '/' && right == 0) {
      phase = InputPhase.error;
      message = 'Cannot divide by zero. Press AC or a digit to start again.';
      accumulator = null;
      pendingOperator = null;
      return false;
    }
    final left = accumulator ?? 0;
    accumulator = switch (pendingOperator) {
      '+' => left + right,
      '-' => left - right,
      '*' => left * right,
      '/' => left / right,
      _ => right,
    };
    if (!accumulator!.isFinite) {
      phase = InputPhase.error;
      message = 'Result is too large. Press AC or a digit to start again.';
      accumulator = null;
      pendingOperator = null;
      return false;
    }
    return true;
  }

  void operator(String operator) {
    if (phase == InputPhase.error) return;
    message = null;
    if (phase == InputPhase.entering && !_apply()) return;
    pendingOperator = operator;
    phase = InputPhase.awaitingOperand;
  }

  void equals() {
    if (phase == InputPhase.error || phase == InputPhase.result) return;
    if (phase == InputPhase.awaitingOperand) {
      // Feedback must not mutate the pending operation or numeric state.
      message = 'Enter a number to complete the operation.';
      return;
    }
    if (!_apply()) return;
    pendingOperator = null;
    phase = InputPhase.result;
    message = null;
  }
}
