import 'package:flutter/material.dart';
import '../../../data/datasources/local/feedback_local_ds.dart';
import '../../../data/models/feedback_model.dart';
import '../../../domain/entities/feedback_entity.dart';

class FeedbackProvider extends ChangeNotifier {
  final FeedbackLocalDataSource localDataSource;

  List<FeedbackEntity> _feedbacks = [];
  bool _isLoading = false;

  FeedbackProvider({required this.localDataSource});

  List<FeedbackEntity> get feedbacks => _feedbacks;
  bool get isLoading => _isLoading;

  Future<void> loadFeedbacks() async {
    _isLoading = true;
    notifyListeners();

    try {
      _feedbacks = await localDataSource.getAllFeedbacks();
    } catch (e) {
      debugPrint('Error loading feedbacks: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addFeedback(String kesan, String pesan) async {
    final feedback = FeedbackModel(
      kesan: kesan,
      pesan: pesan,
      createdAt: DateTime.now(),
    );

    try {
      await localDataSource.insertFeedback(feedback);
      await loadFeedbacks(); // Refresh the list
    } catch (e) {
      debugPrint('Error adding feedback: $e');
      rethrow;
    }
  }
}
