import 'package:flutter/foundation.dart';
import 'package:itto/core/network/api_exception.dart';
import 'package:itto/domain/block/entities/block_item.dart';
import 'package:itto/domain/block/entities/report_request.dart';
import 'package:itto/domain/block/repositories/block_repository.dart';

class BlockProvider extends ChangeNotifier {
  final BlockRepository _repository;

  List<BlockItem> _blocks = [];
  bool _isLoading = false;
  String? _error;

  BlockProvider({required BlockRepository repository})
      : _repository = repository;

  List<BlockItem> get blocks => _blocks;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadBlocks() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _blocks = await _repository.listBlocks();
    } on ApiException catch (e) {
      _error = e.userMessage;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> blockUser(int targetUserId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _repository.blockUser(targetUserId);
      await loadBlocks();
      return true;
    } on ApiException catch (e) {
      _error = e.userMessage;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> unblock(int blockId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _repository.unblock(blockId);
      _blocks = _blocks.where((b) => b.id != blockId).toList();
      return true;
    } on ApiException catch (e) {
      _error = e.userMessage;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> report(ReportRequest request) async {
    try {
      await _repository.report(request);
      return true;
    } on ApiException catch (e) {
      _error = e.userMessage;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
