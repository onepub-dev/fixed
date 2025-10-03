import 'package:fixed/fixed.dart';
import 'package:test/test.dart';

void main() {
  test('multiplication', () {
    final rate = Fixed.fromInt(7548, decimalDigits: 5); // == 0.07548
    expect(rate.minorUnits.toInt(), equals(7548));

    final auDollars = Fixed.fromInt(100); // == 1.00
    final usDollarsHighDecimalDigits =
        auDollars * rate; // == 0.07548000, decimalDigits = 7

    expect(usDollarsHighDecimalDigits.minorUnits.toInt(), equals(754800));
    expect(usDollarsHighDecimalDigits.decimalDigits, equals(7));

    expect(
        Fixed.fromInt(-200) * Fixed.fromInt(100), equals(Fixed.fromInt(-200)));

    expect(Fixed.fromInt(-2) * Fixed.fromInt(100), equals(Fixed.fromInt(-2)));

    expect(Fixed.fromInt(-2) * Fixed.fromInt(-100), equals(Fixed.fromInt(2)));

    expect(
        Fixed.parse('0.00123456789', decimalDigits: 100) *
            Fixed.parse('0.0000000001', decimalDigits: 100),
        equals(Fixed.parse('0.000000000000123456789', decimalDigits: 100)));
  });

  group('division', () {
    test('by zero throws', () {
      expect(() => Fixed.one / Fixed.zero, throwsA(isA<FixedException>()));
    });

    test('division', () {
      final winnings = Fixed.fromInt(600000, decimalDigits: 5); // == 6.0000
      final winners = Fixed.fromNum(2.00, decimalDigits: 2); // == 2.00
      final share = winnings / winners; // == 3.0000, decimalDigits = 5

      expect(share.minorUnits.toInt(), equals(300000));
      expect(share.decimalDigits, equals(5));

      final one = Fixed.fromInt(1, decimalDigits: 0);
      final three = Fixed.fromInt(3, decimalDigits: 0);

      expect(one / three, equals(Fixed.zero));

      final numerator = Fixed.fromInt(612343, decimalDigits: 5); // == 6.0000
      final denominator = Fixed.fromNum(2.00, decimalDigits: 2); // == 2.00
      final result = numerator / denominator; // == 3.0000, decimalDigits = 5

      expect(result.minorUnits.toInt(), equals(306172));
      expect(result.decimalDigits, equals(5));

      expect(Fixed.one / Fixed.parse('10', decimalDigits: 2),
          equals(Fixed.parse('0.1')));
    });
    group('Fixed division with very small numbers (fixed scale policy)', () {
      test('tiny / 10 at 23 dp rounds to zero (no scale change)', () {
        final tiny = Fixed.parse('0.00000000000000000000001'); // 23 dp
        final result = tiny / Fixed.ten; // keeps 23 dp

        // At 23 dp, 1e-24 is not representable -> 0
        expect(result.decimalDigits, equals(23));
        expect(result.minorUnits, equals(BigInt.zero));
        expect(result.toString(), equals('0.00000000000000000000000'));
      });

      test('10 / tiny at 23 dp prints integer with 23 trailing zeros', () {
        final tiny = Fixed.parse('0.00000000000000000000001'); // 23 dp
        final result = Fixed.ten / tiny; // keeps 23 dp

        // Exact value is 1e24; with 23 dp we show a .000... tail
        expect(result.decimalDigits, equals(23));
        expect(result.toString(),
            equals('1000000000000000000000000.00000000000000000000000'));
      });

      test('Ask for more precision to see non-zero tiny result', () {
        // Same magnitude, but we *store* it with 24 decimal digits.
        final tiny24 =
            Fixed.parse('0.00000000000000000000001', decimalDigits: 24);
        final result = tiny24 / Fixed.ten; // keeps 24 dp

        // Now 1e-24 is representable at 24 dp.
        expect(result.decimalDigits, equals(24));
        expect(result.toString(), equals('0.000000000000000000000001'));
        expect(result.minorUnits, equals(BigInt.one));
      });
    });
  });

  test('plus', () {
    final fixed = Fixed.fromInt(100);
    expect(fixed + Fixed.fromNum(1), equals(Fixed.fromNum(2)));

    /// mixed decimalDigits
    final t1 = Fixed.fromNum(100.1234, decimalDigits: 4) + Fixed.fromNum(1);
    expect(t1.minorUnits.toInt(), equals(1011234000000000000));
    expect(t1.decimalDigits, equals(16));
  });

  test('minus', () {
    final fixed = Fixed.fromInt(300);
    expect(fixed - Fixed.fromNum(1), equals(Fixed.fromNum(2)));

    /// mixed decimalDigits
    final t1 = Fixed.fromNum(100.1234, decimalDigits: 4) + Fixed.fromNum(1);
    expect(t1.minorUnits.toInt(), equals(1011234000000000000));
    expect(t1.decimalDigits, equals(16));

    /// mixed decimalDigits
    final t2 = Fixed.fromNum(100.1234, decimalDigits: 4) +
        Fixed.fromNum(1, decimalDigits: 3);
    expect(t2.minorUnits.toInt(), equals(1011234));
    expect(t2.decimalDigits, equals(4));
  });

  test('unary minus', () {
    final t1 = Fixed.fromNum(1, decimalDigits: 4);
    final t2 = -t1;
    expect(t2.integerPart.toInt(), equals(-1));
    expect(t2.decimalPart.toInt(), equals(0));
    expect(t1.decimalDigits, equals(4));
  });

  group('Fixed.pow', () {
    Fixed f(String s) => Fixed.parse(s); // convenience
    test('keeps same scale', () {
      final x = f('10.000'); // scale 3
      final y = x.pow(2);
      expect(y.decimalDigits, equals(3));
      expect(y.toString(), equals('100.000'));
      // Also validate minorUnits directly: 100.000 * 10^3 = 100000
      expect(y.minorUnits, equals(BigInt.from(100000)));
    });

    test('exponent 1 returns same value', () {
      final x = f('3.141');
      final y = x.pow(1);
      expect(y.decimalDigits, equals(x.decimalDigits));
      expect(y.toString(), equals('3.141'));
    });

    test('exponent 0 returns 1 at same scale', () {
      final x = f('99.999');
      final y = x.pow(0);
      expect(y.decimalDigits, equals(x.decimalDigits));
      expect(y.toString(), equals('1.000'));
    });

    test('positive base squared', () {
      final x = f('1.500'); // 1.5^2 = 2.25
      final y = x.pow(2);
      expect(y.toString(), equals('2.250'));
    });

    test('negative base: even exponent gives positive', () {
      final x = f('-2.000'); // (-2)^2 = 4
      final y = x.pow(2);
      expect(y.toString(), equals('4.000'));
    });

    test('negative base: odd exponent gives negative', () {
      final x = f('-2.000'); // (-2)^3 = -8
      final y = x.pow(3);
      expect(y.toString(), equals('-8.000'));
    });

    test('rounding: half-away-from-zero (exact half up)', () {
      // 1.25^2 = 1.5625 -> at scale=3 rounds to 1.563
      final x = f('1.250');
      final y = x.pow(2);
      expect(y.toString(), equals('1.563'));
    });

    test('rounding: below half rounds down', () {
      // 2.005^2 = 4.020025 -> at scale=3 rounds to 4.020
      final x = f('2.005');
      final y = x.pow(2);
      expect(y.toString(), equals('4.020'));
    });

    test('rounding: negative exact half rounds away from zero', () {
      // (-1.25)^2 = 1.5625 -> same as positive in magnitude
      final x = f('-1.250');
      final y = x.pow(2);
      expect(y.toString(), equals('1.563'));
    });

    test('different initial scale preserved', () {
      // Parse with explicit scale=1. 2.5^3 = 15.625 -> scale=1 => 15.6
      final x = Fixed.parse('2.5', decimalDigits: 1);
      final y = x.pow(3);
      expect(y.decimalDigits, equals(1));
      expect(y.toString(), equals('15.6'));
    });

    test('large value squared remains precise and scaled', () {
      // (99999.999)^2 = 9999999800.000001 -> scale=3 => 9999999800.000
      final x = f('99999.999');
      final y = x.pow(2);
      expect(y.toString(), equals('9999999800.000'));
    });

    test('zero base', () {
      final x = f('0.000');
      expect(x.pow(2).toString(), equals('0.000'));
      expect(x.pow(3).toString(), equals('0.000'));
    });

    test('throws on negative exponent', () {
      final x = f('2.000');
      expect(() => x.pow(-1), throwsArgumentError);
    });
  });
}
