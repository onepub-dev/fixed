import 'dart:math';

import 'package:decimal/decimal.dart';
import 'package:decimal/intl.dart';
import 'package:intl/intl.dart';

import 'fixed_decoder.dart';
import 'fixed_encoder.dart';

import 'consts.dart' as platform_consts;

/// Thrown if a number larger than the supported ranges is
/// passed in.
/// This will only occur if you call [Fixed.fromNum] with
/// scale > 20 or a absolute value of > 10^21
/// If you need larger numbers then use one of the alternate
/// constructors.
class AmountTooLargeException extends FixedException {
  AmountTooLargeException(String message) : super(message);
}

/// Represents a fixed scale decimal no.
///
/// The value is stored using the minor units
/// e.g.
/// ```dart
/// Fixed.fromInt(100, scale: 2) == 1.00
/// ```
class Fixed implements Comparable<Fixed> {
  static const int maxInt = platform_consts.maxInt; // 64-bit
  static const int minInt = platform_consts.minInt; // 64-bit

  // The value
  static late final Fixed zero = Fixed.fromNum(0);

  /// The value 1 with [scale] = 2
  static late final Fixed one = Fixed.fromNum(1);

  /// The value 2 with [scale] = 2
  static late final Fixed two = Fixed.fromNum(2);

  /// The value 10 with [scale] = 2
  static late final Fixed ten = Fixed.fromNum(10);

  /// The [value] of this stored as a [Decimal].
  late final Decimal value;

  /// Returns this as minor units.
  ///
  /// e.g.
  /// ```dart
  /// Fixed.fromNum(1.234, scale: 3).minorUnits = 1234
  /// ```
  late final BigInt minorUnits = (value * Decimal.ten.pow(scale)).toBigInt();

  /// The scale to which we store the amount.
  ///
  /// A scale of 2 means we store the value to
  /// two decimal places.
  final int scale;

  /// Returns a new [Fixed] value from an existing one
  /// changing the scale to [scale].
  factory Fixed.copyWith(Fixed fixed, {int? scale}) {
    scale ??= fixed.scale;
    _checkScale(scale);
    return Fixed.fromDecimal(
        _rescale(fixed.value, existingScale: fixed.scale, targetScale: scale),
        scale: scale);
  }

  /// Creates a fixed scale decimal from [minorUnits] with
  /// the given [scale].
  ///
  /// [scale] defaults to 2 if not passed.
  Fixed.fromBigInt(BigInt minorUnits, {this.scale = 2}) {
    _checkScale(scale);
    value = Decimal.fromBigInt(minorUnits) / Decimal.ten.pow(scale);
  }

  /// Creates a fixed scale decimal from [amount] with
  /// the given [scale].
  ///
  /// [scale] defaults to 2 if not passed.
  Fixed.fromDecimal(Decimal amount, {this.scale = 2}) {
    _checkScale(scale);
    value = _rescale(
      amount,
      existingScale: amount.hasFinitePrecision ? amount.scale : null,
      targetScale: scale,
    );
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
    value = Decimal.fromInt(minorUnits) / Decimal.ten.pow(scale);
  }

  /// Creates a Fixed scale value from a double
  /// or integer value and stores the value with
  /// a the given [scale].
  ///
  /// [scale] defaults to 2 if not passed.
  ///
  /// This method will throw AmountToLargeException
  /// if the [scale] is > 20 or the absolute value
  /// is greater than 10^21
  /// This method will clip the no. of decimal places
  /// to 20
  /// ```dart
  /// final value = Fixed.fromNum(1.2345, scale: 2);
  /// print(value) -> 1.23
  /// ```
  ///
  /// For a decimal [amount] we throw a [AmountTooLargeException] if an [amount]
  /// is larger 10^21  is passed in.
  /// An [AmountTooLargeException] will be thrown if the
  /// scale > 20.
  /// If you need larger numbers then use one of the alternate
  /// constructors.
  Fixed.fromNum(num amount, {this.scale = 2}) {
    _checkScale(scale);

    final decoder = FixedDecoder(
      scale: scale,
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
      value = decoder.decode(fixed);
    } on RangeError catch (_) {
      throw AmountTooLargeException('The maximum scale for decimals is 20.');
    }
  }

  /// Returns the absolute value of this.
  Fixed get abs => isNegative ? -this : this;

  /// The component of the number after the decimal point.
  ///
  /// The returned value will always be a +ve no.
  /// The [integerPart] will contain the sign.
  BigInt get decimalPart => (minorUnits - integerPart * scaleFactor).abs();

  @override
  int get hashCode => value.hashCode + scale.hashCode;

  /// The component of the number before the decimal point
  BigInt get integerPart => value.toBigInt();

  /// returns true of the value of this is negative.
  bool get isNegative => value < Decimal.zero;

  /// returns true if the value of this is positive.
  bool get isPositive => value > Decimal.zero;

  /// returns true if the value of this is zero.
  bool get isZero => value == Decimal.zero;

  /// Returns 10 ^ [scale]
  BigInt get scaleFactor => BigInt.from(10).pow(scale);

  /// Returns the sign of this amount.
  ///
  /// Returns 0 for zero, -1 for values less than zero and +1 for values greater than zero.
  int get sign => value.signum;

  /// Returns this % [divisor].
  ///
  /// The scale is the largest of the two [scale]s.
  Fixed operator %(Fixed divisor) => Fixed.fromDecimal(value % divisor.value,
      scale: max(scale, divisor.scale));

