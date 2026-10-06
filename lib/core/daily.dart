/// Data locale, numero del rompicapo e tempo al prossimo.
library;

import 'puzzle.dart';
import 'puzzle_generator.dart';

/// Giorno del rompicapo #1. Le date precedenti (solo in sviluppo) danno numeri
/// minori o uguali a 0, senza errori.
final DateTime launchDate = DateTime.utc(2026, 10, 10);

/// Fonte dell'ora corrente. La logica non chiama mai `DateTime.now()`
/// direttamente, così i test possono simulare i giorni.
abstract interface class Clock {
  DateTime now();
}

final class SystemClock implements Clock {
  const SystemClock();

  @override
  DateTime now() => DateTime.now();
}

/// Mezzanotte locale del giorno di [moment].
DateTime localDay(DateTime moment) =>
    DateTime(moment.year, moment.month, moment.day);

/// Numero del rompicapo per il giorno di [day]. Si confrontano date UTC
/// costruite da anno, mese e giorno: una differenza tra date locali può
/// perdere un giorno al cambio dell'ora.
int puzzleNumber(DateTime day) {
  final DateTime utcDay = DateTime.utc(day.year, day.month, day.day);
  return utcDay.difference(launchDate).inDays + 1;
}

/// Mezzanotte locale successiva a [now].
DateTime nextMidnight(DateTime now) =>
    DateTime(now.year, now.month, now.day + 1);

/// Tempo reale che manca al prossimo rompicapo. Nei giorni del cambio
/// dell'ora tiene conto delle 23 o 25 ore.
Duration timeUntilNextPuzzle(DateTime now) => nextMidnight(now).difference(now);

/// Chiave della data nel formato `aaaa-mm-gg`, per la persistenza.
String dateKey(DateTime day) {
  final String y = day.year.toString().padLeft(4, '0');
  final String m = day.month.toString().padLeft(2, '0');
  final String d = day.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

/// Il rompicapo di un giorno con il suo numero.
final class DailyPuzzle {
  DailyPuzzle._(this.date, this.number, this.puzzle);

  factory DailyPuzzle.forDate(DateTime date) {
    final DateTime day = localDay(date);
    return DailyPuzzle._(day, puzzleNumber(day), generatePuzzleForDate(day));
  }

  factory DailyPuzzle.today(Clock clock) => DailyPuzzle.forDate(clock.now());

  /// Mezzanotte locale del giorno.
  final DateTime date;
  final int number;
  final Puzzle puzzle;

  bool isForDay(DateTime moment) => localDay(moment) == date;
}
