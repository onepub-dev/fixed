/* Copyright (C) Brett Sutton - All Rights Reserved
 * Released under the MIT license.
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'dart:math';

/// returns 10 ^ [decimalDigits]
BigInt calcScaleFactor(int decimalDigits) {
  if (decimalDigits.isNegative) {
    throw ArgumentError.value(
      decimalDigits,
      'decimalDigits',
      'Must be a non-negative value.',
    );
  }
  return BigInt.from(pow(10, decimalDigits));
}
