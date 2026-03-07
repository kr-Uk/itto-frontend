import 'package:flutter/foundation.dart';
import 'package:itto/domain/contact_hash/entities/contact_hash.dart';
import 'package:itto/domain/contact_hash/repositories/contact_hash_repository.dart';
import 'package:itto/domain/contact_hash/usecases/sync_contact_hashes_usecase.dart';

class ContactHashProvider extends ChangeNotifier {
  final ContactHashRepository repository;
  final SyncContactHashesUseCase syncContactHashesUseCase;

  ContactHashProvider({
    required this.repository,
    required this.syncContactHashesUseCase,
  });

  List<ContactHash> _hashes = [];
  List<ContactHash> get hashes => _hashes;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  bool _contactPermissionDenied = false;
  bool get contactPermissionDenied => _contactPermissionDenied;

  bool _isSynced = false;
  bool get isSynced => _isSynced;

  Future<void> syncContacts(
    List<String> phoneNumbers, {
    bool hasPermission = true,
  }) async {
    if (!hasPermission) {
      _contactPermissionDenied = true;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await syncContactHashesUseCase.execute(phoneNumbers);
      _isSynced = true;
      await loadHashes();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadHashes() async {
    try {
      _hashes = await repository.getHashes();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> addManualBlock(String phoneNumber) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await repository.addManualBlock(phoneNumber);
      await loadHashes();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> removeHash(int hashId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await repository.removeHash(hashId);
      _hashes = _hashes.where((h) => h.id != hashId).toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
