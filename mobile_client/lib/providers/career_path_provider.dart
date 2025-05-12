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
      _error = e.toString();
      notifyListeners();
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