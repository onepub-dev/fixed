/* Copyright (C) Brett Sutton - All Rights Reserved
* Released under the MIT license.
* Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
*/

import 'exceptions.dart';
import 'fixed.dart';

/// Encodes a fixed value based on a pattern.
class FixedEncoder {
  ///
  FixedEncoder(this.pattern,
      {this.decimalSeparator = '.', this.groupSeparator = ','});

  /// the pattern to encode to.
  String pattern;

  String decimalSeparator;

  String groupSeparator;

  String encode(Fixed amount) {
    // String formatted;

    final decimalSeperatorCount = decimalSeparator.allMatches(pattern).length;

    if (decimalSeperatorCount > 1) {
      throw IllegalFixedPatternException(
          'A format Pattern may contain, at most, a single decimal '
          "separator '$decimalSeparator'");
    }

    // var decimalSeparatorIndex = pattern.indexOf(decimalSeparator);

    // var hasMinor = true;
    // if (decimalSeparatorIndex == -1) {
    //   decimalSeparatorIndex = pattern.length;
    //   hasMinor = false;
    // }

    // final majorPattern = pattern.substring(0, decimalSeparatorIndex);

    // formatted = formatMajorPart(amount, majorPattern);
    // if (hasMinor) {
    //   final minorPattern = pattern.substring(decimalSeparatorIndex + 1);
    //   final minorPart = formatMinorPart(amount, minorPattern);
    //   if (minorPart.isNotEmpty) {
    //     formatted += decimalSeparator
    //      + formatMinorPart(amount, minorPattern);
    //   }
    // }

    // return formatted;
    return format2(amount, pattern);
  }

  String format2(Fixed amount, String pattern) {
    var whole = amount.minorUnits.toString();

    /// we will add the -ve when we know where it is to be placed.
    if (whole.startsWith('-')) {
      whole = whole.substring(1);
    }

    if (whole.length < amount.scale) {
      whole = whole.padLeft(amount.scale, '0');
    }

    final decimalStart = whole.length - amount.scale;
    final integerPart = whole.substring(0, decimalStart);
    final decimalPart = whole.substring(decimalStart);

    final decimalSeparatorIndex = pattern.indexOf(decimalSeparator);

    final hasDecimalPart = decimalSeparatorIndex != -1;

    final integerPatternPart =
        hasDecimalPart ? pattern.substring(0, decimalSeparatorIndex) : pattern;

    // format integer. We build the no. in from right to left
    var integerAmount = '';
    if (integerPatternPart.isNotEmpty) {
      integerAmount =
          _formatIntegerPart(integerPatternPart, integerPart, integerAmount);
    }

    var decimalAmount = '';
    if (hasDecimalPart) {
      decimalAmount = _formatDecimalPart(
          pattern, decimalSeparatorIndex, decimalPart, decimalAmount);
    }

    var result = '';
    if (integerAmount.isNotEmpty) {
      result = integerAmount;
    }
    if (decimalAmount.isNotEmpty) {
      result += decimalSeparator;
    }
    if (decimalAmount.isNotEmpty) {
      result += decimalAmount;
    }

    if (amount.isNegative) {
      if (integerAmount.isEmpty) {
        result = '0$result';
      }
      result = '-$result';
    }

    return result;
  }

  String _formatIntegerPart(
      String integerPatternPart, String integerPart, String integerAmount) {
    var patternIndex = integerPatternPart.length - 1;
    var lastIntegerPattern = '#';

    final paddedIntegerPart = integerPart.padLeft(
        integerPatternPart.replaceAll(RegExp('[^0]'), '').length - 1, '0');

    var lIntegerAmount = integerAmount;
    for (var integerIndex = paddedIntegerPart.length - 1; integerIndex >= 0;) {
      var patternChar = lastIntegerPattern;
      if (patternIndex >= 0) {
        patternChar = integerPatternPart[patternIndex--];
        lastIntegerPattern = patternChar;
      }

      switch (patternChar) {
        case '#':
          lIntegerAmount = paddedIntegerPart[integerIndex] + lIntegerAmount;
          integerIndex--;
        case '0':
          lIntegerAmount = paddedIntegerPart[integerIndex] + lIntegerAmount;
          integerIndex--;
        // just echo group separators into the stream.
        case ',':
        case '.':
          lIntegerAmount = patternChar + lIntegerAmount;
      }
    }

    if (patternIndex >= 0) {
      // we have to keep process the pattern index incase the user
      // has leading '0' which must always be output.
      var exitLoop = false;
      for (; patternIndex >= 0 && !exitLoop; patternIndex--) {
        final patternChar = integerPatternPart[patternIndex];
        switch (patternChar) {
          case '0':
            lIntegerAmount = patternChar + lIntegerAmount;
          case '#':
            exitLoop = true;

          /// group separators
          case '.':
          case ',':
            // We only output group separators if there ares still '0'
            // in the pattern.
            if (patternIndex > 1 && integerPatternPart[patternIndex] == '0') {
              lIntegerAmount = patternChar + lIntegerAmount;
            } else {
              exitLoop = true;
            }
        }
      }
    }
    return lIntegerAmount;
  }

