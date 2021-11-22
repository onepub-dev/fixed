import 'package:fixed/fixed.dart';

void main() {
  var fixed = Fixed.fromNum(1, scale: 2);

  print(fixed.toString());
  print(fixed.format('#.#'));
  print(fixed.format('#.000'));

  var add = fixed + Fixed.fromNum(1);
  print(add);
}
