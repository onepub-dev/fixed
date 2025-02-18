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

/// Represents a fixed scale decimal no.
///
/// The value is stored using the minor units
/// e.g.
/// ```dart
/// Fixed.fromInt(100, scale: 2) == 1.00
/// ```
@immutable
class Fixed implements Comparable<Fixed> {
  /// Parses [amount] as a decimal value.
  ///
  /// The [scale] controls the number of decimal
  /// places to be retained.
  /// If [scale] is not passed then the scale is determined
  /// by the number of decimal places present in the passed [amount].
  ///
  /// If [scale] < 0 then a FixedException will be thrown.
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
    int? scale,
    String decimalSeparator = '.',
    String groupSeparator = ',',
  }) {
    if (scale != null) {
      _checkScale(scale);
    }

    final decoder = FixedDecoder(
      // ignore: flutter_style_todos
      /// TODO: remove the pattern from the decoder
      /// as I don't think we actually need one.
      /// We just need to know what char is the decimal place.
      pattern: '#$decimalSeparator#',
      groupSeparator: groupSeparator,
      decimalSeparator: decimalSeparator,
    );
    final minorUnitsAndScale = decoder.decode(amount, scale);
    final targetScale = scale ?? minorUnitsAndScale.scale;
    return Fixed.fromBigInt(
        _rescale(minorUnitsAndScale.value,
            existingScale: minorUnitsAndScale.scale, targetScale: targetScale),
        scale: targetScale);
  }

  /// Returns a [Fixed] value from a JSON representation.
  ///
  /// The JSON representation includes the [minorUnits] and [scale].
  factory Fixed.fromJson(Map<String, dynamic> json) => Fixed.fromBigInt(
        BigInt.parse(json['minorUnits'] as String),
        scale: (json['scale'] ?? 2) as int,
      );

  /// Creates a Fixed scale value from a double
  /// or integer value and stores the value with
  /// the given [scale].
  ///
  /// [scale] defaults to 16 if not passed.
  ///
  /// This method will throw [AmountTooLargeException]
  /// if the [scale] is > 20 or the absolute value
  /// is greater than 10^21
  ///
  /// If you need larger numbers then use one of the alternate
  /// constructors.
  Fixed.fromNum(num amount, {this.scale = 16}) {
    ///
    /// ```dart
    /// final value = Fixed.fromNum(1.2345, scale: 2);
    /// print(value) -> 1.23
    /// ```
    ///
    _checkScale(scale);

    if (scale > 20) {
      throw AmountTooLargeException('The maximum scale for num is 20.');
    }

    final decoder = FixedDecoder(
      pattern: '#.#',
      groupSeparator: ',',
      decimalSeparator: '.',
    );

    /// toStringAsFixed is limited to a max of 20 decimal places
    try {
      final fixed = amount.toStringAsFixed(scale);
      if (fixed.contains('e')) {
        throw AmountTooLargeException('The amount must be less than 10^20');
      }
      final decimalAndScale = decoder.decode(fixed, scale);
      minorUnits = decimalAndScale.value;
      // ignore: avoid_catching_errors
    } on RangeError catch (_) {
      throw AmountTooLargeException('The maximum scale for num is 20.');
    }
  }

  /// Creates Fixed scale decimal from [minorUnits] with the given
  /// [scale].
  ///
  /// [scale] defaults to 2 if not passed.
  ///
  /// e.g.
  /// ```dart
  /// final fixed = Fixed.fromInt(100, scale: 2)
  /// print(fixed) : 1.00
  /// ```
  Fixed.fromInt(int minorUnits, {this.scale = 2}) {
    _checkScale(scale);
    // final intrinsicScale = minorUnits.toString().length;
    // if (intrinsicScale < scale) {
    //   this.minorUnits =
    //       BigInt.from(minorUnits) * BigInt.from(10).pow(scale
    //          - intrinsicScale);
    // } else {
    this.minorUnits = BigInt.from(minorUnits);
    // }
  }

  /// Creates a fixed scale decimal from [amount] with
  /// the given [scale].
  ///
  /// [scale] defaults to 16 if not passed.
  Fixed.fromDecimal(Decimal amount, {this.scale = 16}) {
    _checkScale(scale);
    minorUnits = _rescale(
      (amount * Decimal.ten.pow(amount.scale).toDecimal()).toBigInt(),
      existingScale: amount.scale,
      targetScale: scale,
    );
  }

  /// Creates a fixed scale decimal from [minorUnits] with
  /// the given [scale].
  ///
  /// [scale] defaults to 2 if not passed.
  Fixed.fromBigInt(this.minorUnits, {this.scale = 2}) {
    _checkScale(scale);
  }

  /// Returns a new [Fixed] value from an existing one
  /// changing the scale to [scale].
  @Deprecated('Use the copyWith member method')
  factory Fixed.copyWith(Fixed fixed, {int? scale}) {
    scale ??= fixed.scale;
    _checkScale(scale);
    return Fixed.fromBigInt(
        _rescale(fixed.minorUnits,
            existingScale: fixed.scale, targetScale: scale),
        scale: scale);
  }

  /// Returns a new [Fixed] value from an existing one
  /// changing the scale to [scale].
  Fixed copyWith({int? scale}) {
    scale ??= this.scale;
    _checkScale(scale);
    return Fixed.fromBigInt(
        _rescale(minorUnits, existingScale: this.scale, targetScale: scale),
        scale: scale);
  }

  static const int maxInt = platform_consts.maxInt;
  static const int minInt = platform_consts.minInt;
  // The value zero with [scale] = 0
  static final Fixed zero = Fixed.fromNum(0, scale: 0);

  /// The value 1 with [scale] =0
  static final Fixed one = Fixed.fromNum(1, scale: 0);

  /// The value 2 with [scale] = 0
  static final Fixed two = Fixed.fromNum(2, scale: 0);

  /// The value 10 with [scale] = 0
  static final Fixed ten = Fixed.fromNum(10, scale: 0);

  /// The value of this [Fixed] instance stored as minorUnits in a [BigInt].
  /// If the scale is 2 then 1 is stored as 100
  /// If the scale is 3 then 1 is stored as 1000.
  late final BigInt minorUnits;

  /// Returns this as minor units.
  ///
  /// e.g.
  /// ```dart
  /// Fixed.fromNum(1.234, scale: 3).minorUnits = 1234
  /// ```
  // late final BigInt minorUnits = (value * Decimal.ten.pow(scale)).toBigInt();

  /// The scale to which we store the amount.
  ///
  /// A scale of 2 means we store the value to
  /// two decimal places.
  final int scale;

  /// Returns the absolute value of this.
  Fixed get abs => isNegative ? -this : this;

  /// The component of the number after the decimal point.
  ///
  /// The returned value will always be a +ve no.
  /// The [integerPart] will contain the sign.
  BigInt get decimalPart => (minorUnits - integerPart * scaleFactor).abs();

  @override
  int get hashCode => minorUnits.hashCode + scale.hashCode;

  /// The component of the number before the decimal point
  BigInt get integerPart => minorUnits ~/ BigInt.from(10).pow(scale);

  /// returns true of the value of this is negative.
  bool get isNegative => minorUnits < BigInt.zero;

  /// returns true if the value of this is positive.
  bool get isPositive => minorUnits > BigInt.zero;

  /// returns true if the value of this is zero.
  bool get isZero => minorUnits == BigInt.zero;

  /// Returns 10 ^ [scale]
  BigInt get scaleFactor => BigInt.from(10).pow(scale);

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
  /// The scale is the largest of the two [scale]s.
  Fixed operator %(Fixed denominator) {
    final targetScale = max(scale, denominator.scale);

    final numerator =
        _rescale(minorUnits, existingScale: scale, targetScale: targetScale);
    final scaledDenominator = _rescale(denominator.minorUnits,
        existingScale: denominator.scale, targetScale: targetScale);

    return Fixed.fromBigInt(numerator % scaledDenominator, scale: targetScale);
  }

  /// Returns this * [multiplier].
  ///
  /// The result's [scale] is the sum of the [scale] of the two
  /// operands.
  Fixed operator *(Fixed multiplier) {
    // final targetScale = min(scale + multiplier.scale, Scale);
    final targetScale = scale + multiplier.scale;

    final scaledThis =
        _rescale(minorUnits, existingScale: scale, targetScale: targetScale);
    final scaledMultiplier = _rescale(multiplier.minorUnits,
        existingScale: multiplier.scale, targetScale: targetScale);

    final rawResult = scaledThis * scaledMultiplier;

    final scaledResult = _rescale(rawResult,
        existingScale: targetScale * 2, targetScale: targetScale);

    return Fixed.fromBigInt(scaledResult, scale: targetScale);
  }

  /// Returns this + [addition]
  ///
  /// The resulting [scale] is the larger scale of the two operands.
  Fixed operator +(Fixed addition) {
    final targetScale = max(scale, addition.scale);

    final scaledThis =
        _rescale(minorUnits, existingScale: scale, targetScale: targetScale);
    final scaledAddition = _rescale(addition.minorUnits,
        existingScale: addition.scale, targetScale: targetScale);

    return Fixed.fromBigInt(scaledThis + scaledAddition, scale: targetScale);
  }

  /// Returns -this.
  ///
  /// The resulting [scale] is the [scale] of this.
  Fixed operator -() => Fixed.fromBigInt(-minorUnits, scale: scale);

  /// Returns this - [subtration]
  ///
  /// The scale is the largest of the two [scale]s.
  Fixed operator -(Fixed subtration) {
    final targetScale = max(scale, subtration.scale);

    final scaledThis =
        _rescale(minorUnits, existingScale: scale, targetScale: targetScale);
    final scaledSubtraction = _rescale(subtration.minorUnits,
        existingScale: subtration.scale, targetScale: targetScale);

    return Fixed.fromBigInt(scaledThis - scaledSubtraction, scale: targetScale);
  }

  /// Returns this / [denominator]
  ///
  /// The scale is the largest of the two [scale]s.
  Fixed operator /(Fixed denominator) {
    final targetScale = max(scale, denominator.scale);

    final numerator =
        _rescale(minorUnits, existingScale: scale, targetScale: targetScale);
    final scaledDenominator = _rescale(denominator.minorUnits,
        existingScale: denominator.scale, targetScale: targetScale);

    final numResult = numerator / scaledDenominator;

    return Fixed.fromNum(numResult, scale: targetScale);
  }

  /// Returns  this / [divisor].
  ///
  /// The scale is left unchanged.
  Fixed divide(num divisor) => this * Fixed.fromNum(1.0 / divisor.toDouble());

  /// Returns the this ~/ [denominator]
  ///
  /// This is a truncating division operator.
  ///
  /// The scale is the largest of the two [scale]s.
  Fixed operator ~/(Fixed denominator) {
    final targetScale = max(scale, denominator.scale);

    final numerator =
        _rescale(minorUnits, existingScale: scale, targetScale: targetScale);
    final scaledDenominator = _rescale(denominator.minorUnits,
        existingScale: denominator.scale, targetScale: targetScale);

    return Fixed.fromBigInt(numerator ~/ scaledDenominator, scale: targetScale);
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
  /// the same value irrespective of scale.
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
  /// the same [minorUnits] and the same [scale].
  @override
  int compareTo(Fixed other) {
    if (minorUnits == other.minorUnits) {
      return scale.compareTo(other.scale);
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
  String format(
    String pattern, {
    String decimalSeparator = '.',
    String groupSeparator = ',',
  }) =>
      FixedEncoder(pattern,
              decimalSeparator: decimalSeparator,
              groupSeparator: groupSeparator)
          .encode(this);

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
  /// The [multiplier] is scaled based on this' [scale].
  /// The result's [scale] == [scale] * 2.
  Fixed multiply(num multiplier) =>
      this * Fixed.fromNum(multiplier, scale: scale);

  /// Returns this ^ [exponent]
  ///
  /// The returned value has the same [scale] as this.
  Fixed pow(int exponent) =>
      Fixed.fromBigInt(minorUnits.pow(exponent), scale: scale);

  /// Returns the remainder of dividing this / [divisor].
  ///
  /// The [scale] is largest of the two scale + the scale
  /// of the [divisor].
  Fixed remainder(Fixed divisor) => this - (this ~/ divisor) * divisor;

  /// Returns the value as a [Decimal]
  Decimal toDecimal() => Decimal.parse(toString());

  /// Truncates this and returns the integer part.
  int toInt() => minorUnits == BigInt.zero
      ? 0
      : (minorUnits ~/ BigInt.from(10).pow(scale)).toInt();

  /// Returns the [Fixed] value using [scale] to control the
  /// displayed number of decimal places.
  ///
  /// ```dart
  /// Fixed.fromInt(1000, scale: 3).toString() == '1.000'
  /// ```
  ///
  /// If you need to invert the separators or
  /// control the returned scale use [format].
  @override
  String toString() {
    final String pattern;
    if (scale == 0) {
      pattern = '#';
    } else {
      pattern = '0.${'#' * scale}';
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
            scale: scale))
        .toList();
  }

  /// Works the same as [Fixed.parse] but returns a null
  /// if the [amount] cannot be parsed.
  ///
  /// Sets the [scale] of the returned number to [scale].
  ///
  /// [scale] defaults to 2 if not passed.
  static Fixed? tryParse(
    String amount, {
    int scale = 2,
    String decimalSeparator = '.',
    String groupSeparator = ',',
  }) {
    try {
      return Fixed.parse(
        amount,
        //pattern: pattern,
        scale: scale,
        decimalSeparator: decimalSeparator,
        groupSeparator: groupSeparator,
      );
      // ignore: avoid_catches_without_on_clauses
    } catch (_) {
      return null;
    }
  }

  /// Returns a JSON representation of the [Fixed] value.
  ///
  /// The JSON representation includes the [minorUnits] and [scale].
  Map<String, dynamic> toJson() => {
        'minorUnits': minorUnits.toString(),
        'scale': scale,
      };

  static void _checkScale(int scale) {
    if (scale < 0) {
      throw FixedException('A negative scale of $scale was passed. '
          'The scale must be >= 0.');
    }
  }

  static BigInt _rescale(
    BigInt minorUnits, {
    required int existingScale,
    required int targetScale,
  }) {
    if (existingScale < targetScale) {
      // Increase scale: just multiply by 10^(targetScale - existingScale)
      final diff = targetScale - existingScale;
      return minorUnits * BigInt.from(10).pow(diff);
    } else if (existingScale > targetScale) {
      // Reduce scale with round-half-away-from-zero
      final diff = existingScale - targetScale;
      return _roundHalfAwayFromZero(minorUnits, diff);
    } else {
      // No change
      return minorUnits;
    }
  }

  /// Divides [value] by 10^[scaleDiff], then rounds half away from zero.
  /// Example: If [value] = 15241578750190521000000, scaleDiff = 6, we want
  /// to do integer division plus correct rounding—without floating-point.
  static BigInt _roundHalfAwayFromZero(BigInt value, int scaleDiff) {
    final divisor = BigInt.from(10).pow(scaleDiff);
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
    if (fixed.scale > other.scale) {
      return _Scaled2(
          fixed,
          Fixed.fromBigInt(
              _rescale(other.minorUnits,
                  existingScale: other.scale, targetScale: fixed.scale),
              scale: fixed.scale));
    }
    if (fixed.scale < other.scale) {
      return _Scaled2(
          Fixed.fromBigInt(
              _rescale(fixed.minorUnits,
                  existingScale: fixed.scale, targetScale: other.scale),
              scale: other.scale),
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
