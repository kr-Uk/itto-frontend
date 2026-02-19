import 'package:flutter/foundation.dart';
import '../../../core/network/api_exception.dart';
import '../models/relationship_models.dart';
import '../services/relationship_service.dart';

class RelationshipProvider extends ChangeNotifier {
  final RelationshipService _service;

  final Map<String, List<RelationshipItem>> _relationships = {};
  final Map<String, int> _totalCounts = {};
  RelationshipDetail? _selectedDetail;
  bool _isLoading = false;
  String? _error;

  RelationshipProvider({required RelationshipService service})
      : _service = service;

  List<RelationshipItem> getByStatus(String status) =>
      _relationships[status] ?? [];
  int getCount(String status) => _totalCounts[status] ?? 0;
  RelationshipDetail? get selectedDetail => _selectedDetail;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadRelationships(String status, {int page = 0}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final result = await _service.getList(status: status, page: page);
      if (page == 0) {
        _relationships[status] = result.content;
      } else {
        _relationships[status] = [
          ...(_relationships[status] ?? []),
          ...result.content,
        ];
      }
      _totalCounts[status] = result.totalElements;
    } on ApiException catch (e) {
      _error = e.userMessage;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAllTabs() async {
    await Future.wait([
      loadRelationships('INYEON'),
      loadRelationships('PILYEON'),
      loadRelationships('PENDING'),
      loadRelationships('UYEON'),
      loadRelationships('PAST'),
    ]);
  }

  Future<void> loadDetail(int relationshipId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _selectedDetail = await _service.getDetail(relationshipId);
    } on ApiException catch (e) {
      _error = e.userMessage;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> requestInyeon(int relationshipId) async {
    try {
      await _service.request(relationshipId);
      await loadRelationships('PILYEON');
      return true;
    } on ApiException catch (e) {
      _error = e.userMessage;
      notifyListeners();
      return false;
    }
  }

  Future<bool> cancelRequest(int relationshipId) async {
    try {
      await _service.cancel(relationshipId);
      return true;
    } on ApiException catch (e) {
      _error = e.userMessage;
      notifyListeners();
      return false;
    }
  }

  Future<bool> acceptRequest(int relationshipId) async {
    try {
      await _service.accept(relationshipId);
      await loadAllTabs();
      return true;
    } on ApiException catch (e) {
      _error = e.userMessage;
      notifyListeners();
      return false;
    }
  }

  Future<bool> rejectRequest(int relationshipId) async {
    try {
      await _service.reject(relationshipId);
      await loadAllTabs();
      return true;
    } on ApiException catch (e) {
      _error = e.userMessage;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteRelationship(int relationshipId) async {
    try {
      await _service.deleteRelationship(relationshipId);
      await loadAllTabs();
      return true;
    } on ApiException catch (e) {
      _error = e.userMessage;
      notifyListeners();
      return false;
    }
  }

  Future<bool> convertTopilyeon(int relationshipId) async {
    try {
      await _service.convert(relationshipId);
      await loadAllTabs();
      return true;
    } on ApiException catch (e) {
      _error = e.userMessage;
      notifyListeners();
      return false;
    }
  }

  Future<bool> restoreRelationship(int relationshipId) async {
    try {
      await _service.restore(relationshipId);
      return true;
    } on ApiException catch (e) {
      _error = e.userMessage;
      notifyListeners();
      return false;
    }
  }

  Future<bool> restoreAccept(int relationshipId) async {
    try {
      await _service.restoreAccept(relationshipId);
      await loadAllTabs();
      return true;
    } on ApiException catch (e) {
      _error = e.userMessage;
      notifyListeners();
      return false;
    }
  }

  Future<bool> restoreReject(int relationshipId) async {
    try {
      await _service.restoreReject(relationshipId);
      await loadAllTabs();
      return true;
    } on ApiException catch (e) {
      _error = e.userMessage;
      notifyListeners();
      return false;
    }
  }

  RelationshipItem? findByOtherUserId(int userId) {
    for (final items in _relationships.values) {
      for (final item in items) {
        if (item.otherUser.userId == userId) return item;
      }
    }
    return null;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
