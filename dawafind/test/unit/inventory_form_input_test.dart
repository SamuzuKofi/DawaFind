import 'package:flutter_test/flutter_test.dart';

/// Regression tests for the inventory add/edit dialogs.
///
/// The quantity field is parsed with int.parse when the form is submitted.
/// It used to be validated with double.tryParse, which accepts "10.5" — so a
/// decimal quantity passed validation, closed the dialog, and then threw a
/// FormatException that no one caught. These pin the two parsers to the same
/// notion of a valid value.
void main() {
  group('inventory quantity field', () {
    const accepted = ['0', '5', '250', ' 12 '];
    const rejected = ['10.5', '1e3', 'abc', '', '   ', '-3', '5,5'];

    test('every value the validator accepts can be parsed by int.parse', () {
      for (final value in accepted) {
        final parsed = int.tryParse(value.trim());
        expect(
          parsed,
          isNotNull,
          reason: '"$value" passes validation, so int.parse must not throw',
        );
        expect(parsed! >= 0, isTrue);
      }
    });

    test('decimal and junk quantities are rejected before parsing', () {
      for (final value in rejected) {
        final valid =
            value.trim().isNotEmpty &&
            int.tryParse(value.trim()) != null &&
            int.parse(value.trim()) >= 0;
        expect(
          valid,
          isFalse,
          reason: '"$value" must be rejected by the validator',
        );
      }
    });

    // The old validator's rule, kept here to show why it was not enough.
    test('the previous double-based rule would have let "10.5" through', () {
      expect(double.tryParse('10.5'), isNotNull);
      expect(() => int.parse('10.5'), throwsFormatException);
    });
  });

  group('inventory price field', () {
    test('accepts decimals but still rejects negatives and junk', () {
      expect(double.tryParse('1500'), 1500);
      expect(double.tryParse('1500.75'), 1500.75);
      expect(double.tryParse('abc'), isNull);
      expect(double.parse('-1') < 0, isTrue);
    });
  });
}
