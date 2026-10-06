import 'package:fivelink/core/daily.dart';
import 'package:fivelink/core/puzzle.dart';
import 'package:fivelink/core/puzzle_generator.dart';
import 'package:fivelink/game/game_controller.dart';
import 'package:flutter_test/flutter_test.dart';

/// Rompicapo #1 (10 ottobre 2026): partenza 17, obiettivo 114,
/// tessere `⇄ +4 ÷2 −3 ×3`, soluzione `[0, 3, 2, 1, 4]`.
GameController _newGame() =>
    GameController(daily: DailyPuzzle.forDate(DateTime(2026, 10, 10)));

void _place(GameController c, List<int> order) {
  c.clearSlots();
  order.forEach(c.placeTile);
}

/// Ordini sbagliati e distinti tra loro.
List<List<int>> _wrongOrders(Puzzle p) => [
  for (final List<int> o in permutations(p.tiles.length))
    if (p.check(o) != AttemptOutcome.solved) o,
];

void main() {
  test('starts empty and playing', () {
    final GameController c = _newGame();
    expect(c.daily.number, 1);
    expect(c.status, GameStatus.playing);
    expect(c.slots, everyElement(isNull));
    expect(c.attemptsLeft, maxAttempts);
    expect(c.canSubmit, isFalse);
  });

  test('tiles go to the first free slot and come back when removed', () {
    final GameController c = _newGame();
    c.placeTile(3);
    c.placeTile(1);
    expect(c.slots, [3, 1, null, null, null]);
    expect(c.isTileUsed(3), isTrue);

    c.placeTile(3);
    expect(c.slots, [3, 1, null, null, null], reason: 'already placed');

    c.clearSlot(0);
    expect(c.slots, [null, 1, null, null, null]);
    expect(c.isTileUsed(3), isFalse);

    c.placeTile(4);
    expect(c.slots, [4, 1, null, null, null], reason: 'fills the gap first');
  });

  test('clearSlots empties everything', () {
    final GameController c = _newGame();
    _place(c, [0, 1, 2]);
    c.clearSlots();
    expect(c.slotsEmpty, isTrue);
  });

  test('submit needs all slots full', () {
    final GameController c = _newGame();
    _place(c, [0, 1, 2, 3]);
    expect(c.submit(), isNull);
    expect(c.attempts, isEmpty);
  });

  test('a wrong attempt is recorded and the slots stay filled', () {
    final GameController c = _newGame();
    _place(c, [0, 1, 2, 3, 4]);
    final Attempt? a = c.submit();
    expect(a, isNotNull);
    expect(a!.outcome, isNot(AttemptOutcome.solved));
    expect(c.attempts, hasLength(1));
    expect(c.status, GameStatus.playing);
    expect(c.slots, [0, 1, 2, 3, 4]);
  });

  test('the same order cannot be submitted twice', () {
    final GameController c = _newGame();
    _place(c, [0, 1, 2, 3, 4]);
    c.submit();
    expect(c.isDuplicate, isTrue);
    expect(c.canSubmit, isFalse);
    expect(c.submit(), isNull);
    expect(c.attempts, hasLength(1));

    c.clearSlot(4);
    expect(c.isDuplicate, isFalse);
  });

  test('solving wins the game', () {
    final GameController c = _newGame();
    _place(c, c.puzzle.solution);
    final Attempt? a = c.submit();
    expect(a!.outcome, AttemptOutcome.solved);
    expect(a.result.values, [71, 68, 34, 38, 114]);
    expect(c.status, GameStatus.won);
    expect(c.isOver, isTrue);
  });

  test('six wrong attempts lose the game', () {
    final GameController c = _newGame();
    final List<List<int>> wrong = _wrongOrders(c.puzzle);
    for (int i = 0; i < maxAttempts; i++) {
      expect(c.status, GameStatus.playing);
      _place(c, wrong[i]);
      expect(c.submit(), isNotNull);
    }
    expect(c.status, GameStatus.lost);
    expect(c.attemptsLeft, 0);
  });

  test('winning on the last attempt is a win', () {
    final GameController c = _newGame();
    final List<List<int>> wrong = _wrongOrders(c.puzzle);
    for (int i = 0; i < maxAttempts - 1; i++) {
      _place(c, wrong[i]);
      c.submit();
    }
    _place(c, c.puzzle.solution);
    c.submit();
    expect(c.status, GameStatus.won);
  });

  test('input is ignored once the game is over', () {
    final GameController c = _newGame();
    _place(c, c.puzzle.solution);
    c.submit();
    c.clearSlots();
    c.clearSlot(0);
    expect(c.slots, c.puzzle.solution);
    expect(c.submit(), isNull);
  });

  test('listeners are notified on every change', () {
    final GameController c = _newGame();
    int calls = 0;
    c.addListener(() => calls++);
    c.placeTile(0);
    c.clearSlot(0);
    _place(c, [0, 1, 2, 3, 4]);
    c.submit();
    expect(calls, 1 + 1 + 5 + 1);
  });
}
