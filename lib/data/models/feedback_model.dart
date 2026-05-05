import '../../domain/entities/feedback_entity.dart';

class FeedbackModel extends FeedbackEntity {
  const FeedbackModel({
    super.id,
    required super.kesan,
    required super.pesan,
    required super.createdAt,
  });

  factory FeedbackModel.fromMap(Map<String, dynamic> map) {
    return FeedbackModel(
      id: map['id'] as int?,
      kesan: map['kesan'] as String,
      pesan: map['pesan'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'kesan': kesan,
      'pesan': pesan,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory FeedbackModel.fromEntity(FeedbackEntity entity) {
    return FeedbackModel(
      id: entity.id,
      kesan: entity.kesan,
      pesan: entity.pesan,
      createdAt: entity.createdAt,
    );
  }
}
