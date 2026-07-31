import 'package:flutter_test/flutter_test.dart';
import 'package:dawafind/core/utils/validators.dart';

void main() {
  group('Validators.required', () {
    test('rejects null', () {
      expect(Validators.required(null), 'This field is required');
    });
    test('rejects empty/whitespace string', () {
      expect(Validators.required('   '), 'This field is required');
    });
    test('accepts non-empty text', () {
      expect(Validators.required('Linda'), isNull);
    });
  });

  group('Validators.phone', () {
    test('rejects null/empty', () {
      expect(Validators.phone(''), 'Phone number is required');
    });
    test('rejects too-short number', () {
      expect(Validators.phone('1234'), 'Enter a valid phone number');
    });
    test('accepts 8+ character number', () {
      expect(Validators.phone('79123456'), isNull);
    });
  });

  group('Validators.password', () {
    test('rejects empty password', () {
      expect(Validators.password(''), 'Password is required');
    });
    test('rejects password under 6 characters', () {
      expect(
        Validators.password('123'),
        'Password must be at least 6 characters',
      );
    });
    test('accepts password of 6+ characters', () {
      expect(Validators.password('secure123'), isNull);
    });
  });

  group('Validators.email', () {
    test('rejects empty email', () {
      expect(Validators.email(''), 'Email is required');
    });
    test('rejects malformed email', () {
      expect(Validators.email('not-an-email'), 'Enter a valid email');
    });
    test('rejects email missing domain', () {
      expect(Validators.email('linda@'), 'Enter a valid email');
    });
    test('accepts valid email', () {
      expect(Validators.email('lindaumwali5@gmail.com'), isNull);
    });
  });
}
