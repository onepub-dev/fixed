The Fixed package allows you to store and perform maths on decimal numbers
with a fixed scale (fixed no. of decimal places).

All amounts are stored using the Decimal package to allow precision maths to be performed.

The Fixed package allows you to have explicit control over the no. of decimals (the scale) that are stored.

The key difference between the Decimal and Fixed packages:
* Fixed uses a fixed scale (no. of decimal places)
* Fixed provides a builtin formatter `Fixed.format(pattern)`
* Fixed includes a convenience method `Fixed.formatIntl(locale)` which formats the number with the provided locale or the default locale if not provided.
* Most Fixed constructors take minorUnits and a scale (100 scale: 2 == 1.00)

# Storing fixed amounts
If you need to store or transmit a fixed value we recommend that you 
store the value as two discrete numbers; minorUnits and scale.
Storing the value using this technique guarentees no precision loss when storing, transmitting 
or retrieving Fixed decimal values.

# Constructors
There are multiple ways you can create a Fixed object

Example 1
```dart
import 'package:decimal/decimal.dart';
import 'package:fixed/fixed.dart';

expect(Fixed.fromInt(1234, scale: 3).toString(), equals('1.234')); // == 1.

final t3 = Fixed.fromBigInt(BigInt.from(1234), scale: 3); // == 1.234
expect(t3.toString(), equals('1.234'));

final t4 = Fixed.copyWith(t3, scale: 2); // == 1.23
expect(t4.toString(), equals('1.23'));

final t5 = Fixed.parse('1.234', scale: 3); // == 1.234
expect(t5.toString(), equals('1.234'));

final t6 = Fixed.fromDecimal(Decimal.fromInt(1), scale: 2); // == 1.00
expect(t6.toString(), equals('1.00'));

// This is the least desireable method as it can introduce
// rounding errors.
final t7 = Fixed.fromNum(1.234, scale: 3); // == 1.234
expect(t7.toString(), equals('1.234'));
```

# Scale
The Fixed package stores no.s with a fixed scale (number of decimal places).

If you attempt an operation on two Fixed values with different scale the result will
mostly be the larger of the two scales.

You can change the scale of a number by creating a new Fixed object using `Fixed.copyWith`.

Example 2
```dart
  final t7 = Fixed.fromNum(1.234, scale: 3); // == 1.234
  expect(t7.toString(), equals('1.234'));

  /// reduce the scale
  final t8 = Fixed.copyWith(t7, scale: 2); // == 1.23
  expect(t8.toString(), equals('1.23'));

  /// increase the scale
  final t9 = Fixed.copyWith(t8, scale: 5); // == 1.2300
  expect(t9.toString(), equals('1.23000'));
```


## Parsing
You can parse numbers from strings:

Example 3
```dart
var t1 = Fixed.parse('1.234', scale: 2);
expect(t1.minorUnits.toInt(), equals(123));
expect(t1.scale, equals(2));

var t2 = Fixed.parse('1,000,000.234', scale: 2);
expect(t2.minorUnits.toInt(), equals(100000023));
expect(t2.scale, equals(2));

/// for countries that use . for group separators
var t3 = Fixed.parse('1.000.000,234', scale: 2, invertSeparator: true);
expect(t3.minorUnits.toInt(), equals(100000023));
expect(t3.scale, equals(2));
```

# Formatting

You can also format numbers to strings

Example 4
```dart
var t3 = Fixed.fromInt(1234, scale: 3);

expect(t3.toString(), equals('1.234'));

expect(t3.format('00.###0'), equals('01.2340'));

expect(t3.format('00,###0', invertSeparator: true), equals('01,2340'));

var euFormat = Fixed.parse('1.000.000,23', invertSeparator: true, scale: 2);
// Format using a locale
expect(euFormat.formatIntl('en-AUS'), equals('1,000,000.23'));

// Format using default locale
expect(euFormat.formatIntl(), equals('1,000,000.23'));
```

# Performing maths
When performing most mathematical operations the larger scale of the two
operands is used.

For multiplication the resulting scale is the sum of the two scales
e.g.

```dart
  0.01 * 0.02 = 0.0002
```

If you need to change the scale of a number use Fixed.copyWith
passing the required scale.

```dart
 Fixed.copyWith(Fixed.fromInt(5, scale: 2), scale: 10);
```

# Operators
Fixed provides mathematical operations:

Example 6
```dart
final t1 = Fixed.parse('1.23'); // = 1.23
final t2 = Fixed.fromInt(100, scale: 2); // = 1.00

expect((t1 + t2).toString(), equals('2.23')); 
expect((t2 - t1).toString(), equals('-0.23')); 
expect((t1 * t2).toString(), equals('1.2300')); 
expect((t1 / t2).toString(), equals('1.23'));
expect((-t1).toString(), equals('-1.23'));

```

# Comparision

Example 7
```dart
final t1 = Fixed.fromNum(1.23);
final t2 = Fixed.fromInt(123, scale: 2);
final t3 = Fixed.fromBigInt(BigInt.from(1234), scale: 3);

expect(t1 == t2, isTrue);
expect(t1 < t3, isTrue);
expect(t1 <= t3, isTrue);
expect(t1 > t3, isFalse);
expect(t1 >= t3, isFalse);
expect(t1 != t3, isTrue);
expect(-t1, equals(Fixed.fromInt(-123, scale: 2)));

expect(t1.isPositive, isTrue);
expect(t1.isNegative, isFalse);
expect(t1.isZero, isFalse);

expect(t1.compareTo(t2), equals(0));
```
