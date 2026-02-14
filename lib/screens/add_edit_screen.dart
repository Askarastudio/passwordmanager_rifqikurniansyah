import 'package:flutter/material.dart'; // mengambil library Material UI
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // akses secure storage

import '../core/crypto.dart'; // enkripsi/dekripsi
import '../core/password_generator.dart'; // generator password
import '../core/validators.dart'; // validasi input
import '../data/password_repository.dart'; // akses data SQLite
import '../models/password_item.dart'; // model data
import '../widgets/footer_text.dart'; // footer identitas
import '../widgets/secure_text_field.dart'; // field password dengan toggle

// Layar tambah atau edit akun.
class AddEditScreen extends StatefulWidget {
  const AddEditScreen({super.key, this.item});

  final PasswordItem? item;

  @override
  // Buat state untuk form tambah/edit.
  State<AddEditScreen> createState() => _AddEditScreenState();
}

class _AddEditScreenState extends State<AddEditScreen> {
  static const _aesKeyKey = 'aes_key';

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _notesController = TextEditingController();

  final PasswordRepository _repo = PasswordRepository();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  String? _category;
  int _length = 12;
  bool _upper = true;
  bool _numbers = true;
  bool _symbols = true;
  bool _saving = false;

  final List<String> _categories = const [
    'Sosial',
    'Email',
    'Bank',
    'Kerja',
    'Lainnya',
  ];

  @override
  // Isi form jika mode edit.
  void initState() {
    super.initState();
    final item = widget.item;
    if (item != null) {
      _titleController.text = item.title;
      _usernameController.text = item.username;
      _notesController.text = item.notes ?? '';
      _category = item.category;
      _loadPassword();
    }
  }

  // Dekripsi password untuk mode edit.
  Future<void> _loadPassword() async {
    final item = widget.item;
    if (item == null) {
      return;
    }
    final aesKey = await _storage.read(key: _aesKeyKey);
    if (aesKey == null) {
      return;
    }
    final plain = CryptoService.decryptText(item.passwordEnc, aesKey);
    if (!mounted) {
      return;
    }
    setState(() => _passwordController.text = plain);
  }

  @override
  // Bersihkan controller saat widget dilepas.
  void dispose() {
    _titleController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // Enkripsi password dan simpan ke database.
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _saving = true);
    final aesKey = await _storage.read(key: _aesKeyKey);
    if (aesKey == null) {
      setState(() => _saving = false);
      return;
    }

    final now = DateTime.now().toIso8601String();
    final passwordEnc = CryptoService.encryptText(_passwordController.text, aesKey);

    final item = PasswordItem(
      id: widget.item?.id,
      title: _titleController.text.trim(),
      username: _usernameController.text.trim(),
      passwordEnc: passwordEnc,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      category: _category,
      createdAt: widget.item?.createdAt ?? now,
      updatedAt: now,
    );

    if (widget.item == null) {
      await _repo.insert(item);
    } else {
      await _repo.update(item);
    }

    if (!mounted) {
      return;
    }
    setState(() => _saving = false);
    Navigator.of(context).pop(true);
  }

  // Buat password acak sesuai opsi.
  void _generatePassword() {
    final value = PasswordGenerator.generate(
      length: _length,
      upper: _upper,
      numbers: _numbers,
      symbols: _symbols,
    );
    setState(() => _passwordController.text = value);
  }

  @override
  // Bangun UI form input akun.
  Widget build(BuildContext context) {
    final isEdit = widget.item != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Akun' : 'Tambah Akun')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Judul/Akun'),
                validator: (value) => validateRequired(value, 'Judul'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Username/Email'),
                validator: (value) => validateRequired(value, 'Username'),
              ),
              const SizedBox(height: 12),
              SecureTextField(
                controller: _passwordController,
                label: 'Password',
                validator: (value) => validateRequired(value, 'Password'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: 'Catatan (opsional)'),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _category,
                decoration: const InputDecoration(labelText: 'Kategori'),
                items: _categories
                    .map((value) => DropdownMenuItem(value: value, child: Text(value)))
                    .toList(),
                onChanged: (value) => setState(() => _category = value),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Text('Panjang'),
                  Expanded(
                    child: Slider(
                      min: 8,
                      max: 20,
                      divisions: 12,
                      value: _length.toDouble(),
                      label: _length.toString(),
                      onChanged: (value) => setState(() => _length = value.toInt()),
                    ),
                  ),
                ],
              ),
              SwitchListTile(
                title: const Text('Huruf besar'),
                value: _upper,
                onChanged: (value) => setState(() => _upper = value),
              ),
              SwitchListTile(
                title: const Text('Angka'),
                value: _numbers,
                onChanged: (value) => setState(() => _numbers = value),
              ),
              SwitchListTile(
                title: const Text('Simbol'),
                value: _symbols,
                onChanged: (value) => setState(() => _symbols = value),
              ),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _generatePassword,
                  child: const Text('Generate Password'),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Simpan'),
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
