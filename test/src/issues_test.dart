/* Copyright (C) Brett Sutton - All Rights Reserved
 * Released under the MIT license.
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:fixed/src/fixed.dart';
import 'package:test/test.dart';

void main() {
  test('issue #63 from Money2', () {
    final amount = Fixed.fromNum(121);
    final percent = Fixed.fromNum(1.21);
    final result = (amount / percent).copyWith(scale: 0)..toString();
    expect(result, equals(Fixed.fromNum(100, scale: 0)));
  });
}
