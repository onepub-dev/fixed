import 'package:fixed/fixed.dart';
import 'package:test/test.dart';

void main() {
  group('cross-scale value contracts', () {
    test('compareTo orders numeric values and agrees with equality', () {
      // Explicit ranks are independent of Fixed's shared scaling logic.
      final cases = [
        ('-10', 0),
        ('-2.00', 1),
        ('-1.000000000000000000000001', 2),
        ('-1.0', 3),
        ('0.000', 4),
        ('0', 4),
        ('1.00', 5),
        ('1', 5),
        ('1.000000000000000000000001', 6),
        ('2.0', 7),
        ('10', 8),
      ];
      final values = cases.map((entry) => Fixed.parse(entry.$1)).toList();
      for (var i = 0; i < values.length; i++) {
        for (var j = 0; j < values.length; j++) {
          final expected = cases[i].$2.compareTo(cases[j].$2);
          final comparison = values[i].compareTo(values[j]);
          final reason = '${cases[i].$1} compared with ${cases[j].$1}';
          expect(comparison.sign, expected, reason: reason);
          expect(values[i] == values[j], expected == 0, reason: reason);
          expect(values[i] < values[j], expected < 0, reason: reason);
          expect(values[i] > values[j], expected > 0, reason: reason);
          expect(values[i] <= values[j], expected <= 0, reason: reason);
          expect(values[i] >= values[j], expected >= 0, reason: reason);
        }
      }
    });

    test('equal values have equal hashes and work as collection keys', () {
      for (final text in ['0', '1', '-1', '1.25', '-1.25']) {
        final value = Fixed.parse(text);
        final rescaled = value.copyWith(decimalDigits: 30);
        expect(value, rescaled);
        expect(value.hashCode, rescaled.hashCode);
        expect({value, rescaled}, hasLength(1));
        expect({value: 'found'}[rescaled], 'found');
      }
    });
  });

  group('complete parsing', () {
    for (final input in [
      '',
      ' \t\n',
      '-',
      '.',
      '-.',
      ',',
      '-,',
      '1x',
      '1.23junk',
      '1.2.3',
      '1e2',
      '1.23e4',
      '1.23-',
    ]) {
      test('rejects malformed input ${input.replaceAll('\n', r'\n')}', () {
        expect(() => Fixed.parse(input), throwsA(isA<FixedParseException>()));
        expect(Fixed.tryParse(input), isNull);
      });
    }

    test('rejects suffixes with inverted separators', () {
      expect(() => Fixed.parse('1,23junk', invertSeparator: true),
          throwsA(isA<FixedParseException>()));
      expect(() => Fixed.parse('1,2,3', invertSeparator: true),
          throwsA(isA<FixedParseException>()));
    });

    test('preserves whitespace, grouping and omitted whole or fraction', () {
      expect(Fixed.parse(' \t1, 000,000.2 34\n'), Fixed.parse('1000000.234'));
      expect(Fixed.parse(' 1.000.000,2 34 ', invertSeparator: true),
          Fixed.parse('1000000.234'));
      expect(Fixed.parse('.1'), Fixed.parse('0.1'));
      expect(Fixed.parse('-.1'), Fixed.parse('-0.1'));
      expect(Fixed.parse('1.'), Fixed.one);
    });

    test('accepts permissive grouping but rejects trailing text', () {
      for (final invertSeparator in [false, true]) {
        final group = invertSeparator ? '.' : ',';
        final decimal = invertSeparator ? ',' : '.';
        final cases = {
          '1$group${group}2': '12',
          '1$group': '1',
          '1${decimal}2${group}3': '1.23',
        };
        for (final entry in cases.entries) {
          expect(
              Fixed.parse(entry.key, invertSeparator: invertSeparator)
                  .toString(),
              entry.value);
          expect(
              () => Fixed.parse('${entry.key}x',
                  invertSeparator: invertSeparator),
              throwsA(isA<FixedParseException>()));
          expect(
              Fixed.tryParse('${entry.key}x', invertSeparator: invertSeparator),
              isNull);
        }
      }
    });
  });

  group('truncating division and remainder', () {
    for (final numerator in ['7.50', '-7.50']) {
      for (final denominator in ['2.0', '-2.0']) {
        test('$numerator ~/ $denominator retains its documented scale', () {
          final a = Fixed.parse(numerator);
          final b = Fixed.parse(denominator);
          final quotient = a ~/ b;
          final remainder = a.remainder(b);
          final quotientSign = a.sign * b.sign;
          expect(quotient.minorUnits, BigInt.from(300 * quotientSign));
          expect(quotient.decimalDigits, 2);
          expect(remainder, Fixed.parse(a.isNegative ? '-1.5' : '1.5'));
          expect(remainder.decimalDigits, 3);
          expect(quotient * b + remainder, a);
        });
      }
    }

    test('quotient below one truncates to zero at the larger scale', () {
      final quotient = Fixed.parse('1.0') ~/ Fixed.parse('2.000');
      expect(quotient.minorUnits, BigInt.zero);
      expect(quotient.decimalDigits, 3);
    });

    test('higher-scale denominator preserves remainder scale', () {
      final denominator = Fixed.parse('2.00');
      for (final entry in [
        ('7.5', '3.00', '1.5000'),
        ('-7.5', '-3.00', '-1.5000'),
        ('8.0', '4.00', '0.0000'),
        ('0.0', '0.00', '0.0000'),
      ]) {
        final numerator = Fixed.parse(entry.$1);
        expect((numerator ~/ denominator).toString(), entry.$2);
        expect(numerator.remainder(denominator).toString(), entry.$3);
      }
    });

    test('zero denominator retains the BigInt division error contract', () {
      final denominator = Fixed.parse('0.00');
      for (final numerator in [Fixed.zero, Fixed.parse('7.5')]) {
        // BigInt truncating division still throws this deprecated error type.
        // ignore: deprecated_member_use
        final divisionError = isA<IntegerDivisionByZeroException>();
        expect(() => numerator ~/ denominator, throwsA(divisionError));
        expect(() => numerator.remainder(denominator), throwsA(divisionError));
      }
    });
  });

  group('divide(num)', () {
    test('divides exactly before rounding once to the original scale', () {
      final result = Fixed.parse('1.000000000000000000000000').divide(3);
      expect(result.toString(), '0.333333333333333333333333');
      expect(result.decimalDigits, 24);
      expect(Fixed.parse('12.00').divide(0.3).toString(), '40.00');
      expect(Fixed.parse('1.00').divide(0.2221).toString(), '4.50');
      expect(Fixed.parse('1.00').divide(1e-7).toString(), '10000000.00');
    });

    test('rounds ties away from zero at the original scale', () {
      expect(Fixed.parse('1.01').divide(2).toString(), '0.51');
      expect(Fixed.parse('-1.01').divide(2).toString(), '-0.51');
      expect(Fixed.parse('1.01').divide(-2).toString(), '-0.51');
      expect(Fixed.parse('5').divide(2).toString(), '3');
    });

    test('handles positive exponents and extreme finite divisors', () {
      expect(Fixed.parse('1000000000000000000000.00').divide(1e21).toString(),
          '1.00');
      expect(Fixed.parse('1.00').divide(double.maxFinite).toString(), '0.00');
      // double.minPositive has decimal string representation 5e-324.
      final result = Fixed.one.divide(double.minPositive);
      expect(result.minorUnits, BigInt.from(2) * BigInt.from(10).pow(323));
      expect(result.decimalDigits, 0);
    });

    test('rejects zero and non-finite divisors', () {
      for (final divisor in [
        0,
        -0.0,
        double.nan,
        double.infinity,
        double.negativeInfinity
      ]) {
        expect(() => Fixed.one.divide(divisor), throwsA(isA<FixedException>()));
      }
    });
  });

  test('pow(0) supports more than 20 decimal digits', () {
    for (final base in ['0', '-2', '2']) {
      final result = Fixed.parse(base, decimalDigits: 30).pow(0);
      expect(result.minorUnits, BigInt.from(10).pow(30));
      expect(result.decimalDigits, 30);
    }
  });
}
