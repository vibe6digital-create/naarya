class Validators {
  Validators._();

  static String? phone(String? value) {
    if (value == null || value.isEmpty) return 'Phone number is required';
    final cleaned = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleaned.length != 10) return 'Enter a valid 10-digit phone number';
    return null;
  }

  static String? otp(String? value) {
    if (value == null || value.isEmpty) return 'OTP is required';
    if (value.length != 6) return 'Enter complete 6-digit OTP';
    return null;
  }

  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) return 'Name is required';
    if (value.trim().length < 2) return 'Name is too short';
    return null;
  }
}
