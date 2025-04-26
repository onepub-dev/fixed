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

    expect(result.minorUnits.toInt(), equals(306171));
    expect(result.decimalDigits, equals(5));

    expect(Fixed.one / Fixed.parse('10', decimalDigits: 2),
        equals(Fixed.parse('0.1')));
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
}
