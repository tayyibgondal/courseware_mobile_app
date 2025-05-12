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
      if (username.isEmpty || password.isEmpty) {
        throw Exception('Username and password are required');
      }

      _currentUser = await _apiService.login(username, password);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      if (e.toString().contains('Connection failed')) {
        _error = 'Connection failed. Please check if the server is running.';
      } else if (e.toString().contains('Invalid username or password')) {
        _error = 'Invalid username or password';
      } else if (e.toString().contains('Username and password are required')) {
        _error = 'Username and password are required';
      } else {
        _error = 'An error occurred during login. Please try again.';
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
      if (username.isEmpty || password.isEmpty) {
        throw Exception('Username and password are required');
      }

      if (password.length < 6) {
        throw Exception('Password must be at least 6 characters long');
      }

      await _apiService.register(username, password);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      if (e.toString().contains('Connection failed')) {
        _error = 'Connection failed. Please check if the server is running.';
      } else if (e.toString().contains('Could not register')) {
        _error = 'Registration failed. Username might already be taken.';
      } else {
        _error = e.toString();
      }
      notifyListeners();
      throw _error!;
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