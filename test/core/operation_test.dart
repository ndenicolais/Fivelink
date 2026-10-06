import 'package:fivelink/core/operation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('add', () {
    test('sums', () => expect(const Operation.add(7).apply(17), 24));
    test('upper bound is inclusive', () {
      expect(const Operation.add(9).apply(990), 999);
      expect(const Operation.add(9).apply(991), isNull);
    });
  });

  group('subtract', () {
    test('subtracts', () {
      expect(const Operation.subtract(8).apply(171), 163);
    });
    test('lower bound is inclusive', () {
      expect(const Operation.subtract(1).apply(2), 1);
      expect(const Operation.subtract(1).apply(1), isNull);
      expect(const Operation.subtract(9).apply(5), isNull);
    });
  });

  group('multiply', () {
    test('multiplies', () {
      expect(const Operation.multiply(2).apply(24), 48);
      expect(const Operation.multiply(3).apply(57), 171);
    });
    test('breaks above 999', () {
      expect(const Operation.multiply(3).apply(333), 999);
      expect(const Operation.multiply(3).apply(334), isNull);
      expect(const Operation.multiply(2).apply(500), isNull);
    });
  });

  group('divide', () {
    test('divides exactly', () {
      expect(const Operation.divide(2).apply(48), 24);
      expect(const Operation.divide(3).apply(999), 333);
    });
    test('breaks when not divisible', () {
      expect(const Operation.divide(2).apply(7), isNull);
      expect(const Operation.divide(3).apply(10), isNull);
      expect(const Operation.divide(2).apply(1), isNull);
    });
  });

  group('reverse', () {
    const Operation reverse = Operation.reverse();
    test('reverses digits', () {
      expect(reverse.apply(36), 63);
      expect(reverse.apply(123), 321);
      expect(reverse.apply(998), 899);
    });
    test('keeps inner zeros', () => expect(reverse.apply(105), 501));
    test('breaks on single digits', () {
      expect(reverse.apply(1), isNull);
      expect(reverse.apply(9), isNull);
    });
    test('breaks on trailing zero', () {
      expect(reverse.apply(10), isNull);
      expect(reverse.apply(120), isNull);
    });
    test('breaks on palindromes', () {
      expect(reverse.apply(11), isNull);
      expect(reverse.apply(121), isNull);
      expect(reverse.apply(999), isNull);
    });
  });

  test('labels use typographic symbols', () {
    expect(const Operation.add(7).label, '+7');
    expect(const Operation.subtract(8).label, '−8');
    expect(const Operation.multiply(3).label, '×3');
    expect(const Operation.divide(2).label, '÷2');
    expect(const Operation.reverse().label, '⇄');
  });

  test('isSpecial marks multiply, divide and reverse', () {
    expect(const Operation.add(1).isSpecial, isFalse);
    expect(const Operation.subtract(1).isSpecial, isFalse);
    expect(const Operation.multiply(2).isSpecial, isTrue);
    expect(const Operation.divide(3).isSpecial, isTrue);
    expect(const Operation.reverse().isSpecial, isTrue);
  });

  test('equality is by value', () {
    expect(const Operation.add(3), const Operation.add(3));
    expect(const Operation.add(3), isNot(const Operation.subtract(3)));
    expect(
      const Operation.multiply(2).hashCode,
      const Operation.multiply(2).hashCode,
    );
  });
}
