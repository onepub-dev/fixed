import 'dart:convert';
import 'package:fixed/fixed.dart';
import 'package:test/test.dart';

void main() {
  final amount = '${'9' * 100}.${'9' * 100}';

  test('toJson/fromJson', () {
    final f0 = Fixed.parse(amount);
    final json = jsonEncode(f0.toJson());
    final f1 = Fixed.fromJson(jsonDecode(json) as Map<String, dynamic>);
    expect(f1.toString(), amount);
  });
}
