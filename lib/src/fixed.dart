import 'dart:math';

import 'fixed_decoder.dart';
import 'fixed_encoder.dart';

/// Represents a fixed scale decimal no.
/// The value is stored using the minor units
/// e.g.
/// If a Fixed no. has a scale of 2 then
/// 1 is stored as 100.
class Fixed implements Comparable<Fixed> {
  static const int maxInt = 0x7fffffffffffffff; // 64-bit
  static const int minInt = 0xffffffffffffffff; // 64-bit

  // We store the value using the minor units
  // So if a number has a scale of 2 then
  // 1 would be stored as 100.
  late final BigInt minorUnits;

  /// The scale to which we store the amount
  /// A scale of 2 means we store the value to
  /// two decimal places.
  final int scale;

  static late final Fixed zero = Fixed.from(0);
  static late final Fixed one = Fixed.from(1);
  static late final Fixed two = Fixed.from(2);

  /// Parses [amount] for a decimal value
  /// using [pattern] to interpret the string.
  ///
  /// The [scale] expects the number of decimal
  /// places to be retained.
  /// If [scale] < 0 then a FixedException will be thrown.
  ///
  /// If the [pattern] is invalid or the [amount] isn't valid then
  /// a [FixedParseException] is thrown.
  Fixed.parse(
    String amount, {
    String pattern = '#.#',
    this.scale = 2,
    bool invertSeparator = false,
  }) {
    _checkScale();
    final decoder = FixedDecoder(
      pattern: pattern,
      groupSeparator: invertSeparator ? '.' : ',',
      decimalSeparator: invertSeparator ? ',' : '.',
      scale: scale,
    );
    minorUnits = decoder.decode(amount);
  }

  /// Works the same as [parse] but returns a null
  /// if the [amount] cannot be parsed.
  static Fixed? tryParse(
    String amount, {
    String pattern = '#.#',
    int scale = 2,
    bool invertSeparator = false,
  }) {
    try {
      return Fixed.parse(amount,
          pattern: pattern, scale: scale, invertSeparator: invertSeparator);
    } on FixedParseException catch (e) {
      return null;
    }
  }

  /// Fixed a new fixed value from an existing one
  /// adjusting the scale.
  Fixed(Fixed fixed, {this.scale = 2}) {
    _checkScale();

    minorUnits = _rescale(fixed.minorUnits,
        existingScale: fixed.scale, targetScale: scale);
  }

  BigInt _rescale(BigInt minorUnits,
      {required int existingScale, required int targetScale}) {
    if (existingScale == targetScale) {
      return minorUnits;
    }

    if (targetScale > existingScale) {
      final rescale = targetScale - existingScale;

      minorUnits = minorUnits * ten.pow(rescale);
    }

    if (existingScale > targetScale) {
      final rescale = existingScale - targetScale;

      for (var i = 0; i < rescale; i++) {
        minorUnits = minorUnits ~/ ten;
      }
    }
    return minorUnits;
  }

  /// Creates a Fixed scale value from decimal
  /// or integer value and stores the value with
  /// a the given [scale].
  /// ```dart
  /// final value = Fixed.from(1.2345, scale: 2);
  /// print(value) -> 1.23
  Fixed.from(num amount, {this.scale = 2}) {
    _checkScale();

    final decoder = FixedDecoder(
      scale: scale,
      pattern: '#.#',
      groupSeparator: ',',
      decimalSeparator: '.',
    );

    minorUnits = decoder.decode(amount.toStringAsFixed(scale));
  }
  static late final ten = BigInt.from(10);

  /// Creates Fixed scale decimal from [minorUnits].
  ///
  /// e.g.
  /// ```dart
  /// final fixed = Fixed.fromMinorUnits(100, scale: 2)
  /// print(fixed) : 1.00
  /// ```
  Fixed.fromMinorUnits(int minorUnits, {this.scale = 2}) {
    _checkScale();
    this.minorUnits = BigInt.from(minorUnits);
  }
  // Fixed.fromParts(int integerPart, int decimalPart, {this.scale = 2}) {
  //   _checkScale();
  //   minorUnits = integerPart * pow(10, scale) + (decimalPart * );
  // }

  /// Creates a fixed scale decimal from [minorUnits]
  Fixed.fromBigInt(this.minorUnits, {this.scale = 2}) {
    _checkScale();
  }

  void _checkScale() {
    if (scale < 0) {
      throw FixedException('A negative scale of $scale was passed. '
          'The scale must be >= 0.');
    }
  }

  //String toString() => FixedPresionEncoder

