// lib/utils/form_validators.dart
class FormValidators {
  static String? phoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your phone number';
    }
    if (!value.startsWith('+')) {
      return 'Phone number start with country code (+92)';
    }
    // Add more specific phone validation if needed
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }
}
