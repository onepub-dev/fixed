import 'fixed.dart';

/// Base exception of all exceptions
/// thrown from the Fixed package.
class FixedException implements Exception {
  FixedException(this.message);
  String message;

  @override
  String toString() => message;
}

/// Exception thrown when a parse fails.
class FixedParseException extends FixedException {
  /// Exception thrown when a parse fails.
  FixedParseException(super.message);

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

/// Thrown when you pass an invalid pattern to [Fixed.format].
class IllegalFixedPatternException extends FixedException {
  ///
  IllegalFixedPatternException(super.message);
}

/// Thrown if a number larger than the supported ranges is
/// passed in.
/// This will only occur if you call [Fixed.fromNum] with
/// scale > 20 or a absolute value of > 10^21
/// If you need larger numbers then use one of the alternate
/// constructors.
class AmountTooLargeException extends FixedException {
  AmountTooLargeException(super.message);
}
