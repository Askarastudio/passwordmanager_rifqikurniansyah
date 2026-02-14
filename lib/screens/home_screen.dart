import 'package:flutter/material.dart'; // mengambil library Material UI
import 'package:flutter/services.dart'; // clipboard
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // akses secure storage

import '../core/crypto.dart'; // dekripsi password
import '../data/password_repository.dart'; // akses data SQLite
import '../models/password_item.dart'; // model data
import '../widgets/footer_text.dart'; // footer identitas
import '../widgets/password_card.dart'; // kartu list item
import 'add_edit_screen.dart'; // layar tambah/edit
import 'detail_screen.dart'; // layar detail

// Dashboard utama menampilkan daftar akun.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  // Buat state untuk dashboard.
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _aesKeyKey = 'aes_key';

  final PasswordRepository _repo = PasswordRepository();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final TextEditingController _searchController = TextEditingController();

  List<PasswordItem> _items = [];
  String _category = 'All';
  bool _loading = true;

  final List<String> _categories = const [
    'All',
    'Sosial',
    'Email',
    'Bank',
    'Kerja',
    'Lainnya',
  ];

  @override
  // Load data saat pertama kali tampil.
  void initState() {
    super.initState();
    _loadItems();
  }

  @override
  // Bersihkan controller saat widget dilepas.
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Ambil data akun dari database.
  Future<void> _loadItems() async {
    setState(() => _loading = true);
    final items = await _repo.getAll();
    if (!mounted) {
      return;
    }
    setState(() {
      _items = items;
      _loading = false;
    });
  }

  // Filter data berdasarkan kategori dan pencarian.
  List<PasswordItem> get _filteredItems {
    final query = _searchController.text.trim().toLowerCase();
    return _items.where((item) {
      final matchesCategory = _category == 'All' || item.category == _category;
      final matchesQuery = query.isEmpty ||
          item.title.toLowerCase().contains(query) ||
          item.username.toLowerCase().contains(query);
      return matchesCategory && matchesQuery;
    }).toList();
  }

  // Dekripsi password saat akan dicopy.
  Future<void> _copyPassword(PasswordItem item) async {
    final aesKey = await _storage.read(key: _aesKeyKey);
    if (aesKey == null) {
      return;
    }
    final plain = CryptoService.decryptText(item.passwordEnc, aesKey);
    await Clipboard.setData(ClipboardData(text: plain));
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password disalin')),
    );
  }

  @override
  // Bangun UI dashboard, search, filter, dan list.
  Widget build(BuildContext context) {
    final items = _filteredItems;

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard Password')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Cari judul atau username',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _category,
              decoration: const InputDecoration(labelText: 'Kategori'),
              items: _categories
                  .map((value) => DropdownMenuItem(value: value, child: Text(value)))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _category = value);
                }
              },
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : items.isEmpty
                      ? const Center(child: Text('Belum ada data, klik + untuk menambah'))
                      : ListView.builder(
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final item = items[index];
                            return PasswordCard(
                              title: item.title,
                              username: item.username,
                              category: item.category ?? 'Lainnya',
                              onTap: () async {
                                await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => DetailScreen(item: item),
                                  ),
                                );
                                _loadItems();
                              },
                              onCopyUsername: () async {
                                await Clipboard.setData(ClipboardData(text: item.username));
                                if (!mounted) {
                                  return;
                                }
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Username disalin')),
                                );
                              },
                              onCopyPassword: () => _copyPassword(item),
                            );
                          },
                        ),
            ),
            const SizedBox(height: 8),
            const FooterText(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final saved = await Navigator.of(context).push<bool>(
            MaterialPageRoute(builder: (_) => const AddEditScreen()),
          );
          if (saved == true) {
            _loadItems();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
