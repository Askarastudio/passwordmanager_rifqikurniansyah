import 'dart:async'; // timer untuk lockout

import 'package:flutter/material.dart'; // mengambil library Material UI
import 'package:flutter/services.dart'; // input formatter
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // akses secure storage

import '../core/crypto.dart'; // hash PIN
import '../core/validators.dart'; // validasi input
import '../widgets/footer_text.dart'; // footer identitas
import 'home_screen.dart'; // navigasi setelah login

// Layar login untuk memasukkan PIN.
class LoginPinScreen extends StatefulWidget {
  const LoginPinScreen({super.key});

  @override
  // Buat state untuk form login PIN.
  State<LoginPinScreen> createState() => _LoginPinScreenState();
}

class _LoginPinScreenState extends State<LoginPinScreen> {
  static const _pinHashKey = 'master_pin_hash';

  final _formKey = GlobalKey<FormState>();
  final _pinController = TextEditingController();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  int _failCount = 0;
  DateTime? _lockUntil;
  Timer? _timer;
  bool _checking = false;

  bool get _isLocked => _lockUntil != null && DateTime.now().isBefore(_lockUntil!);

  @override
  // Bersihkan timer dan controller saat widget dilepas.
  void dispose() {
    _timer?.cancel();
    _pinController.dispose();
    super.dispose();
  }

  // Validasi PIN dan terapkan lockout jika salah berulang.
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_isLocked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Terlalu banyak percobaan. Tunggu sebentar.')),
      );
      return;
    }

    setState(() => _checking = true);
    final storedHash = await _storage.read(key: _pinHashKey);
    final inputHash = CryptoService.hashPin(_pinController.text);

    if (storedHash != null && storedHash == inputHash) {
      if (!mounted) {
        return;
      }
      setState(() => _checking = false);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
      return;
    }

    _failCount += 1;
    if (_failCount >= 3) {
      _lockUntil = DateTime.now().add(const Duration(seconds: 30));
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!_isLocked) {
          _timer?.cancel();
          setState(() {});
        } else {
          setState(() {});
        }
      });
    }

    if (!mounted) {
      return;
    }
    setState(() => _checking = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('PIN salah')),
    );
  }

  @override
  // Bangun form input PIN dan tombol masuk.
  Widget build(BuildContext context) {
    final lockRemaining = _isLocked
        ? _lockUntil!.difference(DateTime.now()).inSeconds
        : 0;

    return Scaffold(
      appBar: AppBar(title: const Text('Masuk')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _pinController,
                decoration: const InputDecoration(labelText: 'PIN'),
                keyboardType: TextInputType.number,
                obscureText: true,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                validator: validatePin,
              ),
              const SizedBox(height: 20),
              if (_isLocked)
                Text('Coba lagi dalam $lockRemaining detik'),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _checking ? null : _login,
                  child: _checking
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Masuk'),
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
