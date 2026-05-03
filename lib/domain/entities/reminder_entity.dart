/// Entity untuk data Reminder di domain layer.
/// Tidak bergantung pada framework atau library apapun.
class ReminderEntity {
  final int? id;
  final int userId;
  final String title;
  final String description;
  final DateTime dateTime;
  final bool isActive;

  const ReminderEntity({
    this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.dateTime,
    this.isActive = true,
  });

  ReminderEntity copyWith({
    int? id,
    int? userId,
    String? title,
    String? description,
    DateTime? dateTime,
    bool? isActive,
  }) {
    return ReminderEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      dateTime: dateTime ?? this.dateTime,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  String toString() =>
      'ReminderEntity(id: $id, title: $title, dateTime: $dateTime, isActive: $isActive)';
}
