import 'package:flutter/foundation.dart';
import '../models/career_path.dart';
import '../services/api_service.dart';

class CareerPathProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<CareerPath> _careerPaths = [];
  CareerPath? _selectedCareerPath;
  bool _isLoading = false;
  String? _error;

  List<CareerPath> get careerPaths => _careerPaths;
  CareerPath? get selectedCareerPath => _selectedCareerPath;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchCareerPaths() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      debugPrint('CareerPathProvider: Fetching career paths');
      _careerPaths = await _apiService.getCareerPaths();
      debugPrint('CareerPathProvider: Fetched ${_careerPaths.length} career paths');
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('CareerPathProvider: Error fetching career paths - $e');
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> fetchCareerPathById(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      debugPrint('CareerPathProvider: Fetching career path by id - $id');
      _selectedCareerPath = await _apiService.getCareerPathById(id);
      debugPrint('CareerPathProvider: Fetched career path - ${_selectedCareerPath?.title}');
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('CareerPathProvider: Error fetching career path by id - $e');
      _isLoading = false;
      
      // Check if the error is a 404 (not found)
      if (e.toString().contains('404') || e.toString().contains('not found')) {
        _selectedCareerPath = null;
        _error = 'Career path not found';
      } else {
        _error = e.toString();
      }
      
      notifyListeners();
    }
  }
  
  Future<bool> createCareerPath(Map<String, dynamic> careerPathData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      await _apiService.createCareerPath(careerPathData);
      await fetchCareerPaths(); // Refresh the list
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  Future<bool> updateCareerPath(String id, Map<String, dynamic> careerPathData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      await _apiService.updateCareerPath(id, careerPathData);
      
      // Refresh the list
      await fetchCareerPaths();
      
      // If this was the selected career path, refresh it
      if (_selectedCareerPath != null && _selectedCareerPath!.id == id) {
        await fetchCareerPathById(id);
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  Future<bool> deleteCareerPath(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      await _apiService.deleteCareerPath(id);
      
      // Remove the career path from the local list
      _careerPaths.removeWhere((path) => path.id == id);
      
      // If this was the selected career path, clear it
      if (_selectedCareerPath != null && _selectedCareerPath!.id == id) {
        _selectedCareerPath = null;
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  List<CareerPath> searchCareerPaths(String query) {
    if (query.isEmpty) {
      return _careerPaths;
    }
    
    final queryLower = query.toLowerCase();
    return _careerPaths.where((path) {
      return path.title.toLowerCase().contains(queryLower) ||
          path.description.toLowerCase().contains(queryLower);
    }).toList();
  }

  void clearSelectedCareerPath() {
    _selectedCareerPath = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
} 