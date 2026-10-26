The Fixed package allows you to store and perform math on decimal numbers with a fixed scale (fixed no. of decimal places).

All amounts are stored as BigInts to allow precision math to be performed.

The features of Fixed are:
* Fixed uses a selectable fixed scale (no. of decimal places)
* Fixed provides a builtin formatter and parser Fixed.format(pattern)
* Full set of mathematical opertors.
* Fixed includes a convenience method Fixed.formatIntl(locale) which formats the number with the provided locale or the default locale if not provided.


# Sponsors

Fixed is sponsored by OnePub, the Dart private package repository.

<a href="https://onepub.dev">
  <img src="https://raw.githubusercontent.com/onepub-dev/fixed/main/images/LogoAndByLine.png" alt="OnePub" width="300">
</a>



You can create a Fixed instance from a number of sources:
```dart
import 'package:fixed/fixed.dart';

void main() {
  final t1 = Fixed.fromNum(1, decimalDigits: 2); // 1.00
  final t2 = Fixed.fromNum(1, decimalDigits: 3); // 1.000

  final add = t1 + Fixed.ten;
  final multiply = t1 * t2;
  print(add); // 11.00
  print(multiply); // 1.00000

  final t3 = Fixed.parse('1.23356'); // decimalDigits: 5

  if (t1 == t2) { // true
    print(t1.format('0.##')); // 1.00
    print(t3.format('0.###')); // 1.233
  }
}
```


Numeric equality, ordering (`compareTo` and relational operators), and hash codes
ignore differences in scale: `Fixed.parse('1.0')` and `Fixed.parse('1.00')`
represent the same value and can be used interchangeably as map keys.

Parsing consumes the entire input and throws `FixedParseException` for invalid
suffixes or input without digits. `Fixed.tryParse` returns `null` for invalid
input. Whitespace is ignored, grouping separators are accepted, and
`invertSeparator: true` swaps the decimal and grouping separators.

`~/` truncates the quotient towards zero and retains the larger operand scale.
For example, `Fixed.parse('7.50') ~/ Fixed.parse('2.0')` produces `3.00`,
and the corresponding `remainder` is `1.500`.

`divide(num)` retains the original value's scale and rounds once, half away
from zero. It interprets the divisor's decimal string representation without
computing a floating-point reciprocal. For example,
`Fixed.parse('1.00').divide(3)` produces `0.33`. Zero and non-finite divisors
throw `FixedException`. `pow(0)` returns one at the original scale, including
scales above 20 decimal digits.

Full documentation can be found [here.](https://fixed.onepub.dev)
