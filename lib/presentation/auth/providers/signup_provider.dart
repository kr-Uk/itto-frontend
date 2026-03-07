import 'package:flutter/foundation.dart';
import 'package:itto/core/network/api_exception.dart';
import 'package:itto/domain/common/entities/hobby.dart';
import 'package:itto/domain/auth/repositories/signup_repository.dart';

class SignupProvider extends ChangeNotifier {
  final SignupRepository _repository;

  bool _isLoading = false;
  String? _error;

  // Hobby list from API
  List<Hobby> _hobbies = [];
  List<Hobby> get hobbies => _hobbies;

  // Identity verification result (from NICE)
  bool _identityVerified = false;
  String? _verifiedName;
  String? _verifiedPhone;
  String? _verifiedGender;
  String? _verifiedBirthDate;

  bool get identityVerified => _identityVerified;
  String? get verifiedName => _verifiedName;
  String? get verifiedPhone => _verifiedPhone;
  String? get verifiedGender => _verifiedGender;
  String? get verifiedBirthDate => _verifiedBirthDate;

  // Form data collected across steps
  static const int maxPhotos = 1;

  String nickname = '';
  String gender = '';
  String birthDate = '';
  List<int> hobbyIds = [];
  String introduction = '';
  List<String> photoFilePaths = [];
  int representativePhotoIndex = 0;
  bool marketingConsent = false;

  SignupProvider({required SignupRepository repository})
    : _repository = repository;

  bool get isLoading => _isLoading;
  String? get error => _error;

  void addPhoto(String filePath) {
    if (photoFilePaths.length >= maxPhotos) return;
    photoFilePaths.add(filePath);
    if (photoFilePaths.length == 1) {
      representativePhotoIndex = 0;
    }
    notifyListeners();
  }

  Future<void> fetchHobbies() async {
    if (_hobbies.isNotEmpty) return;
    _isLoading = true;
    notifyListeners();
    try {
      _hobbies = await _repository.getHobbies();
    } catch (_) {
      // 실패 시 빈 리스트 유지
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> saveTerms() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _repository.saveTerms(
        serviceTerms: true,
        privacyPolicy: true,
        locationTerms: true,
        marketingConsent: marketingConsent,
      );
      return true;
    } on ApiException catch (e) {
      _error = e.userMessage;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> saveProfile() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _repository.saveProfile(
        nickname: nickname,
        gender: gender,
        birthDate: birthDate,
        hobbyIds: hobbyIds,
        introduction: introduction.isEmpty ? null : introduction,
      );
      return true;
    } on ApiException catch (e) {
      _error = e.userMessage;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> uploadPhotos() async {
    if (photoFilePaths.isEmpty) return true;
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _repository.uploadPhotos(
        filePaths: photoFilePaths,
        representativeIndex: representativePhotoIndex,
      );
      return true;
    } on ApiException catch (e) {
      _error = e.userMessage;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setIdentityResult({
    required String name,
    required String phone,
    required String gender,
    required String birthDate,
  }) {
    _identityVerified = true;
    _verifiedName = name;
    _verifiedPhone = phone;
    _verifiedGender = gender;
    _verifiedBirthDate = birthDate;
    this.gender = gender;
    this.birthDate = birthDate;
    notifyListeners();
  }

  Future<bool> completeSignup() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _repository.complete();
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

  void resetForm() {
    nickname = '';
    gender = '';
    birthDate = '';
    hobbyIds = [];
    introduction = '';
    photoFilePaths = [];
    representativePhotoIndex = 0;
    marketingConsent = false;
    _identityVerified = false;
    _verifiedName = null;
    _verifiedPhone = null;
    _verifiedGender = null;
    _verifiedBirthDate = null;
    notifyListeners();
  }
}