  String _formatDecimalPart(String pattern, int decimalSeparatorIndex,
      String decimalPart, String decimalAmount) {
    var lDecimalAmount = decimalAmount;
    final decimalPatternPart = pattern.substring(decimalSeparatorIndex + 1);

    // format decimal.
    var decimalPatternIndex = 0;
    for (var decimalIndex = 0;
        decimalIndex < decimalPart.length;
        decimalIndex++) {
      // when the decimal pattern finishes so do we.
      if (decimalPatternIndex == decimalPatternPart.length) {
        break;
      }
      final patternChar = decimalPatternPart[decimalPatternIndex++];

      switch (patternChar) {
        case '#':
          lDecimalAmount += decimalPart[decimalIndex];
        case '0':
          lDecimalAmount += decimalPart[decimalIndex];

        // just echo group separators into the stream.
        case ',':
        case '.':
          lDecimalAmount += patternChar;
      }
    }

    if (decimalPatternIndex < decimalPatternPart.length) {
      // we have to keep process the pattern index incase the user
      // has trailing '0' which must always be output.
      var exitLoop = false;
      for (;
          decimalPatternIndex < decimalPatternPart.length && !exitLoop;
          decimalPatternIndex++) {
        final patternChar = decimalPatternPart[decimalPatternIndex];
        switch (patternChar) {
          case '0':
            lDecimalAmount += patternChar;
          case '#':
            exitLoop = true;

          /// group separators
          case '.':
          case ',':
            // We only output group separators if there ares still '0'
            // in the pattern.
            if (decimalPatternIndex < decimalPatternPart.length &&
                decimalPatternPart[decimalPatternIndex] == '0') {
              lDecimalAmount += patternChar;
            } else {
              exitLoop = true;
            }
        }
      }
    }
    return lDecimalAmount;
  }

  // /// Formats the major part of the [amount].
  // String formatMajorPart(Fixed amount, final String majorPattern) {
  //   var formatted = '';

  //   // extract the contiguous money components made up of 0 # , and .
  //   final moneyPattern = getMoneyPattern(majorPattern);
  //   checkZeros(moneyPattern, groupSeparator, minor: false);

  //   final wholeNumberPart = amount.integerPart;

  //   final formattedMajorUnits =
  //       getFormattedMajorUnits(amount, moneyPattern, wholeNumberPart);

  //   // replace the the money components with a single #
  //   var compressedMajorPattern = compressMoney(majorPattern);

  //   // Replace the compressed patterns with actual values.
  //   // The periods and commas have already been removed from the pattern.
  //   for (var i = 0; i < compressedMajorPattern.length; i++) {
  //     final char = compressedMajorPattern[i];
  //     switch (char) {
  //       case '#':
  //         formatted += formattedMajorUnits;
  //         break;
  //       case ' ':
  //         formatted += ' ';
  //         break;
  //       case '0':
  //       case ',':
  //       case '.':
  //       default:
  //         throw IllegalPatternException(
  //             "The pattern contains an unknown character: '$char'");
  //     }
  //   }

  //   return formatted;
  // }

  // ///
  // String getFormattedMajorUnits(
  //     Fixed amount, final String moneyPattern, BigInt majorUnits) {
  //   String normalisedMoneyPattern;
  //   if (decimalSeparator == ',') {
  //     // the NumberFormat doesn't like the inverted characters
  //     // so we normalise them for the conversion.
  //     normalisedMoneyPattern = moneyPattern.replaceAll('.', ',');
  //   } else {
  //     normalisedMoneyPattern = moneyPattern;
  //   }
  //   // format the no. into that pattern.
  //   var formattedMajorUnits =
  //       NumberFormat(normalisedMoneyPattern).format(majorUnits.toInt());

