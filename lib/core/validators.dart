// Validasi PIN minimum 4 digit.
String? validatePin(String? pin) {
  if (pin == null || pin.trim().isEmpty) {
    return 'PIN wajib diisi';
  }
  if (pin.length < 4) {
    return 'PIN minimal 4 digit';
  }
  return null;
}

// Validasi field wajib diisi.
String? validateRequired(String? value, String label) {
  if (value == null || value.trim().isEmpty) {
    return '$label wajib diisi';
  }
  return null;
}
