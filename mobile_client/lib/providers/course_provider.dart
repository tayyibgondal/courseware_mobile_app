import 'package:flutter/foundation.dart';
import '../models/course.dart';
import '../services/api_service.dart';

class CourseProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<Course> _courses = [];
  Course? _selectedCourse;
  bool _isLoading = false;
  String? _error;

  List<Course> get courses => _courses;
  Course? get selectedCourse => _selectedCourse;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchCourses() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _courses = await _apiService.getCourses();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> fetchCourseById(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedCourse = await _apiService.getCourseById(id);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<bool> createCourse(Map<String, dynamic> courseData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _apiService.createCourse(courseData);
      // Refresh the courses list after adding a new course
      await fetchCourses();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  Future<bool> updateCourse(String id, Map<String, dynamic> courseData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      await _apiService.updateCourse(id, courseData);
      
      // Refresh the courses list
      await fetchCourses();
      
      // If this was the selected course, refresh it
      if (_selectedCourse != null && _selectedCourse!.id == id) {
        await fetchCourseById(id);
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
  
  Future<bool> deleteCourse(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      await _apiService.deleteCourse(id);
      
      // Remove the course from the local list
      _courses.removeWhere((course) => course.id == id);
      
      // If this was the selected course, clear it
      if (_selectedCourse != null && _selectedCourse!.id == id) {
        _selectedCourse = null;
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

  List<Course> searchCourses(String query) {
    if (query.isEmpty) {
      return _courses;
    }
    
    final queryLower = query.toLowerCase();
    return _courses.where((course) {
      return course.name.toLowerCase().contains(queryLower) ||
          course.instructor.toLowerCase().contains(queryLower) ||
          course.description.toLowerCase().contains(queryLower) ||
          course.university.toLowerCase().contains(queryLower);
    }).toList();
  }

  void clearSelectedCourse() {
    _selectedCourse = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
} 