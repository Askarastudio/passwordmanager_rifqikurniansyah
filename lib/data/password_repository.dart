import '../models/password_item.dart'; // model data password
import 'db_helper.dart'; // akses database

// Repository CRUD untuk password_items.
class PasswordRepository {
  // Ambil semua data tersimpan.
  Future<List<PasswordItem>> getAll() async {
    final db = await DbHelper.instance.database;
    final rows = await db.query('password_items', orderBy: 'updated_at DESC');
    return rows.map(PasswordItem.fromMap).toList();
  }

  // Simpan data baru.
  Future<int> insert(PasswordItem item) async {
    final db = await DbHelper.instance.database;
    return db.insert('password_items', item.toMap());
  }

  // Update data berdasarkan id.
  Future<int> update(PasswordItem item) async {
    final db = await DbHelper.instance.database;
    return db.update(
      'password_items',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  // Hapus data berdasarkan id.
  Future<int> delete(int id) async {
    final db = await DbHelper.instance.database;
    return db.delete('password_items', where: 'id = ?', whereArgs: [id]);
  }
}
