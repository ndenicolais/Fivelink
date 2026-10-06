import 'package:fivelink/core/chain.dart';
import 'package:fivelink/core/operation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('complete chain reports all intermediate values', () {
    final ChainResult r = evaluateChain(17, const [
      Operation.add(7),
      Operation.multiply(2),
      Operation.add(9),
      Operation.multiply(3),
      Operation.subtract(8),
    ]);
    expect(r.values, [24, 48, 57, 171, 163]);
    expect(r.isComplete, isTrue);
    expect(r.brokenAt, isNull);
    expect(r.finalValue, 163);
  });

  test('broken chain stops at the first invalid step', () {
    // 17 → 24 → 8, poi ⇄ si spezza su una cifra sola.
    final ChainResult r = evaluateChain(17, const [
      Operation.add(7),
      Operation.divide(3),
      Operation.reverse(),
      Operation.add(1),
      Operation.add(2),
    ]);
    expect(r.values, [24, 8]);
    expect(r.isComplete, isFalse);
    expect(r.brokenAt, 2);
    expect(r.finalValue, isNull);
  });

  test('chain can break on the first tile', () {
    final ChainResult r = evaluateChain(7, const [Operation.divide(2)]);
    expect(r.values, isEmpty);
    expect(r.brokenAt, 0);
  });

  test('chain can break on the last tile', () {
    final ChainResult r = evaluateChain(500, const [
      Operation.add(1),
      Operation.multiply(2),
    ]);
    expect(r.values, [501]);
    expect(r.brokenAt, 1);
  });

  test('chain touching the range limits stays valid', () {
    final ChainResult r = evaluateChain(2, const [
      Operation.subtract(1),
      Operation.add(9),
      Operation.multiply(3),
    ]);
    expect(r.values, [1, 10, 30]);
    expect(r.isComplete, isTrue);

    final ChainResult top = evaluateChain(333, const [Operation.multiply(3)]);
    expect(top.finalValue, 999);
  });

  test('empty chain returns the start value', () {
    final ChainResult r = evaluateChain(5, const []);
    expect(r.isComplete, isTrue);
    expect(r.finalValue, 5);
  });

  test('values are read-only', () {
    final ChainResult r = evaluateChain(5, const [Operation.add(1)]);
    expect(() => r.values.add(1), throwsUnsupportedError);
  });
}
