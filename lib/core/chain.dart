/// Valutazione di una sequenza di tessere: valori intermedi e punto di rottura.
library;

import 'operation.dart';

final class ChainResult {
  ChainResult({
    required this.start,
    required List<int> values,
    required this.length,
  }) : values = List.unmodifiable(values);

  final int start;

  /// Valore dopo ogni tessera applicata con successo, in ordine. Se la catena
  /// si spezza contiene solo i valori prima della rottura.
  final List<int> values;

  /// Numero di tessere nella sequenza valutata.
  final int length;

  bool get isComplete => values.length == length;

  /// Indice della tessera che ha spezzato la catena, o null se è completa.
  int? get brokenAt => isComplete ? null : values.length;

  /// Risultato finale, o null se la catena si è spezzata.
  int? get finalValue {
    if (!isComplete) return null;
    return values.isEmpty ? start : values.last;
  }
}

/// Applica [operations] a [start] una dopo l'altra, fermandosi alla prima che
/// spezza la catena.
ChainResult evaluateChain(int start, List<Operation> operations) {
  final List<int> values = [];
  int current = start;
  for (final Operation op in operations) {
    final int? next = op.apply(current);
    if (next == null) break;
    values.add(next);
    current = next;
  }
  return ChainResult(start: start, values: values, length: operations.length);
}
