/// Entity User — representasi murni di domain layer.
/// Tidak boleh bergantung pada framework apapun.
class UserEntity {
  final int? id;
  final String fullName;
  final String email;
  final String? photoPath;
  final DateTime createdAt;

  const UserEntity({
    this.id,
    required this.fullName,
    required this.email,
    this.photoPath,
    required this.createdAt,
  });

  UserEntity copyWith({
    int? id,
    String? fullName,
    String? email,
    String? photoPath,
    DateTime? createdAt,
  }) {
    return UserEntity(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      photoPath: photoPath ?? this.photoPath,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserEntity && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'UserEntity(id: $id, fullName: $fullName, email: $email)';
}
