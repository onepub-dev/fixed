import 'package:fixed/fixed.dart';
import 'package:test/test.dart';

void main() {
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

    expect(
        Fixed.parse('0.00123456789', scale: 100) *
            Fixed.parse('0.0000000001', scale: 100),
        equals(Fixed.parse('0.000000000000123456789', scale: 100)));
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

    expect(Fixed.one / Fixed.parse('10', scale: 2), equals(Fixed.parse('0.1')));
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

  group('Fixed.pow', () {
    Fixed f(String s) => Fixed.parse(s); // convenience
    test('keeps same scale', () {
      final x = f('10.000'); // scale 3
      final y = x.pow(2);
      expect(y.scale, equals(3));
      expect(y.toString(), equals('100.000'));
      // Also validate minorUnits directly: 100.000 * 10^3 = 100000
      expect(y.minorUnits, equals(BigInt.from(100000)));
    });

    test('exponent 1 returns same value', () {
      final x = f('3.141');
      final y = x.pow(1);
      expect(y.scale, equals(x.scale));
      expect(y.toString(), equals('3.141'));
    });

    test('exponent 0 returns 1 at same scale', () {
      final x = f('99.999');
      final y = x.pow(0);
      expect(y.scale, equals(x.scale));
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
      final x = Fixed.parse('2.5', scale: 1);
      final y = x.pow(3);
      expect(y.scale, equals(1));
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
