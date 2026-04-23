import '../../entities/user_entity.dart';
import '../../repositories/auth_repository.dart';

/// Use case untuk proses registrasi user baru.
class RegisterUseCase {
  final AuthRepository _repository;

  const RegisterUseCase(this._repository);

  Future<UserEntity> call({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final trimmedEmail = email.trim().toLowerCase();

    final emailExists = await _repository.isEmailRegistered(trimmedEmail);
    if (emailExists) {
      throw Exception('Email sudah terdaftar. Gunakan email lain.');
    }

    return _repository.register(
      fullName: fullName.trim(),
      email: trimmedEmail,
      password: password,
    );
  }
}
