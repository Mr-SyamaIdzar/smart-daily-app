import '../../domain/entities/user_entity.dart';

/// Model untuk mapping data User dari/ke SQLite.
///
/// Perbedaan dengan Entity:
/// - Model: data layer, tahu format database (Map)
/// - Entity: domain layer, pure Dart object
class UserModel {
  final int? id;
  final String fullName;
  final String email;
  final String passwordHash;
  final String? photoPath;
  final String createdAt;

  const UserModel({
    this.id,
    required this.fullName,
    required this.email,
    required this.passwordHash,
    this.photoPath,
    required this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as int?,
      fullName: map['full_name'] as String,
      email: map['email'] as String,
      passwordHash: map['password_hash'] as String,
      photoPath: map['photo_path'] as String?,
      createdAt: map['created_at'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'full_name': fullName,
      'email': email,
      'password_hash': passwordHash,
      'photo_path': photoPath,
      'created_at': createdAt,
    };
  }

  /// Konversi ke Domain Entity (tanpa passwordHash).
  UserEntity toEntity() {
    return UserEntity(
      id: id,
      fullName: fullName,
      email: email,
      photoPath: photoPath,
      createdAt: DateTime.parse(createdAt),
    );
  }

  factory UserModel.fromEntity(UserEntity entity,
      {required String passwordHash}) {
    return UserModel(
      id: entity.id,
      fullName: entity.fullName,
      email: entity.email,
      passwordHash: passwordHash,
      photoPath: entity.photoPath,
      createdAt: entity.createdAt.toIso8601String(),
    );
  }

  @override
  String toString() => 'UserModel(id: $id, email: $email)';
}
