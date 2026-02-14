import 'package:flutter/material.dart'; // mengambil library Material UI
import 'package:flutter/services.dart'; // clipboard
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // akses secure storage

import '../core/crypto.dart'; // dekripsi password
import '../data/password_repository.dart'; // akses data SQLite
import '../models/password_item.dart'; // model data
import '../widgets/footer_text.dart'; // footer identitas
import 'add_edit_screen.dart'; // layar edit akun
import 'change_pin_screen.dart'; // layar ubah PIN

// Layar detail untuk melihat akun lengkap.
class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key, required this.item});

  final PasswordItem item;

  @override
  // Buat state untuk detail akun.
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  static const _aesKeyKey = 'aes_key';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final PasswordRepository _repo = PasswordRepository();

  bool _showPassword = false;
  String _plainPassword = '';

  @override
  // Load password terdekripsi saat layar tampil.
  void initState() {
    super.initState();
    _loadPassword();
  }

  // Dekripsi password hanya untuk ditampilkan.
  Future<void> _loadPassword() async {
    final key = await _storage.read(key: _aesKeyKey);
    if (key == null) {
      return;
    }
    final plain = CryptoService.decryptText(widget.item.passwordEnc, key);
    if (!mounted) {
      return;
    }
    setState(() => _plainPassword = plain);
  }

  // Hapus akun dari database.
  Future<void> _delete() async {
    if (widget.item.id == null) {
      return;
    }
    await _repo.delete(widget.item.id!);
    if (!mounted) {
      return;
    }
    Navigator.of(context).pop(true);
  }

  @override
  // Bangun UI detail, copy, edit, delete, dan ubah PIN.
  Widget build(BuildContext context) {
    final item = widget.item;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Akun'),
        actions: [
          IconButton(
            icon: const Icon(Icons.lock_reset),
            onPressed: () async {
              await Navigator.of(context).push<bool>(
                MaterialPageRoute(builder: (_) => const ChangePinScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final updated = await Navigator.of(context).push<bool>(
                MaterialPageRoute(builder: (_) => AddEditScreen(item: item)),
              );
              if (updated == true && mounted) {
                Navigator.of(context).pop(true);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _delete,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.title,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                ),
                if (item.category != null)
                  Chip(label: Text(item.category!)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: Text(item.username)),
                IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: item.username));
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(_showPassword ? _plainPassword : '••••••'),
                ),
                IconButton(
                  icon: Icon(_showPassword ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _showPassword = !_showPassword),
                ),
                IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: _plainPassword));
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (item.notes != null && item.notes!.isNotEmpty)
              Text(item.notes!),
            const SizedBox(height: 12),
            if (item.createdAt != null)
              Text('Dibuat: ${item.createdAt}'),
            if (item.updatedAt != null)
              Text('Diubah: ${item.updatedAt}'),
            const Spacer(),
            const FooterText(),
          ],
        ),
      ),
    );
  }
}
