import 'package:flutter/foundation.dart';
import 'package:itto/core/network/api_exception.dart';
import 'package:itto/domain/common/entities/hobby.dart';
import 'package:itto/domain/profile/entities/my_profile.dart';
import 'package:itto/domain/profile/entities/other_profile.dart';
import 'package:itto/domain/profile/repositories/profile_repository.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileRepository _repository;

  MyProfile? _myProfile;
  OtherProfile? _otherProfile;
  List<Hobby> _allHobbies = [];
  bool _isLoading = false;
  String? _error;

  ProfileProvider({required ProfileRepository repository})
      : _repository = repository;

  MyProfile? get myProfile => _myProfile;
  OtherProfile? get otherProfile => _otherProfile;
  List<Hobby> get allHobbies => _allHobbies;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadMyProfile() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _myProfile = await _repository.getMyProfile();
    } on ApiException catch (e) {
      _error = e.userMessage;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAllHobbies() async {
    try {
      _allHobbies = await _repository.getHobbies();
      notifyListeners();
    } on ApiException catch (e) {
      _error = e.userMessage;
      notifyListeners();
    }
  }

  Future<bool> updateProfile({
    String? nickname,
    List<int>? hobbyIds,
    String? introduction,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _repository.updateProfile(
        nickname: nickname,
        hobbyIds: hobbyIds,
        introduction: introduction,
      );
      await loadMyProfile();
      return true;
    } on ApiException catch (e) {
      _error = e.userMessage;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updatePhotos({
    List<String>? newPhotoPaths,
    List<int>? existingPhotoIds,
    required int representativeIndex,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _repository.updatePhotos(
        newPhotoPaths: newPhotoPaths,
        existingPhotoIds: existingPhotoIds,
        representativeIndex: representativeIndex,
      );
      await loadMyProfile();
      return true;
    } on ApiException catch (e) {
      _error = e.userMessage;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deletePhoto(int photoId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _repository.deletePhoto(photoId);
      await loadMyProfile();
      return true;
    } on ApiException catch (e) {
      _error = e.userMessage;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadOtherProfile(int userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _otherProfile = await _repository.getOtherProfile(userId);
    } on ApiException catch (e) {
      _error = e.userMessage;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> reverify(String filePath) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _repository.reverify(filePath);
      await loadMyProfile();
      return true;
    } on ApiException catch (e) {
      _error = e.userMessage;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearOtherProfile() {
    _otherProfile = null;
    notifyListeners();
  }
}
