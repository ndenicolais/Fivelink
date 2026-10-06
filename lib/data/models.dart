/// Stato della giornata, statistiche e impostazioni, con conversione JSON.
///
/// I `fromJson` sono tolleranti: dati mancanti o corrotti non devono mai far
/// crashare l'app, al massimo si riparte dai valori iniziali.
library;

import '../core/daily.dart';
import '../core/puzzle.dart';

enum GameStatus { playing, won, lost }

/// Partita di un giorno, salvata per riprenderla se l'app viene chiusa.
final class DayRecord {
  DayRecord({
    required this.date,
    required List<List<int>> attempts,
    required this.status,
  }) : attempts = List.unmodifiable(
         attempts.map<List<int>>(List<int>.unmodifiable),
       );

  /// Data nel formato di [dateKey].
  final String date;

  /// Ogni tentativo come lista di indici delle tessere.
  final List<List<int>> attempts;
  final GameStatus status;

  Map<String, Object?> toJson() => {
    'date': date,
    'attempts': attempts,
    'status': status.name,
  };

  static DayRecord? fromJson(Object? json) {
    if (json is! Map<String, Object?>) return null;
    final Object? date = json['date'];
    final Object? attempts = json['attempts'];
    final GameStatus? status = _enumByName(GameStatus.values, json['status']);
    if (date is! String || attempts is! List<Object?> || status == null) {
      return null;
    }
    final List<List<int>> parsed = [];
    for (final Object? attempt in attempts) {
      if (attempt is! List<Object?> || attempt.any((i) => i is! int)) {
        return null;
      }
      parsed.add(attempt.cast<int>());
    }
    return DayRecord(date: date, attempts: parsed, status: status);
  }
}

final class Stats {
  Stats({
    this.played = 0,
    this.won = 0,
    this.currentStreak = 0,
    this.maxStreak = 0,
    List<int>? distribution,
    this.lastCompletedDate,
    this.lastWonDate,
  }) : distribution = List.unmodifiable(
         distribution ?? List<int>.filled(maxAttempts, 0),
       );

  final int played;
  final int won;

  /// Serie salvata all'ultima partita conclusa. Per mostrarla usa [streakOn],
  /// che la azzera se nel frattempo è stato saltato un giorno.
  final int currentStreak;
  final int maxStreak;

  /// Vittorie per numero di tentativi: indice 0 = vinta al primo.
  final List<int> distribution;

  /// Date nel formato di [dateKey].
  final String? lastCompletedDate;
  final String? lastWonDate;

  int get winPercent => played == 0 ? 0 : (won * 100 / played).round();

  /// Le statistiche avanzano solo in avanti nel tempo: una partita conta solo
  /// se il suo giorno viene dopo l'ultimo già conteggiato. Così spostare
  /// indietro la data del telefono (o cambiare fuso) non conta due volte la
  /// stessa partita e non rompe la serie.
  bool countsFor(DateTime day) {
    final DateTime? last = lastCompletedDate == null
        ? null
        : parseDateKey(lastCompletedDate!);
    return last == null || daysBetween(last, day) > 0;
  }

  /// Una vittoria aumenta la serie se l'ultima vittoria è di ieri, altrimenti
  /// la riporta a 1.
  Stats recordWin(DateTime day, int attempts) {
    final int streak = _isDayBefore(lastWonDate, day) ? currentStreak + 1 : 1;
    final List<int> dist = [...distribution];
    dist[(attempts - 1).clamp(0, maxAttempts - 1)]++;
    return Stats(
      played: played + 1,
      won: won + 1,
      currentStreak: streak,
      maxStreak: streak > maxStreak ? streak : maxStreak,
      distribution: dist,
      lastCompletedDate: dateKey(day),
      lastWonDate: dateKey(day),
    );
  }

