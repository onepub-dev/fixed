import 'package:fixed/fixed.dart';
import 'package:test/test.dart';

void main() {
  test('rescale - rounding', () {
    final t1 = Fixed.parse('1.2345678', decimalDigits: 7);
    final t2 = t1.copyWith(decimalDigits: 3);

    expect(t2.integerPart, equals(BigInt.from(1)));
    expect(t2.decimalPart, equals(BigInt.from(235)));
    expect(t2.decimalDigits, equals(3));
  });

  test('rounding', () {
    expect(Fixed.tryParse('3.1415926535897932', decimalDigits: 4).toString(),
        '3.1416');
  });
}
