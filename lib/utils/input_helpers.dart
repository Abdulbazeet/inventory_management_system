import 'dart:io';

class InputHelpers {
  static String readRequired(String label) {
    while (true) {
      stdout.write('$label: ');
      final value = stdin.readLineSync()?.trim() ?? '';
      if (value.isNotEmpty) return value;
      stdout.writeln('A value is required.');
    }
  }

  static String readOptional(String label) {
    stdout.write('$label: ');
    return stdin.readLineSync()?.trim() ?? '';
  }

  static int readInt(String label, {int minimum = 0}) {
    while (true) {
      final value = readRequired(label);
      final number = int.tryParse(value);
      if (number != null && number >= minimum) return number;
      stdout.writeln('Enter a whole number of at least $minimum.');
    }
  }

  static double readDouble(String label, {double minimum = 0}) {
    while (true) {
      final value = readRequired(label);
      final number = double.tryParse(value);
      if (number != null && number >= minimum) return number;
      stdout.writeln('Enter a number of at least $minimum.');
    }
  }
}
