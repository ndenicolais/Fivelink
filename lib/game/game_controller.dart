import 'dart:async';

import 'package:flutter/foundation.dart';

import '../core/chain.dart';
import '../core/daily.dart';
import '../core/puzzle.dart';
import '../data/models.dart';
import '../data/storage.dart';
import 'share_text.dart';

export '../data/models.dart' show GameStatus;

final class Attempt {
  Attempt({
    required List<int> order,
    required this.result,
    required this.outcome,
  }) : order = List.unmodifiable(order);

  /// Indici delle tessere nell'ordine provato.
  final List<int> order;
  final ChainResult result;
  final AttemptOutcome outcome;
}

/// Stato della partita del giorno, salvato a ogni tentativo.
class GameController extends ChangeNotifier {
  GameController({required this._storage, required this._clock}) {
    _load(DailyPuzzle.today(_clock));
    unawaited(_storage.pruneOldDays(_daily.date));
  }

  final Storage _storage;
  final Clock _clock;

  late DailyPuzzle _daily;
  late List<int?> _slots;
  final List<Attempt> _attempts = [];
  GameStatus _status = GameStatus.playing;
  late Stats _stats;

  DailyPuzzle get daily => _daily;

  Puzzle get puzzle => _daily.puzzle;

  /// Per ogni slot l'indice della tessera inserita, o null se è vuoto.
  List<int?> get slots => List.unmodifiable(_slots);

  List<Attempt> get attempts => List.unmodifiable(_attempts);

  GameStatus get status => _status;

  bool get isOver => _status != GameStatus.playing;

  int get attemptsLeft => maxAttempts - _attempts.length;

  Stats get stats => _stats;

  /// Serie attuale, azzerata se è stato saltato un giorno.
  int get currentStreak => _stats.streakOn(_clock.now());

  bool isTileUsed(int tile) => _slots.contains(tile);

  bool get slotsFull => !_slots.contains(null);

  bool get slotsEmpty => _slots.every((s) => s == null);

  /// Gli slot ripetono un ordine già provato.
  bool get isDuplicate {
    if (!slotsFull) return false;
    final List<int> order = _slots.cast<int>();
    return _attempts.any((a) => listEquals(a.order, order));
  }

  bool get canSubmit => !isOver && slotsFull && !isDuplicate;

  /// Testo da condividere a partita finita, senza la soluzione.
  String get shareText => buildShareText(
    number: _daily.number,
    outcomes: [for (final Attempt a in _attempts) a.outcome],
  );

  /// Mette [tile] nel primo slot libero.
  void placeTile(int tile) {
    if (isOver || isTileUsed(tile)) return;
    final int free = _slots.indexOf(null);
    if (free < 0) return;
    _slots[free] = tile;
    notifyListeners();
  }

  /// Rimette a disposizione la tessera nello slot [slot].
  void clearSlot(int slot) {
    if (isOver || _slots[slot] == null) return;
    _slots[slot] = null;
    notifyListeners();
  }

  void clearSlots() {
    if (isOver || slotsEmpty) return;
    _slots.fillRange(0, _slots.length, null);
    notifyListeners();
  }

  /// Verifica l'ordine negli slot. Restituisce il tentativo registrato, o null
  /// se non si può verificare. Gli slot restano pieni, così il giocatore può
  /// correggere l'ordine senza ricominciare.
  Attempt? submit() {
    if (!canSubmit) return null;
    _addAttempt(_slots.cast<int>().toList());
    _recordResultIfOver();
    unawaited(
      _storage.saveDay(
        DayRecord(
          date: dateKey(_daily.date),
          attempts: [for (final Attempt a in _attempts) a.order],
          status: _status,
        ),
      ),
    );
    notifyListeners();
    return _attempts.last;
  }

  /// Se la data è cambiata carica il rompicapo del nuovo giorno. Da chiamare
  /// quando l'app torna in primo piano e a mezzanotte.
  bool refreshDay() {
    if (_daily.isForDay(_clock.now())) return false;
    _load(DailyPuzzle.today(_clock));
    unawaited(_storage.pruneOldDays(_daily.date));
    notifyListeners();
    return true;
  }

  void _load(DailyPuzzle daily) {
    _daily = daily;
    _slots = List<int?>.filled(daily.puzzle.tiles.length, null);
    _attempts.clear();
    _status = GameStatus.playing;
    _stats = _storage.loadStats();

    final DayRecord? saved = _storage.loadDay(daily.date);
    if (saved == null) return;
    for (final List<int> order in saved.attempts) {
      if (isOver || !_isValidOrder(order)) break;
      _addAttempt(order);
    }
    if (_attempts.isNotEmpty && !isOver) {
      _slots.setAll(0, _attempts.last.order);
    }
    // Se l'app si è chiusa tra il salvataggio della partita e quello delle
    // statistiche, il risultato viene registrato adesso.
    _recordResultIfOver();
  }

  void _addAttempt(List<int> order) {
    final ChainResult result = puzzle.evaluate(order);
    final Attempt attempt = Attempt(
      order: order,
      result: result,
      outcome: puzzle.outcomeOf(result),
    );
    _attempts.add(attempt);
    if (attempt.outcome == AttemptOutcome.solved) {
      _status = GameStatus.won;
    } else if (_attempts.length >= maxAttempts) {
      _status = GameStatus.lost;
    }
  }

  /// Aggiorna le statistiche al massimo una volta per giorno.
  void _recordResultIfOver() {
    if (!isOver || _stats.lastCompletedDate == dateKey(_daily.date)) return;
    _stats = _status == GameStatus.won
        ? _stats.recordWin(_daily.date, _attempts.length)
        : _stats.recordLoss(_daily.date);
    unawaited(_storage.saveStats(_stats));
  }

  bool _isValidOrder(List<int> order) {
    final int n = puzzle.tiles.length;
    return order.length == n &&
        order.toSet().length == n &&
        order.every((i) => i >= 0 && i < n);
  }
}
