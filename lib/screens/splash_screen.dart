import 'package:flutter/material.dart'; // mengambil library Material UI
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // akses secure storage

import 'login_pin_screen.dart'; // navigasi ke layar login PIN
import 'setup_pin_screen.dart'; // navigasi ke layar setup PIN
import '../widgets/footer_text.dart'; // footer identitas

// Layar awal untuk cek PIN tersimpan.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  // Buat state untuk proses bootstrap.
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const _pinHashKey = 'master_pin_hash';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  @override
  // Jalankan cek PIN saat layar pertama tampil.
  void initState() {
    super.initState();
    _bootstrap();
  }

  // Cek PIN di storage lalu arahkan ke layar yang sesuai.
  Future<void> _bootstrap() async {
    final pinHash = await _storage.read(key: _pinHashKey);
    if (!mounted) {
      return;
    }
    final route = pinHash == null ? const SetupPinScreen() : const LoginPinScreen();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => route),
    );
  }

  @override
  // Tampilkan logo dan indikator loading.
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock, size: 56),
            SizedBox(height: 16),
            Text('SafeManager', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
            SizedBox(height: 16),
            CircularProgressIndicator(),
            SizedBox(height: 20),
            FooterText(),
          ],
        ),
      ),
    );
  }
}
