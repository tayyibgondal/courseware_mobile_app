import 'package:flutter/foundation.dart';
import '../models/faq.dart';
import '../services/api_service.dart';

class FAQProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<FAQ> _faqs = [];
  bool _isLoading = false;
  String? _error;

  List<FAQ> get faqs => _faqs;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchFAQs() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      debugPrint('FAQProvider: Fetching FAQs');
      _faqs = await _apiService.getFAQs();
      debugPrint('FAQProvider: Fetched ${_faqs.length} FAQs');
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('FAQProvider: Error fetching FAQs - $e');
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }
  
  Future<bool> createFAQ(Map<String, dynamic> faqData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      await _apiService.createFAQ(faqData);
      await fetchFAQs(); // Refresh the list
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
  
  Future<bool> updateFAQ(String id, Map<String, dynamic> faqData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      await _apiService.updateFAQ(id, faqData);
      await fetchFAQs(); // Refresh the list
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
  
  Future<bool> deleteFAQ(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      await _apiService.deleteFAQ(id);
      _faqs.removeWhere((faq) => faq.id == id);
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

  List<FAQ> searchFAQs(String query) {
    if (query.isEmpty) {
      return _faqs;
    }
    
    final queryLower = query.toLowerCase();
    return _faqs.where((faq) {
      return faq.question.toLowerCase().contains(queryLower) ||
          faq.answer.toLowerCase().contains(queryLower);
    }).toList();
  }

  List<String> getCategories() {
    return ['General']; // Only one category in the simplified model
  }

  List<FAQ> getFAQsByCategory(String category) {
    return _faqs; // All FAQs are in the 'General' category
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
} 