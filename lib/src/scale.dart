import 'dart:math';

BigInt calcScaleFactor(int scale) {
  if (scale.isNegative) {
    throw ArgumentError.value(
      scale,
      'scale',
      'Must be a non-negative value.',
    );
  }
  return BigInt.from(pow(10, scale));
}
