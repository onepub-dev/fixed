import 'package:fixed/fixed.dart';
import 'package:test/test.dart';

void main() {
  test('format', () {
    var euFormat = Fixed.parse('1.000.000,23', invertSeparator: true, scale: 2);
    // Format using a locale
    expect(euFormat.formatIntl('en-AUS'), equals('1,000,000.23'));

// Format using default locale
    expect(euFormat.formatIntl(), equals('1,000,000.23'));
  });
}
