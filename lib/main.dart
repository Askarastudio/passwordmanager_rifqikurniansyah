import 'package:flutter/material.dart'; // mengambil library Material UI

import 'screens/splash_screen.dart'; // layar awal aplikasi

// Entry point aplikasi.
void main() {
  // Pastikan binding Flutter siap sebelum runApp.
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SafeManagerApp());
}

// Widget root aplikasi.
class SafeManagerApp extends StatelessWidget {
  const SafeManagerApp({super.key});

  @override
  // Konfigurasi tema dan halaman awal.
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SafeManager',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
