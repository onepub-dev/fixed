/* Copyright (C) Brett Sutton - All Rights Reserved
 * Released under the MIT license.
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:fixed/fixed.dart';
import 'package:test/test.dart';

void main() {
  test('format', () {
    final euFormat = Fixed.parse(
      '1.000.000,23',
      decimalSeparator: ',',
      groupSeparator: '.',
      scale: 2,
    );
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

    var fixed = Fixed.fromNum(1, scale: 2);

    expect(fixed.toString(), equals('1.00'));

    expect(fixed.format('#.#'), equals('1.0'));
    expect(fixed.format('#.000'), equals('1.000'));
    expect(fixed.format('#'), equals('1'));
    expect(fixed.format('.##'), equals('.00'));

    fixed = Fixed.fromNum(1.23, scale: 2);
    expect(fixed.toString(), equals('1.23'));

    expect(fixed.format('#.#'), equals('1.2'));
    expect(fixed.format('#.000'), equals('1.230'));
    expect(fixed.format('#'), equals('1'));
    expect(fixed.format('.##'), equals('.23'));

    final t3 = Fixed.fromInt(-10000, scale: 4);
    expect(t3.format('#.#'), equals('-1.0'));
    expect(t3.format('#'), equals('-1'));
    final t4 = Fixed.fromInt(10000, scale: 4);
    expect(t4.format('#.#'), equals('1.0'));
    expect(t4.format('#'), equals('1'));

    final t5 = Fixed.fromInt(1234567, scale: 3);
    expect(t5.format('#.#'), equals('1234.5'));
    expect(t5.format('#.##0'), equals('1234.567'));
    expect(t5.format('#,##0'), equals('1,234'));

    final t6 = Fixed.fromInt(10, scale: 0);
    expect(t6.format('000,000'), equals('000,010'));

    final t7 = Fixed.fromInt(1234567, scale: 0);
    expect(t7.format('##,##,###'), equals('12,34,567'));

    final t8 = Fixed.fromInt(376, scale: 0);
    expect(t8.format('###,###'), equals('376'));
  });

  test('toString', () {
    final t1 = Fixed.fromNum(1.01, scale: 0);
    expect(t1.toString(), equals('1'));

    final t2 = Fixed.fromNum(1.01, scale: 1);
    expect(t2.toString(), equals('1.0'));

    final t3 = Fixed.fromNum(1.01, scale: 2);
    expect(t3.toString(), equals('1.01'));

    final t4 = Fixed.fromNum(-1.01, scale: 0);
    expect(t4.toString(), equals('-1'));

    final t5 = Fixed.fromNum(-1.01, scale: 1);
    expect(t5.toString(), equals('-1.0'));

    final t6 = Fixed.fromNum(-1.01, scale: 2);
    expect(t6.toString(), equals('-1.01'));
  });
}
