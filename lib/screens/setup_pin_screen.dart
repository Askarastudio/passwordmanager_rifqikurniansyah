import 'package:flutter/material.dart'; // mengambil library Material UI
import 'package:flutter/services.dart'; // input formatter
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // akses secure storage

import '../core/crypto.dart'; // hash PIN dan key AES
import '../core/validators.dart'; // validasi input
import '../widgets/footer_text.dart'; // footer identitas
import 'home_screen.dart'; // navigasi setelah setup

// Layar pertama untuk membuat Master PIN.
class SetupPinScreen extends StatefulWidget {
  const SetupPinScreen({super.key});

  @override
  // Buat state untuk form setup PIN.
  State<SetupPinScreen> createState() => _SetupPinScreenState();
}

class _SetupPinScreenState extends State<SetupPinScreen> {
  static const _pinHashKey = 'master_pin_hash';
  static const _aesKeyKey = 'aes_key';

  final _formKey = GlobalKey<FormState>();
  final _pinController = TextEditingController();
  final _confirmController = TextEditingController();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  bool _saving = false;

  @override
  // Bersihkan controller saat widget dilepas.
  void dispose() {
    _pinController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  // Simpan PIN baru dan AES key ke secure storage.
  Future<void> _savePin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_pinController.text != _confirmController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Konfirmasi PIN tidak sama')),
      );
      return;
    }

    setState(() => _saving = true);
    final pinHash = CryptoService.hashPin(_pinController.text);
    final aesKey = CryptoService.generateAesKey();

    await _storage.write(key: _pinHashKey, value: pinHash);
    await _storage.write(key: _aesKeyKey, value: aesKey);

    if (!mounted) {
      return;
    }
    setState(() => _saving = false);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  // Bangun form input PIN dan tombol simpan.
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Setup Master PIN')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _pinController,
                decoration: const InputDecoration(labelText: 'PIN (4-6 digit)'),
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
                decoration: const InputDecoration(labelText: 'Konfirmasi PIN'),
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
