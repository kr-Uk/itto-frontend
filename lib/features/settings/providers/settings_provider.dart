import 'package:flutter/foundation.dart';
import '../../../core/network/api_exception.dart';
import '../models/settings_models.dart';
import '../services/settings_service.dart';

class SettingsProvider extends ChangeNotifier {
  final SettingsService _service;

  MatchingSettings? _matchingSettings;
  NotificationSettings? _notificationSettings;
  bool _isLoading = false;
  String? _error;

  SettingsProvider({required SettingsService service}) : _service = service;

  MatchingSettings? get matchingSettings => _matchingSettings;
  NotificationSettings? get notificationSettings => _notificationSettings;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadMatchingSettings() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _matchingSettings = await _service.getMatchingSettings();
    } on ApiException catch (e) {
      _error = e.userMessage;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateMatchingSettings(MatchingSettings settings) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _service.updateMatchingSettings(settings);
      _matchingSettings = settings;
      return true;
    } on ApiException catch (e) {
      _error = e.userMessage;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadNotificationSettings() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _notificationSettings = await _service.getNotificationSettings();
    } on ApiException catch (e) {
      _error = e.userMessage;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateNotificationSettings(NotificationSettings settings) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _service.updateNotificationSettings(settings);
      _notificationSettings = settings;
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
}
