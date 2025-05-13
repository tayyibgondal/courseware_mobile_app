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
  
  Future<bool> createBook(Map<String, dynamic> bookData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      await _apiService.createBook(bookData);
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
  
  Future<bool> updateBook(String id, Map<String, dynamic> bookData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      await _apiService.updateBook(id, bookData);
      
      // Update the book in the local list
      final index = _books.indexWhere((book) => book.id == id);
      if (index != -1) {
        // If we have the updated book data, update it in the list
        await fetchBooks(); // Refresh the list for simplicity
      }
      
      // If this was the selected book, refresh it
      if (_selectedBook != null && _selectedBook!.id == id) {
        await fetchBookById(id);
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
  
  Future<bool> deleteBook(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      await _apiService.deleteBook(id);
      
      // Remove the book from the local list
      _books.removeWhere((book) => book.id == id);
      
      // If this was the selected book, clear it
      if (_selectedBook != null && _selectedBook!.id == id) {
        _selectedBook = null;
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