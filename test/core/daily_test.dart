// Le date si scrivono sempre per intero, anche quando il giorno è 1.
// ignore_for_file: avoid_redundant_argument_values

import 'package:fivelink/core/daily.dart';
import 'package:fivelink/core/puzzle_generator.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_clock.dart';

void main() {
  group('puzzleNumber', () {
    test('launch day is #1', () {
      expect(puzzleNumber(DateTime(2026, 10, 10)), 1);
      expect(puzzleNumber(DateTime(2026, 10, 11)), 2);
    });

    test('dates before launch do not crash', () {
      expect(puzzleNumber(DateTime(2026, 10, 9)), 0);
      expect(puzzleNumber(DateTime(2026, 10, 1)), -8);
    });

    test('time of day does not matter', () {
      expect(puzzleNumber(DateTime(2026, 10, 10, 0, 0, 1)), 1);
      expect(puzzleNumber(DateTime(2026, 10, 10, 23, 59, 59)), 1);
    });

    test('across the October DST change', () {
      // In Italia il 25 ottobre 2026 dura 25 ore.
      expect(puzzleNumber(DateTime(2026, 10, 24, 23, 30)), 15);
      expect(puzzleNumber(DateTime(2026, 10, 25)), 16);
      expect(puzzleNumber(DateTime(2026, 10, 25, 23, 59)), 16);
      expect(puzzleNumber(DateTime(2026, 10, 26)), 17);
      expect(puzzleNumber(DateTime(2026, 10, 26, 0, 30)), 17);
    });

    test('across the March DST change', () {
      // Il 28 marzo 2027 dura 23 ore.
      final int before = puzzleNumber(DateTime(2027, 3, 27, 23, 59));
      expect(puzzleNumber(DateTime(2027, 3, 28)), before + 1);
      expect(puzzleNumber(DateTime(2027, 3, 29, 0, 1)), before + 2);
    });

    test('across the end of the year', () {
      expect(puzzleNumber(DateTime(2026, 12, 31)), 83);
      expect(puzzleNumber(DateTime(2027, 1, 1)), 84);
    });

    test('across a leap day', () {
      final int feb28 = puzzleNumber(DateTime(2028, 2, 28));
      expect(puzzleNumber(DateTime(2028, 2, 29)), feb28 + 1);
      expect(puzzleNumber(DateTime(2028, 3, 1)), feb28 + 2);
    });

    test('every consecutive day increases by one', () {
      int previous = puzzleNumber(DateTime(2026, 10, 10));
      for (int i = 1; i < 1000; i++) {
        final int n = puzzleNumber(DateTime(2026, 10, 10 + i, 12));
        expect(n, previous + 1);
        previous = n;
      }
    });
  });

  group('time until the next puzzle', () {
    test('counts down to local midnight', () {
      expect(
        timeUntilNextPuzzle(DateTime(2026, 10, 20, 23, 59, 30)),
        const Duration(seconds: 30),
      );
      expect(
        timeUntilNextPuzzle(DateTime(2026, 12, 31, 22)),
        const Duration(hours: 2),
      );
    });

    test('lands exactly on the next day across DST changes', () {
      for (final DateTime now in [
        DateTime(2026, 10, 25),
        DateTime(2026, 10, 25, 1, 30),
        DateTime(2027, 3, 28),
        DateTime(2027, 3, 28, 1, 30),
      ]) {
        final Duration left = timeUntilNextPuzzle(now);
        expect(left, greaterThan(Duration.zero));
        expect(left, lessThanOrEqualTo(const Duration(hours: 25)));
        expect(
          localDay(now.add(left)),
          DateTime(now.year, now.month, now.day + 1),
        );
      }
    });

    test('nextMidnight rolls over months and years', () {
      expect(nextMidnight(DateTime(2026, 10, 31, 15)), DateTime(2026, 11, 1));
      expect(nextMidnight(DateTime(2026, 12, 31, 15)), DateTime(2027, 1, 1));
    });
  });

  test('daysBetween counts calendar days', () {
    expect(
      daysBetween(DateTime(2026, 10, 24, 23), DateTime(2026, 10, 26, 1)),
      2,
    );
    expect(daysBetween(DateTime(2026, 10, 10), DateTime(2026, 10, 9)), -1);
    expect(daysBetween(DateTime(2026, 12, 31), DateTime(2027, 1, 1)), 1);
  });

  test('parseDateKey reverses dateKey and rejects bad input', () {
    expect(parseDateKey('2026-10-25'), DateTime(2026, 10, 25));
    expect(parseDateKey(dateKey(DateTime(2028, 2, 29))), DateTime(2028, 2, 29));
    expect(parseDateKey('2026-02-31'), isNull);
    expect(parseDateKey('2026-1-5'), isNull);
    expect(parseDateKey('bad'), isNull);
  });

  test('dateKey is zero-padded', () {
    expect(dateKey(DateTime(2026, 1, 5)), '2026-01-05');
    expect(dateKey(DateTime(2026, 10, 25, 23, 59)), '2026-10-25');
  });

  group('DailyPuzzle', () {
    test('uses the injected clock', () {
      final FakeClock clock = FakeClock(DateTime(2026, 10, 25, 18, 45));
      final DailyPuzzle daily = DailyPuzzle.today(clock);
      expect(daily.date, DateTime(2026, 10, 25));
      expect(daily.number, 16);
      expect(
        daily.puzzle.tiles,
        generatePuzzleForDate(DateTime(2026, 10, 25)).tiles,
      );
    });

    test('isForDay detects a day change', () {
      final FakeClock clock = FakeClock(DateTime(2026, 10, 25, 23, 59));
      final DailyPuzzle daily = DailyPuzzle.today(clock);
      expect(daily.isForDay(clock.now()), isTrue);
      clock.current = DateTime(2026, 10, 26, 0, 0, 1);
      expect(daily.isForDay(clock.now()), isFalse);
      expect(DailyPuzzle.today(clock).number, 17);
    });

    test('works before the launch date', () {
      final DailyPuzzle daily = DailyPuzzle.forDate(DateTime(2026, 10, 6));
      expect(daily.number, -3);
      expect(daily.puzzle.solutions, isNotEmpty);
    });
  });
}
