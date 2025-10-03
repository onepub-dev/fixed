import 'package:fixed/fixed.dart';
import 'package:test/test.dart';

void main() {
  test('decimalDigits', () {
    final highDecimalDigits = Fixed.fromInt(10000, decimalDigits: 4);
    expect(highDecimalDigits.minorUnits.toInt(), equals(10000));
    expect(highDecimalDigits.decimalDigits, equals(4));

    /// reduce the decimalDigits to 2 decimal places.
    final lowDecimalDigits = highDecimalDigits.copyWith(decimalDigits: 2);
    expect(lowDecimalDigits.minorUnits.toInt(), equals(100));
    expect(lowDecimalDigits.decimalDigits, equals(2));
  });

  test('rescale', () {
    final t1 = Fixed.parse('1.2345678', decimalDigits: 7);

    final t2 = t1.copyWith(decimalDigits: 2);
    expect(t2.integerPart, equals(BigInt.from(1)));
    expect(t2.decimalPart, equals(BigInt.from(23)));
    expect(t2.decimalDigits, equals(2));

    final t3 = t2.copyWith(decimalDigits: 7);
    expect(t3.integerPart, equals(BigInt.from(1)));
    expect(t3.decimalPart, equals(BigInt.from(2300000)));
    expect(t3.decimalDigits, equals(7));

    final t4 = t1.copyWith();
    expect(t4.integerPart, equals(BigInt.from(1)));
    expect(t4.decimalPart, equals(BigInt.from(2345678)));
    expect(t4.decimalDigits, equals(7));

    final t5 = Fixed.fromInt(1234567, decimalDigits: 6);
    final t6 = t5.copyWith(decimalDigits: 2);
    final t7 = t5.copyWith(decimalDigits: 8);
    final t8 = t5.copyWith(decimalDigits: 0);

    expect(t6.minorUnits.toInt(), equals(123));
    expect(t7.minorUnits.toInt(), equals(123456700));
    expect(t8.minorUnits.toInt(), equals(1));
  });
}
