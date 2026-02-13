import 'package:flutter/foundation.dart';
import '../../../core/network/api_exception.dart';
import '../models/block_models.dart';
import '../services/block_service.dart';

class BlockProvider extends ChangeNotifier {
  final BlockService _service;

  List<BlockItem> _blocks = [];
  bool _isLoading = false;
  String? _error;

  BlockProvider({required BlockService service}) : _service = service;

  List<BlockItem> get blocks => _blocks;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadBlocks() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _blocks = await _service.listBlocks();
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
      await _service.blockUser(targetUserId);
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
      await _service.unblock(blockId);
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
      await _service.report(request);
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
