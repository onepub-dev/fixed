import 'package:decimal/decimal.dart';
import 'package:fixed/fixed.dart';
import 'package:test/test.dart';

void main() {
  test('toInt', () {
    expect(Fixed.parse('0').toInt(), 0);
    expect(Fixed.parse('1').toInt(), 1);
    expect(Fixed.parse('2.33').toInt(), 2);
    expect(Fixed.parse('2.99999').toInt(), 2);
    expect(Fixed.parse('0.99999').toInt(), 0);
  });

  test('toInt', () {
    expect(Fixed.parse('0').toInt(), 0);
    expect(Fixed.parse('1').toInt(), 1);
    expect(Fixed.parse('2.33').toInt(), 2);
    expect(Fixed.parse('2.99999').toInt(), 2);
    expect(Fixed.parse('0.99999').toInt(), 0);
  });

  test('Fixed.fromMinorUnits', () {
    final t1 = Fixed.fromInt(1);
    expect(t1.minorUnits.toInt(), equals(1));
    expect(t1.integerPart.toInt(), equals(0));
    expect(t1.decimalDigits, equals(2));

    final t7 = Fixed.fromInt(10);
    expect(t7.minorUnits.toInt(), equals(10));
    expect(t7.integerPart.toInt(), equals(0));
    expect(t7.decimalDigits, equals(2));

    final t2 = Fixed.fromInt(100);
    expect(t2.minorUnits.toInt(), equals(100));
    expect(t2.integerPart.toInt(), equals(1));
    expect(t2.decimalDigits, equals(2));

    final t3 = Fixed.fromInt(1000, decimalDigits: 3);
    expect(t3.minorUnits.toInt(), equals(1000));
    expect(t3.integerPart.toInt(), equals(1));
    expect(t3.decimalDigits, equals(3));

    final t4 = Fixed.fromInt(1000, decimalDigits: 0);
    expect(t4.minorUnits.toInt(), equals(1000));
    expect(t4.integerPart.toInt(), equals(1000));
    expect(t4.decimalDigits, equals(0));

    expect(() => Fixed.fromNum(1000, decimalDigits: -1),
        throwsA(isA<FixedException>()));

    final t5 = Fixed.fromInt(75486, decimalDigits: 5); // == 0.75486
    expect(t5.minorUnits.toInt(), equals(75486));
    expect(t5.integerPart.toInt(), equals(0));
    expect(t5.decimalDigits, equals(5));

    final t6 = Fixed.fromInt(1);
    expect(t6.minorUnits.toInt(), equals(1));
    expect(t6.integerPart.toInt(), equals(0));
    expect(t6.decimalDigits, equals(2));

    final rate2 = Fixed.fromInt(7548, decimalDigits: 5); // == 0.07548
    expect(rate2.minorUnits.toInt(), equals(7548));
    expect(rate2.integerPart.toInt(), equals(0));
    expect(rate2.decimalDigits, equals(5));
  });

  test('Fixed.from', () {
    final t1 = Fixed.fromNum(1);
    expect(t1.minorUnits.toInt(), equals(10000000000000000));
    expect(t1.integerPart.toInt(), equals(1));
    expect(t1.decimalDigits, equals(16));

    final t2 = Fixed.fromNum(100, decimalDigits: 2);
    expect(t2.minorUnits.toInt(), equals(10000));
    expect(t2.integerPart.toInt(), equals(100));
    expect(t2.decimalDigits, equals(2));

    final t3 = Fixed.fromNum(1000, decimalDigits: 3);
    expect(t3.minorUnits.toInt(), equals(1000000));
    expect(t3.integerPart.toInt(), equals(1000));
    expect(t3.decimalDigits, equals(3));

    final t4 = Fixed.fromNum(1000, decimalDigits: 0);
    expect(t4.minorUnits.toInt(), equals(1000));
    expect(t4.integerPart.toInt(), equals(1000));
    expect(t4.decimalDigits, equals(0));

    expect(() => Fixed.fromNum(1000, decimalDigits: -1),
        throwsA(isA<FixedException>()));

    final t5 = Fixed.fromNum(75486, decimalDigits: 5); // == 0.75486
    expect(t5.minorUnits.toInt(), equals(7548600000));
    expect(t5.integerPart.toInt(), equals(75486));
    expect(t5.decimalDigits, equals(5));

    final t6 = Fixed.fromNum(1.123456789);
    expect(t6.minorUnits.toInt(), equals(11234567890000000));
    expect(t6.integerPart.toInt(), equals(1));
    expect(t6.decimalDigits, equals(16));

    final t7 = Fixed.fromDecimal(
        (Decimal.fromInt(1) / Decimal.fromInt(3))
            .toDecimal(scaleOnInfinitePrecision: 16),
        decimalDigits: 2); // == 1.00
    expect(t7.minorUnits.toInt(), equals(33));
    expect(t7.integerPart.toInt(), equals(0));
    expect(t7.decimalDigits, equals(2));
  });
}
