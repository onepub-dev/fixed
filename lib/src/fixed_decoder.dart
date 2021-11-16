import 'dart:math';

import 'package:decimal/decimal.dart';

/// Decodes a monetary amount based on a pattern.
class FixedDecoder {
  /// the pattern used to decode the amount.
  final String pattern;

  final String decimalSeparator;
  final String thousandSeparator;

  final int scale;

  /// ctor
  FixedDecoder({
    required this.pattern,
    required this.thousandSeparator,
    required this.decimalSeparator,
    required this.scale,
  }) {
    ArgumentError.checkNotNull(pattern, 'pattern');
  }

  /// Parses [monetaryValue] and returns
  /// the value as a BigInt holding the minorUnits
  Decimal decode(final String monetaryValue) {
    var majorUnits = BigInt.zero;
    var minorUnits = BigInt.zero;

    var compressedPattern = compressDigits(pattern);
    compressedPattern = compressWhitespace(compressedPattern);
    final compressedMonetaryValue = compressWhitespace(monetaryValue);

    var isNegative = false;
    var seenMajor = false;

    final valueQueue = ValueQueue(compressedMonetaryValue, thousandSeparator);

    for (var i = 0; i < compressedPattern.length; i++) {
      switch (compressedPattern[i]) {
        case '#':
          if (!seenMajor) {
            final char = valueQueue.peek();
            if (char == '-') {
              valueQueue.takeOne();
              isNegative = true;
            }
          }
          if (seenMajor) {
            if (valueQueue.isNotEmpty) {
              minorUnits = valueQueue.takeMinorDigits(scale);
            }
          } else {
            majorUnits = valueQueue.takeMajorDigits();
          }
          break;
        case '.':
          if (valueQueue.isNotEmpty) {
            final char = valueQueue.takeOne();
            if (char != decimalSeparator) {
              throw FixedParseException.fromValue(
                  compressedPattern: compressedPattern,
                  patternIndex: i,
                  compressedValue: compressedMonetaryValue,
                  monetaryIndex: valueQueue.index,
                  monetaryValue: monetaryValue);
            }
          }
          seenMajor = true;
          break;
        case ' ':
          break;
        default:
          throw FixedParseException(
            'Invalid character "${compressedPattern[i]}" found in pattern.',
          );
      }
    }

    final value = Decimal.fromBigInt(majorUnits) +
        Decimal.fromBigInt(minorUnits) / Decimal.ten.pow(scale);
    return isNegative ? -value : value;
  }

  ///
  /// Compresses all 0 # , . characters into a single #.#
  ///
  String compressDigits(String pattern) {
    var result = '';

    final regExPattern =
        '([#|0|$thousandSeparator]+)(?:$decimalSeparator([#|0]+))?';

    final regEx = RegExp(regExPattern);

    final matches = regEx.allMatches(pattern);

    if (matches.isEmpty) {
      throw FixedParseException(
        'The pattern did not contain a valid pattern such as "0.00"',
      );
    }

    if (matches.length != 1) {
      throw FixedParseException(
        'The pattern contained more than one numberic pattern.'
        " Check you don't have spaces in the numeric parts of the pattern.",
      );
    }

    final Match match = matches.first;

    if (match.group(1) != null && match.group(2) != null) {
      result = pattern.replaceFirst(regEx, '#.#');
    } else if (match.group(1) != null) {
      result = pattern.replaceFirst(regEx, '#');
    } else if (match.group(2) != null) {
      result = pattern.replaceFirst(regEx, '.#');
    }
    return result;
  }

  /// Removes all whitespace from a pattern or a value
  /// as when we are parsing we ignore whitespace.
  String compressWhitespace(String value) {
    final regEx = RegExp(r'\s+');

    return value.replaceAll(regEx, '');
  }
}

/// Takes a monetary value and turns it into a queue
/// of digits which can be taken one at a time.
class ValueQueue {
  /// the amount we are queuing the digits of.
  String monetaryValue;

  /// current index into the [monetaryValue]
  int index = 0;

  /// the thousands seperator used in this [monetaryValue]
  String thousandsSeparator;

  /// The last character we took from the queue.
  String? lastTake;

  ///
  ValueQueue(this.monetaryValue, this.thousandsSeparator);

  String peek() {
    return monetaryValue[index];
  }

  /// takes the next character from the value.
  String takeOne() => lastTake = monetaryValue[index++];

  bool get isEmpty => monetaryValue.length == index;

  bool get isNotEmpty => !isEmpty;

  /// takes the next [n] character from the value.
  String takeN(int n) {
    var end = index + n;

    end = min(end, monetaryValue.length);
    final take = lastTake = monetaryValue.substring(index, end);

    index += n;

    return take;
  }

  /// return all of the digits from the current position
  /// until we find a non-digit.
  BigInt takeMajorDigits() {
    return BigInt.parse(_takeDigits());
  }

  /// true if the passed character is a digit.
  bool isDigit(String char) {
    return RegExp('[0123456789]').hasMatch(char);
  }

  /// Takes any remaining digits as minor digits.
  /// If there are less digits than [Currency.scale]
  /// then we pad the number with zeros before we convert it to an it.
  ///
  /// e.g.
  /// 1.2 -> 1.20
  /// 1.21 -> 1.21
  BigInt takeMinorDigits(int scale) {
    var digits = _takeDigits();

    if (digits.length < scale) {
      digits += '0' * max(0, scale - digits.length);
    }

    // we have no way of storing less than a minorDigit is this a problem?
    if (digits.length > scale) {
      digits = digits.substring(0, scale);
    }

    return BigInt.parse(digits);
  }

  String _takeDigits() {
    var digits = ''; //  = lastTake;

    while (index < monetaryValue.length &&
        (isDigit(monetaryValue[index]) ||
            monetaryValue[index] == thousandsSeparator)) {
      if (monetaryValue[index] != thousandsSeparator) {
        digits += monetaryValue[index];
      }
      index++;
    }

    if (digits.isEmpty) {
      throw FixedParseException(
        'Character "${monetaryValue[index]}" at pos $index'
        ' is not a digit when a digit was expected',
      );
    }
    return digits;
  }
}

/// Exception thrown when a parse fails.
class FixedParseException implements Exception {
  /// The error message
  String message;

  ///
  FixedParseException(this.message);

  ///
  factory FixedParseException.fromValue(
      {required String compressedPattern,
      required int patternIndex,
      required String compressedValue,
      required int monetaryIndex,
      required String monetaryValue}) {
    final message = '''
$monetaryValue contained an unexpected character '${compressedValue[monetaryIndex]}' at pos $monetaryIndex
        when a match for pattern character ${compressedPattern[patternIndex]} at pos $patternIndex was expected.''';
    return FixedParseException(message);
  }

  @override
  String toString() => message;
}
