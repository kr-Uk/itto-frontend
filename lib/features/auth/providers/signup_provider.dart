import 'package:flutter/foundation.dart';
import '../../../core/network/api_exception.dart';
import '../models/signup_models.dart';
import '../services/signup_service.dart';

class SignupProvider extends ChangeNotifier {
  final SignupService _signupService;

  bool _isLoading = false;
  String? _error;

  // Form data collected across steps
  String nickname = '';
  String gender = '';
  String birthDate = '';
  List<int> hobbyIds = [];
  String introduction = '';
  List<String> photoFilePaths = [];
  int representativePhotoIndex = 0;
  String? verificationFilePath;
  bool marketingConsent = false;

  SignupProvider({required SignupService signupService})
      : _signupService = signupService;

  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<bool> saveTerms() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _signupService.saveTerms(SignupTermsRequest(
        serviceTerms: true,
        privacyPolicy: true,
        locationTerms: true,
        marketingConsent: marketingConsent,
      ));
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
      await _signupService.saveProfile(SignupProfileRequest(
        nickname: nickname,
        gender: gender,
        birthDate: birthDate,
        hobbyIds: hobbyIds,
        introduction: introduction.isEmpty ? null : introduction,
      ));
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

  Future<bool> uploadVerification() async {
    if (verificationFilePath == null) return false;
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _signupService.uploadVerification(verificationFilePath!);
      return true;
    } on ApiException catch (e) {
      _error = e.userMessage;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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
    verificationFilePath = null;
    marketingConsent = false;
    notifyListeners();
  }
}
