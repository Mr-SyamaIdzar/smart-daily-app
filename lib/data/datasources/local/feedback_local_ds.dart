import 'package:sqflite/sqflite.dart';
import '../../models/feedback_model.dart';
import 'db_helper.dart';

abstract class FeedbackLocalDataSource {
  Future<int> insertFeedback(FeedbackModel feedback);
  Future<List<FeedbackModel>> getAllFeedbacks();
}

class FeedbackLocalDataSourceImpl implements FeedbackLocalDataSource {
  final DbHelper dbHelper;

  FeedbackLocalDataSourceImpl(this.dbHelper);

  @override
  Future<int> insertFeedback(FeedbackModel feedback) async {
    final db = await dbHelper.database;
    return await db.insert(DbHelper.tableFeedbacks, feedback.toMap());
  }

  @override
  Future<List<FeedbackModel>> getAllFeedbacks() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DbHelper.tableFeedbacks,
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => FeedbackModel.fromMap(map)).toList();
  }
}
