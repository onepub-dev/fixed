/* Copyright (C) Brett Sutton - All Rights Reserved
 * Released under the MIT license.
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'dart:math';

import 'package:decimal/decimal.dart';
import 'package:fixed/src/exceptions.dart';
import 'package:fixed/src/fixed.dart';
import 'package:test/test.dart';

void main() {
  test('format ...', () async {
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
  });

  group('ctors', () {
    test('Fixed.from', () {
      final t1 = Fixed.fromNum(1);
      expect(t1.minorUnits.toInt(), equals(10000000000000000));
      expect(t1.integerPart.toInt(), equals(1));
      expect(t1.scale, equals(16));

      final t2 = Fixed.fromNum(100, scale: 2);
      expect(t2.minorUnits.toInt(), equals(10000));
      expect(t2.integerPart.toInt(), equals(100));
      expect(t2.scale, equals(2));

      final t3 = Fixed.fromNum(1000, scale: 3);
      expect(t3.minorUnits.toInt(), equals(1000000));
      expect(t3.integerPart.toInt(), equals(1000));
      expect(t3.scale, equals(3));

      final t4 = Fixed.fromNum(1000, scale: 0);
      expect(t4.minorUnits.toInt(), equals(1000));
      expect(t4.integerPart.toInt(), equals(1000));
      expect(t4.scale, equals(0));

      expect(
          () => Fixed.fromNum(1000, scale: -1), throwsA(isA<FixedException>()));

      final t5 = Fixed.fromNum(75486, scale: 5); // == 0.75486
      expect(t5.minorUnits.toInt(), equals(7548600000));
      expect(t5.integerPart.toInt(), equals(75486));
      expect(t5.scale, equals(5));

      final t6 = Fixed.fromNum(1.123456789);
      expect(t6.minorUnits.toInt(), equals(11234567890000000));
      expect(t6.integerPart.toInt(), equals(1));
      expect(t6.scale, equals(16));

      final t7 = Fixed.fromDecimal(
          (Decimal.fromInt(1) / Decimal.fromInt(3))
              .toDecimal(scaleOnInfinitePrecision: 16),
          scale: 2); // == 1.00
      expect(t7.minorUnits.toInt(), equals(33));
      expect(t7.integerPart.toInt(), equals(0));
      expect(t7.scale, equals(2));
    });

    test('Fixed.fromMinorUnits', () {
      final t1 = Fixed.fromInt(1);
      expect(t1.minorUnits.toInt(), equals(1));
      expect(t1.integerPart.toInt(), equals(0));
      expect(t1.scale, equals(2));

      final t7 = Fixed.fromInt(10);
      expect(t7.minorUnits.toInt(), equals(10));
      expect(t7.integerPart.toInt(), equals(0));
      expect(t7.scale, equals(2));

      final t2 = Fixed.fromInt(100);
      expect(t2.minorUnits.toInt(), equals(100));
      expect(t2.integerPart.toInt(), equals(1));
      expect(t2.scale, equals(2));

      final t3 = Fixed.fromInt(1000, scale: 3);
      expect(t3.minorUnits.toInt(), equals(1000));
      expect(t3.integerPart.toInt(), equals(1));
      expect(t3.scale, equals(3));

      final t4 = Fixed.fromInt(1000, scale: 0);
      expect(t4.minorUnits.toInt(), equals(1000));
      expect(t4.integerPart.toInt(), equals(1000));
      expect(t4.scale, equals(0));

      expect(
          () => Fixed.fromNum(1000, scale: -1), throwsA(isA<FixedException>()));

      final t5 = Fixed.fromInt(75486, scale: 5); // == 0.75486
      expect(t5.minorUnits.toInt(), equals(75486));
      expect(t5.integerPart.toInt(), equals(0));
      expect(t5.scale, equals(5));

      final t6 = Fixed.fromInt(1);
      expect(t6.minorUnits.toInt(), equals(1));
      expect(t6.integerPart.toInt(), equals(0));
      expect(t6.scale, equals(2));

      final rate2 = Fixed.fromInt(7548, scale: 5); // == 0.07548
      expect(rate2.minorUnits.toInt(), equals(7548));
      expect(rate2.integerPart.toInt(), equals(0));
      expect(rate2.scale, equals(5));
    });
  });

  test('multiplication', () {
    final rate = Fixed.fromInt(7548, scale: 5); // == 0.07548
    expect(rate.minorUnits.toInt(), equals(7548));

    final auDollars = Fixed.fromInt(100); // == 1.00
    final usDollarsHighScale = auDollars * rate; // == 0.07548000, scale = 7

    expect(usDollarsHighScale.minorUnits.toInt(), equals(754800));
    expect(usDollarsHighScale.scale, equals(7));

    expect(
        Fixed.fromInt(-200) * Fixed.fromInt(100), equals(Fixed.fromInt(-200)));

    expect(Fixed.fromInt(-2) * Fixed.fromInt(100), equals(Fixed.fromInt(-2)));

    expect(Fixed.fromInt(-2) * Fixed.fromInt(-100), equals(Fixed.fromInt(2)));
  });

  test('division', () {
    final winnings = Fixed.fromInt(600000, scale: 5); // == 6.0000
    final winners = Fixed.fromNum(2.00, scale: 2); // == 2.00
    final share = winnings / winners; // == 3.0000, scale = 5

    expect(share.minorUnits.toInt(), equals(300000));
    expect(share.scale, equals(5));

    final one = Fixed.fromInt(1, scale: 0);
    final three = Fixed.fromInt(3, scale: 0);

    expect(one / three, equals(Fixed.zero));

    final numerator = Fixed.fromInt(612343, scale: 5); // == 6.0000
    final denominator = Fixed.fromNum(2.00, scale: 2); // == 2.00
    final result = numerator / denominator; // == 3.0000, scale = 5

    expect(result.minorUnits.toInt(), equals(306171));
    expect(result.scale, equals(5));
  });

  test('plus', () {
    final fixed = Fixed.fromInt(100);
    expect(fixed + Fixed.fromNum(1), equals(Fixed.fromNum(2)));

    /// mixed scale
    final t1 = Fixed.fromNum(100.1234, scale: 4) + Fixed.fromNum(1);
    expect(t1.minorUnits.toInt(), equals(1011234000000000000));
    expect(t1.scale, equals(16));
  });

  test('minus', () {
    final fixed = Fixed.fromInt(300);
    expect(fixed - Fixed.fromNum(1), equals(Fixed.fromNum(2)));

    /// mixed scale
    final t1 = Fixed.fromNum(100.1234, scale: 4) + Fixed.fromNum(1);
    expect(t1.minorUnits.toInt(), equals(1011234000000000000));
    expect(t1.scale, equals(16));

    /// mixed scale
    final t2 = Fixed.fromNum(100.1234, scale: 4) + Fixed.fromNum(1, scale: 3);
    expect(t2.minorUnits.toInt(), equals(1011234));
    expect(t2.scale, equals(4));
  });

  test('unary minus', () {
    final t1 = Fixed.fromNum(1, scale: 4);
    final t2 = -t1;
    expect(t2.integerPart.toInt(), equals(-1));
    expect(t2.decimalPart.toInt(), equals(0));
    expect(t1.scale, equals(4));
  });

  test('scale', () {
    final highScale = Fixed.fromInt(10000, scale: 4);
    expect(highScale.minorUnits.toInt(), equals(10000));
    expect(highScale.scale, equals(4));

    /// reduce the scale to 2 decimal places.
    final lowScale = Fixed.copyWith(highScale, scale: 2);
    expect(lowScale.minorUnits.toInt(), equals(100));
    expect(lowScale.scale, equals(2));
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

  test('compare', () {
    final t1 = Fixed.fromNum(1.01, scale: 0);
    final t2 = Fixed.fromNum(1.01, scale: 1);
    final t3 = Fixed.fromNum(1.01, scale: 2);
    final t4 = Fixed.fromNum(2.01, scale: 2);
    final t5 = Fixed.fromNum(2.01, scale: 2);

    expect(t1 == t1, isTrue);

    expect(t1 != t1, isFalse);

    expect(t1 < t2, isFalse);
    expect(t1 <= t2, isTrue);
    expect(t1 >= t2, isTrue);

    expect(t1 > t2, isFalse);
    expect(t1 >= t2, isTrue);
    expect(t1 <= t2, isTrue);
    expect(t1 == t2, isTrue);
    expect(t1 != t2, isFalse);

    expect(t3 > t2, isTrue);
    expect(t3 >= t2, isTrue);
    expect(t3 <= t2, isFalse);
    expect(t3 == t2, isFalse);
    expect(t3 != t2, isTrue);

    expect(t4.compareTo(t5) == 0, isTrue);
    expect(t4 == t5, isTrue);
    expect(t4 != t5, isFalse);
  });

  test('is', () {
    final t1 = Fixed.fromNum(2.01, scale: 2);
    final t2 = Fixed.fromNum(-2.01, scale: 5);

    final t3 = Fixed.fromNum(-0.01, scale: 1);
    final t4 = Fixed.fromNum(0, scale: 5);

    expect(t1.isNegative, isFalse);
    expect(t2.isNegative, isTrue);

    expect(t1.isPositive, isTrue);
    expect(t2.isPositive, isFalse);

    expect(t3.isZero, isTrue);
    expect(t4.isZero, isTrue);
  });

  test('rescale', () {
    final t1 = Fixed.fromInt(1234567, scale: 6);
    final t2 = Fixed.copyWith(t1, scale: 2);
    final t3 = Fixed.copyWith(t1, scale: 8);
    final t4 = Fixed.copyWith(t1, scale: 0);

    expect(t2.minorUnits.toInt(), equals(123));
    expect(t3.minorUnits.toInt(), equals(123456700));
    expect(t4.minorUnits.toInt(), equals(1));
  });

  test('examples', () {
    final rate = Fixed.fromNum(0.75486, scale: 5); // == 0.75486
    expect(rate.toString(), equals('0.75486'));
    expect(rate.format('0.#####'), equals('0.75486'));
    final auDollars = Fixed.fromNum(1, scale: 2); // == 1.00
    final usDollarsHighScale = auDollars * rate; // ==0.7548600, scale = 7
    expect(usDollarsHighScale.minorUnits.toInt(), equals(7548600));
    expect(usDollarsHighScale.scale, equals(7));

    /// reduce the scale to 2 decimal places.
    final usDollars = Fixed.copyWith(usDollarsHighScale, scale: 2); // == 1.75
    expect(usDollars.minorUnits.toInt(), equals(75));
    expect(usDollars.scale, equals(2));

    /// reduce the scale to 2 decimal places.
    final winnings = Fixed.fromNum(6, scale: 5); // == 6.00000
    final winners = Fixed.fromNum(2, scale: 2); // == 2.00
    final share = winnings / winners; // == 3.00000, scale = 5

    expect(share.minorUnits.toInt(), equals(300000));
    expect(share.scale, 5);
  });

  test('rescale', () {
    final t1 = Fixed.parse('1.2345678', scale: 7);

    final t2 = Fixed.copyWith(t1, scale: 2);
    expect(t2.integerPart, equals(BigInt.from(1)));
    expect(t2.decimalPart, equals(BigInt.from(23)));
    expect(t2.scale, equals(2));

    final t3 = Fixed.copyWith(t2, scale: 7);
    expect(t3.integerPart, equals(BigInt.from(1)));
    expect(t3.decimalPart, equals(BigInt.from(2300000)));
    expect(t3.scale, equals(7));

    final t4 = Fixed.copyWith(t1);
    expect(t4.integerPart, equals(BigInt.from(1)));
    expect(t4.decimalPart, equals(BigInt.from(2345678)));
    expect(t4.scale, equals(7));
  });

  test('rounding', () {
    expect(Fixed.tryParse('3.1415926535897932', scale: 4).toString(), '3.1416');
  });
  test('rescale - rounding', () {
    final t1 = Fixed.parse('1.2345678', scale: 7);
    final t2 = Fixed.copyWith(t1, scale: 3);

    expect(t2.integerPart, equals(BigInt.from(1)));
    expect(t2.decimalPart, equals(BigInt.from(235)));
    expect(t2.scale, equals(3));
  });

  test('double to big', () {
    expect(() => Fixed.fromNum(10, scale: 63),
        throwsA(isA<AmountTooLargeException>()));

    expect(() => Fixed.fromNum(10, scale: 21),
        throwsA(isA<AmountTooLargeException>()));
    expect(() => Fixed.fromNum(pow(10.0, 23), scale: 0),
        throwsA(isA<AmountTooLargeException>()));
  });

  test('issue #63 from Money2', () {
    final amount = Fixed.fromNum(121);
    final percent = Fixed.fromNum(1.21);
    final result = Fixed.copyWith(amount / percent, scale: 0)..toString();
    expect(result, equals(Fixed.fromNum(100, scale: 0)));
  });

  test('allocate', () {
    final t1 = Fixed.parse('23.84');
    t1.allocationAccordingTo([
      1,
      4,
      2,
    ]).forEach(print);
  });

  test('zero', () {
    expect(Fixed.fromInt(0).toInt(), 0);
  });

  test('toInt', () {
    expect(Fixed.parse('0').toInt(), 0);
    expect(Fixed.parse('1').toInt(), 1);
    expect(Fixed.parse('2.33').toInt(), 2);
    expect(Fixed.parse('2.99999').toInt(), 2);
    expect(Fixed.parse('0.99999').toInt(), 0);
  });

  test('invalid', () {
    expect(Fixed.tryParse(''), null);
    expect(Fixed.tryParse('a'), null);
    expect(Fixed.tryParse('1ea'), null);
    expect(Fixed.tryParse('131.A'), null);
  });

  test('constants', () {
    expect(Fixed.zero.integerPart, equals(BigInt.zero));
    expect(Fixed.zero.decimalPart, equals(BigInt.zero));

    expect(Fixed.one.integerPart, equals(BigInt.one));
    expect(Fixed.one.decimalPart, equals(BigInt.zero));

    expect(Fixed.two.integerPart, equals(BigInt.two));
    expect(Fixed.two.decimalPart, equals(BigInt.zero));

    expect(Fixed.ten.integerPart, equals(BigInt.from(10)));
    expect(Fixed.ten.decimalPart, equals(BigInt.zero));
  });

  test('less than zero', () {
    expect(Fixed.tryParse('.1')!.decimalPart, equals(BigInt.from(10)));
    expect(Fixed.tryParse('0.1')!.decimalPart, equals(BigInt.from(10)));

    expect(Fixed.tryParse('.01')!.decimalPart, equals(BigInt.from(1)));
    expect(Fixed.tryParse('0.01')!.decimalPart, equals(BigInt.from(1)));
  });
}
