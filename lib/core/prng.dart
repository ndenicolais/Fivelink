/// Generatore di numeri pseudocasuali deterministico.
///
/// Non si usa `dart:math Random` perché la sequenza prodotta da un seed non è
/// garantita stabile tra versioni dell'SDK. Qui ogni operazione è mascherata a
/// 32 bit, quindi la sequenza dipende solo dal seed.
library;

const int _mask32 = 0xFFFFFFFF;
const int _range32 = 0x100000000;

/// Sostituisce un seed nullo: xorshift resta bloccato su 0 per sempre.
const int _zeroSeedReplacement = 0x6D2B79F5;

/// Prodotto di due interi a 32 bit, ridotto a 32 bit.
///
/// Spezza il moltiplicatore in due metà da 16 bit, così nessun prodotto
/// intermedio supera i 48 bit.
int mul32(int a, int b) {
  final int x = a & _mask32;
  final int y = b & _mask32;
  final int low = x * (y & 0xFFFF);
  final int high = ((x * (y >> 16)) & 0xFFFF) << 16;
  return (low + high) & _mask32;
}

/// Un passo di xorshift32 (shift 13, 17, 5). Non restituisce mai 0 se
/// l'ingresso è diverso da 0.
int xorshiftStep(int state) {
  int x = state & _mask32;
  x ^= (x << 13) & _mask32;
  x ^= x >> 17;
  x ^= (x << 5) & _mask32;
  return x;
}

/// Rimescola un valore qualsiasi in un seed a 32 bit, sempre diverso da 0.
int mixSeed(int value) {
  int x = mul32(value, 0x9E3779B1);
  if (x == 0) x = _zeroSeedReplacement;
  for (int i = 0; i < 8; i++) {
    x = xorshiftStep(x);
  }
  return x;
}

final class Xorshift32 {
  /// Usa [seed] ridotto a 32 bit. Un seed nullo viene sostituito con una
  /// costante.
  Xorshift32(int seed) : _state = _nonZero(seed & _mask32);

  int _state;

  static int _nonZero(int seed) => seed == 0 ? _zeroSeedReplacement : seed;

  /// Prossimo valore grezzo, tra 1 e 2^32 - 1.
  int nextUint32() {
    _state = xorshiftStep(_state);
    return _state;
  }

  /// Intero uniforme in `[0, bound)`.
  int nextInt(int bound) {
    if (bound <= 0 || bound > _range32) {
      throw ArgumentError.value(bound, 'bound', 'must be in 1..2^32');
    }
    // Scarta la coda che renderebbe il modulo non uniforme.
    final int limit = _range32 - _range32 % bound;
    while (true) {
      final int x = nextUint32();
      if (x < limit) return x % bound;
    }
  }

  /// Intero uniforme in `[min, max]`, estremi inclusi.
  int nextInRange(int min, int max) {
    if (max < min) {
      throw ArgumentError('max ($max) must be >= min ($min)');
    }
    return min + nextInt(max - min + 1);
  }

  /// Mescola [list] sul posto (Fisher-Yates).
  void shuffle<T>(List<T> list) {
    for (int i = list.length - 1; i > 0; i--) {
      final int j = nextInt(i + 1);
      final T tmp = list[i];
      list[i] = list[j];
      list[j] = tmp;
    }
  }
}
