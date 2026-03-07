import 'package:itto/domain/auth/repositories/auth_repository.dart';

class LogoutUseCase {
  final AuthRepository repository;

  LogoutUseCase({required this.repository});

  Future<void> execute() => repository.logout();
}
