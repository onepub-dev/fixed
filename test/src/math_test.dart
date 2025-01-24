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
}
