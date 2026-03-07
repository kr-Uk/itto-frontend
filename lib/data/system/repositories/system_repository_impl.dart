import 'package:itto/domain/common/entities/hobby.dart';
import 'package:itto/domain/system/entities/nickname_validation.dart';
import 'package:itto/domain/system/entities/version_info.dart';
import 'package:itto/domain/system/repositories/system_repository.dart';
import 'package:itto/data/system/datasources/system_remote_datasource.dart';

class SystemRepositoryImpl implements SystemRepository {
  final SystemRemoteDataSource remoteDataSource;

  SystemRepositoryImpl({required this.remoteDataSource});

  @override
  Future<VersionInfo> checkVersion() async {
    final model = await remoteDataSource.checkVersion();
    return model.toEntity();
  }

  @override
  Future<List<Hobby>> getHobbies() async {
    final models = await remoteDataSource.getHobbies();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<NicknameValidation> validateNickname(String nickname) async {
    final model = await remoteDataSource.validateNickname(nickname);
    return model.toEntity();
  }
}
