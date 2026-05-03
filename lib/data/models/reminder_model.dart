import '../../domain/entities/reminder_entity.dart';

/// Model data untuk Reminder — mapping antara SQLite row dan domain entity.
class ReminderModel extends ReminderEntity {
  const ReminderModel({
    super.id,
    required super.userId,
    required super.title,
    required super.description,
    required super.dateTime,
    super.isActive,
  });

  /// Buat ReminderModel dari Map SQLite row.
  factory ReminderModel.fromMap(Map<String, dynamic> map) {
    return ReminderModel(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      title: map['title'] as String,
      description: map['description'] as String,
      dateTime: DateTime.parse(map['datetime'] as String),
      isActive: (map['is_active'] as int) == 1,
    );
  }

  /// Konversi ke Map untuk SQLite insert/update.
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'datetime': dateTime.toIso8601String(),
      'is_active': isActive ? 1 : 0,
    };
  }

  /// Buat ReminderModel dari ReminderEntity.
  factory ReminderModel.fromEntity(ReminderEntity entity) {
    return ReminderModel(
      id: entity.id,
      userId: entity.userId,
      title: entity.title,
      description: entity.description,
      dateTime: entity.dateTime,
      isActive: entity.isActive,
    );
  }
}