  /// Returns this * [multiplier].
  ///
  /// The result's [scale] is the sum of the [scale] of the two
  /// operands.
  Fixed operator *(Fixed multiplier) =>
      Fixed.fromDecimal(value * multiplier.value,
          scale: scale + multiplier.scale);

  /// Returns this + [addition]
  ///
  /// The resulting [scale] is the larger scale of the two operands.
  Fixed operator +(Fixed addition) => Fixed.fromDecimal(value + addition.value,
      scale: max(scale, addition.scale));

  /// Returns -this.
  ///
  /// The resulting [scale] is the [scale] of this.
  Fixed operator -() => Fixed.fromDecimal(-value, scale: scale);

  /// Returns this - [subtration]
  ///
  /// The scale is the largest of the two [scale]s.
  Fixed operator -(Fixed subtration) =>
      Fixed.fromDecimal(value - subtration.value,
          scale: max(scale, subtration.scale));

  /// Returns this / [divisor]
  ///
  /// The scale is the largest of the two [scale]s.
  Fixed operator /(Fixed divisor) => Fixed.fromDecimal(value / divisor.value,
      scale: max(scale, divisor.scale));

  /// less than operator
  bool operator <(Fixed other) => value < other.value;

  /// less than or equal operator
  bool operator <=(Fixed other) => value <= other.value;

  /// Two Fixed values are considered equal if they have
  /// the same value irrespective of scale.
  @override
  bool operator ==(covariant Fixed other) => value == other.value;

  /// greater than operator
  bool operator >(Fixed other) => value > other.value;

  /// greater than or equal operator
  bool operator >=(Fixed other) => value >= other.value;

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
  /// the same [value] and the same [scale].
  @override
  int compareTo(Fixed other) {
    if (value == other.value) {
      return scale.compareTo(other.scale);
    } else {
      return value.compareTo(other.value);
    }
  }

  /// Returns  this / [divisor].
  ///
  /// The scale is left unchanged.
  Fixed divide(num divisor) {
    return this * Fixed.fromNum(1.0 / divisor.toDouble());
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
      return FixedEncoder(pattern, decimalSeparator: '.', groupSeparator: ',')
          .encode(this);
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

    var formatter = NumberFormat.decimalPattern(locale);
    return formatter.format(DecimalIntl(value));
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
  Fixed pow(int exponent) {
    return Fixed.fromBigInt(minorUnits.pow(exponent), scale: scale);
  }

  /// Returns the remainder of dividing this / [divisor].
  ///
  /// The [scale] is largest of the two scale + the scale
  /// of the [divisor].
  Fixed remainder(Fixed divisor) {
    return this - (this ~/ divisor) * divisor;
  }

  /// Returns the value as a [Decimal]
  Decimal toDecimal() => value;

  /// Truncates this and returns the integer part.
  int toInt() => value.toInt();

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
      pattern = '#.${'#' * scale}';
    }
    final encoder =
        FixedEncoder(pattern, decimalSeparator: '.', groupSeparator: ',');

    return encoder.encode(this);
  }

  /// Returns the this ~/ [divisor]
  ///
  /// This is a truncating division operator.
  ///
  /// The scale is the largest of the two [scale]s.
  Fixed operator ~/(Fixed divisor) => Fixed.fromDecimal(value ~/ divisor.value,
      scale: max(scale, divisor.scale));

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

  /// Parses [amount] as a decimal value.
  ///
  /// The [scale] controls the number of decimal
  /// places to be retained.
  /// If [scale] is not passe it defaults to 2.
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
  static Fixed parse(
    String amount, {
    int scale = 2,
    bool invertSeparator = false,
  }) {
    _checkScale(scale);

    final decimalSeparator = invertSeparator ? ',' : '.';

    final decoder = FixedDecoder(
      /// TODO: remove the pattern from the decoder
      /// as I don't think we actually need one.
      /// We just need to know what char is the decimal place.
      pattern: '#$decimalSeparator#',
      groupSeparator: invertSeparator ? '.' : ',',
      decimalSeparator: invertSeparator ? ',' : '.',
      scale: scale,
    );
    return Fixed.fromDecimal(decoder.decode(amount), scale: scale);
  }

  /// Works the same as [parse] but returns a null
  /// if the [amount] cannot be parsed.
  ///
  /// Sets the [scale] of the returned number to [scale].
  ///
  /// [scale] defaults to 2 if not passed.
  static Fixed? tryParse(
    String amount, {
    //String pattern = '#.#',
    int scale = 2,
    bool invertSeparator = false,
  }) {
    try {
      return Fixed.parse(amount,
          //pattern: pattern,
          scale: scale,
          invertSeparator: invertSeparator);
    } on FixedParseException catch (_) {
      return null;
    }
  }

  static void _checkScale(int scale) {
    if (scale < 0) {
      throw FixedException('A negative scale of $scale was passed. '
          'The scale must be >= 0.');
    }
  }

  static Decimal _rescale(
    Decimal value, {
    required int? existingScale,
    required int targetScale,
  }) {
    if (existingScale != null && existingScale <= targetScale) {
      // no precision lost
      return value;
    }
    if (value.hasFinitePrecision && value.scale <= targetScale) {
      // no precision lost
      return value;
    }
    var coef = Decimal.ten.pow(targetScale);
    return (value * coef).round() / coef;
  }
}

/// Base exception of all exceptions
/// thrown from the Fixed package.
class FixedException implements Exception {
  String message;

  FixedException(this.message);

  @override
  String toString() => message;
}
