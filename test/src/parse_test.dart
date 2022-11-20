/* Copyright (C) Brett Sutton - All Rights Reserved
 * Released under the MIT license.
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:fixed/fixed.dart';
import 'package:test/test.dart';

void main() {
  test('parse', () {
    validate(Fixed.parse('1'), sign: 1, integer: 1, decimal: 0, scale: 0);
    validate(Fixed.parse('1.0'), sign: 1, integer: 1, decimal: 0, scale: 1);

    validate(Fixed.parse('1.1'), sign: 1, integer: 1, decimal: 1, scale: 1);
    validate(Fixed.parse('1.10'), sign: 1, integer: 1, decimal: 10, scale: 2);

    validate(Fixed.parse('1.11'), sign: 1, integer: 1, decimal: 11, scale: 2);
    validate(Fixed.parse('1.111'), sign: 1, integer: 1, decimal: 111, scale: 3);
    // restriced by largest safe java script integer.
    validate(Fixed.parse('1.1234567890123456'),
        sign: 1, integer: 1, decimal: 1234567890123456, scale: 16);

    validate(Fixed.parse('1.11', scale: 3),
        sign: 1, integer: 1, decimal: 110, scale: 3);

    validate(Fixed.parse('1.111', scale: 3),
        sign: 1, integer: 1, decimal: 111, scale: 3);
    validate(Fixed.parse('1.111', scale: 2),
        sign: 1, integer: 1, decimal: 11, scale: 2);

    validate(Fixed.parse('1,111', scale: 3, invertSeparator: true),
        sign: 1, integer: 1, decimal: 111, scale: 3);

    validate(Fixed.parse('10.101,111', scale: 3, invertSeparator: true),
        sign: 1, integer: 10101, decimal: 111, scale: 3);
  });
}

void validate(Fixed t1,
    {required int decimal,
    required int integer,
    required int scale,
    required int sign}) {
  expect(t1.sign, equals(sign));
  expect(t1.integerPart, equals(BigInt.from(integer)));
  expect(t1.decimalPart, equals(BigInt.from(decimal)));
  expect(t1.scale, equals(scale));
}