  BigInt get scaleFactor => ten.pow(scale);

  /// The component of the number before the decimal point
  BigInt get integerPart => minorUnits ~/ scaleFactor;

  Fixed get abs => isNegative ? -this : this;

  /// The component of the number after the decimal point.
  /// The returned value will always be a +ve no.
  /// The [integerPart] will contain the sign.
  BigInt get decimalPart =>
      minorUnits.abs() % scaleFactor * BigInt.from(minorUnits.sign);

  /// Returns the sign of this [Fixed] amount.
  /// Returns 0 for zero, -1 for values less than zero and +1 for values greater than zero.
  int get sign => minorUnits.sign;

  /// returns true of the value of this [MinorUnit] is zero.
  bool get isZero => minorUnits == BigInt.zero;

  /// returns true of the value of this [MinorUnit] is negative.
  bool get isNegative => minorUnits < BigInt.zero;

  /// returns true of the value of this [MinorUnit] is positive.
  bool get isPositive => minorUnits > BigInt.zero;

  /// Two [Fixed] instances are the same if they have
  /// the same minorUnits and the same scale.
  @override
  int compareTo(Fixed other) {
    if (minorUnits == other.minorUnits) {
      return scale.compareTo(other.scale);
    } else {
      return minorUnits.compareTo(other.minorUnits);
    }
  }

  @override
  int get hashCode => minorUnits.hashCode + scale.hashCode;

  /// Two Fixed values are considered equal if they have
  /// the same numeric amount.
  /// We convert the minorUnits to the same scale in
  /// order to do the comparision.
  @override
  bool operator ==(covariant Fixed other) {
    final operands = _Operands(this, other);
    return identical(this, other) || operands.scaledLhs == operands.scaledRhs;
  }

  /// less than operator
  bool operator <(Fixed other) {
    final operands = _Operands(this, other);
    return operands.scaledLhs < operands.scaledRhs;
  }

  /// less than or equal operator
  bool operator <=(Fixed other) {
    final operands = _Operands(this, other);
    return operands.scaledLhs <= operands.scaledRhs;
  }

  /// greater than operator
  bool operator >(Fixed other) {
    final operands = _Operands(this, other);
    return operands.scaledLhs > operands.scaledRhs;
  }

  /// greater than or equal operator
  bool operator >=(Fixed other) {
    final operands = _Operands(this, other);
    return operands.scaledLhs >= operands.scaledRhs;
  }

  /// Arithmetic

  /// add operator
  /// The resulting [scale] is the larger scale of the two operands.
  Fixed operator +(Fixed operand) {
    final operands = _Operands(this, operand);

    final result = operands.scaledLhs + operands.scaledRhs;

    return Fixed.fromMinorUnits(result, scale: operands.maxScale);
  }

  /// unary minus operator.
  Fixed operator -() => Fixed.fromBigInt(-minorUnits, scale: scale);

  /// subtract operator
  Fixed operator -(Fixed operand) {
    final operands = _Operands(this, operand);

    final result = operands.scaledLhs - operands.scaledRhs;

    return Fixed.fromMinorUnits(result, scale: operands.maxScale);
  }

  /// multiplication operator.
  /// The scale in the result is the sum or the scale of the two
  /// operands.
  Fixed operator *(Fixed operand) {
    final operands = _Operands(this, operand);
    var result = (operands.scaledLhs * operands.scaledRhs).toInt();
    result = operands.rescale(result);
    return Fixed.fromMinorUnits(result.toInt(), scale: scale + operand.scale);

    // if (operand is int) {
    //   return Fixed.fromBigInt(minorUnits * BigInt.from(operand));
    // }

    // if (operand is double) {
    //   const floatingDecimalFactor = 1e14;
    //   final decimalFactor = BigInt.from(100000000000000); // 1e14
    //   final roundingFactor = BigInt.from(50000000000000); // 5 * 1e14

    //   final product = minorUnits *
    //       BigInt.from((operand.abs() * floatingDecimalFactor).round());

    //   var result = product ~/ decimalFactor;
    //   if (product.remainder(decimalFactor) >= roundingFactor) {
    //     result += BigInt.one;
    //   }
    //   if (operand.isNegative) {
    //     result *= -BigInt.one;
    //   }

    //   return Fixed.fromBigInt(result, +-);
    // }

    // throw UnsupportedError(
    //     'Unsupported type of multiplier: "${operand.runtimeType}", '
    //     '(int or double are expected)');
  }

