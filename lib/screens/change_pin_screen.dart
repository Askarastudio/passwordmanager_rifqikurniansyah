import 'package:flutter/material.dart'; // mengambil library Material UI
import 'package:flutter/services.dart'; // input formatter
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // akses secure storage

import '../core/crypto.dart'; // hash PIN
import '../core/validators.dart'; // validasi input
import '../widgets/footer_text.dart'; // footer identitas

// Layar untuk mengganti Master PIN.
class ChangePinScreen extends StatefulWidget {
  const ChangePinScreen({super.key});

  @override
  // Buat state untuk form ubah PIN.
  State<ChangePinScreen> createState() => _ChangePinScreenState();
}

class _ChangePinScreenState extends State<ChangePinScreen> {
  static const _pinHashKey = 'master_pin_hash';

  final _formKey = GlobalKey<FormState>();
  final _oldPinController = TextEditingController();
  final _newPinController = TextEditingController();
  final _confirmController = TextEditingController();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  bool _saving = false;

  @override
  // Bersihkan controller saat widget dilepas.
  void dispose() {
    _oldPinController.dispose();
    _newPinController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  // Validasi PIN lama lalu simpan PIN baru.
  Future<void> _savePin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_newPinController.text != _confirmController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Konfirmasi PIN tidak sama')),
      );
      return;
    }

    setState(() => _saving = true);
    final storedHash = await _storage.read(key: _pinHashKey);
    final oldHash = CryptoService.hashPin(_oldPinController.text);
    if (storedHash == null || storedHash != oldHash) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PIN lama tidak sesuai')),
        );
      }
      return;
    }

    final newHash = CryptoService.hashPin(_newPinController.text);
    await _storage.write(key: _pinHashKey, value: newHash);

    if (!mounted) {
      return;
    }
    setState(() => _saving = false);
    Navigator.of(context).pop(true);
  }

  @override
  // Bangun form ubah PIN.
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ubah PIN')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _oldPinController,
                decoration: const InputDecoration(labelText: 'PIN Lama'),
                keyboardType: TextInputType.number,
                obscureText: true,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                validator: validatePin,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _newPinController,
                decoration: const InputDecoration(labelText: 'PIN Baru'),
                keyboardType: TextInputType.number,
                obscureText: true,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                validator: validatePin,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _confirmController,
                decoration: const InputDecoration(labelText: 'Konfirmasi PIN Baru'),
                keyboardType: TextInputType.number,
                obscureText: true,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                validator: validatePin,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saving ? null : _savePin,
                  child: _saving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Simpan PIN'),
                ),
              ),
              const SizedBox(height: 12),
              const FooterText(),
            ],
          ),
        ),
      ),
    );
  }
}
