/// Generazione deterministica del rompicapo da una data.
///
/// ATTENZIONE: dopo la pubblicazione qualunque modifica a questo file (pool,
/// ordine del pool, seed, ordine delle estrazioni, vincoli) cambia i rompicapi
/// di tutti i giorni. Non toccarlo senza una decisione esplicita, e in quel
/// caso incrementa [generatorVersion] e aggiorna lo snapshot nei test.
library;

import 'operation.dart';
import 'prng.dart';
import 'puzzle.dart';

const int generatorVersion = 1;

/// Tessere per rompicapo.
const int tileCount = 5;

/// Tutte le tessere estraibili. L'ordine fa parte del generatore.
const List<Operation> operationPool = [
  Operation.add(1),
  Operation.add(2),
  Operation.add(3),
  Operation.add(4),
  Operation.add(5),
  Operation.add(6),
  Operation.add(7),
  Operation.add(8),
  Operation.add(9),
  Operation.subtract(1),
  Operation.subtract(2),
  Operation.subtract(3),
  Operation.subtract(4),
  Operation.subtract(5),
  Operation.subtract(6),
  Operation.subtract(7),
  Operation.subtract(8),
  Operation.subtract(9),
  Operation.multiply(2),
  Operation.multiply(3),
  Operation.divide(2),
  Operation.divide(3),
  Operation.reverse(),
];

const int _minStart = 2;
const int _maxStart = 20;
const int _minSpecial = 2;
const int _maxSpecial = 4;
const int _minTarget = 10;
const int _maxTarget = 300;

/// Oltre questo numero di candidati si accettano fino a 2 soluzioni.
const int fallbackAfterCandidates = 20000;

/// Limite assoluto: non dovrebbe mai essere raggiunto.
const int _maxCandidates = 200000;

/// Seed del giorno: dipende solo da anno, mese e giorno di [date] (l'ora e il
/// fuso vengono ignorati) e da [generatorVersion].
int dateSeed(DateTime date) {
  final int base = date.year * 10000 + date.month * 100 + date.day;
  return mixSeed(base ^ mul32(generatorVersion, 0x85EBCA6B));
}

Puzzle generatePuzzleForDate(DateTime date) => generatePuzzle(dateSeed(date));

/// Genera un rompicapo da un seed qualsiasi. Usato dal rompicapo quotidiano e,
/// in futuro, da una modalità allenamento.
Puzzle generatePuzzle(int seed) {
  for (int candidate = 0; candidate < _maxCandidates; candidate++) {
    // Il contatore entra nel seed: ogni candidato ha la sua sequenza.
    final Xorshift32 rng = Xorshift32(
      mixSeed(seed ^ mul32(candidate + 1, 0x9E3779B9)),
    );

    final int start = rng.nextInRange(_minStart, _maxStart);
    final List<Operation> drawn = _drawTiles(rng);

    final int specialCount = drawn.where((op) => op.isSpecial).length;
    if (specialCount < _minSpecial || specialCount > _maxSpecial) continue;

    final int? target = _run(start, drawn, List<int>.generate(tileCount, _id));
    if (target == null) continue;
    if (target < _minTarget || target > _maxTarget || target == start) {
      continue;
    }

    final List<List<int>> solutions = findSolutions(start, target, drawn);
    final int allowed = candidate < fallbackAfterCandidates ? 1 : 2;
    if (solutions.length > allowed) continue;

    // presentation[p] è l'indice in drawn della tessera mostrata in posizione p.
    final List<int> presentation = List<int>.generate(tileCount, _id);
    rng.shuffle(presentation);
    final List<int> positionOf = List<int>.filled(tileCount, 0);
    for (int p = 0; p < tileCount; p++) {
      positionOf[presentation[p]] = p;
    }

    return Puzzle(
      start: start,
      target: target,
      tiles: [for (final int i in presentation) drawn[i]],
      solutions: [
        for (final List<int> s in solutions)
          [for (final int i in s) positionOf[i]],
      ],
    );
  }
  throw StateError('No puzzle found for seed $seed');
}

/// Tutti gli ordini di [tiles] (come indici) che partendo da [start] formano
/// una catena valida e arrivano a [target].
List<List<int>> findSolutions(int start, int target, List<Operation> tiles) {
  return [
    for (final List<int> order in permutations(tiles.length))
      if (_run(start, tiles, order) == target) order,
  ];
}

final Map<int, List<List<int>>> _permutationCache = {};

/// Tutte le permutazioni di `0..n-1`, in ordine lessicografico.
List<List<int>> permutations(int n) {
  return _permutationCache.putIfAbsent(n, () {
    final List<List<int>> result = [];
    void build(List<int> prefix, List<int> rest) {
      if (rest.isEmpty) {
        result.add(List<int>.unmodifiable(prefix));
        return;
      }
      for (int i = 0; i < rest.length; i++) {
        build([...prefix, rest[i]], [...rest]..removeAt(i));
      }
    }

    build([], List<int>.generate(n, _id));
    return List.unmodifiable(result);
  });
}

/// Estrae [tileCount] tessere distinte dal pool (Fisher-Yates parziale).
List<Operation> _drawTiles(Xorshift32 rng) {
  final List<int> indices = List<int>.generate(operationPool.length, _id);
  for (int i = 0; i < tileCount; i++) {
    final int j = rng.nextInRange(i, indices.length - 1);
    final int tmp = indices[i];
    indices[i] = indices[j];
    indices[j] = tmp;
  }
  return [for (int i = 0; i < tileCount; i++) operationPool[indices[i]]];
}

/// Risultato finale della catena, o null se si spezza. Versione senza
/// allocazioni di `evaluateChain`, usata nel ciclo caldo.
int? _run(int start, List<Operation> tiles, List<int> order) {
  int value = start;
  for (final int i in order) {
    final int? next = tiles[i].apply(value);
    if (next == null) return null;
    value = next;
  }
  return value;
}

int _id(int i) => i;
