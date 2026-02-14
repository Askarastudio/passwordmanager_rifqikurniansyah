import 'package:flutter/material.dart'; // mengambil library Material UI

// Footer identitas pembuat aplikasi.
class FooterText extends StatelessWidget {
  const FooterText({super.key});

  @override
  // Tampilkan teks footer di bawah layar.
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 12),
      child: Text(
        'Create By Rifqi Kurniansyah | 220101010105',
        style: TextStyle(fontSize: 12, color: Colors.black54),
        textAlign: TextAlign.center,
      ),
    );
  }
}
