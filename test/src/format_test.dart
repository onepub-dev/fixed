/* Copyright (C) Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:fixed/fixed.dart';
import 'package:test/test.dart';

void main() {
  test('format', () {
    var euFormat = Fixed.parse('1.000.000,23', invertSeparator: true, scale: 2);
    // Format using a locale
    expect(euFormat.formatIntl('en-AUS'), equals('1,000,000.23'));

// Format using default locale
    expect(euFormat.formatIntl(), equals('1,000,000.23'));

    expect(Fixed.fromInt(300, scale: 2).toString(), '3.00');
    expect(Fixed.fromInt(30, scale: 2).toString(), '0.30');
    expect(Fixed.fromInt(3, scale: 2).toString(), '0.03');

    expect(Fixed.fromInt(-300, scale: 2).toString(), '-3.00');
    expect(Fixed.fromInt(-30, scale: 2).toString(), '-0.30');
    expect(Fixed.fromInt(-3, scale: 2).toString(), '-0.03');
  });
}
