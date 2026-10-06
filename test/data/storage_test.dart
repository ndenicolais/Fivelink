import 'package:fivelink/data/models.dart';
import 'package:fivelink/data/storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/test_storage.dart';

void main() {
  test('empty storage gives defaults', () async {
    final Storage storage = await createStorage();
    expect(storage.loadDay(DateTime(2026, 10, 10)), isNull);
    expect(storage.loadStats().played, 0);
    expect(storage.loadSettings().helpSeen, isFalse);
  });

  test('saves and loads a day under a versioned key', () async {
    final Storage storage = await createStorage();
    await storage.saveDay(
      DayRecord(
        date: '2026-10-10',
        attempts: const [
          [0, 1, 2, 3, 4],
        ],
        status: GameStatus.playing,
      ),
    );
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    expect(prefs.getKeys(), contains('day_v1_2026-10-10'));
    final DayRecord? back = storage.loadDay(DateTime(2026, 10, 10, 23, 59));
    expect(back!.attempts.single, [0, 1, 2, 3, 4]);
    expect(storage.loadDay(DateTime(2026, 10, 11)), isNull);
  });

  test('saves stats and settings', () async {
    final Storage storage = await createStorage();
    await storage.saveStats(Stats().recordWin(DateTime(2026, 10, 10), 2));
    await storage.saveSettings(const Settings(helpSeen: true));
    expect(storage.loadStats().won, 1);
    expect(storage.loadSettings().helpSeen, isTrue);
  });

  test('corrupt JSON does not crash', () async {
    final Storage storage = await createStorage({
      'stats_v1': '{not json',
      'settings_v1': '[]',
      'day_v1_2026-10-10': 'garbage',
    });
    expect(storage.loadStats().played, 0);
    expect(storage.loadSettings().helpSeen, isFalse);
    expect(storage.loadDay(DateTime(2026, 10, 10)), isNull);
  });

  test('prunes days older than 7 days and unreadable keys', () async {
    final Storage storage = await createStorage({
      'day_v1_2026-10-01': '{}',
      'day_v1_2026-10-02': '{}',
      'day_v1_2026-10-09': '{}',
      'day_v1_2026-10-10': '{}',
      'day_v1_bad': '{}',
      'stats_v1': '{}',
    });
    await storage.pruneOldDays(DateTime(2026, 10, 9));
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    expect(prefs.getKeys(), {
      'day_v1_2026-10-02',
      'day_v1_2026-10-09',
      'day_v1_2026-10-10',
      'stats_v1',
    });
  });
}