  //   if (!majorUnits.isNegative && amount.minorUnits.isNegative) {
  //     formattedMajorUnits = '-$formattedMajorUnits';
  //   }

  //   if (decimalSeparator == ',') {
  //     // Now convert them back
  //     formattedMajorUnits = formattedMajorUnits.replaceAll(',', '.');
  //   }
  //   return formattedMajorUnits;
  // }

  // ///
  // String formatMinorPart(Fixed amount, String minorPattern) {
  //   var formatted = '';

  //   // extract the contiguous money components made up of 0 # , and .
  //   var moneyPattern = getMoneyPattern(minorPattern);

  //   /// check that the zeros are only at is at the end of the pattern.
  //   checkZeros(moneyPattern, groupSeparator, minor: true);

  //   /// If there are trailing zeros then we must ensure
  //   /// the final string is at least [requiredPatternWidth] or if
  //   /// its not then we pad with zeros.
  //   var requiredPatternWidth = 0;
  //   final firstZero = moneyPattern.indexOf('0');
  //   if (firstZero != -1) {
  //     requiredPatternWidth = moneyPattern.length;
  //   }

  //   /// If the pattern is longer than the minor digits we need to clip the
  //   /// pattern and add trailing zeros back at the end.
  //   const extendFormatWithZeros = 0;
  //   if (moneyPattern.length > amount.scale) {
  //     moneyPattern = moneyPattern.substring(0, amount.scale);
  //     // extendFormatWithZeros

  //   }

  //   final decimals = amount.decimalPart;

  //   // format the no. using the pattern.
  //   // In order for Number format to minor units
  //   // with proper 0s, we first add [minorDigitsFactor] and then strip the 1
  //   // after being formatted.
  //   //
  //   // e.g., using ## to format 1 would result in 1, but we want it
  //   // formatted as 01 because it is really the decimal part of the number.

  //   var formattedMinorUnits =
  //       NumberFormat(moneyPattern).format(decimals.toInt());

  //   /// If the scale is 4 and minorunits = 10
  //   /// then the number format will produce 10 rather than 0010
  //   /// So we need to add leading zeros
  //   if (formattedMinorUnits.length < amount.scale) {
  //     final leadingZeros = amount.scale - formattedMinorUnits.length;
  //     formattedMinorUnits = '${'0' * leadingZeros}$formattedMinorUnits';
  //   }

  //   // money pattern is short, so we need to force a truncation as
  //   // NumberFormat doesn't know we are dealing with minor units.
  //   if (moneyPattern.length < formattedMinorUnits.length) {
  //     formattedMinorUnits =
  //         formattedMinorUnits.substring(0, moneyPattern.length);
  //   }

  //   // Fixed problems caused by passing a int to the NumberFormat
  //   // when we are trying to format a decimal.
  //   // Move leading zeros to the end when minor units >= 10 - i.e.,
  //   // we want to keep the leading zeros for single digit cents.
  //   if (decimals.toInt() >= amount.scaleFactor.toInt()) {
  //     formatted = invertZeros(formatted);
  //   }

  //   // If the no. of decimal digits contained in the minorunits
  //   // then we need to pad the result.
  //   if (formattedMinorUnits.length < moneyPattern.length) {
  //     formattedMinorUnits.padLeft(moneyPattern.length
  //      - formatted.length, '0');
  //   }

  //   // Add trailing zeros if the pattern width requires it
  //   if (requiredPatternWidth != 0) {
  //     formattedMinorUnits =
  //         formattedMinorUnits.padRight(requiredPatternWidth, '0');
  //   }

  //   if (extendFormatWithZeros != 0) {
  //     formattedMinorUnits =
  //         formattedMinorUnits.padRight(extendFormatWithZeros, '0');
  //   }

  //   // replace the the money components in the pattern with a single #
  //   var compressedMinorPattern = compressMoney(minorPattern);

  //   // expand the pattern
  //   for (var i = 0; i < compressedMinorPattern.length; i++) {
  //     final char = compressedMinorPattern[i];
  //     switch (char) {
  //       case '#':
  //         formatted += formattedMinorUnits;
  //         break;
  //       case ' ':
  //         formatted += ' ';
  //         break;
  //       case '0':
  //       case ',':
  //       case '.':
  //       default:
  //         throw IllegalPatternException(
  //             "The minor part of the pattern contains an unexpected "
  //              "character: '$char'");
  //     }
  //   }

  //   return formatted;
  // }

