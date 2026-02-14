// Model data untuk tabel password_items.
class PasswordItem {
  final int? id;
  final String title;
  final String username;
  final String passwordEnc;
  final String? notes;
  final String? category;
  final String? createdAt;
  final String? updatedAt;

  // Constructor untuk membuat item data.
  const PasswordItem({
    this.id,
    required this.title,
    required this.username,
    required this.passwordEnc,
    this.notes,
    this.category,
    this.createdAt,
    this.updatedAt,
  });

  // Membuat salinan object dengan beberapa field berubah.
  PasswordItem copyWith({
    int? id,
    String? title,
    String? username,
    String? passwordEnc,
    String? notes,
    String? category,
    String? createdAt,
    String? updatedAt,
  }) {
    return PasswordItem(
      id: id ?? this.id,
      title: title ?? this.title,
      username: username ?? this.username,
      passwordEnc: passwordEnc ?? this.passwordEnc,
      notes: notes ?? this.notes,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Konversi object ke map untuk SQLite.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'username': username,
      'password_enc': passwordEnc,
      'notes': notes,
      'category': category,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  // Membuat object dari map SQLite.
  factory PasswordItem.fromMap(Map<String, dynamic> map) {
    return PasswordItem(
      id: map['id'] as int?,
      title: map['title'] as String,
      username: map['username'] as String,
      passwordEnc: map['password_enc'] as String,
      notes: map['notes'] as String?,
      category: map['category'] as String?,
      createdAt: map['created_at'] as String?,
      updatedAt: map['updated_at'] as String?,
    );
  }
}
