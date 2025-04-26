import 'package:fixed/fixed.dart';
import 'package:test/test.dart';

void main() {
  test('is', () {
    final t1 = Fixed.fromNum(2.01, decimalDigits: 2);
    final t2 = Fixed.fromNum(-2.01, decimalDigits: 5);

    final t3 = Fixed.fromNum(-0.01, decimalDigits: 1);
    final t4 = Fixed.fromNum(0, decimalDigits: 5);

    expect(t1.isNegative, isFalse);
    expect(t2.isNegative, isTrue);

    expect(t1.isPositive, isTrue);
    expect(t2.isPositive, isFalse);

    expect(t3.isZero, isTrue);
    expect(t4.isZero, isTrue);
  });

  test('compare', () {
    final t1 = Fixed.fromNum(1.01, decimalDigits: 0);
    final t2 = Fixed.fromNum(1.01, decimalDigits: 1);
    final t3 = Fixed.fromNum(1.01, decimalDigits: 2);
    final t4 = Fixed.fromNum(2.01, decimalDigits: 2);
    final t5 = Fixed.fromNum(2.01, decimalDigits: 2);

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

  test('less than zero', () {
    expect(Fixed.tryParse('.1')!.decimalPart, equals(BigInt.from(10)));
    expect(Fixed.tryParse('0.1')!.decimalPart, equals(BigInt.from(10)));

    expect(Fixed.tryParse('.01')!.decimalPart, equals(BigInt.from(1)));
    expect(Fixed.tryParse('0.01')!.decimalPart, equals(BigInt.from(1)));
  });

  test('compare other', () {
    // This example better demonstrates the issue
    final list = <Object>[Fixed.fromInt(10), 10, Fixed.fromInt(20)];
    // This can lead to inconsistent behavior
    expect(list[0] == 10, equals(false));
    expect(10 == list[0], equals(false));
    expect(list[0] == Fixed.fromInt(10), equals(true));
  });
}
