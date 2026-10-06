import 'package:fivelink/core/operation.dart';
import 'package:fivelink/core/puzzle.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Esempio della sezione 2 del piano, tessere nell'ordine mostrato.
  final Puzzle example = Puzzle(
    start: 17,
    target: 163,
    tiles: const [
      Operation.multiply(3),
      Operation.add(7),
      Operation.subtract(8),
      Operation.multiply(2),
      Operation.add(9),
    ],
    solutions: const [
      [1, 3, 4, 0, 2],
    ],
  );

  test('the solution order solves the puzzle', () {
    expect(example.check(example.solution), AttemptOutcome.solved);
    expect(example.evaluate(example.solution).values, [24, 48, 57, 171, 163]);
    expect(example.tilesInOrder(example.solution).join(' '), '+7 ×2 +9 ×3 −8');
  });

  test('a complete chain with the wrong result', () {
    // 17 → 51 → 58 → 50 → 100 → 109
    expect(example.evaluate([0, 1, 2, 3, 4]).values, [51, 58, 50, 100, 109]);
    expect(example.check([0, 1, 2, 3, 4]), AttemptOutcome.wrongResult);
  });

  test('a broken chain', () {
    final Puzzle p = Puzzle(
      start: 5,
      target: 10,
      tiles: const [Operation.divide(2), Operation.add(5)],
      solutions: const [
        [1, 0],
      ],
    );
    expect(p.check([0, 1]), AttemptOutcome.broken);
    expect(p.check([1, 0]), AttemptOutcome.wrongResult);
  });

  test('validation uses the result, not the stored solution', () {
    final Puzzle p = Puzzle(
      start: 10,
      target: 13,
      tiles: const [Operation.add(1), Operation.add(2)],
      solutions: const [
        [0, 1],
      ],
    );
    expect(p.check([1, 0]), AttemptOutcome.solved);
  });

  test('orders that are not permutations are rejected', () {
    expect(() => example.evaluate([0, 1, 2, 3]), throwsArgumentError);
    expect(() => example.evaluate([0, 0, 1, 2, 3]), throwsArgumentError);
    expect(() => example.evaluate([0, 1, 2, 3, 5]), throwsArgumentError);
  });

  test('tiles and solutions are read-only', () {
    expect(
      () => example.tiles.add(const Operation.add(1)),
      throwsUnsupportedError,
    );
    expect(() => example.solution[0] = 4, throwsUnsupportedError);
  });

  test('a puzzle needs at least one solution', () {
    expect(
      () => Puzzle(start: 1, target: 2, tiles: const [], solutions: const []),
      throwsArgumentError,
    );
  });
}