  /// Una sconfitta azzera la serie.
  Stats recordLoss(DateTime day) => Stats(
    played: played + 1,
    won: won,
    maxStreak: maxStreak,
    distribution: distribution,
    lastCompletedDate: dateKey(day),
    lastWonDate: lastWonDate,
  );

  /// Serie valida in [today]: resta solo se l'ultima vittoria è di oggi o di
  /// ieri.
  int streakOn(DateTime today) {
    final DateTime? won = lastWonDate == null
        ? null
        : parseDateKey(lastWonDate!);
    if (won == null) return 0;
    final int gap = daysBetween(won, today);
    return gap == 0 || gap == 1 ? currentStreak : 0;
  }

  static bool _isDayBefore(String? key, DateTime day) {
    final DateTime? date = key == null ? null : parseDateKey(key);
    return date != null && daysBetween(date, day) == 1;
  }

  Map<String, Object?> toJson() => {
    'played': played,
    'won': won,
    'currentStreak': currentStreak,
    'maxStreak': maxStreak,
    'distribution': distribution,
    'lastCompletedDate': lastCompletedDate,
    'lastWonDate': lastWonDate,
  };

  static Stats fromJson(Object? json) {
    if (json is! Map<String, Object?>) return Stats();
    int count(String key) {
      final Object? v = json[key];
      return v is int && v >= 0 ? v : 0;
    }

    final Object? dist = json['distribution'];
    final List<int> parsed = List<int>.filled(maxAttempts, 0);
    if (dist is List<Object?>) {
      for (int i = 0; i < dist.length && i < maxAttempts; i++) {
        final Object? v = dist[i];
        if (v is int && v >= 0) parsed[i] = v;
      }
    }
    final Object? completed = json['lastCompletedDate'];
    final Object? lastWon = json['lastWonDate'];
    return Stats(
      played: count('played'),
      won: count('won'),
      currentStreak: count('currentStreak'),
      maxStreak: count('maxStreak'),
      distribution: parsed,
      lastCompletedDate: completed is String ? completed : null,
      lastWonDate: lastWon is String ? lastWon : null,
    );
  }
}

enum ThemePreference { system, light, dark }

/// Lingua dell'app: quella del dispositivo (con l'inglese come ripiego) oppure
/// una scelta a mano.
enum LanguagePreference { system, italian, english }

final class Settings {
  const Settings({
    this.theme = ThemePreference.system,
    this.language = LanguagePreference.system,
    this.haptics = true,
    this.helpSeen = false,
  });

  final ThemePreference theme;
  final LanguagePreference language;
  final bool haptics;

  /// La guida è già stata mostrata al primo avvio.
  final bool helpSeen;

  Settings copyWith({
    ThemePreference? theme,
    LanguagePreference? language,
    bool? haptics,
    bool? helpSeen,
  }) => Settings(
    theme: theme ?? this.theme,
    language: language ?? this.language,
    haptics: haptics ?? this.haptics,
    helpSeen: helpSeen ?? this.helpSeen,
  );

  Map<String, Object?> toJson() => {
    'theme': theme.name,
    'language': language.name,
    'haptics': haptics,
    'helpSeen': helpSeen,
  };

  static Settings fromJson(Object? json) {
    if (json is! Map<String, Object?>) return const Settings();
    final Object? haptics = json['haptics'];
    final Object? helpSeen = json['helpSeen'];
    return Settings(
      theme:
          _enumByName(ThemePreference.values, json['theme']) ??
          ThemePreference.system,
      // Assente nelle impostazioni salvate prima che esistesse: vale "sistema".
      language:
          _enumByName(LanguagePreference.values, json['language']) ??
          LanguagePreference.system,
      haptics: haptics is bool ? haptics : true,
      helpSeen: helpSeen is bool && helpSeen,
    );
  }
}

T? _enumByName<T extends Enum>(List<T> values, Object? name) {
  for (final T value in values) {
    if (value.name == name) return value;
  }
  return null;
}
