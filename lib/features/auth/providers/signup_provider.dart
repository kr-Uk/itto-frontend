import 'package:flutter/foundation.dart';
import '../../../core/network/api_exception.dart';
import '../../profile/models/profile_models.dart';
import '../models/signup_models.dart';
import '../services/signup_service.dart';

class SignupProvider extends ChangeNotifier {
  final SignupService _signupService;

  bool _isLoading = false;
  String? _error;

  // Hobby list from API
  List<HobbyItem> _hobbies = [];
  List<HobbyItem> get hobbies => _hobbies;

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

  SignupProvider({required SignupService signupService})
    : _signupService = signupService;

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
      _hobbies = await _signupService.getHobbies();
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
      await _signupService.saveTerms(
        SignupTermsRequest(
          serviceTerms: true,
          privacyPolicy: true,
          locationTerms: true,
          marketingConsent: marketingConsent,
        ),
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
      await _signupService.saveProfile(
        SignupProfileRequest(
          nickname: nickname,
          gender: gender,
          birthDate: birthDate,
          hobbyIds: hobbyIds,
          introduction: introduction.isEmpty ? null : introduction,
        ),
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
      await _signupService.uploadPhotos(
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
      await _signupService.complete();
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
