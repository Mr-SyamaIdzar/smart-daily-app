import '../../repositories/auth_repository.dart';

/// Use case untuk logout user.
class LogoutUseCase {
  final AuthRepository _repository;

  const LogoutUseCase(this._repository);

  Future<void> call() async {
    await _repository.clearSession();
  }
}
