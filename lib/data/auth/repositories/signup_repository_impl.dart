import 'package:itto/domain/common/entities/hobby.dart';
import 'package:itto/domain/common/entities/photo.dart';
import 'package:itto/domain/auth/repositories/signup_repository.dart';
import 'package:itto/data/auth/datasources/signup_remote_datasource.dart';
import 'package:itto/data/auth/models/signup_request_models.dart';

class SignupRepositoryImpl implements SignupRepository {
  final SignupRemoteDataSource remoteDataSource;

  SignupRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Hobby>> getHobbies() async {
    final models = await remoteDataSource.getHobbies();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> saveTerms({
    required bool serviceTerms,
    required bool privacyPolicy,
    required bool locationTerms,
    bool marketingConsent = false,
  }) {
    final model = SignupTermsRequestModel(
      serviceTerms: serviceTerms,
      privacyPolicy: privacyPolicy,
      locationTerms: locationTerms,
      marketingConsent: marketingConsent,
    );
    return remoteDataSource.saveTerms(model.toJson());
  }

  @override
  Future<void> saveProfile({
    required String nickname,
    required String gender,
    required String birthDate,
    required List<int> hobbyIds,
    String? introduction,
  }) {
    final model = SignupProfileRequestModel(
      nickname: nickname,
      gender: gender,
      birthDate: birthDate,
      hobbyIds: hobbyIds,
      introduction: introduction,
    );
    return remoteDataSource.saveProfile(model.toJson());
  }

  @override
  Future<List<Photo>> uploadPhotos({
    required List<String> filePaths,
    required int representativeIndex,
  }) async {
    final models = await remoteDataSource.uploadPhotos(
      filePaths: filePaths,
      representativeIndex: representativeIndex,
    );
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> complete() => remoteDataSource.complete();
}
