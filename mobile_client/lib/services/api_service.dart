import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform, File;
import 'package:path/path.dart' as path;
import '../models/user.dart';
import '../models/course.dart';
import '../models/book.dart';
import '../models/career_path.dart';
import '../models/faq.dart';
import '../models/post.dart';

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
      
      // For 404 errors, make the message more specific
      if (response.statusCode == 404) {
        if (errorMessage == 'Unknown error') {
          errorMessage = 'Resource not found';
        }
      }
    } catch (e) {
      if (response.statusCode == 404) {
        errorMessage = 'Resource not found';
      } else {
        errorMessage = 'Error ${response.statusCode}: ${response.reasonPhrase}';
      }
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

  Future<void> updateCourse(String courseId, Map<String, dynamic> courseData) async {
    try {
      await _put('/courses/edit/$courseId', courseData);
    } catch (e) {
      debugPrint('Error updating course: $e');
      rethrow;
    }
  }

  Future<void> deleteCourse(String courseId) async {
    try {
      await _delete('/courses/delete/$courseId');
    } catch (e) {
      debugPrint('Error deleting course: $e');
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

  Future<void> updateBook(String bookId, Map<String, dynamic> bookData) async {
    try {
      await _put('/library/edit/$bookId', bookData);
    } catch (e) {
      debugPrint('Error updating book: $e');
      rethrow;
    }
  }

  Future<void> deleteBook(String bookId) async {
    try {
      await _delete('/library/delete/$bookId');
    } catch (e) {
      debugPrint('Error deleting book: $e');
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

  Future<void> updateCareerPath(String careerPathId, Map<String, dynamic> careerPathData) async {
    try {
      await _put('/careerpaths/edit/$careerPathId', careerPathData);
    } catch (e) {
      debugPrint('Error updating career path: $e');
      rethrow;
    }
  }

  Future<void> deleteCareerPath(String careerPathId) async {
    try {
      await _delete('/careerpaths/delete/$careerPathId');
    } catch (e) {
      debugPrint('Error deleting career path: $e');
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

  Future<void> updateFAQ(String faqId, Map<String, dynamic> faqData) async {
    try {
      await _put('/faqs/edit/$faqId', faqData);
    } catch (e) {
      debugPrint('Error updating FAQ: $e');
      rethrow;
    }
  }

  Future<void> deleteFAQ(String faqId) async {
    try {
      await _delete('/faqs/delete/$faqId');
    } catch (e) {
      debugPrint('Error deleting FAQ: $e');
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

  // Helper method to make PUT requests
  Future<dynamic> _put(String endpoint, Map<String, dynamic> data) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      debugPrint('PUT request to: $url');
      debugPrint('PUT data: $data');
      
      final response = await http.put(
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
      debugPrint('Error in PUT request: $e');
      if (e is http.ClientException) {
        throw Exception('Connection failed. Please check if the server is running.');
      }
      rethrow;
    }
  }
  
  // Helper method to make DELETE requests
  Future<dynamic> _delete(String endpoint) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      debugPrint('DELETE request to: $url');
      
      final response = await http.delete(
        url,
        headers: await _getHeaders(),
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
      debugPrint('Error in DELETE request: $e');
      if (e is http.ClientException) {
        throw Exception('Connection failed. Please check if the server is running.');
      }
      rethrow;
    }
  }

  // Helper method to upload files with multipart request
  Future<dynamic> _uploadFile(String endpoint, Map<String, dynamic> data, File? imageFile) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      debugPrint('POST with file upload to: $url');
      
      final request = http.MultipartRequest('POST', url);
      
      // Add headers
      final headers = await _getHeaders();
      headers.forEach((key, value) {
        request.headers[key] = value;
      });
      
      // Add text fields
      data.forEach((key, value) {
        if (value != null) {
          request.fields[key] = value.toString();
        }
      });
      
      // Add file if provided
      if (imageFile != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'file',
          imageFile.path,
          filename: path.basename(imageFile.path),
        ));
      }
      
      // Send the request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
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
      debugPrint('Error in file upload: $e');
      rethrow;
    }
  }
  
  // Helper method to update with file
  Future<dynamic> _updateWithFile(String endpoint, Map<String, dynamic> data, File? imageFile) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      debugPrint('PUT with file upload to: $url');
      
      final request = http.MultipartRequest('PUT', url);
      
      // Add headers
      final headers = await _getHeaders();
      headers.forEach((key, value) {
        request.headers[key] = value;
      });
      
      // Add text fields
      data.forEach((key, value) {
        if (value != null) {
          request.fields[key] = value.toString();
        }
      });
      
      // Add file if provided
      if (imageFile != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'file',
          imageFile.path,
          filename: path.basename(imageFile.path),
        ));
      }
      
      // Send the request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
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
      debugPrint('Error in file update: $e');
      rethrow;
    }
  }

  // Blog Post methods
  Future<List<Post>> getPosts() async {
    try {
      final data = await _get('/posts');
      return (data as List).map((json) => Post.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetching posts: $e');
      rethrow;
    }
  }

  Future<Post> getPostById(String id) async {
    try {
      final data = await _get('/posts/$id');
      return Post.fromJson(data);
    } catch (e) {
      debugPrint('Error fetching post by id: $e');
      rethrow;
    }
  }

  Future<void> createPost(Map<String, dynamic> postData, File? imageFile) async {
    try {
      if (imageFile == null) {
        // If no image, use regular post request
        await _post('/posts/create', postData);
      } else {
        // If image provided, use multipart request
        await _uploadFile('/posts/create', postData, imageFile);
      }
    } catch (e) {
      debugPrint('Error creating post: $e');
      rethrow;
    }
  }

  Future<void> updatePost(String postId, Map<String, dynamic> postData, File? imageFile) async {
    try {
      if (imageFile == null) {
        // If no image, use regular put request
        await _put('/posts/edit/$postId', postData);
      } else {
        // If image provided, use multipart request
        await _updateWithFile('/posts/edit/$postId', postData, imageFile);
      }
    } catch (e) {
      debugPrint('Error updating post: $e');
      rethrow;
    }
  }

  Future<void> deletePost(String postId) async {
    try {
      await _delete('/posts/delete/$postId');
    } catch (e) {
      debugPrint('Error deleting post: $e');
      rethrow;
    }
  }

  Future<List<Post>> searchPosts(String query) async {
    try {
      final data = await _get('/posts/search/$query');
      return (data as List).map((json) => Post.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error searching posts: $e');
      // Return empty list if not found (404)
      if (e.toString().contains('404')) {
        return [];
      }
      rethrow;
    }
  }
} 