import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../../core/network/api_exception.dart';
import '../models/shop_models.dart';
import '../services/shop_service.dart';

class ShopProvider extends ChangeNotifier {
  final ShopService _service;

  KnotBalance? _balance;
  List<KnotPackage> _packages = [];
  SubscriptionInfo? _subscription;
  bool _isLoading = false;
  String? _error;

  ShopProvider({required ShopService service}) : _service = service;

  String get _store => Platform.isIOS ? 'APPLE' : 'GOOGLE';

  KnotBalance? get balance => _balance;
  int get knots => _balance?.knots ?? 0;
  List<KnotPackage> get packages => _packages;
  SubscriptionInfo? get subscription => _subscription;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadBalance() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _balance = await _service.getKnots();
    } on ApiException catch (e) {
      _error = e.userMessage;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadPackages() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _packages = await _service.getPackages();
    } on ApiException catch (e) {
      _error = e.userMessage;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> purchase(int packageId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _service.purchase(
        packageId: packageId,
        receiptToken: 'test_receipt_token',
        store: _store,
      );
      await loadBalance();
      return true;
    } on ApiException catch (e) {
      _error = e.userMessage;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadSubscription() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _subscription = await _service.getSubscription();
    } on ApiException catch (e) {
      _error = e.userMessage;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> subscribe() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _service.subscribe(
        receiptToken: 'test_receipt_token',
        store: _store,
      );
      await loadSubscription();
      return true;
    } on ApiException catch (e) {
      _error = e.userMessage;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> cancelSubscription() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _service.cancelSubscription();
      await loadSubscription();
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
