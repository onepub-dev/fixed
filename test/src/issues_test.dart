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

  test('issue wrong result #19', () {
    final v1 = Fixed.fromInt(123456789, scale: 1);
    final v2 = Fixed.fromInt(123456789, scale: 5);
    expect(v1 * v2, equals(Fixed.parse('15241578750.190521')));
  });
}
