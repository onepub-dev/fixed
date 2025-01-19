import 'package:fixed/fixed.dart';
import 'package:test/test.dart';

void main() {


  test('scale', () {
    final highScale = Fixed.fromInt(10000, scale: 4);
    expect(highScale.minorUnits.toInt(), equals(10000));
    expect(highScale.scale, equals(4));

    /// reduce the scale to 2 decimal places.
    final lowScale = highScale.copyWith( scale: 2);
    expect(lowScale.minorUnits.toInt(), equals(100));
    expect(lowScale.scale, equals(2));
  });


  test('rescale', () {
    final t1 = Fixed.parse('1.2345678', scale: 7);

    final t2 = t1.copyWith( scale: 2);
    expect(t2.integerPart, equals(BigInt.from(1)));
    expect(t2.decimalPart, equals(BigInt.from(23)));
    expect(t2.scale, equals(2));

    final t3 = t2.copyWith( scale: 7);
    expect(t3.integerPart, equals(BigInt.from(1)));
    expect(t3.decimalPart, equals(BigInt.from(2300000)));
    expect(t3.scale, equals(7));

    final t4 = t1.copyWith();
    expect(t4.integerPart, equals(BigInt.from(1)));
    expect(t4.decimalPart, equals(BigInt.from(2345678)));
    expect(t4.scale, equals(7));

    final t5 = Fixed.fromInt(1234567, scale: 6);
    final t6 = t5.copyWith( scale: 2);
    final t7 = t5.copyWith( scale: 8);
    final t8 = t5.copyWith( scale: 0);

    expect(t6.minorUnits.toInt(), equals(123));
    expect(t7.minorUnits.toInt(), equals(123456700));
    expect(t8.minorUnits.toInt(), equals(1));
  });

}
