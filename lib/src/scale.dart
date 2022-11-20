/* Copyright (C) Brett Sutton - All Rights Reserved
 * Released under the MIT license.
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

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
