/* Copyright (C) Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
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
