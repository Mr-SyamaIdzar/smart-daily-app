import 'package:sqflite/sqflite.dart';

import '../../models/user_model.dart';
import 'db_helper.dart';

/// Data source untuk operasi CRUD user di SQLite.
/// Tidak tahu tentang domain entity atau business logic.
class UserLocalDataSource {
  final DbHelper _dbHelper;

  UserLocalDataSource(this._dbHelper);

  Future<Database> get _db => _dbHelper.database;

  /// Insert user baru, returns model dengan id yang digenerate.
  Future<UserModel> insertUser(UserModel user) async {
    final db = await _db;
    final id = await db.insert(
      DbHelper.tableUsers,
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.fail,
    );
    return UserModel(
      id: id,
      fullName: user.fullName,
      email: user.email,
      passwordHash: user.passwordHash,
      photoPath: user.photoPath,
      createdAt: user.createdAt,
    );
  }

  /// Ambil user berdasarkan email. Returns null jika tidak ditemukan.
  Future<UserModel?> getUserByEmail(String email) async {
    final db = await _db;
    final result = await db.query(
      DbHelper.tableUsers,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return UserModel.fromMap(result.first);
  }

  /// Ambil user berdasarkan id.
  Future<UserModel?> getUserById(int id) async {
    final db = await _db;
    final result = await db.query(
      DbHelper.tableUsers,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return UserModel.fromMap(result.first);
  }

  /// Cek apakah email sudah ada di database.
  Future<bool> emailExists(String email) async {
    final db = await _db;
    final result = await db.query(
      DbHelper.tableUsers,
      columns: ['id'],
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  /// Update data user.
  Future<void> updateUser(UserModel user) async {
    final db = await _db;
    await db.update(
      DbHelper.tableUsers,
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  /// Hapus user dari database.
  Future<void> deleteUser(int id) async {
    final db = await _db;
    await db.delete(
      DbHelper.tableUsers,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Update path foto profil user.
  Future<void> updateProfilePhoto(int id, String photoPath) async {
    final db = await _db;
    await db.update(
      DbHelper.tableUsers,
      {'photo_path': photoPath},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
