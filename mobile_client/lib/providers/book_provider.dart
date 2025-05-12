import 'package:flutter/foundation.dart';
import '../models/book.dart';
import '../services/api_service.dart';

class BookProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<Book> _books = [];
  Book? _selectedBook;
  bool _isLoading = false;
  String? _error;

  List<Book> get books => _books;
  Book? get selectedBook => _selectedBook;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchBooks() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      debugPrint('BookProvider: Fetching books');
      _books = await _apiService.getBooks();
      debugPrint('BookProvider: Fetched ${_books.length} books');
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('BookProvider: Error fetching books - $e');
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> fetchBookById(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      debugPrint('BookProvider: Fetching book by id - $id');
      _selectedBook = await _apiService.getBookById(id);
      debugPrint('BookProvider: Fetched book - ${_selectedBook?.title}');
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('BookProvider: Error fetching book by id - $e');
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  List<Book> searchBooks(String query) {
    if (query.isEmpty) {
      return _books;
    }
    
    final queryLower = query.toLowerCase();
    return _books.where((book) {
      return book.title.toLowerCase().contains(queryLower) ||
          book.author.toLowerCase().contains(queryLower) ||
          book.description.toLowerCase().contains(queryLower);
    }).toList();
  }

  void clearSelectedBook() {
    _selectedBook = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
} 