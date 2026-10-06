import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../core/daily.dart';
import 'models.dart';

/// Lettura e scrittura su shared_preferences, come JSON con chiavi versionate.
class Storage {
  Storage(this._prefs);

  final SharedPreferences _prefs;

  static const String statsKey = 'stats_v1';
  static const String settingsKey = 'settings_v1';
  static const String dayKeyPrefix = 'day_v1_';

  /// Le partite più vecchie di così vengono eliminate.
  static const int keepDays = 7;

  static String dayKeyFor(DateTime day) => '$dayKeyPrefix${dateKey(day)}';

  DayRecord? loadDay(DateTime day) {
    final DayRecord? record = DayRecord.fromJson(_readJson(dayKeyFor(day)));
    return record?.date == dateKey(day) ? record : null;
  }

  Future<void> saveDay(DayRecord record) =>
      _prefs.setString('$dayKeyPrefix${record.date}', jsonEncode(record));

  Stats loadStats() => Stats.fromJson(_readJson(statsKey));

  Future<void> saveStats(Stats stats) =>
      _prefs.setString(statsKey, jsonEncode(stats));

  Settings loadSettings() => Settings.fromJson(_readJson(settingsKey));

  Future<void> saveSettings(Settings settings) =>
      _prefs.setString(settingsKey, jsonEncode(settings));

  /// Elimina le partite salvate più vecchie di [keepDays] giorni rispetto a
  /// [today], e quelle con una chiave illeggibile.
  Future<void> pruneOldDays(DateTime today) async {
    for (final String key in _prefs.getKeys().toList()) {
      if (!key.startsWith(dayKeyPrefix)) continue;
      final DateTime? date = parseDateKey(key.substring(dayKeyPrefix.length));
      if (date == null || daysBetween(date, today) > keepDays) {
        await _prefs.remove(key);
      }
    }
  }

  Object? _readJson(String key) {
    final String? raw = _prefs.getString(key);
    if (raw == null) return null;
    try {
      return jsonDecode(raw);
    } on FormatException {
      return null;
    }
  }
}
