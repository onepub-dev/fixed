/* Copyright (C) Brett Sutton - All Rights Reserved
 * Released under the MIT license.
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:fixed/src/fixed.dart';
import 'package:test/test.dart';

void main() {
  test('examples', () {
    final rate = Fixed.fromNum(0.75486, scale: 5); // == 0.75486
    expect(rate.toString(), equals('0.75486'));
    expect(rate.format('0.#####'), equals('0.75486'));
    final auDollars = Fixed.fromNum(1, scale: 2); // == 1.00
    final usDollarsHighScale = auDollars * rate; // ==0.7548600, scale = 7
    expect(usDollarsHighScale.minorUnits.toInt(), equals(7548600));
    expect(usDollarsHighScale.scale, equals(7));

    /// reduce the scale to 2 decimal places.
    final usDollars = usDollarsHighScale.copyWith(scale: 2); // == 1.75
    expect(usDollars.minorUnits.toInt(), equals(75));
    expect(usDollars.scale, equals(2));

    /// reduce the scale to 2 decimal places.
    final winnings = Fixed.fromNum(6, scale: 5); // == 6.00000
    final winners = Fixed.fromNum(2, scale: 2); // == 2.00
    final share = winnings / winners; // == 3.00000, scale = 5

    expect(share.minorUnits.toInt(), equals(300000));
    expect(share.scale, 5);
  });
  test('allocate', () {
    final t1 = Fixed.parse('23.84');
    final allocated = t1.allocationAccordingTo([
      1,
      4,
      2,
    ]).toList();

    expect(allocated.length, equals(3));
    expect(allocated[0], equals(Fixed.fromNum(3.41)));
    expect(allocated[0], equals(Fixed.fromNum(13.62)));
    expect(allocated[2], equals(Fixed.fromNum(6.81)));
  });

  test('zero', () {
    expect(Fixed.fromInt(0).toInt(), 0);
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
}
