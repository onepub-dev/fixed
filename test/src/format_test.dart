/* Copyright (C) Brett Sutton - All Rights Reserved
 * Released under the MIT license.
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:fixed/fixed.dart';
import 'package:test/test.dart';

void main() {
  test('format', () {
    final euFormat =
        Fixed.parse('1.000.000,23', invertSeparator: true, decimalDigits: 2);
    // Format using a locale
    expect(euFormat.formatIntl('en-AUS'), equals('1,000,000.23'));

// Format using default locale
    expect(euFormat.formatIntl(), equals('1,000,000.23'));

    expect(Fixed.fromInt(300).toString(), '3.00');
    expect(Fixed.fromInt(30).toString(), '0.30');
    expect(Fixed.fromInt(3).toString(), '0.03');

    expect(Fixed.fromInt(-300).toString(), '-3.00');
    expect(Fixed.fromInt(-30).toString(), '-0.30');
    expect(Fixed.fromInt(-3).toString(), '-0.03');

    var fixed = Fixed.fromNum(1, decimalDigits: 2);

    expect(fixed.toString(), equals('1.00'));

    expect(fixed.format('#.#'), equals('1.0'));
    expect(fixed.format('#.000'), equals('1.000'));
    expect(fixed.format('#'), equals('1'));
    expect(fixed.format('.##'), equals('.00'));

    fixed = Fixed.fromNum(1.23, decimalDigits: 2);
    expect(fixed.toString(), equals('1.23'));

    expect(fixed.format('#.#'), equals('1.2'));
    expect(fixed.format('#.000'), equals('1.230'));
    expect(fixed.format('#'), equals('1'));
    expect(fixed.format('.##'), equals('.23'));

    final t3 = Fixed.fromInt(-10000, decimalDigits: 4);
    expect(t3.format('#.#'), equals('-1.0'));
    expect(t3.format('#'), equals('-1'));
    final t4 = Fixed.fromInt(10000, decimalDigits: 4);
    expect(t4.format('#.#'), equals('1.0'));
    expect(t4.format('#'), equals('1'));
  });

  test('toString', () {
    final t1 = Fixed.fromNum(1.01, decimalDigits: 0);
    expect(t1.toString(), equals('1'));

    final t2 = Fixed.fromNum(1.01, decimalDigits: 1);
    expect(t2.toString(), equals('1.0'));

    final t3 = Fixed.fromNum(1.01, decimalDigits: 2);
    expect(t3.toString(), equals('1.01'));

    final t4 = Fixed.fromNum(-1.01, decimalDigits: 0);
    expect(t4.toString(), equals('-1'));

    final t5 = Fixed.fromNum(-1.01, decimalDigits: 1);
    expect(t5.toString(), equals('-1.0'));

    final t6 = Fixed.fromNum(-1.01, decimalDigits: 2);
    expect(t6.toString(), equals('-1.01'));
  });
}
