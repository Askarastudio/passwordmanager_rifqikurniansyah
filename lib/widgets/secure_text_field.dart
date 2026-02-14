import 'package:flutter/material.dart'; // mengambil library Material UI

// Field input password dengan toggle show/hide.
class SecureTextField extends StatefulWidget {
  const SecureTextField({
    super.key,
    required this.controller,
    required this.label,
    this.validator,
  }); // constructor untuk properti input

  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;

  @override
  // Buat state untuk toggle visibility.
  State<SecureTextField> createState() => _SecureTextFieldState();
}

class _SecureTextFieldState extends State<SecureTextField> {
  bool _obscure = true;

  @override
  // Bangun TextFormField dengan tombol visibility.
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      decoration: InputDecoration(
        labelText: widget.label,
        suffixIcon: IconButton(
          icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
          onPressed: () => setState(() => _obscure = !_obscure),
        ),
      ),
      obscureText: _obscure,
      validator: widget.validator,
    );
  }
}
