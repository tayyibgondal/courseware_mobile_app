import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;
  String? get error => _error;

  Future<bool> checkAuthentication() async {
    final token = await _storage.read(key: 'token');
    if (token != null) {
      // TODO: Implement token validation with the backend
      // For now, we'll just return true if a token exists
      return true;
    }
    return false;
  }

  Future<void> login(String username, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentUser = await _apiService.login(username, password);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      // Extract the error message for better user feedback
      if (e.toString().contains('message')) {
        try {
          // Try to extract the message from the error
          final errorMsg = e.toString().split('message":"')[1].split('"}')[0];
          _error = errorMsg;
        } catch (_) {
          _error = e.toString();
        }
      } else {
        _error = e.toString();
      }
      notifyListeners();
      throw _error!;
    }
  }

  Future<void> register(String username, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _apiService.register(username, password);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      throw e; // Re-throw to handle in the UI
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _apiService.logout();
      _currentUser = null;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
} 