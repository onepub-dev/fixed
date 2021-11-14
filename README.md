The Fixed package allows you to store and perform maths on numbers
with a fixed scale (fixed no. of decimal places).

All amounts are store as integers to allow precision maths to be performed.

The Fixed package allows you to have explicit control over the no. of decimals (the scale) that are stored.

Fixed instances are immutable.

For multiplication the resulting scale is the same of the two scales
e.g.
```
  0.01 * 0.02 = 0.0002
```

After a mathematical operation you may need to build a new Fixed object with the required scale.

```dart
final rate = Fixed.fromMinorUnits(75486, scale: 5); // == 0.75486
final auDollars = Fixed.fromMinorUnits(100, scale: 2); // == 1.00
final usDollarsHighScale = auDollars * rate;  // ==0.7548600, scale = 7

/// reduce the scale to 2 decimal places.
final usDollars = Fixed(usDollarsHighScale, scale: 2); // == 0.75
```

When performing division the result will have larger scale of the
two operands.

```dart
final winnings = Fixed.fromMinorUnits(600000, scale: 5); // == 6.00000
final winners = Fixed.fromMinorUnits(200, scale: 2); // == 2.00
final share = winnings / winners;  // == 3.00000, scale = 5

```

# Operators
Fixed provides mathematical operations:

```dart
final t1 = Fixed.from(1.23);
final t2 = Fixed.fromMinorUnits(123, scale: 2);
final t3 = Fixed.fromBigInt(BigInt.from(1234), scale: 3));

expect(t1 == t2, isTrue);
expect(t1 < t3, isTrue);
expect(t1 <= t3, isTrue);
expect(t1 > t3, isFalse);
expect(t1 >= t3, isFalse);
expect(t1 != t3, isTrue);
expect(-t1, equals(Fixed.fromMinorUnits(-123, scale: 2)));

expect(t1.isPositive, isTrue);
expect(t1.isNegative, isFalse);
expect(t1.isZero, isTrue);

expect(t1.compareTo(t2) , isTrue);
```

## Parsing

You can parse numbers from strings:

```dart
var t1 = Fixed.parse('1.234', pattern: '#.#', scale: 2);
expect(t1.minorUnits.toInt(), equals(1234));
expect(t1.scale, equals(2));


var t1 = Fixed.parse('1,000,000.234', pattern: '#,###.#', scale: 2);
expect(t1.minorUnits.toInt(), equals(1000000.23));
expect(t1.scale, equals(2));


/// for countries that use . for thousand separators
var t1 = Fixed.parse('1.000.000,234', pattern: '#.###,#', scale: 2, invertSeparators);
expect(t1.minorUnits.toInt(), equals(1000000.23));
expect(t1.scale, equals(2));
```

# Formating

You can also format numbers to strings
```dart
var t1 = Fixed.fromMinorUnits(1234, scale: 3);

expect(t3.toString(), equals('1.234'));

expect(t3.format('00.###0'), equals('00.12340'));

expect(t3.format('00.###0', invertSeparators: true), equals('00,12340'));

```