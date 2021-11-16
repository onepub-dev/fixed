import 'package:fixed/src/fixed.dart';
import 'package:test/test.dart';

void main() {
  test('format ...', () async {
    var fixed = Fixed.from(1, scale: 2);

    expect(fixed.toString(), equals('1.00'));

    expect(fixed.format('#.#'), equals('1.0'));
    expect(fixed.format('#.000'), equals('1.000'));
    expect(fixed.format('#'), equals('1'));
    expect(fixed.format('.##'), equals('.00'));

    fixed = Fixed.from(1.23, scale: 2);
    expect(fixed.toString(), equals('1.23'));

    expect(fixed.format('#.#'), equals('1.2'));
    expect(fixed.format('#.000'), equals('1.230'));
    expect(fixed.format('#'), equals('1'));
    expect(fixed.format('.##'), equals('.23'));

    final t3 = Fixed.fromMinorUnits(-10000, scale: 4);
    expect(t3.format('#.#'), equals('-1.0'));
    expect(t3.format('#'), equals('-1'));
    final t4 = Fixed.fromMinorUnits(10000, scale: 4);
    expect(t4.format('#.#'), equals('1.0'));
    expect(t4.format('#'), equals('1'));
  });

  group('ctors', () {
    test('Fixed.from', () {
      final t1 = Fixed.from(1);
      expect(t1.minorUnits.toInt(), equals(100));
      expect(t1.integerPart.toInt(), equals(1));
      expect(t1.scale, equals(2));

      final t2 = Fixed.from(100, scale: 2);
      expect(t2.minorUnits.toInt(), equals(10000));
      expect(t2.integerPart.toInt(), equals(100));
      expect(t2.scale, equals(2));

      final t3 = Fixed.from(1000, scale: 3);
      expect(t3.minorUnits.toInt(), equals(1000000));
      expect(t3.integerPart.toInt(), equals(1000));
      expect(t3.scale, equals(3));

      final t4 = Fixed.from(1000, scale: 0);
      expect(t4.minorUnits.toInt(), equals(1000));
      expect(t4.integerPart.toInt(), equals(1000));
      expect(t4.scale, equals(0));

      expect(() => Fixed.from(1000, scale: -1), throwsA(isA<FixedException>()));

      final t5 = Fixed.from(75486, scale: 5); // == 0.75486
      expect(t5.minorUnits.toInt(), equals(7548600000));
      expect(t5.integerPart.toInt(), equals(75486));
      expect(t5.scale, equals(5));
    });

    test('Fixed.fromMinorUnits', () {
      final t1 = Fixed.fromMinorUnits(1, scale: 2);
      expect(t1.minorUnits.toInt(), equals(1));
      expect(t1.integerPart.toInt(), equals(0));
      expect(t1.scale, equals(2));

      final t2 = Fixed.fromMinorUnits(100, scale: 2);
      expect(t2.minorUnits.toInt(), equals(100));
      expect(t2.integerPart.toInt(), equals(1));
      expect(t2.scale, equals(2));

      final t3 = Fixed.fromMinorUnits(1000, scale: 3);
      expect(t3.minorUnits.toInt(), equals(1000));
      expect(t3.integerPart.toInt(), equals(1));
      expect(t3.scale, equals(3));

      final t4 = Fixed.fromMinorUnits(1000, scale: 0);
      expect(t4.minorUnits.toInt(), equals(1000));
      expect(t4.integerPart.toInt(), equals(1000));
      expect(t4.scale, equals(0));

      expect(() => Fixed.from(1000, scale: -1), throwsA(isA<FixedException>()));

      final t5 = Fixed.fromMinorUnits(75486, scale: 5); // == 0.75486
      expect(t5.minorUnits.toInt(), equals(75486));
      expect(t5.integerPart.toInt(), equals(0));
      expect(t5.scale, equals(5));

      final t6 = Fixed.fromMinorUnits(1);
      expect(t6.minorUnits.toInt(), equals(1));
      expect(t6.integerPart.toInt(), equals(0));
      expect(t6.scale, equals(2));

      final rate2 = Fixed.fromMinorUnits(7548, scale: 5); // == 0.07548
      expect(rate2.minorUnits.toInt(), equals(7548));
      expect(rate2.integerPart.toInt(), equals(0));
      expect(rate2.scale, equals(5));
    });
  });

  test('multiplication', () {
    final rate = Fixed.fromMinorUnits(7548, scale: 5); // == 0.07548
    final auDollars = Fixed.fromMinorUnits(100, scale: 2); // == 1.00
    final usDollarsHighScale = auDollars * rate; // == 0.07548000, scale = 7

    expect(usDollarsHighScale.minorUnits.toInt(), equals(754800));
    expect(usDollarsHighScale.scale, equals(7));
  });

  test('division', () {
    final winnings = Fixed.fromMinorUnits(600000, scale: 5); // == 6.0000
    final winners = Fixed.from(2.00, scale: 2); // == 2.00
    final share = winnings / winners; // == 3.0000, scale = 5

    expect(share.minorUnits.toInt(), equals(300000));
    expect(share.scale, equals(5));
  });

  test('plus', () {
    final fixed = Fixed.fromMinorUnits(100);
    expect(fixed + Fixed.from(1), equals(Fixed.from(2)));

    /// mixed scale
    final t1 = Fixed.from(100.1234, scale: 4) + Fixed.from(1);
    expect(t1.minorUnits.toInt(), equals(1011234));
    expect(t1.scale, equals(4));
  });

  test('minus', () {
    final fixed = Fixed.fromMinorUnits(300);
    expect(fixed - Fixed.from(1), equals(Fixed.from(2)));

    /// mixed scale
    final t1 = Fixed.from(100.1234, scale: 4) + Fixed.from(1);
    expect(t1.minorUnits.toInt(), equals(1011234));
    expect(t1.scale, equals(4));
  });

  test('unary minus', () {
    final t1 = Fixed.from(1, scale: 4);
    final t2 = -t1;
    expect(t2.integerPart.toInt(), equals(-1));
    expect(t2.decimalPart.toInt(), equals(0));
    expect(t1.scale, equals(4));
  });

  test('scale', () {
    final highScale = Fixed.fromMinorUnits(10000, scale: 4);
    expect(highScale.minorUnits.toInt(), equals(10000));
    expect(highScale.scale, equals(4));

    /// reduce the scale to 2 decimal places.
    final lowScale = Fixed(highScale, scale: 2);
    expect(lowScale.minorUnits.toInt(), equals(100));
    expect(lowScale.scale, equals(2));
  });

  test('toString', () {
    final t1 = Fixed.from(1.01, scale: 0);
    expect(t1.toString(), equals('1'));

    final t2 = Fixed.from(1.01, scale: 1);
    expect(t2.toString(), equals('1.0'));

    final t3 = Fixed.from(1.01, scale: 2);
    expect(t3.toString(), equals('1.01'));

    final t4 = Fixed.from(-1.01, scale: 0);
    expect(t4.toString(), equals('-1'));

    final t5 = Fixed.from(-1.01, scale: 1);
    expect(t5.toString(), equals('-1.0'));

    final t6 = Fixed.from(-1.01, scale: 2);
    expect(t6.toString(), equals('-1.01'));
  });

  test('compare', () {
    final t1 = Fixed.from(1.01, scale: 0);
    final t2 = Fixed.from(1.01, scale: 1);
    final t3 = Fixed.from(1.01, scale: 2);
    final t4 = Fixed.from(2.01, scale: 2);
    final t5 = Fixed.from(2.01, scale: 2);

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
    final t1 = Fixed.from(2.01, scale: 2);
    final t2 = Fixed.from(-2.01, scale: 5);

    final t3 = Fixed.from(-0.01, scale: 1);
    final t4 = Fixed.from(0, scale: 5);

    expect(t1.isNegative, isFalse);
    expect(t2.isNegative, isTrue);

    expect(t1.isPositive, isTrue);
    expect(t2.isPositive, isFalse);

    expect(t3.isZero, isTrue);
    expect(t4.isZero, isTrue);
  });

  test('rescale', () {
    final t1 = Fixed.fromMinorUnits(1234567, scale: 6);
    final t2 = Fixed(t1, scale: 2);
    final t3 = Fixed(t1, scale: 8);
    final t4 = Fixed(t1, scale: 0);

    expect(t2.minorUnits.toInt(), equals(123));
    expect(t3.minorUnits.toInt(), equals(123456700));
    expect(t4.minorUnits.toInt(), equals(1));
  });

  test('examples', () {
    final rate = Fixed.from(0.75486, scale: 5); // == 0.75486
    expect(rate.toString(), equals('0.75486'));
    final auDollars = Fixed.from(1, scale: 2); // == 1.00
    final usDollarsHighScale = auDollars * rate; // ==0.7548600, scale = 7
    expect(usDollarsHighScale.minorUnits.toInt(), equals(7548600));
    expect(usDollarsHighScale.scale, equals(7));

    /// reduce the scale to 2 decimal places.
    final usDollars = Fixed(usDollarsHighScale, scale: 2); // == 1.75

    expect(usDollars.minorUnits.toInt(), equals(75));
    expect(usDollars.scale, equals(2));

    final winnings = Fixed.from(6, scale: 5); // == 6.00000
    final winners = Fixed.from(2, scale: 2); // == 2.00
    final share = winnings / winners; // == 3.00000, scale = 5

    expect(share.minorUnits.toInt(), equals(300000));
    expect(share.scale, 5);
  });
}