  /// Just extract the number specific format chacters leaving out
  /// currency and symbols
  /// MinorUnits use trailing zeros, MajorUnits use leading zeros.
  String getMoneyPattern(String pattern) {
    var foundMoney = false;
    var inMoney = false;
    var moneyPattern = '';
    for (var i = 0; i < pattern.length; i++) {
      final char = pattern[i];
      switch (char) {
        case '#':
          inMoney = true;
          foundMoney = true;

          isMoneyAllowed(inMoney: inMoney, foundMoney: foundMoney, pos: i);
          moneyPattern += '#';
        case '0':
          isMoneyAllowed(inMoney: inMoney, foundMoney: foundMoney, pos: i);
          moneyPattern += '0';
          inMoney = true;
          foundMoney = true;
        case ',':
          isMoneyAllowed(inMoney: inMoney, foundMoney: foundMoney, pos: i);
          moneyPattern += ',';
          inMoney = true;
          foundMoney = true;

        case '.':
          isMoneyAllowed(inMoney: inMoney, foundMoney: foundMoney, pos: i);
          moneyPattern += '.';
          inMoney = true;
          foundMoney = true;

        case ' ':
          inMoney = false;
        default:
          throw IllegalFixedPatternException(
              "The pattern contains an unknown character: '$char'");
      }
    }
    return moneyPattern;
  }

  /// counts the no. of # and 0s in the pattern before the decimal seperator.
  int countMajorPatternDigits(String pattern, String decimalSeparator) {
    var count = 0;
    for (var i = 0; i < pattern.length; i++) {
      final char = pattern[i];
      if (char == decimalSeparator) {
        break;
      }

      if (char == '#' || char == '0') {
        count++;
      }
    }
    return count;
  }

  /// counts the no. of # and 0s in the pattern before the decimal separator.
  int countMinorPatternDigits(String pattern, String decimalSeparator) {
    var count = 0;
    var foundDecimalSeparator = false;

    for (var i = 0; i < pattern.length; i++) {
      final char = pattern[i];
      if (char == decimalSeparator) {
        foundDecimalSeparator = true;
      }

      if (!foundDecimalSeparator) {
        continue;
      }

      if (char == '#' || char == '0') {
        count++;
      }
    }
    return count;
  }

  ///
  void isMoneyAllowed(
      {required bool inMoney, required bool foundMoney, required int pos}) {
    if (!inMoney && foundMoney) {
      throw IllegalFixedPatternException('Found a 0 at location $pos. '
          'All money characters (0#,.)must be contiguous');
    }
  }

  ///
  String compressMoney(String majorPattern) =>
      majorPattern.replaceAll(RegExp(r'[#|0|,|\.]+'), '#');

  /// Check that Zeros are only at the end of the pattern unless
  /// we have group separators as there
  /// can then be a zero at the end of each segment.
  void checkZeros(String moneyPattern, String groupSeparator,
      {required bool minor}) {
    if (!moneyPattern.contains('0')) {
      return;
    }

    final illegalPattern = IllegalFixedPatternException(
        '''The '0' pattern characters must only be at the end of the pattern for ${minor ? 'Minor' : 'Major'} Units''');

    // compress zeros so we have only one which should be at the end,
    // unless we have group separators then we can have several 0s e.g. 0,0,0
    final comppressedMoneyPattern = moneyPattern.replaceAll(RegExp('0+'), '0');

    // last char must be a zero (i.e. group separater not allowed here)
    if (comppressedMoneyPattern[comppressedMoneyPattern.length - 1] != '0') {
      throw illegalPattern;
    }

    // check that zeros are the trailing character.
    // if the pattern has group separators then there can be more than one 0.
    var zerosEnded = false;
    final len = comppressedMoneyPattern.length - 1;
    for (var i = len; i > 0; i--) {
      final char = comppressedMoneyPattern[i];
      var isValid = char == '0';

      // when looking at the intial zeros a group separator
      // is consider  valid.
      if (!zerosEnded) {
        isValid &= char == groupSeparator;
      }

      if (isValid && zerosEnded) {
        throw illegalPattern;
      }
      if (!isValid) {
        zerosEnded = true;
      }
    }
  }

  /// move leading zeros to the end of the string.
  String invertZeros(String formatted) {
    var trailingZeros = '';
    var result = '';
    for (var i = 0; i < formatted.length; i++) {
      final char = formatted[i];

      if (char == '0' && result.isEmpty) {
        trailingZeros += '0';
      } else {
        result += char;
      }
    }
    return result + trailingZeros;
  }
}
