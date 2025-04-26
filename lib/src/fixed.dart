/* Copyright (C) Brett Sutton - All Rights Reserved
 * Released under the MIT license.
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'dart:math';

import 'package:decimal/decimal.dart';
import 'package:decimal/intl.dart';
import 'package:intl/intl.dart';
import 'package:meta/meta.dart';

import 'consts.dart' as platform_consts;
import 'exceptions.dart';
import 'fixed_decoder.dart';
import 'fixed_encoder.dart';

/// Represents a number with a fixed number of decimal digits
/// allowing precision mathematics without rounding errors.
///
/// The Fixed package also provides formatting and parsing of
/// Fixed values.
///
/// Fixed internally uses a BigInt which means the maximum size
/// of a number is only limited by memory.
///
/// The value is stored using the minor units
/// e.g.
/// ```dart
/// Fixed.fromInt(100, decimalDigits: 2) == 1.00
/// ```
@immutable
class Fixed implements Comparable<Fixed> {
  /// Parses [amount] as a decimal value.
  ///
  /// The [decimalDigits] controls the number of decimal
  /// places to be retained.
  /// If [decimalDigits] is not passed then the decimalDigits is determined
  /// by the number of decimal places present in the passed [amount].
  ///
  /// If [decimalDigits] < 0 then a FixedException will be thrown.
  /// If the [amount] isn't valid then
  /// a [FixedParseException] is thrown.
  ///
  /// If [invertSeparator] = false then we
  /// assume '.' is the decimal place and ',' is the group separator.
  ///
  /// If [invertSeparator] = true then we
  /// assume ',' is the decimal place and '.' is the group separator.
  factory Fixed.parse(
    String amount, {
    int? decimalDigits,
    bool invertSeparator = false,
  }) {
    if (decimalDigits != null) {
      _checkDecimalDigits(decimalDigits);
    }

    final decimalSeparator = invertSeparator ? ',' : '.';

    final decoder = FixedDecoder(
      // TODO(bsutton): remove the pattern from the decoder
      // as I don't think we actually need one.
      // We just need to know what char is the decimal place.
      pattern: '#$decimalSeparator#',
      groupSeparator: invertSeparator ? '.' : ',',
      decimalSeparator: invertSeparator ? ',' : '.',
    );
    final minorUnitsAndScale = decoder.decode(amount, decimalDigits);
    final targetDecimalDigits =
        decimalDigits ?? minorUnitsAndScale.decimalDigits;
    return Fixed.fromBigInt(
        _rescale(minorUnitsAndScale.value,
            existingDecimalDigits: minorUnitsAndScale.decimalDigits,
            targetDecimalDigits: targetDecimalDigits),
        decimalDigits: targetDecimalDigits);
  }

  /// Creates a Fixed value from a double
  /// or integer value and stores the value with
  /// the given [decimalDigits].
  ///
  /// [decimalDigits] defaults to 16 if not passed.
  ///
  /// This method will throw [AmountTooLargeException]
  /// if the [decimalDigits] is > 20 or the absolute value
  /// is greater than 10^21
  ///
  /// If you need larger numbers then use one of the alternate
  /// constructors.
  Fixed.fromNum(num amount, {this.decimalDigits = 16}) {
    ///
    /// ```dart
    /// final value = Fixed.fromNum(1.2345, decimalDigits: 2);
    /// print(value) -> 1.23
    /// ```
    ///
    _checkDecimalDigits(decimalDigits);

    if (decimalDigits > 20) {
      throw AmountTooLargeException(
          'The maximum decimal digits for num is 20.');
    }

    final decoder = FixedDecoder(
      pattern: '#.#',
      groupSeparator: ',',
      decimalSeparator: '.',
    );

    /// toStringAsFixed is limited to a max of 20 decimal places
    try {
      final fixed = amount.toStringAsFixed(decimalDigits);
      if (fixed.contains('e')) {
        throw AmountTooLargeException('The amount must be less than 10^20');
      }
      final decimalAndScale = decoder.decode(fixed, decimalDigits);
      minorUnits = decimalAndScale.value;
      // We catch the error so we can provide a more meaningful message.
      // ignore: avoid_catching_errors
    } on RangeError catch (_) {
      throw AmountTooLargeException(
          'The maximum decimal digits for num is 20.');
    }
  }

  /// Creates Fixed instance from [minorUnits] with the given
  /// [decimalDigits].
  ///
  /// [decimalDigits] defaults to 2 if not passed.
  ///
  /// e.g.
  /// ```dart
  /// final fixed = Fixed.fromInt(100, decimalDigits: 2)
  /// print(fixed) : 1.00
  /// ```
  Fixed.fromInt(int minorUnits, {this.decimalDigits = 2}) {
    _checkDecimalDigits(decimalDigits);
    this.minorUnits = BigInt.from(minorUnits);
  }

  /// Creates a Fixed instance from [amount] with
  /// the given [decimalDigits].
  ///
  /// [decimalDigits] defaults to 16 if not passed.
  Fixed.fromDecimal(Decimal amount, {this.decimalDigits = 16}) {
    _checkDecimalDigits(decimalDigits);
    minorUnits = _rescale(
      (amount * Decimal.ten.pow(amount.scale).toDecimal()).toBigInt(),
      existingDecimalDigits: amount.scale,
      targetDecimalDigits: decimalDigits,
    );
  }

  /// Creates a Fixed instance from [minorUnits] with
  /// the given [decimalDigits].
  ///
  /// [decimalDigits] defaults to 2 if not passed.
  Fixed.fromBigInt(this.minorUnits, {this.decimalDigits = 2}) {
    _checkDecimalDigits(decimalDigits);
  }

  /// Returns a new [Fixed] value from an existing one
  /// changing the decimalDigits to [decimalDigits].
  @Deprecated('Use the copyWith member method')
  factory Fixed.copyWith(Fixed fixed, {int? decimalDigits}) {
    decimalDigits ??= fixed.decimalDigits;
    _checkDecimalDigits(decimalDigits);
    return Fixed.fromBigInt(
        _rescale(fixed.minorUnits,
            existingDecimalDigits: fixed.decimalDigits,
            targetDecimalDigits: decimalDigits),
        decimalDigits: decimalDigits);
  }

  /// Returns a new [Fixed] value from an existing one
  /// changing the scale to [decimalDigits].
  Fixed copyWith({int? decimalDigits}) {
    decimalDigits ??= this.decimalDigits;
    _checkDecimalDigits(decimalDigits);
    return Fixed.fromBigInt(
        _rescale(minorUnits,
            existingDecimalDigits: this.decimalDigits,
            targetDecimalDigits: decimalDigits),
        decimalDigits: decimalDigits);
  }

  static const int maxInt = platform_consts.maxInt;
  static const int minInt = platform_consts.minInt;
  // The value zero with [decimalDigits] = 0
  static final Fixed zero = Fixed.fromNum(0, decimalDigits: 0);

  /// The value 1 with [decimalDigits] =0
  static final Fixed one = Fixed.fromNum(1, decimalDigits: 0);

  /// The value 2 with [decimalDigits] = 0
  static final Fixed two = Fixed.fromNum(2, decimalDigits: 0);

  /// The value 10 with [decimalDigits] = 0
  static final Fixed ten = Fixed.fromNum(10, decimalDigits: 0);

  /// The value of this [Fixed] instance stored as minorUnits in a [BigInt].
  /// If the decimalDigits is 2 then 1 is stored as 100
  /// If the decimalDigits is 3 then 1 is stored as 1000.
  late final BigInt minorUnits;

  /// Returns this as minor units.
  ///
  /// e.g.
  /// ```dart
  /// Fixed.fromNum(1.234, decimalDigits: 3).minorUnits = 1234
  ///
  /// late final BigInt minorUnits =
  ///    (value * Decimal.ten.pow(decimalDigits)).toBigInt();
  /// ```
  ///
  /// The decimalDigits with which we store the amount.
  ///
  /// A decimalDigits of 2 means we store the value to
  /// two decimal places.
  final int decimalDigits;

  /// Returns the absolute value of this.
  Fixed get abs => isNegative ? -this : this;

  /// The component of the number after the decimal point.
  ///
  /// The returned value will always be a +ve no.
  /// The [integerPart] will contain the sign.
  BigInt get decimalPart => (minorUnits - integerPart * scaleFactor).abs();

  String decimalPartAsString() {
    var whole = minorUnits.toString();

    /// we will add the -ve when we know where it is to be placed.
    if (whole.startsWith('-')) {
      whole = whole.substring(1);
    }

    if (whole.length < decimalDigits) {
      whole = whole.padLeft(decimalDigits, '0');
    }

    final decimalStart = whole.length - decimalDigits;
    final decimalPart = whole.substring(decimalStart);

    return decimalPart;
  }

  @override
  int get hashCode => minorUnits.hashCode + decimalDigits.hashCode;

  /// The component of the number before the decimal point
  BigInt get integerPart => minorUnits ~/ BigInt.from(10).pow(decimalDigits);

  /// returns true of the value of this is negative.
  bool get isNegative => minorUnits < BigInt.zero;

  /// returns true if the value of this is positive.
  bool get isPositive => minorUnits > BigInt.zero;

  /// returns true if the value of this is zero.
  bool get isZero => minorUnits == BigInt.zero;

  /// Returns 10 ^ [decimalDigits]
  BigInt get scaleFactor => BigInt.from(10).pow(decimalDigits);

  /// Returns the sign of this amount.
  ///
  /// Returns 0 for zero, -1 for values less than zero and +1 for
  ///  values greater than zero.
  int get sign => minorUnits.isNegative
      ? -1
      : minorUnits == BigInt.zero
          ? 0
          : 1;

  /// Returns this % [denominator].
  ///
  /// The decimalDigits is the largest of the two [decimalDigits]s.
  Fixed operator %(Fixed denominator) {
    final targetDecimalDigits = max(decimalDigits, denominator.decimalDigits);

    final numerator = _rescale(minorUnits,
        existingDecimalDigits: decimalDigits,
        targetDecimalDigits: targetDecimalDigits);
    final scaledDenominator = _rescale(denominator.minorUnits,
        existingDecimalDigits: denominator.decimalDigits,
        targetDecimalDigits: targetDecimalDigits);

    return Fixed.fromBigInt(numerator % scaledDenominator,
        decimalDigits: targetDecimalDigits);
  }

  /// Returns this * [multiplier].
  ///
  /// The result's [decimalDigits] is the sum of the [decimalDigits] of the two
  /// operands.
  Fixed operator *(Fixed multiplier) {
    final targetDecimalDigits = decimalDigits + multiplier.decimalDigits;

    final scaledThis = _rescale(minorUnits,
        existingDecimalDigits: decimalDigits,
        targetDecimalDigits: targetDecimalDigits);
    final scaledMultiplier = _rescale(multiplier.minorUnits,
        existingDecimalDigits: multiplier.decimalDigits,
        targetDecimalDigits: targetDecimalDigits);

    final rawResult = scaledThis * scaledMultiplier;

    final scaledResult = _rescale(rawResult,
        existingDecimalDigits: targetDecimalDigits * 2,
        targetDecimalDigits: targetDecimalDigits);

    return Fixed.fromBigInt(scaledResult, decimalDigits: targetDecimalDigits);
  }

  /// Returns this + [addition]
  ///
  /// The resulting [decimalDigits] is the larger decimalDigits of
  /// the two operands.
  Fixed operator +(Fixed addition) {
    final targetDecimalDigits = max(decimalDigits, addition.decimalDigits);

    final scaledThis = _rescale(minorUnits,
        existingDecimalDigits: decimalDigits,
        targetDecimalDigits: targetDecimalDigits);
    final scaledAddition = _rescale(addition.minorUnits,
        existingDecimalDigits: addition.decimalDigits,
        targetDecimalDigits: targetDecimalDigits);

    return Fixed.fromBigInt(scaledThis + scaledAddition,
        decimalDigits: targetDecimalDigits);
  }

  /// Returns -this.
  ///
  /// The resulting [decimalDigits] is the [decimalDigits] of this.
  Fixed operator -() =>
      Fixed.fromBigInt(-minorUnits, decimalDigits: decimalDigits);

  /// Returns this - [subtration]
  ///
  /// The decimalDigits is the largest of the two [decimalDigits]s.
  Fixed operator -(Fixed subtration) {
    final targetDecimalDigits = max(decimalDigits, subtration.decimalDigits);

    final scaledThis = _rescale(minorUnits,
        existingDecimalDigits: decimalDigits,
        targetDecimalDigits: targetDecimalDigits);
    final scaledSubtraction = _rescale(subtration.minorUnits,
        existingDecimalDigits: subtration.decimalDigits,
        targetDecimalDigits: targetDecimalDigits);

    return Fixed.fromBigInt(scaledThis - scaledSubtraction,
        decimalDigits: targetDecimalDigits);
  }

  /// Returns this / [denominator]
  ///
  /// The decimalDigits is the largest of the two [decimalDigits]s.
  Fixed operator /(Fixed denominator) {
    final targetDecimalDigits = max(decimalDigits, denominator.decimalDigits);

    final numerator = _rescale(minorUnits,
        existingDecimalDigits: decimalDigits,
        targetDecimalDigits: targetDecimalDigits);
    final scaledDenominator = _rescale(denominator.minorUnits,
        existingDecimalDigits: denominator.decimalDigits,
        targetDecimalDigits: targetDecimalDigits);

    final numResult = numerator / scaledDenominator;

    return Fixed.fromNum(numResult, decimalDigits: targetDecimalDigits);
  }

  /// Returns  this / [divisor].
  ///
  /// The decimalDigits is left unchanged.
  Fixed divide(num divisor) => this * Fixed.fromNum(1.0 / divisor.toDouble());

  /// Returns the this ~/ [denominator]
  ///
  /// This is a truncating division operator.
  ///
  /// The decimalDigits is the largest of the two [decimalDigits]s.
  Fixed operator ~/(Fixed denominator) {
    final targetDecimalDigits = max(decimalDigits, denominator.decimalDigits);

    final numerator = _rescale(minorUnits,
        existingDecimalDigits: decimalDigits,
        targetDecimalDigits: targetDecimalDigits);
    final scaledDenominator = _rescale(denominator.minorUnits,
        existingDecimalDigits: denominator.decimalDigits,
        targetDecimalDigits: targetDecimalDigits);

    return Fixed.fromBigInt(numerator ~/ scaledDenominator,
        decimalDigits: targetDecimalDigits);
  }

  /// less than operator
  bool operator <(Fixed other) {
    final scaled = _scale(this, other);
    return scaled.one.minorUnits < scaled.two.minorUnits;
  }

  /// less than or equal operator
  bool operator <=(Fixed other) {
    final scaled = _scale(this, other);
    return scaled.one.minorUnits <= scaled.two.minorUnits;
  }

  /// Two Fixed values are considered equal if they have
  /// the same value irrespective of decimalDigits.
  @override
  bool operator ==(Object other) {
    if (other is! Fixed) {
      return false;
    }
    final scaled = _scale(this, other);
    return scaled.one.minorUnits == scaled.two.minorUnits;
  }

  /// greater than operator
  bool operator >(Fixed other) {
    final scaled = _scale(this, other);
    return scaled.one.minorUnits > scaled.two.minorUnits;
  }

  /// greater than or equal operator
  bool operator >=(Fixed other) {
    final scaled = _scale(this, other);
    return scaled.one.minorUnits >= scaled.two.minorUnits;
  }

  ///  Spread the value across 'n' Fixed values according
  /// to the supplie [ratios].
  ///
  /// 'n' is controlled by the number
  /// of [ratios] passed.
  List<Fixed> allocationAccordingTo(List<int> ratios) {
    if (ratios.isEmpty) {
      throw ArgumentError.value(ratios, 'ratios',
          'List of ratios must not be empty, cannot allocate to nothing.');
    }

    return _doAllocationAccordingTo(ratios.map((ratio) {
      if (ratio < 0) {
        throw ArgumentError.value(
            ratios, 'ratios', 'Ratio must not be negative.');
      }

      return BigInt.from(ratio);
    }).toList());
  }

  /// Two [Fixed] instances are the same if they have
  /// the same [minorUnits] and the same [decimalDigits].
  @override
  int compareTo(Fixed other) {
    if (minorUnits == other.minorUnits) {
      return decimalDigits.compareTo(other.decimalDigits);
    } else {
      return minorUnits.compareTo(other.minorUnits);
    }
  }

  /// Formats a [Fixed] value into a String according to the
  /// passed [pattern].
  ///
  /// If [invertSeparator] is true then the role of the '.' and ',' are
  /// reversed. By default the '.' is used as the decimal separator
  /// whilst the ',' is used as the grouping separator.
  ///
  /// 0 A single digit
  /// # A single digit, omitted if the value is zero
  /// . or , Decimal separator dependant on [invertSeparator]
  /// - Minus sign
  /// , or . Grouping separator dependant on [invertSeparator]
  /// space Space character.
  ///
  String format(String pattern, {bool invertSeparator = false}) {
    if (!invertSeparator) {
      return FixedEncoder(pattern).encode(this);
    } else {
      return FixedEncoder(pattern, decimalSeparator: ',', groupSeparator: '.')
          .encode(this);
    }
  }

  /// Formats the value using the [locale]'s decimal pattern.
  ///
  /// If you don't provide a [locale] then we use the systems
  /// default locale.
  String formatIntl([String? locale]) {
    locale ??= Intl.defaultLocale;

    final formatter = NumberFormat.decimalPattern(locale);
    return DecimalFormatter(formatter).format(toDecimal());
  }

  /// Returns this * [multiplier]
  ///
  /// if you pass [decimalDigits] then it will be used
  /// to determine the number of decimals to retain from [multiplier].
  /// If you don't pass [decimalDigits] then this.decimalDigits
  /// will be used.
  /// 
  /// The result's [decimalDigits] == [decimalDigits] * 2.
  Fixed multiply(num multiplier, {int? decimalDigits}) =>
      this *
      Fixed.fromNum(multiplier,
          decimalDigits: decimalDigits ?? this.decimalDigits);

  /// Returns this ^ [exponent]
  ///
  /// The returned value has the same [decimalDigits] as this.
  Fixed pow(int exponent) =>
      Fixed.fromBigInt(minorUnits.pow(exponent), decimalDigits: decimalDigits);

  /// Returns the remainder of dividing this / [divisor].
  ///
  /// The [decimalDigits] is largest of the two decimalDigits
  /// + the decimalDigits of the [divisor].
  Fixed remainder(Fixed divisor) => this - (this ~/ divisor) * divisor;

  /// Returns the value as a [Decimal]
  Decimal toDecimal() => Decimal.parse(toString());

  /// Truncates this and returns the integer part.
  int toInt() => minorUnits == BigInt.zero
      ? 0
      : (minorUnits ~/ BigInt.from(10).pow(decimalDigits)).toInt();

  /// Returns the [Fixed] value using [decimalDigits] to control the
  /// displayed number of decimal places.
  ///
  /// ```dart
  /// Fixed.fromInt(1000, decimalDigits: 3).toString() == '1.000'
  /// ```
  ///
  /// If you need to modify the separators or
  /// control the returned decimalDigits use [format].
  @override
  String toString() {
    final String pattern;
    if (decimalDigits == 0) {
      pattern = '#';
    } else {
      pattern = '0.${'#' * decimalDigits}';
    }
    final encoder = FixedEncoder(pattern);

    return encoder.encode(this);
  }

  List<Fixed> _doAllocationAccordingTo(List<BigInt> ratios) {
    final totalVolume = ratios.reduce((a, b) => a + b);

    if (totalVolume == BigInt.zero) {
      throw ArgumentError('Sum of ratios must be greater than zero, '
          'cannot allocate to nothing.');
    }

    final absoluteValue = minorUnits.abs();
    var remainder = absoluteValue;

    final shares = ratios.map((ratio) {
      final share = absoluteValue * ratio ~/ totalVolume;
      remainder -= share;

      return share;
    }).toList();

    for (var i = 0; remainder > BigInt.zero && i < shares.length; ++i) {
      if (ratios[i] > BigInt.zero) {
        shares[i] += BigInt.one;
        remainder -= BigInt.one;
      }
    }

    return shares
        .map((share) => Fixed.fromBigInt(minorUnits.isNegative ? -share : share,
            decimalDigits: decimalDigits))
        .toList();
  }

  /// Works the same as [Fixed.parse] but returns a null
  /// if the [amount] cannot be parsed.
  ///
  /// Sets the [decimalDigits] of the returned number to [decimalDigits].
  ///
  /// [decimalDigits] defaults to 2 if not passed.
  static Fixed? tryParse(
    String amount, {
    int decimalDigits = 2,
    bool invertSeparator = false,
  }) {
    try {
      return Fixed.parse(amount,
          //pattern: pattern,
          decimalDigits: decimalDigits,
          invertSeparator: invertSeparator);
    } catch (_) {
      return null;
    }
  }

  static void _checkDecimalDigits(int decimalDigits) {
    if (decimalDigits < 0) {
      throw FixedException(
          'A negative decimalDigits of $decimalDigits was passed. '
          'The decimalDigits must be >= 0.');
    }
  }

  static BigInt _rescale(
    BigInt minorUnits, {
    required int existingDecimalDigits,
    required int targetDecimalDigits,
  }) {
    if (existingDecimalDigits < targetDecimalDigits) {
      // Increase decimalDigits:
      //  just multiply by 10^(targetDecimalDigits - existingDecimalDigits)
      final diff = targetDecimalDigits - existingDecimalDigits;
      return minorUnits * BigInt.from(10).pow(diff);
    } else if (existingDecimalDigits > targetDecimalDigits) {
      // Reduce decimalDigits with round-half-away-from-zero
      final diff = existingDecimalDigits - targetDecimalDigits;
      return _roundHalfAwayFromZero(minorUnits, diff);
    } else {
      // No change
      return minorUnits;
    }
  }

  /// Divides [value] by 10^[decimalDigitsDiff], then rounds half
  ///   away from zero.
  /// Example: If [value] = 15241578750190521000000, decimalDigitsDiff = 6,
  ///   we want to do integer division plus correct
  ///   rounding—without floating-point.
  static BigInt _roundHalfAwayFromZero(BigInt value, int decimalDigitsDiff) {
    final divisor = BigInt.from(10).pow(decimalDigitsDiff);
    if (divisor == BigInt.one) {
      // Nothing to scale
      return value;
    }

    // Determine sign; work with absolute
    final isNegative = value.isNegative;
    final absValue = isNegative ? -value : value;

    // Integer division and remainder
    final absQuotient = absValue ~/ divisor;
    final absRemainder = absValue % divisor; // remainder in [0 .. divisor-1]

    // Compare remainder to half of divisor
    // If remainder * 2 == divisor => exactly half => also round up
    final twiceRemainder = absRemainder << 1; // same as absRemainder * 2

    if (twiceRemainder > divisor) {
      // remainder > 0.5 => round up
      return isNegative
          ? -(absQuotient + BigInt.one)
          : (absQuotient + BigInt.one);
    } else if (twiceRemainder < divisor) {
      // remainder < 0.5 => round down
      return isNegative ? -absQuotient : absQuotient;
    } else {
      // remainder == exactly 0.5 => round half AWAY from zero => also round up
      return isNegative
          ? -(absQuotient + BigInt.one)
          : (absQuotient + BigInt.one);
    }
  }

  _Scaled2 _scale(Fixed fixed, Fixed other) {
    if (fixed.decimalDigits > other.decimalDigits) {
      return _Scaled2(
          fixed,
          Fixed.fromBigInt(
              _rescale(other.minorUnits,
                  existingDecimalDigits: other.decimalDigits,
                  targetDecimalDigits: fixed.decimalDigits),
              decimalDigits: fixed.decimalDigits));
    }
    if (fixed.decimalDigits < other.decimalDigits) {
      return _Scaled2(
          Fixed.fromBigInt(
              _rescale(fixed.minorUnits,
                  existingDecimalDigits: fixed.decimalDigits,
                  targetDecimalDigits: other.decimalDigits),
              decimalDigits: other.decimalDigits),
          other);
    }
    return _Scaled2(fixed, other);
  }
}

class _Scaled2 {
  _Scaled2(this.one, this.two);
  Fixed one;
  Fixed two;
}
