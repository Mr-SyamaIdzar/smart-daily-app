import '../../entities/user_entity.dart';
import '../../repositories/auth_repository.dart';

/// Use case untuk proses login.
/// Single responsibility: hanya menangani logic login.
class LoginUseCase {
  final AuthRepository _repository;

  const LoginUseCase(this._repository);

  Future<UserEntity> call({
    required String email,
    required String password,
  }) async {
    final trimmedEmail = email.trim().toLowerCase();
    final user = await _repository.login(
      email: trimmedEmail,
      password: password,
    );
    await _repository.saveSession(user);
    return user;
  }
}
