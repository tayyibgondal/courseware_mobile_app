import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import '../models/user.dart';
import '../models/course.dart';
import '../models/book.dart';
import '../models/career_path.dart';
import '../models/faq.dart';

class ApiService {
  // Base URL of the backend API
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:4000'; // Web
    } else if (!kIsWeb && Platform.isAndroid) {
      return 'http://10.0.2.2:4000'; // Android emulator
    } else if (!kIsWeb && Platform.isIOS) {
      return 'http://localhost:4000'; // iOS simulator
    } else {
      return 'http://localhost:4000'; // Default
    }
  }
  
  // Secure storage for storing the JWT token
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  // HTTP headers with CORS headers for web
  Future<Map<String, String>> _getHeaders() async {
    final token = await _storage.read(key: 'token');
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Helper method to handle HTTP errors
  void _handleHttpError(http.Response response) {
    debugPrint('HTTP Error: ${response.statusCode}');
    debugPrint('Response body: ${response.body}');
    
    String errorMessage;
    try {
      final errorJson = jsonDecode(response.body);
      errorMessage = errorJson['message'] ?? 'Unknown error';
    } catch (e) {
      errorMessage = 'Error ${response.statusCode}: ${response.reasonPhrase}';
    }
    
    throw Exception(errorMessage);
  }

  // Helper method to make GET requests
  Future<dynamic> _get(String endpoint) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      debugPrint('GET request to: $url');
      
      final response = await http.get(
        url,
        headers: await _getHeaders(),
      ).timeout(const Duration(seconds: 15));
      
      debugPrint('Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        _handleHttpError(response);
      }
    } catch (e) {
      debugPrint('Error in GET request: $e');
      if (e is http.ClientException) {
        throw Exception('Connection failed. Please check if the server is running.');
      }
      rethrow;
    }
  }

  // Helper method to make POST requests
  Future<dynamic> _post(String endpoint, Map<String, dynamic> data) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      debugPrint('POST request to: $url');
      debugPrint('POST data: $data');
      
      final response = await http.post(
        url,
        headers: await _getHeaders(),
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 15));
      
      debugPrint('Response status: ${response.statusCode}');
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.isNotEmpty) {
          return jsonDecode(response.body);
        }
        return {'success': true};
      } else {
        _handleHttpError(response);
      }
    } catch (e) {
      debugPrint('Error in POST request: $e');
      if (e is http.ClientException) {
        throw Exception('Connection failed. Please check if the server is running.');
      }
      rethrow;
    }
  }

  // Authentication methods
  Future<User> login(String username, String password) async {
    try {
      final data = await _post('/login', {
        'username': username,
        'password': password,
      });
      
      await _storage.write(key: 'token', value: data['token']);
      return User.fromJson(data);
    } catch (e) {
      debugPrint('Login error: $e');
      rethrow;
    }
  }

  Future<void> register(String username, String password) async {
    try {
      await _post('/register', {
        'username': username,
        'password': password,
      });
    } catch (e) {
      debugPrint('Registration error: $e');
      rethrow;
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'token');
  }

  // Course methods
  Future<List<Course>> getCourses() async {
    try {
      final data = await _get('/courses');
      return (data as List).map((json) => Course.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetching courses: $e');
      rethrow;
    }
  }

  Future<Course> getCourseById(String id) async {
    try {
      final data = await _get('/courses/$id');
      return Course.fromJson(data);
    } catch (e) {
      debugPrint('Error fetching course by id: $e');
      rethrow;
    }
  }

  Future<void> createCourse(Map<String, dynamic> courseData) async {
    try {
      debugPrint('Creating course with data: $courseData');
      await _post('/courses/create', courseData);
    } catch (e) {
      debugPrint('Error creating course: $e');
      rethrow;
    }
  }

  // Book methods
  Future<List<Book>> getBooks() async {
    try {
      final data = await _get('/library');
      return (data as List).map((json) => Book.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetching books: $e');
      rethrow;
    }
  }

  Future<Book> getBookById(String id) async {
    try {
      final data = await _get('/library/$id');
      return Book.fromJson(data);
    } catch (e) {
      debugPrint('Error fetching book by id: $e');
      rethrow;
    }
  }

  Future<void> createBook(Map<String, dynamic> bookData) async {
    try {
      await _post('/library/create', bookData);
    } catch (e) {
      debugPrint('Error creating book: $e');
      rethrow;
    }
  }

  // Career path methods
  Future<List<CareerPath>> getCareerPaths() async {
    try {
      final data = await _get('/careerpaths');
      return (data as List).map((json) => CareerPath.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetching career paths: $e');
      rethrow;
    }
  }

  Future<CareerPath> getCareerPathById(String id) async {
    try {
      final data = await _get('/careerpaths/$id');
      return CareerPath.fromJson(data);
    } catch (e) {
      debugPrint('Error fetching career path by id: $e');
      rethrow;
    }
  }

  Future<void> createCareerPath(Map<String, dynamic> careerPathData) async {
    try {
      await _post('/careerpaths/create', careerPathData);
    } catch (e) {
      debugPrint('Error creating career path: $e');
      rethrow;
    }
  }

  // FAQ methods
  Future<List<FAQ>> getFAQs() async {
    try {
      final data = await _get('/faqs');
      return (data as List).map((json) => FAQ.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetching FAQs: $e');
      rethrow;
    }
  }

  Future<void> createFAQ(Map<String, dynamic> faqData) async {
    try {
      await _post('/faqs/create', faqData);
    } catch (e) {
      debugPrint('Error creating FAQ: $e');
      rethrow;
    }
  }

  // Contact method
  Future<void> submitContactForm(Map<String, dynamic> formData) async {
    try {
      await _post('/contact', formData);
    } catch (e) {
      debugPrint('Error submitting contact form: $e');
      rethrow;
    }
  }
  
  // Helper function for substring to avoid RangeError
  int min(int a, int b) {
    return a < b ? a : b;
  }
} 