import 'package:fixed/fixed.dart';

void main() {
  var fixed = Fixed.fromNum(1, scale: 2); // == 1.00

  Fixed.parse('1.234', scale: 2); // == 1.23;

  Fixed.parse('1,000,000.234', scale: 2); // == 1000000.23

  /// decimal separator is ','.
  Fixed.parse('1.000.000,234',
      scale: 2, invertSeparator: true); // == 1000000.23

  /// us minor units
  Fixed.fromInt(1234, scale: 3); // == 1.234

  /// use default formatting
  print(fixed.toString());

  /// control the formatted output
  print(fixed.format('#.#'));
  print(fixed.format('#.000'));

  var add = fixed + Fixed.fromNum(1);
  print(add);
}
