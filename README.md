The Fixed package allows you to store and perform math on decimal numbers with a fixed scale (fixed no. of decimal places).

All amounts are stored as BigInts to allow precision math to be performed.

The features of Fixed are:
* Fixed uses a selectable fixed scale (no. of decimal places)
* Fixed provides a builtin formatter and parser Fixed.format(pattern)
* Full set of mathematical opertors.
* Fixed includes a convenience method Fixed.formatIntl(locale) which formats the number with the provided locale or the default locale if not provided.


# Sponsors

Fixed is sponsored by OnePub, the Dart private package repository.

<a href="https://onepub.dev">![OnePub](https://raw.githubusercontent.com/onepub-dev/fixed/main/images/LogoAndByLine.png)</a>


You can create a Fixed instance from a number sources
```dart
var t1 = Fixed.fromNum(1); /// == 1.00
var t2 = Fixed.fromNum(1, scale: 3); /// == 1.000

var add = t1 + 10;
var multiply = t1 * t2;

var t3 = Fixed.parse("1.23356"); // == 1.23356, scale: 5

if (t1 == t2) // true
{
    print(t1.format('0.##')); // '1.00'
    print(t3.format('0.###')); // '1.123'
}
```


Full documentation can be found [here.](https://fixed.onepub.dev)