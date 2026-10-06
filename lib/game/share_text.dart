import '../core/puzzle.dart';

/// Testo di condivisione, senza rivelare la soluzione:
///
/// ```
/// Fivelink #12 · 3/6
/// 🟥🟧🟩
/// ```
///
/// Una partita persa mostra `X/6`.
String buildShareText({
  required int number,
  required List<AttemptOutcome> outcomes,
}) {
  final bool won =
      outcomes.isNotEmpty && outcomes.last == AttemptOutcome.solved;
  final String score = won ? '${outcomes.length}' : 'X';
  final String squares = outcomes.map(_square).join();
  return 'Fivelink #$number · $score/$maxAttempts\n$squares';
}

String _square(AttemptOutcome outcome) => switch (outcome) {
  AttemptOutcome.broken => '🟥',
  AttemptOutcome.wrongResult => '🟧',
  AttemptOutcome.solved => '🟩',
};
