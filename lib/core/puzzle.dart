/// Modello del rompicapo.
library;

import 'chain.dart';
import 'operation.dart';

/// Tentativi massimi per partita.
const int maxAttempts = 6;

/// Esito di un tentativo, usato anche per il testo di condivisione.
enum AttemptOutcome { broken, wrongResult, solved }

final class Puzzle {
  Puzzle({
    required this.start,
    required this.target,
    required List<Operation> tiles,
    required List<List<int>> solutions,
  }) : tiles = List.unmodifiable(tiles),
       solutions = List.unmodifiable(
         solutions.map<List<int>>(List<int>.unmodifiable),
       ) {
    if (this.solutions.isEmpty) {
      throw ArgumentError.value(solutions, 'solutions', 'must not be empty');
    }
  }

  final int start;
  final int target;

  /// Tessere nell'ordine in cui vengono presentate al giocatore.
  final List<Operation> tiles;

  /// Ogni soluzione è un ordine di indici in [tiles]. Di norma ce n'è una
  /// sola: due solo se il generatore ha dovuto ripiegare.
  final List<List<int>> solutions;

  /// La soluzione da mostrare a partita persa.
  List<int> get solution => solutions.first;

  /// Le tessere disposte secondo [order], una lista di indici in [tiles].
  List<Operation> tilesInOrder(List<int> order) {
    _checkOrder(order);
    return [for (final int i in order) tiles[i]];
  }

  ChainResult evaluate(List<int> order) =>
      evaluateChain(start, tilesInOrder(order));

  /// Si valida il risultato, non il confronto con [solutions].
  AttemptOutcome outcomeOf(ChainResult result) {
    if (!result.isComplete) return AttemptOutcome.broken;
    return result.finalValue == target
        ? AttemptOutcome.solved
        : AttemptOutcome.wrongResult;
  }

  AttemptOutcome check(List<int> order) => outcomeOf(evaluate(order));

  /// [order] deve usare ogni tessera esattamente una volta.
  void _checkOrder(List<int> order) {
    final bool valid =
        order.length == tiles.length &&
        order.toSet().length == order.length &&
        order.every((i) => i >= 0 && i < tiles.length);
    if (!valid) {
      throw ArgumentError.value(order, 'order', 'not a permutation of tiles');
    }
  }
}
