import 'package:flutter/foundation.dart';
import '../../../core/network/api_exception.dart';
import '../models/profile_models.dart';
import '../services/profile_service.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileService _profileService;

  MyProfile? _myProfile;
  OtherProfile? _otherProfile;
  bool _isLoading = false;
  String? _error;

  ProfileProvider({required ProfileService profileService})
    : _profileService = profileService;

  MyProfile? get myProfile => _myProfile;
  OtherProfile? get otherProfile => _otherProfile;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadMyProfile() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _myProfile = await _profileService.getMyProfile();
    } on ApiException catch (e) {
      _error = e.userMessage;
    } finally {
      _isLoading = false;
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
      await _profileService.updateProfile(
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
      await _profileService.updatePhotos(
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
      await _profileService.deletePhoto(photoId);
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
      _otherProfile = await _profileService.getOtherProfile(userId);
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
      await _profileService.reverify(filePath);
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
