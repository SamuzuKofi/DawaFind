class Validators {
  Validators._();

  static String? phone(String? v) {
    if (v == null || v.trim().isEmpty) return 'Phone number is required';
    if (v.trim().length < 10) return 'Enter a valid phone number';
    return null;
  }

  static String? password(String? v) {
    if (v == null || v.isEmpty) return 'Password is required';
    if (v.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  static String? required(String? v) {
    if (v == null || v.trim().isEmpty) return 'This field is required';
    return null;
  }

  static String? confirmPassword(String? v, String original) {
    if (v != original) return 'Passwords do not match';
    return null;
  }
}
