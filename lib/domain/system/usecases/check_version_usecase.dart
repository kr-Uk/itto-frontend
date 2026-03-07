import 'package:itto/domain/system/entities/version_info.dart';
import 'package:itto/domain/system/repositories/system_repository.dart';

class CheckVersionUseCase {
  final SystemRepository repository;

  CheckVersionUseCase({required this.repository});

  Future<VersionInfo> execute() => repository.checkVersion();
}
