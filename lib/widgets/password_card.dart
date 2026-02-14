import 'package:flutter/material.dart'; // mengambil library Material UI

// Widget kartu untuk menampilkan data akun di list.
class PasswordCard extends StatelessWidget {
  const PasswordCard({
    super.key,
    required this.title,
    required this.username,
    required this.category,
    required this.onTap,
    required this.onCopyUsername,
    required this.onCopyPassword,
  }); // constructor untuk data dan aksi di kartu

  final String title;
  final String username;
  final String category;
  final VoidCallback onTap;
  final VoidCallback onCopyUsername;
  final VoidCallback onCopyPassword;

  @override
  // Susun tampilan kartu akun dengan tombol copy.
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        title: Text(title),
        subtitle: Text(username, maxLines: 1, overflow: TextOverflow.ellipsis),
        leading: CircleAvatar(child: Text(category[0])),
        onTap: onTap,
        trailing: Wrap(
          spacing: 8,
          children: [
            IconButton(
              icon: const Icon(Icons.person),
              onPressed: onCopyUsername,
              tooltip: 'Copy Username',
            ),
            IconButton(
              icon: const Icon(Icons.lock),
              onPressed: onCopyPassword,
              tooltip: 'Copy Password',
            ),
          ],
        ),
      ),
    );
  }
}