  /// Division operator.
  Fixed operator /(Fixed divisor) {
    final operands = _Operands(this, divisor);
    var result = (operands.scaledLhs * 1 ~/ operands.scaledRhs).toInt();
    return Fixed.from(result, scale: operands.maxScale);
  }

  /// Truncating division operator.
  /// TODO: either this or / is not implemented correctly
  Fixed operator ~/(Fixed divisor) {
    final operands = _Operands(this, divisor);
    var result = (operands.scaledLhs * 1 ~/ operands.scaledRhs).toInt();
    return Fixed.from(result, scale: operands.maxScale);
  }

  /// Division operator.
  Fixed operator %(Fixed divisor) {
    final operands = _Operands(this, divisor);
    var result = (operands.scaledLhs * 1 % operands.scaledRhs).toInt();
    return Fixed.from(result, scale: operands.maxScale);
  }

  Fixed remainder(Fixed divisor) {
    return this - (this ~/ divisor) * divisor;
  }

  Fixed pow(int exponent) {
    return Fixed.fromBigInt(minorUnits.pow(exponent), scale: scale);
  }

  int toInt() {
    final intP = integerPart;

    // bit length excludes sign
    if (intP.bitLength + 1 == 64) {
      if (intP.sign == 1) {
        return maxInt;
      } else {
        return minInt;
      }
    }
    return intP.toInt();
  }

  Fixed multiply(num multiplier) {
    if (multiplier is int) {
      return Fixed.fromBigInt(minorUnits * BigInt.from(multiplier));
    }

    if (multiplier is double) {
      const floatingDecimalFactor = 1e14;
      final decimalFactor = BigInt.from(100000000000000); // 1e14
      final roundingFactor = BigInt.from(50000000000000); // 5 * 1e14

      final product = minorUnits *
          BigInt.from((multiplier.abs() * floatingDecimalFactor).round());

      var result = product ~/ decimalFactor;
      if (product.remainder(decimalFactor) >= roundingFactor) {
        result += BigInt.one;
      }
      if (multiplier.isNegative) {
        result *= -BigInt.one;
      }

      return Fixed.fromBigInt(result);
    }
    throw UnsupportedError(
        'Unsupported type of multiplier: "${multiplier.runtimeType}", '
        '(int or double are expected)');
  }

  Fixed divide(num divisor) {
    return this * Fixed.from(1.0 / divisor.toDouble());
  }

  ///  Allocation
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

  ///
  /// Type Conversion **********************************************************
  ///

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

  ///
  /// Formats a [Fixed] value into a String according to the
  /// passed [pattern].
  ///
  /// If [invertSeparators] is true then the role of the '.' and ',' are
  /// reversed. By default the '.' is used as the decimal separator
  /// whilst the ',' is used as the grouping separator.
  ///
  /// 0 A single digit
  /// # A single digit, omitted if the value is zero
  /// . or , Decimal separator dependant on [invertSeparators]
  /// - Minus sign
  /// , or . Grouping separator dependant on [invertSeparators]
  /// space Space character.
  ///
  String format(String pattern, {bool invertSeparators = false}) {
    if (!invertSeparators) {
      return FixedEncoder(pattern, decimalSeparator: '.', groupSeparator: ',')
          .encode(this);
    } else {
      return FixedEncoder(pattern, decimalSeparator: ',', groupSeparator: '.')
          .encode(this);
    }
  }
}

class FixedException implements Exception {
  FixedException(this.message);

  String message;

  @override
  String toString() => message;
}

class _Operands {
  _Operands(this.lhs, this.rhs) {
    var lhsMinor = lhs.minorUnits.toInt();
    var rhsMinor = rhs.minorUnits.toInt();

    if (lhs.scale > rhs.scale) {
      _rescale = lhs.scale - rhs.scale;
      scaledRhs = rhsMinor * pow(10, _rescale) as int;
      scaledLhs = lhsMinor;
    } else if (rhs.scale > lhs.scale) {
      _rescale = rhs.scale - lhs.scale;
      scaledLhs = lhsMinor * pow(10, _rescale) as int;
      scaledRhs = rhsMinor;
    } else {
      _rescale = 0;
      scaledLhs = lhsMinor;
      scaledRhs = rhsMinor;
    }
  }

  final Fixed lhs;
  final Fixed rhs;
  late final int scaledRhs;
  late final int scaledLhs;
  late final int _rescale;

  int get maxScale => max(lhs.scale, rhs.scale);

  int rescale(int result) {
    for (var i = 0; i < _rescale; i++) {
      result = result ~/ 10;
    }
    return result;
  }
}
