import 'package:fixed/fixed.dart';
import 'package:test/test.dart';

void main() {
  test('rescale - rounding', () {
    final t1 = Fixed.parse('1.2345678', scale: 7);
    final t2 = t1.copyWith(scale: 3);

    expect(t2.integerPart, equals(BigInt.from(1)));
    expect(t2.decimalPart, equals(BigInt.from(235)));
    expect(t2.scale, equals(3));
  });


  test('rounding', () {
    expect(Fixed.tryParse('3.1415926535897932', scale: 4).toString(), '3.1416');
  });


 
}
