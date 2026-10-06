/// Tessere operazione e applicazione di una tessera a un valore.
library;

/// Ogni valore intermedio e finale della catena deve stare in
/// `[minValue, maxValue]`.
const int minValue = 1;
const int maxValue = 999;

enum OperationKind { add, subtract, multiply, divide, reverse }

final class Operation {
  const Operation.add(int n)
    : assert(n >= 1 && n <= 9),
      kind = OperationKind.add,
      operand = n;

  const Operation.subtract(int n)
    : assert(n >= 1 && n <= 9),
      kind = OperationKind.subtract,
      operand = n;

  const Operation.multiply(int n)
    : assert(n == 2 || n == 3),
      kind = OperationKind.multiply,
      operand = n;

  const Operation.divide(int n)
    : assert(n == 2 || n == 3),
      kind = OperationKind.divide,
      operand = n;

  const Operation.reverse() : kind = OperationKind.reverse, operand = 0;

  final OperationKind kind;

  /// Il numero sulla tessera. Vale 0 per [OperationKind.reverse].
  final int operand;

  /// Moltiplicazione, divisione e inversione: il generatore ne vuole tra 2 e 4
  /// per rompicapo.
  bool get isSpecial => switch (kind) {
    OperationKind.add || OperationKind.subtract => false,
    OperationKind.multiply ||
    OperationKind.divide ||
    OperationKind.reverse => true,
  };

  /// Applica la tessera a [value], che deve già essere nell'intervallo
  /// valido. Restituisce null se la catena si spezza.
  int? apply(int value) {
    final int? result = switch (kind) {
      OperationKind.add => value + operand,
      OperationKind.subtract => value - operand,
      OperationKind.multiply => value * operand,
      OperationKind.divide => value % operand == 0 ? value ~/ operand : null,
      OperationKind.reverse => _reverseDigits(value),
    };
    if (result == null || result < minValue || result > maxValue) return null;
    return result;
  }

  /// Etichetta mostrata sulla tessera, con i simboli tipografici corretti.
  String get label => switch (kind) {
    OperationKind.add => '+$operand',
    OperationKind.subtract => '−$operand',
    OperationKind.multiply => '×$operand',
    OperationKind.divide => '÷$operand',
    OperationKind.reverse => '⇄',
  };

  /// Inverte le cifre. Restituisce null per valori di una cifra, che terminano
  /// per 0 o palindromi.
  static int? _reverseDigits(int value) {
    if (value < 10 || value % 10 == 0) return null;
    int reversed = 0;
    for (int rest = value; rest > 0; rest ~/= 10) {
      reversed = reversed * 10 + rest % 10;
    }
    return reversed == value ? null : reversed;
  }

  @override
  bool operator ==(Object other) =>
      other is Operation && other.kind == kind && other.operand == operand;

  @override
  int get hashCode => Object.hash(kind, operand);

  @override
  String toString() => label;
}
