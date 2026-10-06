import 'package:fivelink/core/puzzle.dart';
import 'package:fivelink/core/puzzle_generator.dart';
import 'package:fivelink/data/models.dart';
import 'package:fivelink/data/storage.dart';
import 'package:fivelink/game/game_controller.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_clock.dart';
import '../helpers/test_storage.dart';

/// Rompicapo #1 (10 ottobre 2026): partenza 17, obiettivo 114,
/// tessere `⇄ +4 ÷2 −3 ×3`, soluzione `[0, 3, 2, 1, 4]`.
final DateTime _launchDay = DateTime(2026, 10, 10, 9);

late Storage _storage;
late FakeClock _clock;

GameController _newGame() => GameController(storage: _storage, clock: _clock);

void _place(GameController c, List<int> order) {
  c.clearSlots();
  order.forEach(c.placeTile);
}

/// Ordini sbagliati e distinti tra loro.
List<List<int>> _wrongOrders(Puzzle p) => [
  for (final List<int> o in permutations(p.tiles.length))
    if (p.check(o) != AttemptOutcome.solved) o,
];

void _win(GameController c) {
  _place(c, c.puzzle.solution);
  c.submit();
}

void _lose(GameController c) {
  final List<List<int>> wrong = _wrongOrders(c.puzzle);
  for (int i = 0; i < maxAttempts; i++) {
    _place(c, wrong[i]);
    c.submit();
  }
}

void main() {
  setUp(() async {
    _storage = await createStorage();
    _clock = FakeClock(_launchDay);
  });

  group('playing', () {
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
      _lose(c);
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
      _win(c);
      expect(c.status, GameStatus.won);
      expect(c.stats.distribution[maxAttempts - 1], 1);
    });

    test('input is ignored once the game is over', () {
      final GameController c = _newGame();
      _win(c);
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

    test('share text reflects the attempts', () {
      final GameController c = _newGame();
      _place(c, [0, 1, 2, 3, 4]);
      c.submit();
      _win(c);
      expect(c.shareText, 'Fivelink #1 · 2/6\n🟥🟩');
    });
  });

  group('persistence', () {
    test('a game in progress is restored after a restart', () {
      final GameController first = _newGame();
      _place(first, [0, 1, 2, 3, 4]);
      first.submit();
      _place(first, [4, 3, 2, 1, 0]);
      first.submit();

      final GameController second = _newGame();
      expect(second.attempts.map((a) => a.order), [
        [0, 1, 2, 3, 4],
        [4, 3, 2, 1, 0],
      ]);
      expect(second.status, GameStatus.playing);
      expect(second.slots, [4, 3, 2, 1, 0], reason: 'last order is kept');
      expect(second.isDuplicate, isTrue);
    });

    test('a finished game is restored without counting it twice', () {
      _win(_newGame());
      final GameController again = _newGame();
      expect(again.status, GameStatus.won);
      expect(again.stats.played, 1);
      expect(again.stats.won, 1);
    });

    test('stats saved late are recovered on the next start', () async {
      // Partita salvata come vinta, ma statistiche mai scritte.
      _win(_newGame());
      await _storage.saveStats(Stats());
      final GameController again = _newGame();
      expect(again.stats.played, 1);
      expect(again.stats.currentStreak, 1);
    });

    test('a corrupt saved order is ignored', () async {
      await _storage.saveDay(
        DayRecord(
          date: '2026-10-10',
          attempts: const [
            [0, 0, 0, 0, 0],
          ],
          status: GameStatus.playing,
        ),
      );
      final GameController c = _newGame();
      expect(c.attempts, isEmpty);
      expect(c.slotsEmpty, isTrue);
    });
  });

  group('days and streaks', () {
    test('refreshDay loads the next puzzle after midnight', () {
      final GameController c = _newGame();
      _win(c);
      expect(c.refreshDay(), isFalse);

      _clock.current = DateTime(2026, 10, 11, 0, 0, 2);
      expect(c.refreshDay(), isTrue);
      expect(c.daily.number, 2);
      expect(c.status, GameStatus.playing);
      expect(c.attempts, isEmpty);
      expect(c.stats.played, 1);
    });

    test('consecutive wins build a streak', () {
      for (int day = 10; day <= 12; day++) {
        _clock.current = DateTime(2026, 10, day, 20);
        _win(_newGame());
      }
      final GameController c = _newGame();
      expect(c.stats.currentStreak, 3);
      expect(c.currentStreak, 3);
      expect(c.stats.maxStreak, 3);
    });

    test('a skipped day resets the shown streak', () {
      _win(_newGame());
      _clock.current = DateTime(2026, 10, 11, 20);
      _win(_newGame());

      _clock.current = DateTime(2026, 10, 13, 8);
      final GameController c = _newGame();
      expect(c.currentStreak, 0);
      _win(c);
      expect(c.currentStreak, 1);
      expect(c.stats.maxStreak, 2);
    });

    test('a loss resets the streak', () {
      _win(_newGame());
      _clock.current = DateTime(2026, 10, 11, 20);
      final GameController c = _newGame();
      _lose(c);
      expect(c.currentStreak, 0);
      expect(c.stats.played, 2);
      expect(c.stats.won, 1);
    });

    test('moving the clock back to a played day does not count it twice', () {
      _win(_newGame());
      _clock.current = DateTime(2026, 10, 11, 20);
      _win(_newGame());

      _clock.current = DateTime(2026, 10, 10, 21);
      final GameController back = _newGame();
      expect(back.status, GameStatus.won, reason: 'saved game is restored');
      expect(back.stats.played, 2);
      expect(back.stats.won, 2);
      expect(back.stats.currentStreak, 2);
    });

    test('a past day played late does not count or break the streak', () {
      _clock.current = DateTime(2026, 10, 12, 9);
      _win(_newGame());
      _clock.current = DateTime(2026, 10, 13, 9);
      _win(_newGame());

      _clock.current = DateTime(2026, 10, 11, 9);
      final GameController past = _newGame();
      _lose(past);
      expect(past.stats.played, 2);
      expect(past.stats.currentStreak, 2);
    });

    test('playing ahead counts, then today no longer does', () {
      _clock.current = DateTime(2026, 10, 15, 9);
      _win(_newGame());

      _clock.current = DateTime(2026, 10, 10, 9);
      final GameController today = _newGame();
      _win(today);
      expect(today.status, GameStatus.won);
      expect(today.stats.played, 1);
      expect(today.stats.lastCompletedDate, '2026-10-15');
    });

    test('old saved days are pruned', () async {
      _win(_newGame());
      _clock.current = DateTime(2026, 10, 20, 9);
      _newGame();
      await Future<void>.delayed(Duration.zero);
      expect(_storage.loadDay(DateTime(2026, 10, 10)), isNull);
    });
  });
}
