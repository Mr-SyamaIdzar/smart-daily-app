import 'package:sqflite/sqflite.dart';
import '../../models/note_model.dart';
import 'db_helper.dart';

abstract class NotesLocalDataSource {
  Future<List<NoteModel>> getNotes(int userId);
  Future<List<NoteModel>> searchNotes(int userId, String query);
  Future<NoteModel> addNote(NoteModel note);
  Future<void> updateNote(NoteModel note);
  Future<void> deleteNote(int id);
  Future<void> insertDummyDataIfNeeded(int userId);
}

class NotesLocalDataSourceImpl implements NotesLocalDataSource {
  final DbHelper dbHelper;

  NotesLocalDataSourceImpl(this.dbHelper);

  @override
  Future<List<NoteModel>> getNotes(int userId) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DbHelper.tableNotes,
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'updated_at DESC',
    );

    return maps.map((e) => NoteModel.fromMap(e)).toList();
  }

  @override
  Future<List<NoteModel>> searchNotes(int userId, String query) async {
    final db = await dbHelper.database;
    final String searchPattern = '%$query%';
    final List<Map<String, dynamic>> maps = await db.query(
      DbHelper.tableNotes,
      where: 'user_id = ? AND (title LIKE ? OR content LIKE ?)',
      whereArgs: [userId, searchPattern, searchPattern],
      orderBy: 'updated_at DESC',
    );

    return maps.map((e) => NoteModel.fromMap(e)).toList();
  }

  @override
  Future<NoteModel> addNote(NoteModel note) async {
    final db = await dbHelper.database;
    final id = await db.insert(
      DbHelper.tableNotes,
      note.toMap()..remove('id'), // Ensure SQLite auto-generates ID if it's null
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return NoteModel(
      id: id,
      userId: note.userId,
      title: note.title,
      content: note.content,
      createdAt: note.createdAt,
      updatedAt: note.updatedAt,
    );
  }

  @override
  Future<void> updateNote(NoteModel note) async {
    final db = await dbHelper.database;
    await db.update(
      DbHelper.tableNotes,
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  @override
  Future<void> deleteNote(int id) async {
    final db = await dbHelper.database;
    await db.delete(
      DbHelper.tableNotes,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> insertDummyDataIfNeeded(int userId) async {
    final db = await dbHelper.database;
    final count = Sqflite.firstIntValue(await db.rawQuery(
      'SELECT COUNT(*) FROM ${DbHelper.tableNotes} WHERE user_id = ?',
      [userId],
    ));

    if (count == 0) {
      final now = DateTime.now();
      await addNote(NoteModel(
        userId: userId,
        title: 'Catatan Pertamaku',
        content: 'Halo! Ini adalah catatan pertamamu. Anda bisa mengedit atau menghapusnya kapan saja.',
        createdAt: now.subtract(const Duration(minutes: 10)),
        updatedAt: now.subtract(const Duration(minutes: 10)),
      ));
      
      await addNote(NoteModel(
        userId: userId,
        title: 'Ide Aplikasi Flutter',
        content: '- Fitur To-Do List\n- Fitur Habit Tracker\n- UI/UX minimalis\n- Manajemen memori SQLite',
        createdAt: now.subtract(const Duration(minutes: 5)),
        updatedAt: now.subtract(const Duration(minutes: 5)),
      ));
    }
  }
}
