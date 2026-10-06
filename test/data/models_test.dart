// Le date si scrivono sempre per intero, anche quando il giorno è 1.
// ignore_for_file: avoid_redundant_argument_values

import 'dart:convert';

import 'package:fivelink/data/models.dart';
import 'package:flutter_test/flutter_test.dart';

DateTime _day(int d) => DateTime(2026, 10, d);

void main() {
  group('Stats streaks', () {
    test('consecutive wins grow the streak', () {
      final Stats s = Stats()
          .recordWin(_day(10), 3)
          .recordWin(_day(11), 1)
          .recordWin(_day(12), 6);
      expect(s.currentStreak, 3);
      expect(s.maxStreak, 3);
      expect(s.played, 3);
      expect(s.won, 3);
      expect(s.distribution, [1, 0, 1, 0, 0, 1]);
      expect(s.lastWonDate, '2026-10-12');
      expect(s.streakOn(_day(12)), 3);
      expect(s.streakOn(_day(13)), 3, reason: 'today is not over yet');
    });

    test('a skipped day resets the streak', () {
      final Stats s = Stats().recordWin(_day(10), 2).recordWin(_day(11), 2);
      expect(s.streakOn(_day(13)), 0);
      final Stats after = s.recordWin(_day(13), 2);
      expect(after.currentStreak, 1);
      expect(after.maxStreak, 2);
    });

    test('a loss resets the streak but keeps the best one', () {
      final Stats s = Stats()
          .recordWin(_day(10), 2)
          .recordWin(_day(11), 2)
          .recordLoss(_day(12));
      expect(s.currentStreak, 0);
      expect(s.maxStreak, 2);
      expect(s.played, 3);
      expect(s.won, 2);
      expect(s.winPercent, 67);
      expect(s.lastCompletedDate, '2026-10-12');
      expect(s.lastWonDate, '2026-10-11');
      expect(s.recordWin(_day(13), 1).currentStreak, 1);
    });

    test('streaks cross month and year boundaries', () {
      final Stats s = Stats()
          .recordWin(DateTime(2026, 12, 31), 2)
          .recordWin(DateTime(2027, 1, 1), 2);
      expect(s.currentStreak, 2);
    });

    test('empty stats', () {
      final Stats s = Stats();
      expect(s.winPercent, 0);
      expect(s.streakOn(_day(10)), 0);
      expect(s.distribution, List<int>.filled(6, 0));
    });
  });

  group('JSON', () {
    test('Stats round trip', () {
      final Stats s = Stats().recordWin(_day(10), 4).recordLoss(_day(11));
      final Stats back = Stats.fromJson(jsonDecode(jsonEncode(s)));
      expect(back.toJson(), s.toJson());
    });

    test('corrupt Stats fall back to defaults field by field', () {
      final Stats s = Stats.fromJson({
        'played': 'x',
        'won': 3,
        'distribution': [1, 'a', -2],
        'lastWonDate': 5,
      });
      expect(s.played, 0);
      expect(s.won, 3);
      expect(s.distribution, [1, 0, 0, 0, 0, 0]);
      expect(s.lastWonDate, isNull);
      expect(Stats.fromJson('nope').played, 0);
    });

    test('DayRecord round trip', () {
      final DayRecord r = DayRecord(
        date: '2026-10-10',
        attempts: const [
          [0, 1, 2, 3, 4],
          [4, 3, 2, 1, 0],
        ],
        status: GameStatus.lost,
      );
      final DayRecord? back = DayRecord.fromJson(jsonDecode(jsonEncode(r)));
      expect(back!.date, r.date);
      expect(back.attempts, r.attempts);
      expect(back.status, GameStatus.lost);
    });

    test('malformed DayRecord is rejected', () {
      expect(DayRecord.fromJson(null), isNull);
      expect(DayRecord.fromJson({'date': '2026-10-10'}), isNull);
      expect(
        DayRecord.fromJson({
          'date': '2026-10-10',
          'attempts': [
            [0, 'x'],
          ],
          'status': 'playing',
        }),
        isNull,
      );
      expect(
        DayRecord.fromJson({
          'date': '2026-10-10',
          'attempts': <Object?>[],
          'status': 'unknown',
        }),
        isNull,
      );
    });

    test('Settings round trip and defaults', () {
      const Settings s = Settings(
        theme: ThemePreference.dark,
        haptics: false,
        helpSeen: true,
      );
      final Settings back = Settings.fromJson(jsonDecode(jsonEncode(s)));
      expect(back.theme, ThemePreference.dark);
      expect(back.haptics, isFalse);
      expect(back.helpSeen, isTrue);

      final Settings defaults = Settings.fromJson({'theme': 'neon'});
      expect(defaults.theme, ThemePreference.system);
      expect(defaults.haptics, isTrue);
      expect(defaults.helpSeen, isFalse);
    });
  });
}
