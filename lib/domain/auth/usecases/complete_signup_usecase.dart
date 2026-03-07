import 'package:itto/domain/auth/repositories/signup_repository.dart';

class CompleteSignupUseCase {
  final SignupRepository repository;

  CompleteSignupUseCase({required this.repository});

  Future<void> execute() => repository.complete();
}
