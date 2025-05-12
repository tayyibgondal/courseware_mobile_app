import 'dart:html' as html;
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../services/groq_service.dart';
import 'package:read_pdf_text/read_pdf_text.dart';

class Message {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  Message({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

class AITutorProvider with ChangeNotifier {
  final GroqService _groqService = GroqService();
  List<Message> _messages = [];
  bool _isLoading = false;
  bool _showSources = false;
  String? _streamingText;

  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;
  bool get showSources => _showSources;
  String? get streamingText => _streamingText;

  void setShowSources(bool value) {
    _showSources = value;
    notifyListeners();
  }

  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    _messages.add(Message(
      text: message,
      isUser: true,
      timestamp: DateTime.now(),
    ));
    notifyListeners();

    try {
      _isLoading = true;
      _streamingText = '';
      notifyListeners();

      final response = await _groqService.getAIResponse(
        message,
        showSources: _showSources,
      );

      // Simulate streaming by revealing the response character by character
      for (int i = 1; i <= response.length; i++) {
        _streamingText = response.substring(0, i);
        notifyListeners();
        await Future.delayed(const Duration(milliseconds: 5)); // Faster typing speed
      }

      _messages.add(Message(
        text: response,
        isUser: false,
        timestamp: DateTime.now(),
      ));
      _streamingText = null;
    } catch (e) {
      _messages.add(Message(
        text: 'Sorry, I encountered an error: ${e.toString()}',
        isUser: false,
        timestamp: DateTime.now(),
      ));
      _streamingText = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearChat() {
    _messages.clear();
    notifyListeners();
  }
} 