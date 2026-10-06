import 'package:flutter/foundation.dart';

import '../core/chain.dart';
import '../core/daily.dart';
import '../core/puzzle.dart';

enum GameStatus { playing, won, lost }

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

/// Stato della partita del giorno. Per ora solo in memoria.
class GameController extends ChangeNotifier {
  GameController({required this.daily})
    : _slots = List<int?>.filled(daily.puzzle.tiles.length, null);

  final DailyPuzzle daily;

  final List<int?> _slots;
  final List<Attempt> _attempts = [];
  GameStatus _status = GameStatus.playing;

  Puzzle get puzzle => daily.puzzle;

  /// Per ogni slot l'indice della tessera inserita, o null se è vuoto.
  List<int?> get slots => List.unmodifiable(_slots);

  List<Attempt> get attempts => List.unmodifiable(_attempts);

  GameStatus get status => _status;

  bool get isOver => _status != GameStatus.playing;

  int get attemptsLeft => maxAttempts - _attempts.length;

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
    final List<int> order = _slots.cast<int>().toList();
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
    notifyListeners();
    return attempt;
  }
}
