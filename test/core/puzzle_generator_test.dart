// Le date si scrivono sempre per intero, anche quando il giorno è 1.
// ignore_for_file: avoid_redundant_argument_values

import 'package:fivelink/core/chain.dart';
import 'package:fivelink/core/operation.dart';
import 'package:fivelink/core/puzzle.dart';
import 'package:fivelink/core/puzzle_generator.dart';
import 'package:flutter_test/flutter_test.dart';

/// Rompicapi attesi per alcune date fisse: partenza, obiettivo, tessere
/// nell'ordine mostrato, soluzione.
///
/// Se questo test fallisce, il generatore è stato modificato e i rompicapi di
/// tutti i giorni sono cambiati. Aggiorna lo snapshot solo se la modifica è
/// voluta (e in quel caso incrementa `generatorVersion`).
final List<(DateTime, int, int, String, List<int>)> _snapshot = [
  (DateTime(2026, 10, 1), 15, 56, '+2 +9 −3 ⇄ ×2', [1, 4, 2, 3, 0]),
  (DateTime(2026, 10, 10), 17, 114, '⇄ +4 ÷2 −3 ×3', [0, 3, 2, 1, 4]),
  (DateTime(2026, 10, 11), 4, 42, '×3 ⇄ +6 −5 +9', [2, 3, 0, 4, 1]),
  (DateTime(2026, 10, 25), 8, 65, '×3 +6 +4 +1 ⇄', [1, 0, 2, 4, 3]),
  (DateTime(2026, 10, 26), 5, 12, '×3 ÷2 +7 −5 +4', [4, 0, 2, 1, 3]),
  (DateTime(2026, 12, 31), 20, 68, '+6 +5 ⇄ +3 ×2', [1, 4, 0, 2, 3]),
  (DateTime(2027, 1, 1), 18, 15, '÷2 +5 −4 ⇄ −6', [2, 0, 1, 3, 4]),
  (DateTime(2027, 2, 28), 7, 10, '⇄ ÷2 −1 +5 +1', [3, 0, 4, 1, 2]),
  (DateTime(2028, 2, 29), 10, 95, '×3 ⇄ +1 +9 −8', [3, 0, 4, 1, 2]),
  (DateTime(2030, 6, 15), 16, 11, '−2 +5 ×3 −8 ÷2', [3, 4, 0, 2, 1]),
];

void main() {
  test('pool has the 23 expected distinct tiles', () {
    expect(operationPool, hasLength(23));
    expect(operationPool.toSet(), hasLength(23));
    expect(operationPool.where((op) => op.isSpecial), hasLength(5));
  });

  test('permutations of 5 are the 120 distinct orders', () {
    final List<List<int>> perms = permutations(5);
    expect(perms, hasLength(120));
    expect(perms.map((p) => p.join()).toSet(), hasLength(120));
    expect(perms.first, [0, 1, 2, 3, 4]);
    expect(perms.last, [4, 3, 2, 1, 0]);
  });

  test('the example from the plan has exactly one solution', () {
    const List<Operation> tiles = [
      Operation.multiply(3),
      Operation.add(7),
      Operation.subtract(8),
      Operation.multiply(2),
      Operation.add(9),
    ];
    final List<List<int>> solutions = findSolutions(17, 163, tiles);
    expect(solutions, [
      [1, 3, 4, 0, 2],
    ]);
    expect(
      evaluateChain(17, [
        for (final int i in solutions.single) tiles[i],
      ]).values,
      [24, 48, 57, 171, 163],
    );
  });

  test('730 consecutive days produce valid puzzles', () {
    for (int i = 0; i < 730; i++) {
      final DateTime day = DateTime(2026, 10, 10 + i);
      final Puzzle p = generatePuzzleForDate(day);
      final String where = 'on $day';

      expect(p.start, inInclusiveRange(2, 20), reason: where);
      expect(p.target, inInclusiveRange(10, 300), reason: where);
      expect(p.target, isNot(p.start), reason: where);
      expect(p.tiles, hasLength(tileCount), reason: where);
      expect(p.tiles.toSet(), hasLength(tileCount), reason: where);
      expect(
        p.tiles.where((op) => op.isSpecial).length,
        inInclusiveRange(2, 4),
        reason: where,
      );
      expect(p.solutions.length, inInclusiveRange(1, 2), reason: where);
      for (final List<int> s in p.solutions) {
        expect(
          s,
          isNot([0, 1, 2, 3, 4]),
          reason: 'tiles shown already in solution order ',
        );
      }

      // Le soluzioni dichiarate sono esattamente quelle reali.
      final Set<String> actual = {
        for (final List<int> s in findSolutions(p.start, p.target, p.tiles))
          s.join(),
      };
      expect(actual, {
        for (final List<int> s in p.solutions) s.join(),
      }, reason: where);

      for (final List<int> s in p.solutions) {
        final ChainResult r = p.evaluate(s);
        expect(p.outcomeOf(r), AttemptOutcome.solved, reason: where);
        for (final int v in r.values) {
          expect(v, inInclusiveRange(minValue, maxValue), reason: where);
        }
      }
    }
  });

  test('in normal conditions there is exactly one solution', () {
    for (int i = 0; i < 730; i++) {
      final Puzzle p = generatePuzzleForDate(DateTime(2026, 10, 10 + i));
      expect(p.solutions, hasLength(1));
    }
  });

  test('snapshot of fixed dates is unchanged', () {
    for (final (
          DateTime day,
          int start,
          int target,
          String tiles,
          List<int> solution,
        )
        in _snapshot) {
      final Puzzle p = generatePuzzleForDate(day);
      expect(
        (p.start, p.target, p.tiles.join(' '), p.solution.join()),
        (start, target, tiles, solution.join()),
        reason: 'on $day',
      );
    }
  });

  test('only the calendar day matters, not the time', () {
    final Puzzle morning = generatePuzzleForDate(DateTime(2026, 11, 3, 0, 1));
    final Puzzle night = generatePuzzleForDate(DateTime(2026, 11, 3, 23, 59));
    final Puzzle utc = generatePuzzleForDate(DateTime.utc(2026, 11, 3, 12));
    for (final Puzzle p in [night, utc]) {
      expect(p.tiles, morning.tiles);
      expect(p.start, morning.start);
      expect(p.target, morning.target);
    }
  });

  test('different days give different puzzles', () {
    final Puzzle a = generatePuzzleForDate(DateTime(2026, 11, 3));
    final Puzzle b = generatePuzzleForDate(DateTime(2026, 11, 4));
    expect((
      a.start,
      a.target,
      a.tiles.join(),
    ), isNot((b.start, b.target, b.tiles.join())));
  });

  test('day seeds are never zero', () {
    for (int i = 0; i < 3650; i++) {
      expect(dateSeed(DateTime(2026, 1, 1 + i)), isNot(0));
    }
  });
}
