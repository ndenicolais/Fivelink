import 'package:fivelink/core/prng.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('xorshift32 matches the reference sequence for seed 1', () {
    final Xorshift32 rng = Xorshift32(1);
    expect(
      [rng.nextUint32(), rng.nextUint32(), rng.nextUint32()],
      [270369, 67634689, 2647435461],
    );
  });

  test('zero seed is replaced and never yields zero', () {
    final Xorshift32 rng = Xorshift32(0);
    for (int i = 0; i < 1000; i++) {
      expect(rng.nextUint32(), isNot(0));
    }
    expect(mixSeed(0), isNot(0));
  });

  test('values stay within 32 bits', () {
    final Xorshift32 rng = Xorshift32(0xFFFFFFFF);
    for (int i = 0; i < 1000; i++) {
      expect(rng.nextUint32(), inInclusiveRange(1, 0xFFFFFFFF));
    }
  });

  test('mul32 matches 32-bit wrapping multiplication', () {
    expect(mul32(0xFFFFFFFF, 0xFFFFFFFF), 1);
    expect(mul32(0x12345678, 0x9E3779B1), 0xF6D680F8);
    expect(mul32(3, 5), 15);
  });

  test('nextInRange covers both bounds and nothing else', () {
    final Xorshift32 rng = Xorshift32(42);
    final Set<int> seen = {
      for (int i = 0; i < 2000; i++) rng.nextInRange(2, 20),
    };
    expect(seen, {for (int i = 2; i <= 20; i++) i});
  });

  test('invalid bounds are rejected', () {
    expect(() => Xorshift32(1).nextInt(0), throwsArgumentError);
    expect(() => Xorshift32(1).nextInRange(5, 4), throwsArgumentError);
  });

  test('shuffle is a deterministic permutation', () {
    final List<int> a = List<int>.generate(10, (i) => i);
    final List<int> b = List<int>.generate(10, (i) => i);
    Xorshift32(7).shuffle(a);
    Xorshift32(7).shuffle(b);
    expect(a, b);
    expect(a.toSet(), {for (int i = 0; i < 10; i++) i});
  });
}
