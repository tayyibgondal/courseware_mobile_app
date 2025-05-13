import 'dart:io';
import 'package:flutter/material.dart';
import '../models/post.dart';
import '../services/api_service.dart';

class PostProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<Post> _posts = [];
  Post? _selectedPost;
  bool _isLoading = false;
  String? _error;
  
  // Getters
  List<Post> get posts => _posts;
  Post? get selectedPost => _selectedPost;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Fetch all posts
  Future<void> fetchPosts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _posts = await _apiService.getPosts();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Fetch a post by ID
  Future<void> fetchPostById(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _selectedPost = await _apiService.getPostById(id);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Create a new post
  Future<bool> createPost({
    required String title,
    required String summary,
    required String content,
    required String userId,
    File? imageFile,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final postData = {
        'title': title,
        'summary': summary,
        'content': content,
        'userId': userId,
      };
      
      await _apiService.createPost(postData, imageFile);
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
  
  // Update a post
  Future<bool> updatePost({
    required String id,
    required String title,
    required String summary,
    required String content,
    required String userId,
    File? imageFile,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final postData = {
        'title': title,
        'summary': summary,
        'content': content,
        'userId': userId,
      };
      
      await _apiService.updatePost(id, postData, imageFile);
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
  
  // Delete a post
  Future<bool> deletePost(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      await _apiService.deletePost(id);
      _posts = _posts.where((post) => post.id != id).toList();
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
  
  // Search posts
  Future<List<Post>> searchPosts(String query) async {
    if (query.trim().isEmpty) {
      return _posts;
    }
    
    try {
      return await _apiService.searchPosts(query);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }
  
  // Clear selected post
  void clearSelectedPost() {
    _selectedPost = null;
    notifyListeners();
  }
  
  // Clear errors
  void clearErrors() {
    _error = null;
    notifyListeners();
  }
} 