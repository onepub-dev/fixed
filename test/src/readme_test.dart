/* Copyright (C) Brett Sutton - All Rights Reserved
 * Released under the MIT license.
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:decimal/decimal.dart';
import 'package:fixed/fixed.dart';
import 'package:test/test.dart';

void main() {
  test('example 1', () {
    expect(Fixed.fromInt(1234, decimalDigits: 3).toString(),
        equals('1.234')); // == 1.
    final t3 =
        Fixed.fromBigInt(BigInt.from(1234), decimalDigits: 3); // == 1.234
    expect(t3.toString(), equals('1.234'));
    final t4 = t3.copyWith(decimalDigits: 2); // == 1.23
    expect(t4.toString(), equals('1.23'));
    final t5 = Fixed.parse('1.234', decimalDigits: 3); // == 1.234
    expect(t5.toString(), equals('1.234'));
    final t6 =
        Fixed.fromDecimal(Decimal.fromInt(1), decimalDigits: 2); // == 1.00
    expect(t6.toString(), equals('1.00'));

    // This is the least desireable method as it can introduce
    // rounding errors.
    final t7 = Fixed.fromNum(1.234, decimalDigits: 3); // == 1.234
    expect(t7.toString(), equals('1.234'));
  });

  test('example 2', () {
    final t7 = Fixed.fromNum(1.234, decimalDigits: 3); // == 1.234
    expect(t7.toString(), equals('1.234'));

    /// reduce the decimalDigits
    final t8 = t7.copyWith(decimalDigits: 2); // == 1.23
    expect(t8.toString(), equals('1.23'));

    /// increase the decimalDigits
    final t9 = t8.copyWith(decimalDigits: 5); // == 1.2300
    expect(t9.toString(), equals('1.23000'));
  });

  test('example 3', () {
    final t1 = Fixed.parse('1.234', decimalDigits: 2);
    expect(t1.minorUnits.toInt(), equals(123));
    expect(t1.decimalDigits, equals(2));

    final t2 = Fixed.parse('1,000,000.234', decimalDigits: 2);
    expect(t2.minorUnits.toInt(), equals(100000023));
    expect(t2.decimalDigits, equals(2));

    /// for countries that use . for group separators
    final t3 =
        Fixed.parse('1.000.000,234', decimalDigits: 2, invertSeparator: true);
    expect(t3.minorUnits.toInt(), equals(100000023));
    expect(t3.decimalDigits, equals(2));
  });

  test('example 4', () {
    final t3 = Fixed.fromInt(1234, decimalDigits: 3);

    expect(t3.toString(), equals('1.234'));

    expect(t3.format('00.###0'), equals('01.2340'));

    expect(t3.format('00,###0', invertSeparator: true), equals('01,2340'));

    final euFormat =
        Fixed.parse('1.000.000,23', invertSeparator: true, decimalDigits: 2);
    // Format using a locale
    expect(euFormat.formatIntl('en-AUS'), equals('1,000,000.23'));

    // Format using default locale
    expect(euFormat.formatIntl(), equals('1,000,000.23'));
  });

  test('example 5', () {
    Fixed.fromInt(5).copyWith(decimalDigits: 10);
  });

  test('example 6', () {
    final t1 = Fixed.parse('1.23'); // = 1.23
    final t2 = Fixed.fromInt(100); // = 1.00

    expect((t1 + t2).toString(), equals('2.23'));
    expect((t2 - t1).toString(), equals('-0.23'));
    expect((t1 * t2).toString(), equals('1.2300'));
    expect((t1 / t2).toString(), equals('1.23'));
    expect((-t1).toString(), equals('-1.23'));
  });

  test('example 7', () {
    final t1 = Fixed.fromNum(1.23, decimalDigits: 2);
    final t2 = Fixed.fromInt(123);
    final t3 = Fixed.fromBigInt(BigInt.from(1234), decimalDigits: 3);

    expect(t1 == t2, isTrue);
    expect(t1 < t3, isTrue);
    expect(t1 <= t3, isTrue);
    expect(t1 > t3, isFalse);
    expect(t1 >= t3, isFalse);
    expect(t1 != t3, isTrue);
    expect(-t1, equals(Fixed.fromInt(-123)));

    expect(t1.isPositive, isTrue);
    expect(t1.isNegative, isFalse);
    expect(t1.isZero, isFalse);

    expect(t1.compareTo(t2), equals(0));
  });
}
