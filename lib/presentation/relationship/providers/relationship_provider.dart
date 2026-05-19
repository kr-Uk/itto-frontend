import 'package:flutter/foundation.dart';
import 'package:itto/core/network/api_exception.dart';
import 'package:itto/domain/relationship/entities/encounter_heatmap.dart';
import 'package:itto/domain/relationship/entities/encounter_location.dart';
import 'package:itto/domain/relationship/entities/relationship.dart';
import 'package:itto/domain/relationship/entities/relationship_detail.dart';
import 'package:itto/domain/relationship/repositories/relationship_repository.dart';

class RelationshipProvider extends ChangeNotifier {
  final RelationshipRepository _repository;

  final Map<String, List<Relationship>> _relationships = {};
  final Map<String, int> _totalCounts = {};
  RelationshipDetail? _selectedDetail;
  bool _isLoading = false;
  String? _error;

  RelationshipProvider({required RelationshipRepository repository})
    : _repository = repository;

  List<Relationship> getByStatus(String status) =>
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
      final result = await _repository.getList(status: status, page: page);
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
      _selectedDetail = await _repository.getDetail(relationshipId);
    } on ApiException catch (e) {
      _error = e.userMessage;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> requestInyeon(int relationshipId) async {
    try {
      await _repository.request(relationshipId);
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
      await _repository.cancel(relationshipId);
      return true;
    } on ApiException catch (e) {
      _error = e.userMessage;
      notifyListeners();
      return false;
    }
  }

  Future<bool> acceptRequest(int relationshipId) async {
    try {
      await _repository.accept(relationshipId);
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
      await _repository.reject(relationshipId);
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
      await _repository.deleteRelationship(relationshipId);
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
      await _repository.convert(relationshipId);
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
      await _repository.restore(relationshipId);
      return true;
    } on ApiException catch (e) {
      _error = e.userMessage;
      notifyListeners();
      return false;
    }
  }

  Future<bool> restoreAccept(int relationshipId) async {
    try {
      await _repository.restoreAccept(relationshipId);
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
      await _repository.restoreReject(relationshipId);
      await loadAllTabs();
      return true;
    } on ApiException catch (e) {
      _error = e.userMessage;
      notifyListeners();
      return false;
    }
  }

  Future<EncounterLocation> getEncounterLocation(int relationshipId) {
    return _repository.getEncounterLocation(relationshipId);
  }

  Future<EncounterHeatmap> getEncounterHeatmap({
    required double latitude,
    required double longitude,
  }) {
    return _repository.getEncounterHeatmap(
      latitude: latitude,
      longitude: longitude,
    );
  }

  Relationship? findByOtherUserId(int userId) {
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
