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
  int _streamingWordIndex = 0;
  List<String> _streamingWords = [];

  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;
  bool get showSources => _showSources;
  String? get streamingText => _streamingText;
  int get streamingWordIndex => _streamingWordIndex;
  List<String> get streamingWords => _streamingWords;

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
      _streamingWords = [];
      _streamingWordIndex = 0;
      notifyListeners();

      final response = await _groqService.getAIResponse(
        message,
        showSources: _showSources,
      );

      // Split response into words and spaces, preserving formatting
      final words = RegExp(r'(\S+|\s+)').allMatches(response).map((m) => m.group(0)!).toList();
      _streamingWords = words;
      _streamingText = '';
      notifyListeners();

      for (int i = 0; i < words.length; i++) {
        _streamingWordIndex = i;
        _streamingText = words.sublist(0, i + 1).join('');
        notifyListeners();
        await Future.delayed(const Duration(milliseconds: 80)); // Adjust speed as desired
      }

      _messages.add(Message(
        text: response,
        isUser: false,
        timestamp: DateTime.now(),
      ));
      _streamingText = null;
      _streamingWords = [];
      _streamingWordIndex = 0;
    } catch (e) {
      _messages.add(Message(
        text: 'Sorry, I encountered an error: ${e.toString()}',
        isUser: false,
        timestamp: DateTime.now(),
      ));
      _streamingText = null;
      _streamingWords = [];
      _streamingWordIndex = 0;
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