import 'package:fivelink/core/puzzle.dart';
import 'package:fivelink/game/share_text.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('a win shows the score and one square per attempt', () {
    expect(
      buildShareText(
        number: 12,
        outcomes: const [
          AttemptOutcome.broken,
          AttemptOutcome.wrongResult,
          AttemptOutcome.solved,
        ],
      ),
      'Fivelink #12 · 3/6\n🟥🟧🟩',
    );
  });

  test('a first-try win', () {
    expect(
      buildShareText(number: 1, outcomes: const [AttemptOutcome.solved]),
      'Fivelink #1 · 1/6\n🟩',
    );
  });

  test('a loss shows X', () {
    expect(
      buildShareText(
        number: 3,
        outcomes: List.filled(6, AttemptOutcome.wrongResult),
      ),
      'Fivelink #3 · X/6\n🟧🟧🟧🟧🟧🟧',
    );
  });
}
